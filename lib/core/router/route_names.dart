/// Route paths and names for GoRouter navigation.
class AppRoutes {
  AppRoutes._();

  // User App Routes
  static const String home = '/';
  static const String explore = '/explore';
  static const String carDetail = '/cars/:id';
  static const String booking = '/booking/:id';
  static const String bookingHistory = '/bookings';
  static const String bookingDetail = '/bookings/:id';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Admin Web Routes
  static const String adminDashboard = '/admin';
  static const String adminCars = '/admin/cars';
  static const String adminCarCreate = '/admin/cars/new';
  static const String adminCarEdit = '/admin/cars/:id/edit';
  static const String adminBrands = '/admin/brands';
  static const String adminCategories = '/admin/categories';
  static const String adminBookings = '/admin/bookings';
  static const String adminUsers = '/admin/users';
  static const String adminPromotions = '/admin/promotions';
  static const String adminReports = '/admin/reports';
  static const String adminAuditLogs = '/admin/audit-logs';
  static const String adminImporter = '/admin/importer';

  static const String payment = '/booking/:id/payment';
  static const String bookingReceipt = '/bookings/:id/receipt';

  // Helper helper to generate car detail path
  static String carDetailPath(String carId) => '/cars/$carId';
  static String bookingPath(String carId) => '/booking/$carId';
  static String bookingDetailPath(String bookingId) => '/bookings/$bookingId';
  static String bookingReceiptPath(String bookingId) => '/bookings/$bookingId/receipt';
  static String paymentPath(String bookingId) => '/booking/$bookingId/payment';
  static String adminCarEditPath(String carId) => '/admin/cars/$carId/edit';
}
