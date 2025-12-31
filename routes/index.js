const express = require('express');
const router = express.Router();

/* GET home page - redirect to dashboard or login */
router.get('/', function(req, res, next) {
  if (req.session && req.session.userId) {
    res.redirect('/dashboard');
  } else {
    res.redirect('/auth/login');
  }
});

module.exports = router;
