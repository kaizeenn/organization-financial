-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 31, 2025 at 03:32 AM
-- Server version: 8.0.30
-- PHP Version: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `organization_financial`
--

-- --------------------------------------------------------

--
-- Table structure for table `activities`
--

CREATE TABLE `activities` (
  `id` int NOT NULL,
  `nama_kegiatan` varchar(150) NOT NULL,
  `divisi` varchar(100) DEFAULT NULL,
  `anggaran` decimal(15,2) NOT NULL,
  `realisasi` decimal(15,2) DEFAULT '0.00',
  `status` enum('perencanaan','berjalan','selesai') DEFAULT 'perencanaan',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `activities`
--

INSERT INTO `activities` (`id`, `nama_kegiatan`, `divisi`, `anggaran`, `realisasi`, `status`, `created_at`) VALUES
(1, 'Seminar Nasional 2025', 'Acara', '25000000.00', '15000000.00', 'berjalan', '2025-12-31 02:36:19'),
(2, 'Pelatihan Soft Skills', 'SDM', '10000000.00', '8000000.00', 'berjalan', '2025-12-31 02:36:19'),
(3, 'Bakti Sosial', 'Sosial', '15000000.00', '0.00', 'perencanaan', '2025-12-31 02:36:19'),
(4, 'Gathering Tahunan', 'Acara', '20000000.00', '0.00', 'perencanaan', '2025-12-31 02:36:19'),
(5, 'Workshop Digital Marketing', 'Media', '8000000.00', '7500000.00', 'selesai', '2025-12-31 02:36:19');

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `aksi` varchar(255) DEFAULT NULL,
  `tabel` varchar(100) DEFAULT NULL,
  `data_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `user_id`, `aksi`, `tabel`, `data_id`, `created_at`) VALUES
(1, 2, 'VERIFY_IURAN_LUNAS', 'iuran_payments', 1, '2025-01-05 03:30:00'),
(2, 2, 'VERIFY_IURAN_LUNAS', 'iuran_payments', 2, '2025-01-06 07:20:00'),
(3, 2, 'APPROVE_EXPENSE_DISETUJUI', 'expenses', 1, '2025-01-15 03:00:00'),
(4, 2, 'APPROVE_EXPENSE_DISETUJUI', 'expenses', 2, '2025-01-16 04:00:00'),
(5, 3, 'CREATE_EXPENSE', 'expenses', 5, '2025-01-25 06:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `id` int NOT NULL,
  `activity_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `kas_account_id` int NOT NULL,
  `jumlah` decimal(15,2) NOT NULL,
  `keterangan` text,
  `bukti` varchar(255) DEFAULT NULL,
  `dibuat_oleh` int DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `status` enum('pending','disetujui','ditolak') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `expenses`
--

INSERT INTO `expenses` (`id`, `activity_id`, `category_id`, `kas_account_id`, `jumlah`, `keterangan`, `bukti`, `dibuat_oleh`, `approved_by`, `status`, `created_at`) VALUES
(1, 1, 1, 2, '5000000.00', 'Konsumsi seminar 200 peserta', '/uploads/expense-1.jpg', 3, 2, 'disetujui', '2025-01-15 03:00:00'),
(2, 1, 4, 2, '3000000.00', 'Sewa venue seminar', '/uploads/expense-2.jpg', 3, 2, 'disetujui', '2025-01-16 04:00:00'),
(3, 1, 6, 3, '2000000.00', 'Publikasi dan promosi', '/uploads/expense-3.jpg', 3, 2, 'disetujui', '2025-01-17 07:00:00'),
(4, 2, 1, 1, '3000000.00', 'Snack dan makan siang pelatihan', '/uploads/expense-4.jpg', 3, 2, 'disetujui', '2025-01-20 02:00:00'),
(5, 2, 5, 2, '5000000.00', 'Honorarium narasumber', '/uploads/expense-5.jpg', 3, NULL, 'pending', '2025-01-25 06:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `expense_categories`
--

CREATE TABLE `expense_categories` (
  `id` int NOT NULL,
  `nama_kategori` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `expense_categories`
--

INSERT INTO `expense_categories` (`id`, `nama_kategori`) VALUES
(1, 'Konsumsi'),
(2, 'Transportasi'),
(3, 'Dokumentasi'),
(4, 'Perlengkapan'),
(5, 'Honorarium'),
(6, 'Publikasi'),
(7, 'Lain-lain');

-- --------------------------------------------------------

--
-- Table structure for table `income_sources`
--

CREATE TABLE `income_sources` (
  `id` int NOT NULL,
  `nama_sumber` varchar(150) NOT NULL COMMENT 'Nama sumber pemasukan (Sponsor, Donasi, Hadiah, dll)',
  `deskripsi` text COMMENT 'Deskripsi detail sumber pemasukan',
  `jumlah` decimal(15,2) NOT NULL COMMENT 'Jumlah uang masuk',
  `kas_account_id` int NOT NULL COMMENT 'ID kas yang menerima',
  `created_by` int NOT NULL COMMENT 'User yang mencatat pemasukan',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `iuran_payments`
--

CREATE TABLE `iuran_payments` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `iuran_type_id` int NOT NULL,
  `periode` varchar(50) DEFAULT NULL,
  `jumlah` decimal(15,2) NOT NULL,
  `metode` enum('tunai','transfer','qris','ewallet') NOT NULL,
  `bukti_pembayaran` varchar(255) DEFAULT NULL,
  `status` enum('pending','lunas','ditolak') DEFAULT 'pending',
  `verified_by` int DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `iuran_payments`
--

INSERT INTO `iuran_payments` (`id`, `user_id`, `iuran_type_id`, `periode`, `jumlah`, `metode`, `bukti_pembayaran`, `status`, `verified_by`, `verified_at`, `created_at`) VALUES
(1, 4, 1, '2025-01', '50000.00', 'transfer', '/uploads/bukti-1.jpg', 'lunas', 2, '2025-01-05 03:30:00', '2025-12-31 02:36:19'),
(2, 5, 1, '2025-01', '50000.00', 'transfer', '/uploads/bukti-2.jpg', 'lunas', 2, '2025-01-06 07:20:00', '2025-12-31 02:36:19'),
(3, 6, 1, '2025-01', '50000.00', 'qris', '/uploads/bukti-3.jpg', 'pending', NULL, NULL, '2025-12-31 02:36:19'),
(4, 4, 2, '2025', '200000.00', 'transfer', '/uploads/bukti-4.jpg', 'lunas', 2, '2025-01-10 02:15:00', '2025-12-31 02:36:19'),
(5, 5, 2, '2025', '200000.00', 'transfer', '/uploads/bukti-5.jpg', 'pending', NULL, NULL, '2025-12-31 02:36:19');

-- --------------------------------------------------------

--
-- Table structure for table `iuran_types`
--

CREATE TABLE `iuran_types` (
  `id` int NOT NULL,
  `nama_iuran` varchar(100) NOT NULL,
  `nominal` decimal(15,2) DEFAULT NULL,
  `sifat` enum('wajib','sukarela') NOT NULL,
  `periode` enum('bulanan','kegiatan','sekali') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `iuran_types`
--

INSERT INTO `iuran_types` (`id`, `nama_iuran`, `nominal`, `sifat`, `periode`, `created_at`) VALUES
(1, 'Iuran Bulanan Anggota', '50000.00', 'wajib', 'bulanan', '2025-12-31 02:36:19'),
(2, 'Iuran Kegiatan Tahunan', '200000.00', 'wajib', 'sekali', '2025-12-31 02:36:19'),
(3, 'Donasi Sukarela', NULL, 'sukarela', 'sekali', '2025-12-31 02:36:19'),
(4, 'Iuran Pembangunan', '100000.00', 'wajib', 'sekali', '2025-12-31 02:36:19');

-- --------------------------------------------------------

--
-- Table structure for table `kas_accounts`
--

CREATE TABLE `kas_accounts` (
  `id` int NOT NULL,
  `nama_akun` varchar(100) NOT NULL,
  `tipe` enum('tunai','bank','ewallet') NOT NULL,
  `saldo` decimal(15,2) DEFAULT '0.00',
  `penanggung_jawab` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `kas_accounts`
--

INSERT INTO `kas_accounts` (`id`, `nama_akun`, `tipe`, `saldo`, `penanggung_jawab`, `created_at`) VALUES
(1, 'Kas Tunai Organisasi', 'tunai', '2000000.00', 2, '2025-12-31 02:36:19'),
(2, 'Bank Mandiri - Organisasi', 'bank', '25300000.00', 2, '2025-12-31 02:36:19'),
(3, 'OVO - Organisasi', 'ewallet', '500000.00', 2, '2025-12-31 02:36:19'),
(4, 'Dana - Organisasi', 'ewallet', '1500000.00', 2, '2025-12-31 02:36:19');

-- --------------------------------------------------------

--
-- Table structure for table `kas_transactions`
--

CREATE TABLE `kas_transactions` (
  `id` int NOT NULL,
  `kas_account_id` int NOT NULL,
  `tipe` enum('masuk','keluar') NOT NULL,
  `sumber` varchar(255) DEFAULT NULL COMMENT 'Sumber transaksi (nama_iuran, nama_pemasukan, nama_kategori_pengeluaran, dll)',
  `referensi_id` int DEFAULT NULL,
  `jumlah` decimal(15,2) NOT NULL,
  `saldo_setelah` decimal(15,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `kas_transactions`
--

INSERT INTO `kas_transactions` (`id`, `kas_account_id`, `tipe`, `sumber`, `referensi_id`, `jumlah`, `saldo_setelah`, `created_at`) VALUES
(1, 1, 'masuk', 'koreksi', NULL, '5000000.00', '5000000.00', '2024-12-31 17:00:00'),
(2, 2, 'masuk', 'koreksi', NULL, '15000000.00', '15000000.00', '2024-12-31 17:00:00'),
(3, 3, 'masuk', 'koreksi', NULL, '2500000.00', '2500000.00', '2024-12-31 17:00:00'),
(4, 4, 'masuk', 'koreksi', NULL, '1500000.00', '1500000.00', '2024-12-31 17:00:00'),
(5, 2, 'masuk', 'iuran', 1, '50000.00', '15050000.00', '2025-01-05 03:30:00'),
(6, 2, 'masuk', 'iuran', 2, '50000.00', '15100000.00', '2025-01-06 07:20:00'),
(7, 2, 'masuk', 'iuran', 4, '200000.00', '15300000.00', '2025-01-10 02:15:00'),
(8, 2, 'keluar', 'pengeluaran', 1, '5000000.00', '10300000.00', '2025-01-15 03:00:00'),
(9, 2, 'keluar', 'pengeluaran', 2, '3000000.00', '7300000.00', '2025-01-16 04:00:00'),
(10, 3, 'keluar', 'pengeluaran', 3, '2000000.00', '500000.00', '2025-01-17 07:00:00'),
(11, 1, 'keluar', 'pengeluaran', 4, '3000000.00', '2000000.00', '2025-01-20 02:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('super_admin','bendahara','pengurus','anggota') NOT NULL,
  `divisi` varchar(100) DEFAULT NULL,
  `status` enum('aktif','nonaktif') DEFAULT 'aktif',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nama`, `email`, `password`, `role`, `divisi`, `status`, `created_at`) VALUES
(1, 'Super Admin', 'admin@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'super_admin', NULL, 'aktif', '2025-12-31 02:36:19'),
(2, 'Bendahara Organisasi', 'bendahara@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'bendahara', 'Keuangan', 'aktif', '2025-12-31 02:36:19'),
(3, 'Ketua Divisi Acara', 'pengurus@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'pengurus', 'Acara', 'aktif', '2025-12-31 02:36:19'),
(4, 'Anggota Aktif', 'anggota@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'anggota', 'Media', 'aktif', '2025-12-31 02:36:19'),
(5, 'Budi Santoso', 'budi@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'anggota', 'Humas', 'aktif', '2025-12-31 02:36:19'),
(6, 'Siti Nurhaliza', 'siti@org.com', '$2b$10$oRCDHrI3t35xUc34/7GEL.XaLcHCIHsAf8HNoLT25XcXqFNZu1WES', 'anggota', 'Acara', 'aktif', '2025-12-31 02:36:19');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activities`
--
ALTER TABLE `activities`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `activity_id` (`activity_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `kas_account_id` (`kas_account_id`),
  ADD KEY `dibuat_oleh` (`dibuat_oleh`),
  ADD KEY `approved_by` (`approved_by`);

--
-- Indexes for table `expense_categories`
--
ALTER TABLE `expense_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `income_sources`
--
ALTER TABLE `income_sources`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_kas_account_id` (`kas_account_id`),
  ADD KEY `idx_created_by` (`created_by`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `iuran_payments`
--
ALTER TABLE `iuran_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `iuran_type_id` (`iuran_type_id`),
  ADD KEY `verified_by` (`verified_by`);

--
-- Indexes for table `iuran_types`
--
ALTER TABLE `iuran_types`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `kas_accounts`
--
ALTER TABLE `kas_accounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `penanggung_jawab` (`penanggung_jawab`);

--
-- Indexes for table `kas_transactions`
--
ALTER TABLE `kas_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `kas_account_id` (`kas_account_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activities`
--
ALTER TABLE `activities`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `expense_categories`
--
ALTER TABLE `expense_categories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `income_sources`
--
ALTER TABLE `income_sources`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `iuran_payments`
--
ALTER TABLE `iuran_payments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `iuran_types`
--
ALTER TABLE `iuran_types`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `kas_accounts`
--
ALTER TABLE `kas_accounts`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `kas_transactions`
--
ALTER TABLE `kas_transactions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`),
  ADD CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`),
  ADD CONSTRAINT `expenses_ibfk_3` FOREIGN KEY (`kas_account_id`) REFERENCES `kas_accounts` (`id`),
  ADD CONSTRAINT `expenses_ibfk_4` FOREIGN KEY (`dibuat_oleh`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `expenses_ibfk_5` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `income_sources`
--
ALTER TABLE `income_sources`
  ADD CONSTRAINT `income_sources_ibfk_1` FOREIGN KEY (`kas_account_id`) REFERENCES `kas_accounts` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `income_sources_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT;

--
-- Constraints for table `iuran_payments`
--
ALTER TABLE `iuran_payments`
  ADD CONSTRAINT `iuran_payments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `iuran_payments_ibfk_2` FOREIGN KEY (`iuran_type_id`) REFERENCES `iuran_types` (`id`),
  ADD CONSTRAINT `iuran_payments_ibfk_3` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `kas_accounts`
--
ALTER TABLE `kas_accounts`
  ADD CONSTRAINT `kas_accounts_ibfk_1` FOREIGN KEY (`penanggung_jawab`) REFERENCES `users` (`id`);

--
-- Constraints for table `kas_transactions`
--
ALTER TABLE `kas_transactions`
  ADD CONSTRAINT `kas_transactions_ibfk_1` FOREIGN KEY (`kas_account_id`) REFERENCES `kas_accounts` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
