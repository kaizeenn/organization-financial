// Helper function for audit logging
const createAuditLog = async (pool, userId, aksi, tabel, dataId = null) => {
  try {
    await pool.execute(
      'INSERT INTO audit_logs (user_id, aksi, tabel, data_id) VALUES (?, ?, ?, ?)',
      [userId, aksi, tabel, dataId]
    );
  } catch (error) {
    console.error('Audit log error:', error);
  }
};

// Format currency to IDR
const formatRupiah = (amount) => {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0
  }).format(amount);
};

// Format date to Indonesian format
const formatDate = (date) => {
  return new Intl.DateTimeFormat('id-ID', {
    day: '2-digit',
    month: 'long',
    year: 'numeric'
  }).format(new Date(date));
};

// Check if user has permission
const hasPermission = (userRole, allowedRoles) => {
  return allowedRoles.includes(userRole);
};

// Generate periode for iuran (format: YYYY-MM)
const getCurrentPeriode = () => {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  return `${year}-${month}`;
};

// Calculate sisa anggaran
const calculateSisaAnggaran = (anggaran, realisasi) => {
  return parseFloat(anggaran) - parseFloat(realisasi);
};

module.exports = {
  createAuditLog,
  formatRupiah,
  formatDate,
  hasPermission,
  getCurrentPeriode,
  calculateSisaAnggaran
};
