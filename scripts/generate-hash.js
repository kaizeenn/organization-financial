const bcrypt = require('bcrypt');

// Generate bcrypt hash for 'password123'
const password = 'password123';
const saltRounds = 10;

bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error('Error:', err);
    return;
  }
  
  console.log('\n=== BCRYPT HASH GENERATOR ===');
  console.log('Password:', password);
  console.log('Hash:', hash);
  console.log('\nUse this hash in your SQL INSERT statements:');
  console.log(`'${hash}'`);
  console.log('\n=== DEMO USERS ===');
  console.log('Email: admin@org.com - Password: password123 - Role: super_admin');
  console.log('Email: bendahara@org.com - Password: password123 - Role: bendahara');
  console.log('Email: pengurus@org.com - Password: password123 - Role: pengurus');
  console.log('Email: anggota@org.com - Password: password123 - Role: anggota');
  console.log('\n');
});
