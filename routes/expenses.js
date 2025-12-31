const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const upload = require('../config/upload');
const { isAuthenticated } = require('../middleware/auth');
const { checkRole, ADMIN_ROLES, MANAGEMENT_ROLES } = require('../middleware/role');
const { createAuditLog } = require('../lib/helpers');

// GET All Expenses
router.get('/', isAuthenticated, checkRole(...MANAGEMENT_ROLES), async (req, res) => {
  try {
    const status = req.query.status || 'all';
    
    let query = `
      SELECT e.*, ec.nama_kategori, ka.nama_akun, a.nama_kegiatan,
             u.nama as dibuat_oleh_nama, ap.nama as approved_by_nama
      FROM expenses e
      LEFT JOIN expense_categories ec ON e.category_id = ec.id
      JOIN kas_accounts ka ON e.kas_account_id = ka.id
      LEFT JOIN activities a ON e.activity_id = a.id
      JOIN users u ON e.dibuat_oleh = u.id
      LEFT JOIN users ap ON e.approved_by = ap.id
    `;
    
    const params = [];
    
    if (status !== 'all') {
      query += ' WHERE e.status = ?';
      params.push(status);
    }
    
    query += ' ORDER BY e.created_at DESC';

    const [expenses] = await pool.execute(query, params);
    
    const [activities] = await pool.execute('SELECT * FROM activities WHERE status != "selesai" ORDER BY nama_kegiatan');
    const [categories] = await pool.execute('SELECT * FROM expense_categories ORDER BY nama_kategori');
    const [kasAccounts] = await pool.execute('SELECT * FROM kas_accounts ORDER BY nama_akun');

    res.render('expenses/index', {
      title: 'Manajemen Pengeluaran',
      user: req.session.user,
      expenses,
      activities,
      categories,
      kasAccounts,
      currentStatus: status
    });
  } catch (error) {
    console.error('Expenses index error:', error);
    res.status(500).render('error', {
      message: 'Gagal memuat data pengeluaran',
      error: { status: 500, stack: error.stack }
    });
  }
});

// POST Create Expense
router.post('/', isAuthenticated, checkRole(...MANAGEMENT_ROLES), upload.single('bukti'), async (req, res) => {
  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();

    const { activity_id, category_id, kas_account_id, jumlah, keterangan } = req.body;
    const bukti = req.file ? `/uploads/${req.file.filename}` : null;

    // Check budget availability
    if (activity_id) {
      const [activity] = await connection.execute(
        'SELECT anggaran, realisasi FROM activities WHERE id = ?',
        [activity_id]
      );

      if (activity.length > 0) {
        const sisaAnggaran = parseFloat(activity[0].anggaran) - parseFloat(activity[0].realisasi);
        if (parseFloat(jumlah) > sisaAnggaran) {
          throw new Error('Anggaran tidak mencukupi');
        }
      }
    }

    // Create expense
    const [result] = await connection.execute(
      'INSERT INTO expenses (activity_id, category_id, kas_account_id, jumlah, keterangan, bukti, dibuat_oleh, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [activity_id || null, category_id || null, kas_account_id, jumlah, keterangan, bukti, req.session.userId, 'pending']
    );

    await createAuditLog(connection, req.session.userId, 'CREATE_EXPENSE', 'expenses', result.insertId);

    await connection.commit();
    res.redirect('/expenses?success=create');
  } catch (error) {
    await connection.rollback();
    console.error('Create expense error:', error);
    res.redirect('/expenses?error=' + encodeURIComponent(error.message));
  } finally {
    connection.release();
  }
});

// POST Approve/Reject Expense
router.post('/:id/approve', isAuthenticated, checkRole(...ADMIN_ROLES), async (req, res) => {
  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();

    const { status } = req.body; // 'disetujui' or 'ditolak'
    const expenseId = req.params.id;

    // Get expense details
    const [expense] = await connection.execute(
      'SELECT * FROM expenses WHERE id = ?',
      [expenseId]
    );

    if (expense.length === 0) {
      throw new Error('Expense not found');
    }

    const expenseData = expense[0];

    // Update expense status
    await connection.execute(
      'UPDATE expenses SET status = ?, approved_by = ? WHERE id = ?',
      [status, req.session.userId, expenseId]
    );

    // If approved, process transaction
    if (status === 'disetujui') {
      // Get kas account current saldo
      const [kasAccount] = await connection.execute(
        'SELECT saldo FROM kas_accounts WHERE id = ?',
        [expenseData.kas_account_id]
      );

      const currentSaldo = parseFloat(kasAccount[0].saldo);
      const newSaldo = currentSaldo - parseFloat(expenseData.jumlah);

      // Update kas saldo
      await connection.execute(
        'UPDATE kas_accounts SET saldo = ? WHERE id = ?',
        [newSaldo, expenseData.kas_account_id]
      );

      // Create kas transaction
      await connection.execute(
        'INSERT INTO kas_transactions (kas_account_id, tipe, sumber, referensi_id, jumlah, saldo_setelah) VALUES (?, ?, ?, ?, ?, ?)',
        [expenseData.kas_account_id, 'keluar', 'pengeluaran', expenseId, expenseData.jumlah, newSaldo]
      );

      // Update activity realisasi
      if (expenseData.activity_id) {
        await connection.execute(
          'UPDATE activities SET realisasi = realisasi + ? WHERE id = ?',
          [expenseData.jumlah, expenseData.activity_id]
        );
      }
    }

    await createAuditLog(connection, req.session.userId, `APPROVE_EXPENSE_${status.toUpperCase()}`, 'expenses', expenseId);

    await connection.commit();
    res.redirect('/expenses?success=approve');
  } catch (error) {
    await connection.rollback();
    console.error('Approve expense error:', error);
    res.redirect('/expenses?error=' + encodeURIComponent(error.message));
  } finally {
    connection.release();
  }
});

module.exports = router;
