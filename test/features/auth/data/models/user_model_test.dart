import 'package:easybook_app/features/auth/data/models/auth_result_model.dart';
import 'package:easybook_app/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/auth_fixtures.dart';

void main() {
  test('UserModel reads the API user and converts it to an entity', () {
    final user = UserModel.fromJson(tUserJson).toEntity();
    expect(user, tUser);
    expect(user.createdAt.isUtc, isTrue);
  });

  test('UserModel accepts a null phone', () {
    final json = {...tUserJson, 'phone': null};
    expect(UserModel.fromJson(json).toEntity().phone, isNull);
  });

  test('AuthResultModel reads the user and the token', () {
    final result = AuthResultModel.fromJson({
      'user': tUserJson,
      'token': tToken,
    });
    expect(result.token, tToken);
    expect(result.user.toEntity(), tUser);
  });

  test('User has initials and a first name for the UI', () {
    expect(tUser.initials, 'DU');
    expect(tUser.firstName, 'Demo');
  });
}
