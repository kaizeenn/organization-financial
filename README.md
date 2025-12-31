# Organization Financial Management System

Aplikasi manajemen keuangan berbasis web untuk organisasi dengan fitur kas, iuran anggota, anggaran kegiatan, dan transparansi keuangan.

## 🚀 Fitur Utama

### 1. **Manajemen Kas Organisasi**
- Multiple akun kas (Tunai, Bank, E-Wallet)
- Track saldo real-time
- Histori transaksi lengkap

### 2. **Iuran & Pembayaran Anggota**
- Jenis iuran (wajib/sukarela, bulanan/sekali)
- Upload bukti pembayaran
- Sistem verifikasi bendahara
- Status: pending/lunas/ditolak

### 3. **Anggaran & Kegiatan**
- Perencanaan anggaran per kegiatan
- Track realisasi pengeluaran
- Alert over-budget
- Progress monitoring

### 4. **Pengeluaran Organisasi**
- Harus terkait kegiatan
- Approval system
- Upload bukti transaksi
- Audit trail lengkap

### 5. **Transparansi**
- Dashboard berbeda untuk setiap role
- Anggota bisa lihat laporan (read-only)
- Audit log semua transaksi

## 👥 Role & Permission

| Role | Akses |
|------|-------|
| **Super Admin** | Full access, manajemen user & settings |
| **Bendahara** | Kelola kas, verifikasi iuran, approve pengeluaran |
| **Pengurus** | Buat pengeluaran, lihat laporan |
| **Anggota** | Upload iuran, lihat status, read-only laporan |

## 🛠️ Tech Stack

- **Backend**: Node.js + Express.js
- **Database**: MySQL
- **View Engine**: EJS
- **CSS Framework**: Tailwind CSS
- **Authentication**: Session-based (express-session)
- **File Upload**: Multer
- **Security**: Bcrypt password hashing

## 📦 Struktur Project

```
organization-financial/
├── config/
│   ├── config.js          # Konfigurasi environment
│   ├── db.js              # Database connection pool
│   └── upload.js          # Multer upload config
├── controllers/           # (Future: Controller logic)
├── middleware/
│   ├── auth.js            # Authentication middleware
│   ├── role.js            # Role-based access control
│   └── validate.js        # Request validation
├── routes/
│   ├── auth.js            # Login/logout
│   ├── dashboard.js       # Dashboard routes
│   ├── kas.js             # Kas management
│   ├── iuran.js           # Iuran & payments
│   ├── activities.js      # Kegiatan & anggaran
│   └── expenses.js        # Pengeluaran
├── views/
│   ├── layout/            # Main & auth layouts
│   ├── partials/          # Reusable components (sidebar)
│   ├── auth/              # Login & register
│   ├── dashboard/         # Dashboard views
│   ├── kas/               # Kas management views
│   ├── iuran/             # Iuran views
│   ├── activities/        # Activities views
│   └── expenses/          # Expenses views
├── lib/
│   └── helpers.js         # Helper functions
├── sql/
│   ├── organization_financial.sql  # Database structure
│   └── seeder.sql                  # Demo data
└── public/
    ├── uploads/           # Uploaded files
    └── stylesheets/       # CSS files
```

## 🚀 Getting Started

### Prerequisites

- Node.js (v16+)
- MySQL (v8+)
- npm atau yarn

### Installation

1. **Clone repository**
```bash
cd organization-financial
```

2. **Install dependencies**
```bash
npm install
```

3. **Setup database**
```sql
-- Create database
CREATE DATABASE organization_financial;

-- Import structure
mysql -u root -p organization_financial < sql/organization_financial.sql

-- Import demo data
mysql -u root -p organization_financial < sql/seeder.sql
```

4. **Configure environment**
```bash
cp .env.example .env
```

Edit `.env` file:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=organization_financial

SESSION_SECRET=your-secret-key
PORT=3001
```

5. **Build Tailwind CSS**
```bash
npm run tailwind
```

6. **Run application**
```bash
# Development
npm run dev

# Production
npm start
```

7. **Access application**
```
http://localhost:3001
```

## 🔐 Demo Accounts

| Role | Email | Password |
|------|-------|----------|
| Super Admin | admin@org.com | password123 |
| Bendahara | bendahara@org.com | password123 |
| Pengurus | pengurus@org.com | password123 |
| Anggota | anggota@org.com | password123 |

## 📱 Fitur Per Role

### Super Admin Dashboard
- Overview total kas
- Pending iuran & approvals
- Chart kas masuk vs keluar
- Manajemen user
- Settings

### Bendahara Dashboard
- Total kas organisasi (semua akun)
- List iuran pending (hitung & jumlah)
- Pengeluaran bulan ini
- Chart 6 bulan terakhir
- Verifikasi iuran
- Approve pengeluaran

### Anggota Dashboard
- Status iuran pribadi (lunas/pending)
- Total bayar & tunggakan
- Riwayat pembayaran
- Kegiatan yang sedang berjalan
- Notifikasi

## 🗃️ Database Schema

### Tables
- **users** - Data user & role
- **kas_accounts** - Akun kas organisasi
- **iuran_types** - Jenis iuran
- **iuran_payments** - Pembayaran iuran
- **activities** - Kegiatan & anggaran
- **expense_categories** - Kategori pengeluaran
- **expenses** - Pengeluaran organisasi
- **kas_transactions** - Transaksi kas (audit trail)
- **audit_logs** - Log aktivitas user

## 🎨 Reuse dari Financial-App

Aplikasi ini menggunakan komponen UI yang sama dengan `financial-app`:

- ✅ Tailwind config & utility classes
- ✅ Layout structure (sidebar, main content)
- ✅ Color scheme & branding
- ✅ Component styles (cards, badges, buttons)
- ✅ Responsive design patterns

**PERBEDAAN**: Logic keuangan 100% berbeda - fokus organisasi bukan personal.

## 🔒 Security Features

- ✅ Password hashing (bcrypt)
- ✅ Session-based authentication
- ✅ Role-based access control
- ✅ CSRF protection ready
- ✅ Input validation
- ✅ Audit logging
- ✅ No hard delete (soft delete via status)

## 📊 Key Business Rules

1. **Kas**: Saldo auto-update saat transaksi approved
2. **Iuran**: Butuh verifikasi bendahara sebelum masuk kas
3. **Pengeluaran**: Harus linked ke kegiatan, tidak boleh over-budget
4. **Approval**: Hanya bendahara/super_admin yang bisa approve
5. **Transparansi**: Anggota read-only, tidak bisa edit transaksi

## 🚧 Future Development

- [ ] Multi-organisasi (tenant-based)
- [ ] Multi-periode akuntansi
- [ ] Export laporan PDF & Excel
- [ ] Notifikasi email/WhatsApp
- [ ] API untuk mobile app
- [ ] Dashboard analytics advanced
- [ ] Budgeting & forecasting

## 📝 Scripts

```bash
# Development dengan auto-reload
npm run dev

# Build Tailwind (watch mode)
npm run tailwind

# Production
npm start
```

## 🐛 Troubleshooting

### Database connection error
- Pastikan MySQL running
- Cek credentials di `.env`
- Pastikan database sudah dibuat

### Tailwind tidak ter-compile
```bash
npm run tailwind
```

### Session error
- Pastikan `SESSION_SECRET` sudah diset di `.env`
- Clear browser cookies

## 👨‍💻 Development Notes

### Menambah Route Baru
1. Buat file di `routes/`
2. Import di `app.js`
3. Tambahkan middleware auth & role

### Menambah Fitur Baru
1. Update database schema di `sql/`
2. Buat route & view
3. Update sidebar navigation
4. Tambahkan audit log

## 📄 License

MIT License - Free for personal and commercial use

## 🤝 Contributing

Contributions welcome! Silakan buat PR atau issue.

---

**Built with ❤️ for better organization financial management**
