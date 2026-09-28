/// Base sealed exception hierarchy for clean error handling across layers.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class NetworkException extends AppException {
  const NetworkException({String message = 'Tidak dapat terhubung ke server. Periksa koneksi Anda.', dynamic originalError})
      : super(message, code: 'NETWORK_ERROR', originalError: originalError);
}

class AuthException extends AppException {
  const AuthException(String message, {String? code, dynamic originalError})
      : super(message, code: code ?? 'AUTH_ERROR', originalError: originalError);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Akses ditolak. Silakan login terlebih dahulu.'])
      : super(message, code: 'UNAUTHORIZED');
}

class ForbiddenException extends AppException {
  const ForbiddenException([String message = 'Anda tidak memiliki izin untuk mengakses halaman ini.'])
      : super(message, code: 'FORBIDDEN');
}

class BookingConflictException extends AppException {
  const BookingConflictException([String message = 'Mobil tidak tersedia untuk tanggal yang dipilih karena sudah terpesan.'])
      : super(message, code: 'BOOKING_CONFLICT');
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'Data yang diminta tidak ditemukan.'])
      : super(message, code: 'NOT_FOUND');
}

class ValidationException extends AppException {
  const ValidationException(String message)
      : super(message, code: 'VALIDATION_ERROR');
}

class ServerException extends AppException {
  const ServerException([String message = 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.', dynamic originalError])
      : super(message, code: 'SERVER_ERROR', originalError: originalError);
}
