const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const { isAuthenticated } = require('../middleware/auth');
const { checkRole, ADMIN_ROLES } = require('../middleware/role');
const { createAuditLog } = require('../lib/helpers');

// GET All Kas Accounts
router.get('/', isAuthenticated, checkRole(...ADMIN_ROLES), async (req, res) => {
  try {
    const [kasAccounts] = await pool.execute(`
      SELECT ka.*, u.nama as penanggung_jawab_nama
      FROM kas_accounts ka
      LEFT JOIN users u ON ka.penanggung_jawab = u.id
      ORDER BY ka.created_at DESC
    `);

    const [totalSaldo] = await pool.execute('SELECT SUM(saldo) as total FROM kas_accounts');

    res.render('kas/index', {
      title: 'Manajemen Kas',
      user: req.session.user,
      kasAccounts,
      totalSaldo: totalSaldo[0].total || 0,
      success: req.query.success
    });
  } catch (error) {
    console.error('Kas index error:', error);
    res.status(500).render('error', {
      message: 'Gagal memuat data kas',
      error: { status: 500, stack: error.stack }
    });
  }
});

// POST Create Kas Account
router.post('/', isAuthenticated, checkRole(...ADMIN_ROLES), async (req, res) => {
  try {
    const { nama_akun, tipe, saldo_awal, penanggung_jawab } = req.body;

    const [result] = await pool.execute(
      'INSERT INTO kas_accounts (nama_akun, tipe, saldo, penanggung_jawab) VALUES (?, ?, ?, ?)',
      [nama_akun, tipe, saldo_awal || 0, penanggung_jawab || null]
    );

    // Create initial transaction if saldo > 0
    if (parseFloat(saldo_awal) > 0) {
      await pool.execute(
        'INSERT INTO kas_transactions (kas_account_id, tipe, sumber, jumlah, saldo_setelah) VALUES (?, ?, ?, ?, ?)',
        [result.insertId, 'masuk', 'koreksi', saldo_awal, saldo_awal]
      );
    }

    // Audit log
    await createAuditLog(pool, req.session.userId, 'CREATE_KAS', 'kas_accounts', result.insertId);

    res.redirect('/kas?success=1');
  } catch (error) {
    console.error('Create kas error:', error);
    res.redirect('/kas?error=1');
  }
});

// GET Kas Transactions
router.get('/:id/transactions', isAuthenticated, async (req, res) => {
  try {
    const [kasAccount] = await pool.execute('SELECT * FROM kas_accounts WHERE id = ?', [req.params.id]);
    
    if (kasAccount.length === 0) {
      return res.status(404).send('Kas account not found');
    }

    const [transactions] = await pool.execute(`
      SELECT * FROM kas_transactions 
      WHERE kas_account_id = ? 
      ORDER BY created_at DESC
      LIMIT 50
    `, [req.params.id]);

    res.render('kas/transactions', {
      title: `Transaksi ${kasAccount[0].nama_akun}`,
      user: req.session.user,
      kasAccount: kasAccount[0],
      transactions
    });
  } catch (error) {
    console.error('Kas transactions error:', error);
    res.status(500).render('error', {
      message: 'Gagal memuat transaksi kas',
      error: { status: 500, stack: error.stack }
    });
  }
});

module.exports = router;
