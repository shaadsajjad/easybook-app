import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/auth/domain/usecases/wake_server.dart';
import 'package:easybook_app/features/auth/presentation/bloc/splash_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockWakeServer extends Mock implements WakeServer;

void main() {
  late _MockWakeServer wakeServer;

  setUp(() => wakeServer = _MockWakeServer());

  blocTest<SplashCubit, SplashState>(
    'shows no hint when the server answers quickly',
    setUp: () =>
        when(() => wakeServer()).thenAnswer((_) async => const Right(unit)),
    build: () => SplashCubit(
      wakeServer: wakeServer,
      hintDelay: const Duration(seconds: 1),
    ),
    act: (cubit) => cubit.start(),
    wait: const Duration(milliseconds: 20),
    expect: () => <SplashState>[],
  );

  blocTest<SplashCubit, SplashState>(
    'shows the wake-up hint when the server is slow, then hides it',
    setUp: () => when(() => wakeServer()).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return const Right(unit);
    }),
    build: () => SplashCubit(
      wakeServer: wakeServer,
      hintDelay: const Duration(milliseconds: 5),
    ),
    act: (cubit) => cubit.start(),
    expect: () => [
      const SplashState(showWakeUpHint: true),
      const SplashState(),
    ],
  );

  blocTest<SplashCubit, SplashState>(
    'hides the hint when the health check fails too',
    setUp: () => when(() => wakeServer()).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return const Left(NetworkFailure());
    }),
    build: () => SplashCubit(
      wakeServer: wakeServer,
      hintDelay: const Duration(milliseconds: 5),
    ),
    act: (cubit) => cubit.start(),
    expect: () => [
      const SplashState(showWakeUpHint: true),
      const SplashState(),
    ],
  );

  test('does not emit after being closed', () async {
    final completer = Completer<Either<Failure, Unit>>();
    when(() => wakeServer()).thenAnswer((_) => completer.future);
    final cubit = SplashCubit(
      wakeServer: wakeServer,
      hintDelay: const Duration(milliseconds: 5),
    );

    final started = cubit.start();
    await cubit.close();
    completer.complete(const Right(unit));
    await started;

    expect(cubit.state, const SplashState());
  });
}
