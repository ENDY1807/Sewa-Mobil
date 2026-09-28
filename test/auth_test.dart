import 'package:flutter_test/flutter_test.dart';
import 'package:sewamobil/features/auth/domain/entities/user_profile.dart';
import 'package:sewamobil/features/auth/domain/entities/user_role.dart';
import 'package:sewamobil/features/auth/data/models/user_profile_model.dart';

void main() {
  group('Phase 2 Authentication & UserRole Domain Tests', () {
    test('UserRole parsing handles all role strings and case-insensitivity', () {
      expect(UserRole.fromString('admin'), equals(UserRole.admin));
      expect(UserRole.fromString('ADMIN'), equals(UserRole.admin));
      expect(UserRole.fromString('staff'), equals(UserRole.staff));
      expect(UserRole.fromString('user'), equals(UserRole.user));
      expect(UserRole.fromString('unknown_role'), equals(UserRole.user));
      expect(UserRole.fromString(null), equals(UserRole.user));
    });

    test('UserRole permission matrix enforces security constraints', () {
      // Admin permissions
      expect(UserRole.admin.isAdmin, isTrue);
      expect(UserRole.admin.isStaffOrAdmin, isTrue);
      expect(UserRole.admin.canManageUsers, isTrue);
      expect(UserRole.admin.canManageCars, isTrue);
      expect(UserRole.admin.canManagePromotions, isTrue);
      expect(UserRole.admin.canViewAuditLogs, isTrue);

      // Staff permissions
      expect(UserRole.staff.isAdmin, isFalse);
      expect(UserRole.staff.isStaff, isTrue);
      expect(UserRole.staff.isStaffOrAdmin, isTrue);
      expect(UserRole.staff.canManageCars, isTrue);
      expect(UserRole.staff.canManageBookings, isTrue);
      expect(UserRole.staff.canManageUsers, isFalse); // Staff cannot manage users
      expect(UserRole.staff.canViewAuditLogs, isFalse); // Staff cannot view audit logs

      // User permissions
      expect(UserRole.user.isAdmin, isFalse);
      expect(UserRole.user.isStaff, isFalse);
      expect(UserRole.user.isStaffOrAdmin, isFalse);
      expect(UserRole.user.canManageCars, isFalse);
      expect(UserRole.user.canManageUsers, isFalse);
    });

    test('UserProfile generates appropriate initials for avatar', () {
      final multiWord = UserProfile(
        id: 'user-1',
        email: 'endy@example.com',
        fullName: 'Endy Pratama',
        role: UserRole.user,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(multiWord.initials, equals('EP'));

      final singleWord = UserProfile(
        id: 'user-2',
        email: 'endy@example.com',
        fullName: 'Administrator',
        role: UserRole.admin,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(singleWord.initials, equals('AD'));

      final emptyName = UserProfile(
        id: 'user-3',
        email: 'test@example.com',
        fullName: '',
        role: UserRole.user,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(emptyName.initials, equals('T'));
    });

    test('UserProfileModel JSON mapping serializes and deserializes accurately', () {
      final json = {
        'id': '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
        'email': 'admin@carrent.id',
        'full_name': 'Super Admin CarRent',
        'phone': '081299998888',
        'avatar_url': 'https://example.com/avatar.jpg',
        'role': 'admin',
        'created_at': '2026-09-29T05:00:00.000Z',
        'updated_at': '2026-09-29T05:00:00.000Z',
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.id, equals('9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d'));
      expect(model.email, equals('admin@carrent.id'));
      expect(model.fullName, equals('Super Admin CarRent'));
      expect(model.role, equals(UserRole.admin));
      expect(model.isAdmin, isTrue);

      final serialized = model.toJson();
      expect(serialized['id'], equals(model.id));
      expect(serialized['role'], equals('admin'));
    });
  });
}
