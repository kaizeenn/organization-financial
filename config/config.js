require('dotenv').config();

module.exports = {
  database: {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'organization_financial',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
  },
  session: {
    secret: process.env.SESSION_SECRET || 'org-financial-secret-key',
    maxAge: parseInt(process.env.SESSION_MAX_AGE) || 86400000
  },
  server: {
    port: process.env.PORT || 3001
  }
};
