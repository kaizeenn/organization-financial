const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const upload = require('../config/upload');
const { isAuthenticated } = require('../middleware/auth');
const { checkRole, ADMIN_ROLES, ALL_ROLES } = require('../middleware/role');
const { createAuditLog } = require('../lib/helpers');

// GET All Iuran (Bendahara view)
router.get('/', isAuthenticated, checkRole(...ADMIN_ROLES), async (req, res) => {
  try {
    const status = req.query.status || 'all';
    
    let query = `
      SELECT ip.*, u.nama as anggota_nama, it.nama_iuran,
             v.nama as verified_by_nama
      FROM iuran_payments ip
      JOIN users u ON ip.user_id = u.id
      JOIN iuran_types it ON ip.iuran_type_id = it.id
      LEFT JOIN users v ON ip.verified_by = v.id
    `;
    
    const params = [];
    
    if (status !== 'all') {
      query += ' WHERE ip.status = ?';
      params.push(status);
    }
    
    query += ' ORDER BY ip.created_at DESC';

    const [payments] = await pool.execute(query, params);
    
    const [iuranTypes] = await pool.execute('SELECT * FROM iuran_types ORDER BY nama_iuran');
    const [users] = await pool.execute('SELECT id, nama FROM users WHERE status = "aktif" ORDER BY nama');

    res.render('iuran/index', {
      title: 'Manajemen Iuran',
      user: req.session.user,
      payments,
      iuranTypes,
      users,
      currentStatus: status
    });
  } catch (error) {
    console.error('Iuran index error:', error);
    res.status(500).render('error', {
      message: 'Gagal memuat data iuran',
      error: { status: 500, stack: error.stack }
    });
  }
});

// GET My Iuran (Anggota view)
router.get('/my', isAuthenticated, async (req, res) => {
  try {
    const [payments] = await pool.execute(`
      SELECT ip.*, it.nama_iuran, it.nominal,
             v.nama as verified_by_nama
      FROM iuran_payments ip
      JOIN iuran_types it ON ip.iuran_type_id = it.id
      LEFT JOIN users v ON ip.verified_by = v.id
      WHERE ip.user_id = ?
      ORDER BY ip.created_at DESC
    `, [req.session.user.id]);
    
    const [iuranTypes] = await pool.execute('SELECT * FROM iuran_types WHERE sifat = "wajib" ORDER BY nama_iuran');

    res.render('iuran/my-iuran', {
      title: 'Iuran Saya',
      user: req.session.user,
      iuranStatus: payments,
      iuranTypes
    });
  } catch (error) {
    console.error('My iuran error:', error);
    res.status(500).render('error', {
      title: 'Error',
      user: req.session.user,
      message: 'Gagal memuat data iuran'
    });
  }
});

// POST Upload Bukti Pembayaran
router.post('/upload', isAuthenticated, upload.single('bukti_pembayaran'), async (req, res) => {
  try {
    const { iuran_type_id, periode, jumlah, metode } = req.body;
    const bukti_pembayaran = req.file ? `/uploads/${req.file.filename}` : null;

    await pool.execute(
      'INSERT INTO iuran_payments (user_id, iuran_type_id, periode, jumlah, metode, bukti_pembayaran, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [req.session.user.id, iuran_type_id, periode, jumlah, metode, bukti_pembayaran, 'pending']
    );

    res.redirect('/iuran/my?success=upload');
  } catch (error) {
    console.error('Upload iuran error:', error);
    res.redirect('/iuran/my?error=1');
  }
});

// POST Verify Payment (Bendahara only)
router.post('/:id/verify', isAuthenticated, checkRole(...ADMIN_ROLES), async (req, res) => {
  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();

    const { status, kas_account_id } = req.body;
    const paymentId = req.params.id;

    // Get payment details
    const [payment] = await connection.execute(
      'SELECT * FROM iuran_payments WHERE id = ?',
      [paymentId]
    );

    if (payment.length === 0) {
      throw new Error('Payment not found');
    }

    // Update payment status
    await connection.execute(
      'UPDATE iuran_payments SET status = ?, verified_by = ?, verified_at = NOW() WHERE id = ?',
      [status, req.session.userId, paymentId]
    );

    // If approved, create kas transaction
    if (status === 'lunas' && kas_account_id) {
      const [kasAccount] = await connection.execute(
        'SELECT saldo FROM kas_accounts WHERE id = ?',
        [kas_account_id]
      );

      const newSaldo = parseFloat(kasAccount[0].saldo) + parseFloat(payment[0].jumlah);

      // Update kas saldo
      await connection.execute(
        'UPDATE kas_accounts SET saldo = ? WHERE id = ?',
        [newSaldo, kas_account_id]
      );

      // Create kas transaction
      await connection.execute(
        'INSERT INTO kas_transactions (kas_account_id, tipe, sumber, referensi_id, jumlah, saldo_setelah) VALUES (?, ?, ?, ?, ?, ?)',
        [kas_account_id, 'masuk', 'iuran', paymentId, payment[0].jumlah, newSaldo]
      );
    }

    // Audit log
    await createAuditLog(connection, req.session.userId, `VERIFY_IURAN_${status.toUpperCase()}`, 'iuran_payments', paymentId);

    await connection.commit();
    res.redirect('/iuran?success=verify');
  } catch (error) {
    await connection.rollback();
    console.error('Verify payment error:', error);
    res.redirect('/iuran?error=1');
  } finally {
    connection.release();
  }
});

module.exports = router;
