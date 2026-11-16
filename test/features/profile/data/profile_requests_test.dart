import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/error/exceptions.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:easybook_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/auth_fixtures.dart';

class _MockDio extends Mock implements Dio;

Response<Object?> _ok(Object? data) => Response(
  requestOptions: RequestOptions(),
  statusCode: 200,
  data: {'success': true, 'data': data},
);

void main() {
  late _MockDio dio;
  late ProfileRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = ProfileRepositoryImpl(ProfileRemoteDataSource(dio));
  });

  group('updateProfile', () {
    test('sends name and phone and returns the updated user', () async {
      when(() => dio.patch<Object?>(ApiEndpoints.me, data: any(named: 'data')))
          .thenAnswer((_) async => _ok(tUserJson));

      final result = await repository.updateProfile(
        name: 'Demo User',
        phone: '+8801700000000',
      );

      expect(result.getRight().toNullable(), tUser);
      verify(
        () => dio.patch<Object?>(
          ApiEndpoints.me,
          data: {'name': 'Demo User', 'phone': '+8801700000000'},
        ),
      ).called(1);
    });

    test('sends phone: null to remove the number', () async {
      when(() => dio.patch<Object?>(ApiEndpoints.me, data: any(named: 'data')))
          .thenAnswer((_) async => _ok({...tUserJson, 'phone': null}));

      final result = await repository.updateProfile(name: 'Demo User');

      expect(result.getRight().toNullable()?.phone, isNull);
      verify(
        () => dio.patch<Object?>(
          ApiEndpoints.me,
          data: {'name': 'Demo User', 'phone': null},
        ),
      ).called(1);
    });

    test('maps a 422 to a ValidationFailure with field messages', () async {
      when(() => dio.patch<Object?>(any(), data: any(named: 'data'))).thenThrow(
        const ApiException(
          statusCode: 422,
          message: 'Validation failed',
          fieldErrors: {
            'phone': ['Enter a valid phone number'],
          },
        ),
      );

      final failure = (await repository.updateProfile(
        name: 'A B',
        phone: 'x',
      )).getLeft().toNullable();

      expect(
        (failure! as ValidationFailure).errorFor('phone'),
        'Enter a valid phone number',
      );
    });
  });

  group('changePassword', () {
    test('sends both passwords', () async {
      when(
        () => dio.patch<Object?>(
          ApiEndpoints.changePassword,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _ok(null));

      final result = await repository.changePassword(
        currentPassword: 'OldPass123',
        newPassword: 'NewPass456',
      );

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => dio.patch<Object?>(
          ApiEndpoints.changePassword,
          data: {'currentPassword': 'OldPass123', 'newPassword': 'NewPass456'},
        ),
      ).called(1);
    });

    test('a wrong current password is a 422 on currentPassword', () async {
      when(() => dio.patch<Object?>(any(), data: any(named: 'data'))).thenThrow(
        const ApiException(
          statusCode: 422,
          message: 'Current password is incorrect',
          fieldErrors: {
            'currentPassword': ['Current password is incorrect'],
          },
        ),
      );

      final failure = (await repository.changePassword(
        currentPassword: 'wrong',
        newPassword: 'NewPass456',
      )).getLeft().toNullable();

      expect(failure, isA<ValidationFailure>());
      expect(
        (failure! as ValidationFailure).errorFor('currentPassword'),
        'Current password is incorrect',
      );
    });
  });
}
