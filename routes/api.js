const express = require('express');
const router = express.Router();
const pool = require('../config/db');

// GET /api/kas-accounts - Get all kas accounts
router.get('/kas-accounts', async (req, res) => {
  try {
    const conn = await pool.getConnection();
    const [accounts] = await conn.query('SELECT id, nama_akun, saldo FROM kas_accounts');
    conn.release();

    res.json(accounts);
  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Failed to fetch kas accounts' });
  }
});

module.exports = router;
