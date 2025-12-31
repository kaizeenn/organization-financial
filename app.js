require('dotenv').config();
const createError = require('http-errors');
const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
const session = require('express-session');
const config = require('./config/config');

// Import routes
const indexRouter = require('./routes/index');
const authRouter = require('./routes/auth');
const dashboardRouter = require('./routes/dashboard');
const kasRouter = require('./routes/kas');
const iuranRouter = require('./routes/iuran');
const activitiesRouter = require('./routes/activities');
const expensesRouter = require('./routes/expenses');
const reportsRouter = require('./routes/reports');
const incomeRouter = require('./routes/income');
const apiRouter = require('./routes/api');

// Import middleware
const { injectUser, isAuthenticated } = require('./middleware/auth');

const app = express();

// View engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

// Middleware
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

// Session configuration
app.use(session({
  secret: config.session.secret,
  resave: false,
  saveUninitialized: false,
  cookie: {
    maxAge: config.session.maxAge,
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production'
  }
}));

// Inject user data to all views
app.use(injectUser);

// Helper functions for views
app.locals.formatRupiah = require('./lib/helpers').formatRupiah;
app.locals.formatDate = require('./lib/helpers').formatDate;

// Routes
app.use('/', indexRouter);
app.use('/auth', authRouter);
app.use('/dashboard', dashboardRouter);
app.use('/kas', kasRouter);
app.use('/iuran', iuranRouter);
app.use('/activities', activitiesRouter);
app.use('/expenses', expensesRouter);
app.use('/income', incomeRouter);
app.use('/reports', reportsRouter);
app.use('/api', apiRouter);

// Catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// Error handler
app.use(function(err, req, res, next) {
  // Set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // Render the error page
  res.status(err.status || 500);
  res.render('error', {
    user: req.session.user || null
  });
});

module.exports = app;
