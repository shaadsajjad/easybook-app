import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/error/exceptions.dart';
import 'package:easybook_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_fixtures.dart';

class _MockDio extends Mock implements Dio;

Response<Object?> _ok(Object? body) =>
    Response(requestOptions: RequestOptions(), statusCode: 200, data: body);

void main() {
  late _MockDio dio;
  late AuthRemoteDataSource dataSource;

  setUp(() {
    dio = _MockDio();
    dataSource = AuthRemoteDataSource(dio);
  });

  test('login posts the credentials and reads user + token', () async {
    when(() => dio.post<Object?>(ApiEndpoints.login, data: any(named: 'data')))
        .thenAnswer(
          (_) async => _ok({
            'success': true,
            'data': {'user': tUserJson, 'token': tToken},
          }),
        );

    final result = await dataSource.login(
      email: 'demo@example.com',
      password: 'Demo1234',
    );

    expect(result.token, tToken);
    verify(
      () => dio.post<Object?>(
        ApiEndpoints.login,
        data: {'email': 'demo@example.com', 'password': 'Demo1234'},
      ),
    ).called(1);
  });

  test('register posts name, email and password', () async {
    when(
      () => dio.post<Object?>(ApiEndpoints.register, data: any(named: 'data')),
    ).thenAnswer(
      (_) async => _ok({
        'success': true,
        'data': {'user': tUserJson, 'token': tToken},
      }),
    );

    await dataSource.register(
      name: 'Demo User',
      email: 'demo@example.com',
      password: 'Demo1234',
    );

    verify(
      () => dio.post<Object?>(
        ApiEndpoints.register,
        data: {
          'name': 'Demo User',
          'email': 'demo@example.com',
          'password': 'Demo1234',
        },
      ),
    ).called(1);
  });

  test('getCurrentUser reads the profile', () async {
    when(() => dio.get<Object?>(ApiEndpoints.me))
        .thenAnswer((_) async => _ok({'success': true, 'data': tUserJson}));
    final user = await dataSource.getCurrentUser();
    expect(user.email, 'demo@example.com');
  });

  test('checkHealth calls GET /health', () async {
    when(() => dio.get<Object?>(ApiEndpoints.health)).thenAnswer(
      (_) async => _ok({
        'success': true,
        'data': {'status': 'ok', 'uptime': 2},
      }),
    );
    await dataSource.checkHealth();
    verify(() => dio.get<Object?>(ApiEndpoints.health)).called(1);
  });

  test('throws ParsingException when data is missing', () async {
    when(() => dio.get<Object?>(ApiEndpoints.me))
        .thenAnswer((_) async => _ok({'success': true}));
    expect(dataSource.getCurrentUser, throwsA(isA<ParsingException>()));
  });
}
