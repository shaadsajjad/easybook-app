import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/error/exceptions.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/ai_assistant/data/datasources/chat_remote_data_source.dart';
import 'package:easybook_app/features/ai_assistant/data/models/chat_reply_model.dart';
import 'package:easybook_app/features/ai_assistant/data/repositories/chat_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/chat_fixtures.dart';

class _MockDio extends Mock implements Dio;

void main() {
  late _MockDio dio;
  late ChatRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(Options()));

  setUp(() {
    dio = _MockDio();
    repository = ChatRepositoryImpl(ChatRemoteDataSource(dio));
  });

  void stubReply() {
    when(
      () => dio.post<Object?>(
        ApiEndpoints.aiChat,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: {'success': true, 'data': tChatReplyJson},
      ),
    );
  }

  test('reads the reply and the suggested services', () {
    expect(ChatReplyModel.fromJson(tChatReplyJson).toEntity(), tAssistantReply);
  });

  test('an empty suggestion list is fine', () {
    final reply = ChatReplyModel.fromJson({
      'reply': 'I can only help with EasyBook services.',
      'suggestedServices': <Object>[],
    }).toEntity();
    expect(reply.suggestions, isEmpty);
  });

  test('sends the message and history as role/content pairs', () async {
    stubReply();

    final result = await repository.sendMessage(
      message: 'Anything cheaper?',
      history: const [tQuestion, tAssistantReply],
    );

    expect(result.getRight().toNullable(), tAssistantReply);
    final captured = verify(
      () => dio.post<Object?>(
        ApiEndpoints.aiChat,
        data: captureAny(named: 'data'),
        options: captureAny(named: 'options'),
      ),
    ).captured;
    expect(captured[0], {
      'message': 'Anything cheaper?',
      'history': [
        {'role': 'user', 'content': 'I have a stiff back.'},
        {'role': 'assistant', 'content': tAssistantReply.text},
      ],
    });
    // AI answers can take longer than normal requests.
    expect(
      (captured[1] as Options).receiveTimeout,
      AppConstants.chatReceiveTimeout,
    );
  });

  test(
    'maps busy, down and rate-limited answers to friendly failures',
    () async {
      final cases = <int, Type>{
        429: RateLimitFailure,
        502: ServiceUnavailableFailure,
        503: ServiceUnavailableFailure,
      };
      for (final MapEntry(key: status, value: type) in cases.entries) {
        when(
          () => dio.post<Object?>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          ApiException(statusCode: status, message: 'Please try again.'),
        );

        final failure = (await repository.sendMessage(
          message: 'hi',
          history: const [],
        )).getLeft().toNullable();

        expect(failure.runtimeType, type, reason: '$status');
        expect(failure?.message, 'Please try again.');
      }
    },
  );
}
