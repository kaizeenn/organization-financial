const mysql = require('mysql2');
const config = require('./config');

// Create connection pool
const pool = mysql.createPool(config.database);

// Test connection
pool.getConnection((err, connection) => {
  if (err) {
    console.error('❌ Database connection failed:', err.message);
  } else {
    console.log('✅ Database connected successfully');
    connection.release();
  }
});

// Export promise-based pool
module.exports = pool.promise();
