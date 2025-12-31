const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const { body } = require('express-validator');
const pool = require('../config/db');
const { isGuest, isAuthenticated } = require('../middleware/auth');
const validate = require('../middleware/validate');

// GET Login Page
router.get('/login', isGuest, (req, res) => {
  res.render('auth/login', {
    title: 'Login - Organization Financial',
    error: null,
    oldInput: {}
  });
});

// POST Login
router.post('/login', isGuest, [
  body('email').isEmail().withMessage('Email tidak valid'),
  body('password').notEmpty().withMessage('Password wajib diisi')
], validate, async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user
    const [users] = await pool.execute(
      'SELECT * FROM users WHERE email = ? AND status = ?',
      [email, 'aktif']
    );

    if (users.length === 0) {
      return res.render('auth/login', {
        title: 'Login - Organization Financial',
        error: 'Email atau password salah',
        oldInput: req.body
      });
    }

    const user = users[0];

    // Verify password
    const match = await bcrypt.compare(password, user.password);

    if (!match) {
      return res.render('auth/login', {
        title: 'Login - Organization Financial',
        error: 'Email atau password salah',
        oldInput: req.body
      });
    }

    // Set session
    req.session.userId = user.id;
    req.session.user = {
      id: user.id,
      nama: user.nama,
      email: user.email,
      role: user.role,
      divisi: user.divisi
    };

    // Redirect based on role
    const returnTo = req.session.returnTo || '/dashboard';
    delete req.session.returnTo;
    
    res.redirect(returnTo);
  } catch (error) {
    console.error('Login error:', error);
    res.render('auth/login', {
      title: 'Login - Organization Financial',
      error: 'Terjadi kesalahan sistem',
      oldInput: req.body
    });
  }
});

// GET Register Page (hanya untuk development)
router.get('/register', isGuest, (req, res) => {
  res.render('auth/register', {
    title: 'Register - Organization Financial',
    error: null,
    oldInput: {}
  });
});

// POST Register
router.post('/register', isGuest, [
  body('nama').notEmpty().withMessage('Nama wajib diisi'),
  body('email').isEmail().withMessage('Email tidak valid'),
  body('password').isLength({ min: 6 }).withMessage('Password minimal 6 karakter'),
  body('role').isIn(['super_admin', 'bendahara', 'pengurus', 'anggota']).withMessage('Role tidak valid')
], validate, async (req, res) => {
  try {
    const { nama, email, password, role, divisi } = req.body;

    // Check if email exists
    const [existing] = await pool.execute(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existing.length > 0) {
      return res.render('auth/register', {
        title: 'Register - Organization Financial',
        error: 'Email sudah terdaftar',
        oldInput: req.body
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    await pool.execute(
      'INSERT INTO users (nama, email, password, role, divisi) VALUES (?, ?, ?, ?, ?)',
      [nama, email, hashedPassword, role, divisi || null]
    );

    res.redirect('/auth/login');
  } catch (error) {
    console.error('Register error:', error);
    res.render('auth/register', {
      title: 'Register - Organization Financial',
      error: 'Terjadi kesalahan sistem',
      oldInput: req.body
    });
  }
});

// GET Logout
router.get('/logout', isAuthenticated, (req, res) => {
  req.session.destroy();
  res.redirect('/auth/login');
});

module.exports = router;
