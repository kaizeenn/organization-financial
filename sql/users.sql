-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 31, 2025 at 03:26 AM
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
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
