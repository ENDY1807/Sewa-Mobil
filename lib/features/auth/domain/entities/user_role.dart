/// User role enumeration matching the Supabase PostgreSQL `user_role` ENUM.
enum UserRole {
  user,
  staff,
  admin;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase().trim()) {
      case 'admin':
        return UserRole.admin;
      case 'staff':
        return UserRole.staff;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  String get dbValue {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.staff:
        return 'staff';
      case UserRole.user:
        return 'user';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.staff:
        return 'Staff Operasional';
      case UserRole.user:
        return 'Pelanggan';
    }
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isStaff => this == UserRole.staff;
  bool get isStaffOrAdmin => this == UserRole.staff || this == UserRole.admin;

  // Granular Permissions
  bool get canManageCars => isStaffOrAdmin;
  bool get canManageBookings => isStaffOrAdmin;
  bool get canManageUsers => isAdmin;
  bool get canManagePromotions => isAdmin;
  bool get canViewAuditLogs => isAdmin;
  bool get canViewReports => isStaffOrAdmin;
}
