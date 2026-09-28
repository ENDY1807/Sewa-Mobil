import 'user_role.dart';

/// Pure domain entity representing an authenticated user profile in CarRent.
class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role.isAdmin;
  bool get isStaffOrAdmin => role.isStaffOrAdmin;

  String get initials {
    if (fullName.trim().isEmpty) {
      return email.isNotEmpty ? email.substring(0, 1).toUpperCase() : 'U';
    }
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
