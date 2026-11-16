import 'package:easybook_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:easybook_app/features/profile/domain/usecases/update_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/auth_fixtures.dart';

class _MockRepository extends Mock implements ProfileRepository;

void main() {
  late _MockRepository repository;
  late UpdateProfile updateProfile;

  setUp(() {
    repository = _MockRepository();
    updateProfile = UpdateProfile(repository);
    when(
      () => repository.updateProfile(
        name: any(named: 'name'),
        phone: any(named: 'phone'),
      ),
    ).thenAnswer((_) async => Right(tUser));
  });

  test('trims the name and phone', () async {
    await updateProfile(
      const UpdateProfileParams(name: ' Ayesha ', phone: ' +880171 '),
    );
    verify(() => repository.updateProfile(name: 'Ayesha', phone: '+880171'))
        .called(1);
  });

  test('an empty phone removes the number', () async {
    await updateProfile(const UpdateProfileParams(name: 'Ayesha', phone: ' '));
    verify(() => repository.updateProfile(name: 'Ayesha')).called(1);
  });
}
