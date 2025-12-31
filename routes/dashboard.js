const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const { isAuthenticated } = require('../middleware/auth');
const { checkRole, ROLES, ADMIN_ROLES, ALL_ROLES } = require('../middleware/role');

// Dashboard route - redirect based on role
router.get('/', isAuthenticated, async (req, res) => {
  try {
    const user = req.session.user;
    
    // Get dashboard data based on role
    if (user.role === ROLES.SUPER_ADMIN || user.role === ROLES.BENDAHARA) {
      // Admin/Bendahara Dashboard
      const [kasAccounts] = await pool.execute('SELECT * FROM kas_accounts');
      const [totalKas] = await pool.execute('SELECT SUM(saldo) as total FROM kas_accounts');
      
      const [pendingIuran] = await pool.execute(`
        SELECT COUNT(*) as count, SUM(jumlah) as total 
        FROM iuran_payments 
        WHERE status = 'pending'
      `);
      
      const [expensesThisMonth] = await pool.execute(`
        SELECT SUM(jumlah) as total 
        FROM expenses 
        WHERE MONTH(created_at) = MONTH(CURRENT_DATE()) 
        AND YEAR(created_at) = YEAR(CURRENT_DATE())
        AND status = 'disetujui'
      `);
      
      const [recentTransactions] = await pool.execute(`
        SELECT kt.*, ka.nama_akun 
        FROM kas_transactions kt
        JOIN kas_accounts ka ON kt.kas_account_id = ka.id
        ORDER BY kt.created_at DESC
        LIMIT 10
      `);
      
      const [chartData] = await pool.execute(`
        SELECT 
          DATE_FORMAT(created_at, '%Y-%m') as bulan,
          SUM(CASE WHEN tipe = 'masuk' THEN jumlah ELSE 0 END) as masuk,
          SUM(CASE WHEN tipe = 'keluar' THEN jumlah ELSE 0 END) as keluar
        FROM kas_transactions
        WHERE created_at >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
        GROUP BY DATE_FORMAT(created_at, '%Y-%m')
        ORDER BY bulan ASC
      `);

      res.render('dashboard/bendahara', {
        title: 'Dashboard Bendahara',
        user,
        stats: {
          totalKas: totalKas[0].total || 0,
          pendingIuranCount: pendingIuran[0].count || 0,
          pendingIuranTotal: pendingIuran[0].total || 0,
          expensesThisMonth: expensesThisMonth[0].total || 0
        },
        kasAccounts,
        recentTransactions,
        chartData
      });
    } else {
      // Anggota/Pengurus Dashboard
      const [iuranStatus] = await pool.execute(`
        SELECT ip.*, it.nama_iuran, it.nominal 
        FROM iuran_payments ip
        JOIN iuran_types it ON ip.iuran_type_id = it.id
        WHERE ip.user_id = ?
        ORDER BY ip.created_at DESC
        LIMIT 10
      `, [user.id]);
      
      const [totalIuran] = await pool.execute(`
        SELECT 
          SUM(CASE WHEN status = 'lunas' THEN jumlah ELSE 0 END) as lunas,
          SUM(CASE WHEN status = 'pending' THEN jumlah ELSE 0 END) as pending
        FROM iuran_payments
        WHERE user_id = ?
      `, [user.id]);
      
      const [activities] = await pool.execute(`
        SELECT * FROM activities 
        WHERE status = 'berjalan' 
        ORDER BY created_at DESC 
        LIMIT 5
      `);

      res.render('dashboard/anggota', {
        title: 'Dashboard Anggota',
        user,
        iuranStatus,
        totalIuran: totalIuran[0] || { lunas: 0, pending: 0 },
        activities
      });
    }
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).render('error', {
      message: 'Terjadi kesalahan saat memuat dashboard',
      error: { status: 500, stack: error.stack }
    });
  }
});

module.exports = router;
