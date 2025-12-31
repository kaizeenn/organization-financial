const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function runMigration() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      multipleStatements: true
    });

    console.log('✅ Connected to MySQL');

    // Read migration file
    const migrationPath = path.join(__dirname, 'sql', '001_add_income_sources.sql');
    const sql = fs.readFileSync(migrationPath, 'utf8');

    // Execute migration
    await connection.query(sql);
    console.log('✅ Migration executed successfully!');

    await connection.end();
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    process.exit(1);
  }
}

runMigration();
