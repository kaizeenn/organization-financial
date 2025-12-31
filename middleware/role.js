// Middleware to check user role
const checkRole = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.session || !req.session.user) {
      return res.status(401).render('error', {
        message: 'Unauthorized',
        error: { status: 401, stack: '' }
      });
    }

    const userRole = req.session.user.role;

    if (allowedRoles.includes(userRole)) {
      return next();
    }

    return res.status(403).render('error-403', {
      message: 'Akses ditolak',
      user: req.session.user
    });
  };
};

// Role constants for easy reference
const ROLES = {
  SUPER_ADMIN: 'super_admin',
  BENDAHARA: 'bendahara',
  PENGURUS: 'pengurus',
  ANGGOTA: 'anggota'
};

// Common role combinations
const ADMIN_ROLES = [ROLES.SUPER_ADMIN, ROLES.BENDAHARA];
const MANAGEMENT_ROLES = [ROLES.SUPER_ADMIN, ROLES.BENDAHARA, ROLES.PENGURUS];
const ALL_ROLES = Object.values(ROLES);

module.exports = {
  checkRole,
  ROLES,
  ADMIN_ROLES,
  MANAGEMENT_ROLES,
  ALL_ROLES
};
