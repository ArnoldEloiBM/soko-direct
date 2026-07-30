import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soko_direct/core/language/language_cubit.dart';
import 'package:soko_direct/core/role/role_cubit.dart';

void main() {
  group('LanguageCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    blocTest<LanguageCubit, AppLanguage>(
      'starts as English by default',
      build: () => LanguageCubit(),
      verify: (cubit) => expect(cubit.state, AppLanguage.english),
    );

    blocTest<LanguageCubit, AppLanguage>(
      'emits Kinyarwanda when setLanguage is called',
      build: () => LanguageCubit(),
      act: (cubit) => cubit.setLanguage(AppLanguage.kinyarwanda),
      expect: () => [AppLanguage.kinyarwanda],
    );

    test('persists language across a new cubit instance', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'rw'});
      final cubit = LanguageCubit();
      await Future.delayed(Duration.zero);
      expect(cubit.state, AppLanguage.kinyarwanda);
    });
  });

  group('RoleCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    blocTest<RoleCubit, UserRole>(
      'starts as none by default',
      build: () => RoleCubit(),
      verify: (cubit) => expect(cubit.state, UserRole.none),
    );

    blocTest<RoleCubit, UserRole>(
      'emits farmer when setRole is called with farmer',
      build: () => RoleCubit(),
      act: (cubit) => cubit.setRole(UserRole.farmer),
      expect: () => [UserRole.farmer],
    );

    test('persists role across a new cubit instance', () async {
      SharedPreferences.setMockInitialValues({'app_user_role': 'buyer'});
      final cubit = RoleCubit();
      await Future.delayed(Duration.zero);
      expect(cubit.state, UserRole.buyer);
    });
  });
}
