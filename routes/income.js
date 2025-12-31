const express = require('express');
const router = express.Router();
const { isAuthenticated, injectUser } = require('../middleware/auth');
const { checkRole, ROLES } = require('../middleware/role');
const { createAuditLog, formatRupiah, formatDate } = require('../lib/helpers');
const pool = require('../config/db');

router.use(isAuthenticated, injectUser);

// GET /income - List all income
router.get('/', checkRole(ROLES.SUPER_ADMIN, ROLES.BENDAHARA), async (req, res) => {
  try {
    const conn = await pool.getConnection();

    const [income] = await conn.query(
      `SELECT 
        i.*,
        k.nama_akun as kas_nama,
        u.nama as dibuat_oleh
      FROM income_sources i
      LEFT JOIN kas_accounts k ON i.kas_account_id = k.id
      LEFT JOIN users u ON i.created_by = u.id
      ORDER BY i.created_at DESC`
    );

    conn.release();

    res.render('income/index', {
      title: 'Pemasukan Lainnya',
      user: req.session.user,
      income
    });
  } catch (error) {
    console.error('Income list error:', error);
    res.status(500).render('error', {
      title: 'Error',
      user: req.session.user,
      message: 'Terjadi kesalahan saat memuat data pemasukan'
    });
  }
});

// POST /income - Create new income
router.post('/', checkRole(ROLES.SUPER_ADMIN, ROLES.BENDAHARA), async (req, res) => {
  try {
    const { nama_sumber, deskripsi, jumlah, kas_account_id } = req.body;

    if (!nama_sumber || !jumlah || !kas_account_id) {
      return res.status(400).json({
        success: false,
        message: 'Data tidak lengkap'
      });
    }

    const conn = await pool.getConnection();

    // Start transaction
    await conn.beginTransaction();

    try {
      // Create income record
      await conn.execute(
        `INSERT INTO income_sources (nama_sumber, deskripsi, jumlah, kas_account_id, created_by)
        VALUES (?, ?, ?, ?, ?)`,
        [nama_sumber, deskripsi || null, jumlah, kas_account_id, req.session.user.id]
      );

      // Update kas balance
      await conn.execute(
        `UPDATE kas_accounts SET saldo = saldo + ? WHERE id = ?`,
        [jumlah, kas_account_id]
      );

      // Create kas transaction
      const [kasData] = await conn.query(
        `SELECT saldo FROM kas_accounts WHERE id = ?`,
        [kas_account_id]
      );

      const saldoSetelah = kasData[0]?.saldo || 0;

      await conn.execute(
        `INSERT INTO kas_transactions (kas_account_id, tipe, sumber, jumlah, saldo_setelah, keterangan)
        VALUES (?, 'masuk', ?, ?, ?, ?)`,
        [kas_account_id, nama_sumber, jumlah, saldoSetelah, deskripsi || null]
      );

      // Create audit log
      await createAuditLog(
        conn,
        req.session.user.id,
        'CREATE',
        'income_sources',
        JSON.stringify({ nama_sumber, jumlah, kas_account_id })
      );

      await conn.commit();
      conn.release();

      res.json({
        success: true,
        message: 'Pemasukan berhasil ditambahkan'
      });
    } catch (error) {
      await conn.rollback();
      conn.release();
      throw error;
    }
  } catch (error) {
    console.error('Income create error:', error);
    res.status(500).json({
      success: false,
      message: 'Gagal menambahkan pemasukan'
    });
  }
});

// DELETE /income/:id - Delete income
router.delete('/:id', checkRole(ROLES.SUPER_ADMIN, ROLES.BENDAHARA), async (req, res) => {
  try {
    const { id } = req.params;
    const conn = await pool.getConnection();

    // Get income details
    const [incomeData] = await conn.query(
      `SELECT * FROM income_sources WHERE id = ?`,
      [id]
    );

    if (incomeData.length === 0) {
      conn.release();
      return res.status(404).json({
        success: false,
        message: 'Data pemasukan tidak ditemukan'
      });
    }

    const income = incomeData[0];

    // Start transaction
    await conn.beginTransaction();

    try {
      // Delete income
      await conn.execute(
        `DELETE FROM income_sources WHERE id = ?`,
        [id]
      );

      // Reverse kas balance
      await conn.execute(
        `UPDATE kas_accounts SET saldo = saldo - ? WHERE id = ?`,
        [income.jumlah, income.kas_account_id]
      );

      // Delete kas transaction
      await conn.execute(
        `DELETE FROM kas_transactions 
        WHERE sumber = ? AND jumlah = ? AND kas_account_id = ? AND tipe = 'masuk'`,
        [income.nama_sumber, income.jumlah, income.kas_account_id]
      );

      // Create audit log
      await createAuditLog(
        conn,
        req.session.user.id,
        'DELETE',
        'income_sources',
        JSON.stringify(income)
      );

      await conn.commit();
      conn.release();

      res.json({
        success: true,
        message: 'Pemasukan berhasil dihapus'
      });
    } catch (error) {
      await conn.rollback();
      conn.release();
      throw error;
    }
  } catch (error) {
    console.error('Income delete error:', error);
    res.status(500).json({
      success: false,
      message: 'Gagal menghapus pemasukan'
    });
  }
});

module.exports = router;
