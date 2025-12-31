const express = require('express');
const router = express.Router();
const { isAuthenticated, injectUser } = require('../middleware/auth');
const { checkRole, ROLES } = require('../middleware/role');
const { createAuditLog, formatRupiah, formatDate } = require('../lib/helpers');
const pool = require('../config/db');

router.use(isAuthenticated, injectUser);

// GET /reports - Main reports page
router.get('/', checkRole(ROLES.SUPER_ADMIN, ROLES.BENDAHARA), async (req, res) => {
  try {
    const conn = await pool.getConnection();

    // Get summary data
    const [masukData] = await conn.query(
      'SELECT SUM(jumlah) as total FROM kas_transactions WHERE tipe = "masuk"'
    );
    const totalMasuk = masukData[0]?.total || 0;

    const [keluarData] = await conn.query(
      'SELECT SUM(jumlah) as total, COUNT(*) as jumlah FROM kas_transactions WHERE tipe = "keluar"'
    );
    const totalKeluar = keluarData[0]?.total || 0;
    const jumlahPengeluaran = keluarData[0]?.jumlah || 0;

    const [kasData] = await conn.query(
      'SELECT SUM(saldo) as total FROM kas_accounts'
    );
    const saldoKas = kasData[0]?.total || 0;

    // Get 6-month cash flow data
    const [monthlyData] = await conn.query(
      `SELECT 
        DATE_FORMAT(created_at, '%Y-%m') as bulan,
        SUM(CASE WHEN tipe = 'masuk' THEN jumlah ELSE 0 END) as masuk,
        SUM(CASE WHEN tipe = 'keluar' THEN jumlah ELSE 0 END) as keluar
      FROM kas_transactions
      WHERE created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
      GROUP BY bulan
      ORDER BY bulan DESC
      LIMIT 6`
    );

    // Get expense by category
    const [categoryData] = await conn.query(
      `SELECT 
        ec.nama_kategori,
        SUM(e.jumlah) as total
      FROM expenses e
      JOIN expense_categories ec ON e.category_id = ec.id
      WHERE e.status = 'disetujui'
      GROUP BY e.category_id, ec.nama_kategori
      ORDER BY total DESC`
    );

    // Get top expenses by activity
    const [topExpenses] = await conn.query(
      `SELECT 
        a.nama_kegiatan,
        SUM(e.jumlah) as total
      FROM expenses e
      JOIN activities a ON e.activity_id = a.id
      WHERE e.status = 'disetujui'
      GROUP BY e.activity_id, a.nama_kegiatan
      ORDER BY total DESC
      LIMIT 5`
    );

    // Get recent transactions
    const [recentTransactions] = await conn.query(
      `SELECT * FROM kas_transactions
      ORDER BY created_at DESC
      LIMIT 10`
    );

    conn.release();

    // Format chart data
    const labels = monthlyData.map(d => {
      const [year, month] = d.bulan.split('-');
      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return `${monthNames[parseInt(month) - 1]} ${year}`;
    }).reverse();

    const masukValues = monthlyData.map(d => d.masuk).reverse();
    const keluarValues = monthlyData.map(d => d.keluar).reverse();

    const chartData = {
      labels: labels,
      masuk: masukValues,
      keluar: keluarValues,
      categories: categoryData.map(d => d.nama_kategori),
      categoryValues: categoryData.map(d => d.total)
    };

    res.render('reports/index', {
      title: 'Laporan Keuangan',
      user: req.session.user,
      summary: {
        totalMasuk,
        totalKeluar,
        saldoKas,
        jumlahPengeluaran
      },
      chartData,
      topExpenses,
      recentTransactions
    });
  } catch (error) {
    console.error('Report error:', error);
    res.status(500).render('error', {
      title: 'Error',
      user: req.session.user,
      message: 'Terjadi kesalahan saat memuat laporan'
    });
  }
});

module.exports = router;
