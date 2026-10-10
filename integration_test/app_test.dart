import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:luna/core/constants/mood_data.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:luna/l10n/app_localizations.dart';
import 'package:luna/main.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

final _shotKey = GlobalKey();
final _shotDir = Directory('${Directory.current.path}/build/integration_screenshots');

// The app has looping animations, so pumpAndSettle would never return.
Future<void> settle(WidgetTester tester, {int frames = 15}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> shot(WidgetTester tester, String name) async {
  await settle(tester);
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_shotKey));
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('${_shotDir.path}/$name.png').writeAsBytes(png!.buffer.asUint8List());
  });
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).last);
  await settle(tester);
}

Future<void> tapDay(WidgetTester tester, int day) async {
  await tester.tap(find.descendant(of: find.byType(TableCalendar), matching: find.text('$day')));
  await settle(tester, frames: 5);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding, logging and every tab', (tester) async {
    final today = DateTime.now();
    if (today.day < 5) {
      markTestSkipped('The current period is picked as days 1-5 of this month, so today must be the 5th or later.');
      return;
    }
    _shotDir.createSync(recursive: true);
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      RepaintBoundary(
        key: _shotKey,
        child: ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const LunaApp(showOnboarding: true),
        ),
      ),
    );
    await settle(tester);
    final l10n = AppLocalizations.of(tester.element(find.byType(OnboardingScreen)))!;
    await shot(tester, '01_onboarding');

    // Current period: 1st to 5th of this month.
    await tapText(tester, l10n.onboardingSelectPeriodDates);
    await tapDay(tester, 1);
    await tapDay(tester, 5);
    await shot(tester, '02_date_picker');
    await tapText(tester, l10n.datePickerConfirm);
    expect(find.textContaining(l10n.onboardingDaysCount(5)), findsOneWidget);
    await tapText(tester, l10n.onboardingContinue);

    // Previous period: the picker opens on the previous month, 5 days are filled in automatically.
    await tapText(tester, l10n.onboardingSelectPeriodDates);
    await tapDay(tester, 1);
    await tapText(tester, l10n.datePickerConfirm);
    final previousMonthDays = DateTime(today.year, today.month, 0).day;
    expect(find.text(l10n.onboardingDays(previousMonthDays)), findsOneWidget);
    await shot(tester, '03_onboarding_step2');
    await tapText(tester, l10n.onboardingGetStarted);
    await settle(tester, frames: 20);
    await shot(tester, '04_onboarding_done');
    await tapText(tester, l10n.onboardingStartTracking);
    await settle(tester, frames: 20);

    final nextPeriod = DateTime(today.year, today.month, 1 + previousMonthDays);
    final daysUntil = nextPeriod.difference(DateTime(today.year, today.month, today.day)).inDays;
    expect(find.text(l10n.homePeriodInDays(daysUntil)), findsOneWidget);
    await shot(tester, '05_home');

    await tapText(tester, l10n.homeMood);
    await shot(tester, '06_mood_sheet');
    await tester.tap(find.text('😊'));
    await settle(tester, frames: 10);
    expect(find.text(l10n.moodLabel(3)), findsOneWidget);

    await tapText(tester, l10n.homeSymptoms);
    await tester.tap(find.text('Cramps'));
    await tester.tap(find.text('Headache'));
    await settle(tester, frames: 3);
    await shot(tester, '07_symptoms_sheet');
    await tapText(tester, l10n.homeSaveCount(2));
    await settle(tester, frames: 10);
    expect(find.text(l10n.homeSymptomsCount(2)), findsOneWidget);
    await shot(tester, '08_home_logged');

    await tapText(tester, 'Calendar');
    await shot(tester, '09_calendar');

    await tapText(tester, 'Analytics');
    expect(find.text(l10n.analyticsUnlock), findsWidgets);
    await shot(tester, '10_analytics');

    await tapText(tester, 'Settings');
    await shot(tester, '11_settings');
    await tapText(tester, l10n.settingsCreateBackup);
    expect(find.text(l10n.paywallCtaNoTrial), findsOneWidget);
    expect(find.text(l10n.paywallEncryptedBackup), findsOneWidget);
    await shot(tester, '12_paywall');
  });
}
