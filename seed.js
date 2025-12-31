const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function seedDatabase() {
  try {
    // Read seeder SQL
    const seederPath = path.join(__dirname, 'sql', 'seeder.sql');
    const seederSQL = fs.readFileSync(seederPath, 'utf8');

    // Create connection
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'organization_financial'
    });

    console.log('✅ Connected to database');

    // Split and execute SQL statements
    const statements = seederSQL
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));

    for (const stmt of statements) {
      try {
        await connection.execute(stmt);
        console.log('✅ Executed:', stmt.substring(0, 60) + '...');
      } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
          console.log('⚠️  Skipped (duplicate):', stmt.substring(0, 50) + '...');
        } else {
          console.error('❌ Error:', error.message);
        }
      }
    }

    await connection.end();
    console.log('\n✅ Database seeded successfully!');
    console.log('\nDemo Accounts:');
    console.log('1. admin@org.com (Super Admin)');
    console.log('2. bendahara@org.com (Bendahara)');
    console.log('3. pengurus@org.com (Pengurus)');
    console.log('4. anggota@org.com (Anggota)');
    console.log('\nAll passwords: password123\n');
  } catch (error) {
    console.error('❌ Seeding failed:', error.message);
    process.exit(1);
  }
}

seedDatabase();
