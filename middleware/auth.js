// Middleware to check if user is authenticated
const isAuthenticated = (req, res, next) => {
  if (req.session && req.session.userId) {
    return next();
  }
  
  req.session.returnTo = req.originalUrl;
  res.redirect('/auth/login');
};

// Middleware to check if user is guest (not authenticated)
const isGuest = (req, res, next) => {
  if (req.session && req.session.userId) {
    return res.redirect('/dashboard');
  }
  next();
};

// Middleware to inject user data into views
const injectUser = (req, res, next) => {
  res.locals.user = req.session.user || null;
  res.locals.isAuthenticated = !!req.session.userId;
  next();
};

module.exports = {
  isAuthenticated,
  isGuest,
  injectUser
};
