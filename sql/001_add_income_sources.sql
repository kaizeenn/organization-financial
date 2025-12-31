-- Migration: Add income_sources table
-- Created: 2025-12-31

USE organization_financial;

-- Create income_sources table
CREATE TABLE IF NOT EXISTS `income_sources` (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `nama_sumber` varchar(150) NOT NULL COMMENT 'Nama sumber pemasukan (Sponsor, Donasi, Hadiah, dll)',
  `deskripsi` text COMMENT 'Deskripsi detail sumber pemasukan',
  `jumlah` decimal(15,2) NOT NULL COMMENT 'Jumlah uang masuk',
  `kas_account_id` int NOT NULL COMMENT 'ID kas yang menerima',
  `created_by` int NOT NULL COMMENT 'User yang mencatat pemasukan',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`kas_account_id`) REFERENCES `kas_accounts`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  
  INDEX `idx_kas_account_id` (`kas_account_id`),
  INDEX `idx_created_by` (`created_by`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Update kas_transactions to ensure saldo_setelah is correct
ALTER TABLE `kas_transactions` 
MODIFY COLUMN `sumber` varchar(255) COMMENT 'Sumber transaksi (nama_iuran, nama_pemasukan, nama_kategori_pengeluaran, dll)';
