import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../utils/logger.dart';
import 'app_exception.dart';

/// Centralized error handler to prevent showing raw stack traces to end users.
class ErrorHandler {
  ErrorHandler._();

  static AppException handleError(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.e('Error intercepted by ErrorHandler: $error', error, stackTrace);

    if (error is AppException) {
      return error;
    }

    if (error is supa.AuthException) {
      if (error.message.toLowerCase().contains('invalid login credentials')) {
        return const AuthException('Email atau kata sandi tidak valid.');
      }
      if (error.message.toLowerCase().contains('email already in use') ||
          error.message.toLowerCase().contains('already registered')) {
        return const AuthException('Email ini sudah terdaftar.');
      }
      return AuthException(error.message, code: error.statusCode, originalError: error);
    }

    if (error is supa.PostgrestException) {
      if (error.code == 'P0001' || error.message.contains('conflict') || error.message.contains('overlapping')) {
        return const BookingConflictException();
      }
      if (error.code == '42501' || error.message.contains('permission denied') || error.message.contains('row-level security')) {
        return const ForbiddenException();
      }
      return ServerException(error.message, error);
    }

    if (error is SocketException) {
      return const NetworkException();
    }

    return ServerException(error.toString(), error);
  }

  static String getDisplayMessage(dynamic error) {
    final appException = handleError(error);
    return appException.message;
  }
}
