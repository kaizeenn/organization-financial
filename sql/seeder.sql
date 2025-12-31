-- Seeder for Organization Financial Management System
-- Run this after creating the database structure

USE organization_financial;

-- Insert demo users (passwords are hashed with bcrypt: password123)
INSERT INTO users (nama, email, password, role, divisi, status) VALUES
('Super Admin', 'admin@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'super_admin', NULL, 'aktif'),
('Bendahara Organisasi', 'bendahara@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'bendahara', 'Keuangan', 'aktif'),
('Ketua Divisi Acara', 'pengurus@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'pengurus', 'Acara', 'aktif'),
('Anggota Aktif', 'anggota@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'anggota', 'Media', 'aktif'),
('Budi Santoso', 'budi@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'anggota', 'Humas', 'aktif'),
('Siti Nurhaliza', 'siti@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'anggota', 'Acara', 'aktif');

-- Insert kas accounts
INSERT INTO kas_accounts (nama_akun, tipe, saldo, penanggung_jawab) VALUES
('Kas Tunai Organisasi', 'tunai', 5000000, 2),
('Bank Mandiri - Organisasi', 'bank', 15000000, 2),
('OVO - Organisasi', 'ewallet', 2500000, 2),
('Dana - Organisasi', 'ewallet', 1500000, 2);

-- Insert expense categories
INSERT INTO expense_categories (nama_kategori) VALUES
('Konsumsi'),
('Transportasi'),
('Dokumentasi'),
('Perlengkapan'),
('Honorarium'),
('Publikasi'),
('Lain-lain');

-- Insert iuran types
INSERT INTO iuran_types (nama_iuran, nominal, sifat, periode) VALUES
('Iuran Bulanan Anggota', 50000, 'wajib', 'bulanan'),
('Iuran Kegiatan Tahunan', 200000, 'wajib', 'sekali'),
('Donasi Sukarela', NULL, 'sukarela', 'sekali'),
('Iuran Pembangunan', 100000, 'wajib', 'sekali');

-- Insert activities
INSERT INTO activities (nama_kegiatan, divisi, anggaran, realisasi, status) VALUES
('Seminar Nasional 2025', 'Acara', 25000000, 15000000, 'berjalan'),
('Pelatihan Soft Skills', 'SDM', 10000000, 8000000, 'berjalan'),
('Bakti Sosial', 'Sosial', 15000000, 0, 'perencanaan'),
('Gathering Tahunan', 'Acara', 20000000, 0, 'perencanaan'),
('Workshop Digital Marketing', 'Media', 8000000, 7500000, 'selesai');

-- Insert sample iuran payments
INSERT INTO iuran_payments (user_id, iuran_type_id, periode, jumlah, metode, bukti_pembayaran, status, verified_by, verified_at) VALUES
(4, 1, '2025-01', 50000, 'transfer', '/uploads/bukti-1.jpg', 'lunas', 2, '2025-01-05 10:30:00'),
(5, 1, '2025-01', 50000, 'transfer', '/uploads/bukti-2.jpg', 'lunas', 2, '2025-01-06 14:20:00'),
(6, 1, '2025-01', 50000, 'qris', '/uploads/bukti-3.jpg', 'pending', NULL, NULL),
(4, 2, '2025', 200000, 'transfer', '/uploads/bukti-4.jpg', 'lunas', 2, '2025-01-10 09:15:00'),
(5, 2, '2025', 200000, 'transfer', '/uploads/bukti-5.jpg', 'pending', NULL, NULL);

-- Insert sample expenses
INSERT INTO expenses (activity_id, category_id, kas_account_id, jumlah, keterangan, bukti, dibuat_oleh, approved_by, status, created_at) VALUES
(1, 1, 2, 5000000, 'Konsumsi seminar 200 peserta', '/uploads/expense-1.jpg', 3, 2, 'disetujui', '2025-01-15 10:00:00'),
(1, 4, 2, 3000000, 'Sewa venue seminar', '/uploads/expense-2.jpg', 3, 2, 'disetujui', '2025-01-16 11:00:00'),
(1, 6, 3, 2000000, 'Publikasi dan promosi', '/uploads/expense-3.jpg', 3, 2, 'disetujui', '2025-01-17 14:00:00'),
(2, 1, 1, 3000000, 'Snack dan makan siang pelatihan', '/uploads/expense-4.jpg', 3, 2, 'disetujui', '2025-01-20 09:00:00'),
(2, 5, 2, 5000000, 'Honorarium narasumber', '/uploads/expense-5.jpg', 3, NULL, 'pending', '2025-01-25 13:00:00');

-- Insert kas transactions (from approved iuran and expenses)
INSERT INTO kas_transactions (kas_account_id, tipe, sumber, referensi_id, jumlah, saldo_setelah, created_at) VALUES
-- Initial balance
(1, 'masuk', 'koreksi', NULL, 5000000, 5000000, '2025-01-01 00:00:00'),
(2, 'masuk', 'koreksi', NULL, 15000000, 15000000, '2025-01-01 00:00:00'),
(3, 'masuk', 'koreksi', NULL, 2500000, 2500000, '2025-01-01 00:00:00'),
(4, 'masuk', 'koreksi', NULL, 1500000, 1500000, '2025-01-01 00:00:00'),
-- Iuran masuk
(2, 'masuk', 'iuran', 1, 50000, 15050000, '2025-01-05 10:30:00'),
(2, 'masuk', 'iuran', 2, 50000, 15100000, '2025-01-06 14:20:00'),
(2, 'masuk', 'iuran', 4, 200000, 15300000, '2025-01-10 09:15:00'),
-- Pengeluaran
(2, 'keluar', 'pengeluaran', 1, 5000000, 10300000, '2025-01-15 10:00:00'),
(2, 'keluar', 'pengeluaran', 2, 3000000, 7300000, '2025-01-16 11:00:00'),
(3, 'keluar', 'pengeluaran', 3, 2000000, 500000, '2025-01-17 14:00:00'),
(1, 'keluar', 'pengeluaran', 4, 3000000, 2000000, '2025-01-20 09:00:00');

-- Insert sample audit logs
INSERT INTO audit_logs (user_id, aksi, tabel, data_id, created_at) VALUES
(2, 'VERIFY_IURAN_LUNAS', 'iuran_payments', 1, '2025-01-05 10:30:00'),
(2, 'VERIFY_IURAN_LUNAS', 'iuran_payments', 2, '2025-01-06 14:20:00'),
(2, 'APPROVE_EXPENSE_DISETUJUI', 'expenses', 1, '2025-01-15 10:00:00'),
(2, 'APPROVE_EXPENSE_DISETUJUI', 'expenses', 2, '2025-01-16 11:00:00'),
(3, 'CREATE_EXPENSE', 'expenses', 5, '2025-01-25 13:00:00');

-- Insert sample income from other sources
INSERT INTO income_sources (nama_sumber, deskripsi, jumlah, kas_account_id, created_by, created_at) VALUES
('Sponsor PT Maju Jaya', 'Sponsor untuk Seminar Nasional 2025', 10000000, 2, 2, '2025-01-10 09:00:00'),
('Donasi Alumni Angkatan 2020', 'Donasi untuk kegiatan sosial', 5000000, 2, 2, '2025-01-15 14:30:00'),
('Hadiah Juara 1 Lomba Inovasi', 'Hadiah dari kompetisi tingkat nasional', 3000000, 1, 2, '2025-01-20 10:00:00');

-- Insert kas transactions for income
INSERT INTO kas_transactions (kas_account_id, tipe, sumber, jumlah, saldo_setelah, keterangan, created_at) VALUES
(2, 'masuk', 'Sponsor PT Maju Jaya', 10000000, 25000000, 'Sponsor untuk Seminar Nasional 2025', '2025-01-10 09:00:00'),
(2, 'masuk', 'Donasi Alumni Angkatan 2020', 5000000, 30000000, 'Donasi untuk kegiatan sosial', '2025-01-15 14:30:00'),
(1, 'masuk', 'Hadiah Juara 1 Lomba Inovasi', 3000000, 8000000, 'Hadiah dari kompetisi tingkat nasional', '2025-01-20 10:00:00');

-- Update kas account saldo to match transactions
UPDATE kas_accounts SET saldo = 8000000 WHERE id = 1;
UPDATE kas_accounts SET saldo = 25300000 WHERE id = 2;
UPDATE kas_accounts SET saldo = 500000 WHERE id = 3;
UPDATE kas_accounts SET saldo = 1500000 WHERE id = 4;

-- Show seeder summary
SELECT 'Seeder completed successfully!' as status;
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_kas_accounts FROM kas_accounts;
SELECT COUNT(*) as total_activities FROM activities;
SELECT COUNT(*) as total_iuran_payments FROM iuran_payments;
SELECT COUNT(*) as total_expenses FROM expenses;
SELECT COUNT(*) as total_income_sources FROM income_sources;
