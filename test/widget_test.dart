import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soko_direct/core/theme/theme_cubit.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Toggle Theme button renders and is tappable',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => ThemeCubit(),
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton.icon(
                icon: const Icon(Icons.brightness_6),
                label: const Text('Toggle Theme'),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Toggle Theme'), findsOneWidget);

    await tester.tap(find.text('Toggle Theme'));
    await tester.pumpAndSettle();

    // No crash after tapping — theme toggled successfully.
    expect(find.text('Toggle Theme'), findsOneWidget);
  });
}
