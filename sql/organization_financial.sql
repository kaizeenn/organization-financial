-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 31, 2025 at 02:10 AM
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

-- --------------------------------------------------------

--
-- Table structure for table `expense_categories`
--

CREATE TABLE `expense_categories` (
  `id` int NOT NULL,
  `nama_kategori` varchar(100) NOT NULL
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

-- --------------------------------------------------------

--
-- Table structure for table `kas_transactions`
--

CREATE TABLE `kas_transactions` (
  `id` int NOT NULL,
  `kas_account_id` int NOT NULL,
  `tipe` enum('masuk','keluar') NOT NULL,
  `sumber` enum('iuran','pengeluaran','koreksi') NOT NULL,
  `referensi_id` int DEFAULT NULL,
  `jumlah` decimal(15,2) NOT NULL,
  `saldo_setelah` decimal(15,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expense_categories`
--
ALTER TABLE `expense_categories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `iuran_payments`
--
ALTER TABLE `iuran_payments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `iuran_types`
--
ALTER TABLE `iuran_types`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kas_accounts`
--
ALTER TABLE `kas_accounts`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kas_transactions`
--
ALTER TABLE `kas_transactions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

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
