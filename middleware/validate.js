const { validationResult } = require('express-validator');

// Middleware to validate request
const validate = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    // If AJAX request, return JSON
    if (req.xhr || req.headers.accept.indexOf('json') > -1) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    // Otherwise, flash errors and redirect back
    req.session.errors = errors.array();
    req.session.oldInput = req.body;
    return res.redirect('back');
  }
  
  next();
};

module.exports = validate;
