const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const { isAuthenticated } = require('../middleware/auth');
const { checkRole, ADMIN_ROLES, MANAGEMENT_ROLES } = require('../middleware/role');
const { createAuditLog, calculateSisaAnggaran } = require('../lib/helpers');

// GET All Activities
router.get('/', isAuthenticated, async (req, res) => {
  try {
    const [activities] = await pool.execute(`
      SELECT * FROM activities 
      ORDER BY created_at DESC
    `);

    // Calculate sisa anggaran for each activity
    activities.forEach(activity => {
      activity.sisa_anggaran = calculateSisaAnggaran(activity.anggaran, activity.realisasi);
    });

    res.render('activities/index', {
      title: 'Manajemen Kegiatan & Anggaran',
      user: req.session.user,
      activities
    });
  } catch (error) {
    console.error('Activities index error:', error);
    res.status(500).render('error', {
      message: 'Gagal memuat data kegiatan',
      error: { status: 500, stack: error.stack }
    });
  }
});

// POST Create Activity
router.post('/', isAuthenticated, checkRole(...ADMIN_ROLES), async (req, res) => {
  try {
    const { nama_kegiatan, divisi, anggaran, status } = req.body;

    const [result] = await pool.execute(
      'INSERT INTO activities (nama_kegiatan, divisi, anggaran, status) VALUES (?, ?, ?, ?)',
      [nama_kegiatan, divisi || null, anggaran, status || 'perencanaan']
    );

    await createAuditLog(pool, req.session.userId, 'CREATE_ACTIVITY', 'activities', result.insertId);

    res.redirect('/activities?success=1');
  } catch (error) {
    console.error('Create activity error:', error);
    res.redirect('/activities?error=1');
  }
});

// GET Activity Details & Expenses
router.get('/:id', isAuthenticated, async (req, res) => {
  try {
    const [activity] = await pool.execute('SELECT * FROM activities WHERE id = ?', [req.params.id]);
    
    if (activity.length === 0) {
      return res.status(404).send('Activity not found');
    }

    const [expenses] = await pool.execute(`
      SELECT e.*, ec.nama_kategori, ka.nama_akun,
             u.nama as dibuat_oleh_nama, a.nama as approved_by_nama
      FROM expenses e
      LEFT JOIN expense_categories ec ON e.category_id = ec.id
      JOIN kas_accounts ka ON e.kas_account_id = ka.id
      JOIN users u ON e.dibuat_oleh = u.id
      LEFT JOIN users a ON e.approved_by = a.id
      WHERE e.activity_id = ?
      ORDER BY e.created_at DESC
    `, [req.params.id]);

    const activityData = activity[0];
    activityData.sisa_anggaran = calculateSisaAnggaran(activityData.anggaran, activityData.realisasi);

    res.render('activities/detail', {
      title: activityData.nama_kegiatan,
      user: req.session.user,
      activity: activityData,
      expenses
    });
  } catch (error) {
    console.error('Activity detail error:', error);
    res.status(500).render('error', {
      message: 'Gagal memuat detail kegiatan',
      error: { status: 500, stack: error.stack }
    });
  }
});

// POST Update Activity Status
router.post('/:id/status', isAuthenticated, checkRole(...ADMIN_ROLES), async (req, res) => {
  try {
    const { status } = req.body;

    await pool.execute(
      'UPDATE activities SET status = ? WHERE id = ?',
      [status, req.params.id]
    );

    await createAuditLog(pool, req.session.userId, 'UPDATE_ACTIVITY_STATUS', 'activities', req.params.id);

    res.redirect(`/activities/${req.params.id}?success=1`);
  } catch (error) {
    console.error('Update activity status error:', error);
    res.redirect(`/activities/${req.params.id}?error=1`);
  }
});

module.exports = router;
