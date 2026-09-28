/// Centralized UI string constants for internationalization and consistent labeling.
class AppStrings {
  AppStrings._();

  // App Identity
  static const String appName = 'CarRent';
  static const String appTagline = 'Sewa Mobil Premium & Terpercaya';

  // Navigation
  static const String navHome = 'Beranda';
  static const String navExplore = 'Eksplor';
  static const String navBookings = 'Pesanan';
  static const String navFavorites = 'Favorit';
  static const String navProfile = 'Profil';
  static const String navAdmin = 'Admin Dashboard';

  // Actions
  static const String rentNow = 'Sewa Sekarang';
  static const String bookVehicle = 'Pesan Mobil';
  static const String viewDetails = 'Lihat Detail';
  static const String searchPlaceholder = 'Cari brand, model, transmisi...';
  static const String filter = 'Filter';
  static const String applyFilter = 'Terapkan Filter';
  static const String resetFilter = 'Reset';
  static const String retry = 'Coba Lagi';
  static const String confirm = 'Konfirmasi';
  static const String cancel = 'Batal';
  static const String save = 'Simpan';
  static const String delete = 'Hapus';
  static const String edit = 'Ubah';

  // Statuses
  static const String statusAvailable = 'Tersedia';
  static const String statusRented = 'Disewa';
  static const String statusReserved = 'Dipesan';
  static const String statusMaintenance = 'Perawatan';
  static const String statusUnavailable = 'Tidak Tersedia';

  // Booking Statuses
  static const String bookingPending = 'Menunggu Pembayaran';
  static const String bookingConfirmed = 'Dikonfirmasi';
  static const String bookingOngoing = 'Sedang Berjalan';
  static const String bookingCompleted = 'Selesai';
  static const String bookingCancelled = 'Dibatalkan';
  static const String bookingRejected = 'Ditolak';

  // Units
  static const String perDay = '/hari';
  static const String perWeek = '/minggu';
  static const String perMonth = '/bulan';
  static const String seatsUnit = 'Kursi';
  static const String doorsUnit = 'Pintu';

  // Empty & Error States
  static const String emptyCarsTitle = 'Mobil Tidak Ditemukan';
  static const String emptyCarsSubtitle = 'Coba sesuaikan filter pencarian atau lokasi Anda.';
  static const String emptyBookingsTitle = 'Belum Ada Pesanan';
  static const String emptyBookingsSubtitle = 'Mobil impian Anda menunggu untuk disewa.';
  static const String emptyFavoritesTitle = 'Belum Ada Mobil Favorit';
  static const String emptyFavoritesSubtitle = 'Simpan kendaraan impian dengan menekan ikon hati.';
  static const String defaultErrorTitle = 'Terjadi Kesalahan';
  static const String networkErrorMessage = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
}
