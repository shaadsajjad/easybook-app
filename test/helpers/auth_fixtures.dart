import 'package:easybook_app/features/auth/domain/entities/user.dart';

/// A user exactly as `GET /users/me` returns it (docs/API.md).
const Map<String, dynamic> tUserJson = {
  'id': '1dd058fe-a3f7-4a74-8d13-d82c020f1de5',
  'name': 'Demo User',
  'email': 'demo@example.com',
  'phone': '+8801700000000',
  'createdAt': '2026-11-16T15:12:36.469Z',
  'updatedAt': '2026-11-16T15:12:41.547Z',
};

final User tUser = User(
  id: '1dd058fe-a3f7-4a74-8d13-d82c020f1de5',
  name: 'Demo User',
  email: 'demo@example.com',
  phone: '+8801700000000',
  createdAt: DateTime.utc(2026, 11, 16, 15, 12, 36, 469),
);

/// The same user after a profile edit.
final User tRenamedUser = User(
  id: tUser.id,
  name: 'New Name',
  email: tUser.email,
  phone: tUser.phone,
  createdAt: tUser.createdAt,
);

/// A user who has not added a phone number.
final User tRenamedUserWithoutPhone = User(
  id: tUser.id,
  name: 'New Name',
  email: tUser.email,
  createdAt: tUser.createdAt,
);

const String tToken = 'header.payload.signature';
