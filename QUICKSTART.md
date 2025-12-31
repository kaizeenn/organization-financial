# Quick Start Guide - Organization Financial

## 🚀 Setup dalam 5 Menit

### 1. Install Dependencies
```bash
cd organization-financial
npm install
```

### 2. Setup Database
```bash
# Login ke MySQL
mysql -u root -p

# Create database
CREATE DATABASE organization_financial;
exit;

# Import struktur
mysql -u root -p organization_financial < sql/organization_financial.sql

# Import demo data
mysql -u root -p organization_financial < sql/seeder.sql
```

### 3. Configure Environment
```bash
# Copy .env.example ke .env
cp .env.example .env

# Edit .env (sesuaikan dengan database Anda)
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=organization_financial

SESSION_SECRET=your-secret-key
PORT=3001
```

### 4. Build CSS
```bash
npm run tailwind
```

### 5. Run Application
```bash
# Development
npm run dev

# atau Production
npm start
```

### 6. Login
Buka browser: `http://localhost:3001`

**Demo Accounts:**
- Bendahara: `bendahara@org.com` / `password123`
- Anggota: `anggota@org.com` / `password123`

## 📋 Test Workflow

### Sebagai Bendahara

1. **Login** sebagai bendahara@org.com
2. **Cek Dashboard** - lihat statistik kas & pending iuran
3. **Verifikasi Iuran**
   - Ke menu "Manajemen Iuran"
   - Lihat pending payments
   - Klik "Verifikasi" → pilih akun kas → Approve
4. **Approve Pengeluaran**
   - Ke menu "Pengeluaran"
   - Lihat pending expenses
   - Klik "Approve" atau "Reject"
5. **Lihat Laporan** - Transaksi kas terupdate otomatis

### Sebagai Anggota

1. **Login** sebagai anggota@org.com
2. **Cek Dashboard** - lihat status iuran & kegiatan
3. **Upload Iuran**
   - Ke menu "Iuran Saya"
   - Pilih jenis iuran
   - Upload bukti pembayaran
   - Submit (status pending, tunggu verifikasi)
4. **Lihat Kegiatan** - Transparansi anggaran kegiatan

### Sebagai Pengurus

1. **Login** sebagai pengurus@org.com
2. **Buat Pengeluaran**
   - Ke menu "Pengeluaran"
   - Pilih kegiatan
   - Input jumlah & upload bukti
   - Submit (pending approval bendahara)
3. **Track Budget** - Lihat realisasi vs anggaran

## 🔍 Features to Test

### ✅ Kas Management
- [x] Multiple kas accounts (Tunai, Bank, E-Wallet)
- [x] Real-time balance tracking
- [x] Transaction history

### ✅ Iuran System
- [x] Upload bukti pembayaran
- [x] Verification workflow
- [x] Auto-update kas when verified
- [x] Status tracking (pending/lunas/ditolak)

### ✅ Budget Control
- [x] Set anggaran per kegiatan
- [x] Block over-budget expenses
- [x] Real-time realisasi tracking
- [x] Progress visualization

### ✅ Approval System
- [x] Expense approval workflow
- [x] Auto-deduct kas when approved
- [x] Update activity realisasi
- [x] Audit trail

### ✅ Role-Based Access
- [x] Different dashboard per role
- [x] Permission-based features
- [x] Read-only for anggota
- [x] Admin controls

## 🛠️ Troubleshooting

### Port already in use
```bash
# Ubah PORT di .env
PORT=3002
```

### Database connection failed
```bash
# Cek MySQL running
# Windows:
net start MySQL80

# Cek credentials di .env
DB_USER=root
DB_PASSWORD=your_password
```

### Tailwind tidak compile
```bash
npm run tailwind
```

### Session error
```bash
# Clear browser cookies
# atau set SESSION_SECRET di .env
SESSION_SECRET=random-secret-key-here
```

## 📱 Test on Mobile

1. Get your local IP:
```bash
ipconfig  # Windows
ifconfig  # Mac/Linux
```

2. Access from phone:
```
http://192.168.x.x:3001
```

## 🎯 Next Steps

1. ✅ Test semua workflow
2. ✅ Cek responsive design
3. ✅ Verifikasi role permissions
4. ✅ Test dengan multiple users
5. 📝 Customize untuk kebutuhan organisasi Anda

## 📞 Need Help?

- Cek [README.md](README.md) untuk dokumentasi lengkap
- Cek [ROUTES.md](ROUTES.md) untuk route mapping
- Review code di `routes/` dan `views/`

---

**Happy Coding! 🚀**
