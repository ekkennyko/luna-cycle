// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeAppTitle => 'Luna';

  @override
  String get homeCycleTracker => 'CYCLE TRACKER';

  @override
  String get homeDayLabel => 'DAY';

  @override
  String get homeTapToLog => 'Tap to log';

  @override
  String get homeYourFirstPeriod => 'your first period';

  @override
  String get homePeriodActive => 'Period active';

  @override
  String get homePeriodExpectedToday => 'Period expected today';

  @override
  String get homeEndPeriod => 'End Period';

  @override
  String get homeLogPeriod => 'Log period';

  @override
  String get homePeriod => 'Period';

  @override
  String get homeMood => 'Mood';

  @override
  String get homeSymptoms => 'Symptoms';

  @override
  String get homePhaseSuffix => ' PHASE';

  @override
  String get homeCycleLength => 'Cycle length';

  @override
  String get homePeriodStat => 'Period';

  @override
  String get homeAvgLength => 'Avg length';

  @override
  String get homeLongerThanUsual => 'Your period is longer than usual.';

  @override
  String get homeLogToKeepAccurate => 'Did your period start? Log it to keep predictions accurate.';

  @override
  String get homeNotYet => 'Not yet';

  @override
  String get homeLogPeriodTitle => 'Log Period';

  @override
  String get homeFlowIntensity => 'FLOW INTENSITY';

  @override
  String get homeStartPeriodButton => '🩸 Start Period';

  @override
  String get homeEndPeriodTitle => 'End Period?';

  @override
  String get homeWhenDidPeriodEnd => 'When did your period end?';

  @override
  String get homeYesterday => 'Yesterday';

  @override
  String get homeToday => 'Today';

  @override
  String get homePickADate => 'Pick a date';

  @override
  String get homeTapToSelect => 'Tap to select';

  @override
  String get homeCancel => 'Cancel';

  @override
  String get homeSaving => 'Saving…';

  @override
  String get homeEndPeriodButton => '✓ End Period';

  @override
  String get homeHowAreYouFeeling => 'How are you feeling?';

  @override
  String get homeLogSymptoms => 'Log Symptoms';

  @override
  String get homeSave => 'Save';

  @override
  String get homePhaseMenstrual => 'Menstrual';

  @override
  String get homePhaseFollicular => 'Follicular';

  @override
  String get homePhaseOvulation => 'Ovulation';

  @override
  String get homePhaseLuteal => 'Luteal';

  @override
  String get homeMenstrualTip =>
      'Your body is releasing. Rest, use warmth, and be gentle with yourself. Iron-rich foods like spinach and lentils can help replenish.';

  @override
  String get homeFollicularTip =>
      'Estrogen is rising — your energy and creativity are building. Great time to start new projects and try challenging workouts.';

  @override
  String get homeOvulationTip =>
      'Peak energy and confidence! You\'re magnetic right now. Ideal for social events, big presentations, and high-intensity exercise.';

  @override
  String get homeLutealTip => 'Progesterone peaks then drops. Prioritize sleep, magnesium-rich foods, and reduce caffeine. Self-care is not optional.';

  @override
  String get homeIntensityLight => 'Light';

  @override
  String get homeIntensityMedium => 'Medium';

  @override
  String get homeIntensityHeavy => 'Heavy';

  @override
  String get homeIntensityVeryHeavy => 'Very Heavy';

  @override
  String get homeSymptomCramps => 'Cramps';

  @override
  String get homeSymptomBloating => 'Bloating';

  @override
  String get homeSymptomHeadache => 'Headache';

  @override
  String get homeSymptomFatigue => 'Fatigue';

  @override
  String get homeSymptomBreastTenderness => 'Breast tenderness';

  @override
  String get homeSymptomMoodSwings => 'Mood swings';

  @override
  String get homeSymptomSpotting => 'Spotting';

  @override
  String get homeSymptomNausea => 'Nausea';

  @override
  String get homeSymptomBackPain => 'Back pain';

  @override
  String get homeSymptomAcne => 'Acne';

  @override
  String homeDayOfPeriod(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String homeDayNumber(int day) {
    return 'Day $day';
  }

  @override
  String homeDaysLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$count $_temp0 late';
  }

  @override
  String homePeriodInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return 'Period in $count $_temp0';
  }

  @override
  String homeSymptomsCount(int count) {
    return '$count symptoms';
  }

  @override
  String homeSaveCount(int count) {
    return 'Save ($count selected)';
  }

  @override
  String homePeriodLate(int count) {
    return 'Your period is $count days late. This is normal — cycles vary.';
  }

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarCycleHistory => 'CYCLE HISTORY';

  @override
  String get calendarLegendPeriod => 'Period';

  @override
  String get calendarLegendPredicted => 'Predicted';

  @override
  String get calendarLegendFollicular => 'Follicular';

  @override
  String get calendarLegendOvulation => 'Ovulation';

  @override
  String get calendarLegendLuteal => 'Luteal';

  @override
  String get calendarPhaseSuffix => ' phase';

  @override
  String get calendarPredictedPeriod => 'Predicted period';

  @override
  String get calendarPeriodBadge => '🩸 Period';

  @override
  String get calendarNothingLogged => 'Nothing logged this day';

  @override
  String get calendarMoodLabel => 'MOOD';

  @override
  String get calendarSymptomsLabel => 'SYMPTOMS';

  @override
  String get onboardingAppTitle => 'Luna';

  @override
  String get onboardingStep0Title => 'Tell us about your\nlast period';

  @override
  String get onboardingStep0Subtitle => 'Enter the start and end dates — Luna will calculate everything automatically.';

  @override
  String get onboardingWhenDidItStart => 'When did it start?';

  @override
  String get onboardingWhenDidItEnd => 'When did it end?';

  @override
  String get onboardingStillOngoing => 'Still ongoing';

  @override
  String get onboardingPrivacyNotice => 'Your data is stored only on your device. Luna never sends it anywhere.';

  @override
  String get onboardingStartFreshLink => 'I don\'t remember — start fresh';

  @override
  String get onboardingStartFreshDialogBody => 'You can always log your first period later.\nLuna will start tracking from your next period.';

  @override
  String get onboardingCancel => 'Cancel';

  @override
  String get onboardingStartFresh => 'Start fresh';

  @override
  String get onboardingStep1Title => 'One more for accuracy';

  @override
  String get onboardingStep1Subtitle => 'When did the period before that start? Luna will calculate your cycle length from real dates.';

  @override
  String get onboardingPrevPeriodStart => 'Previous period — start date';

  @override
  String get onboardingPrevPeriodEnd => 'Previous period — end date';

  @override
  String get onboardingPreview => 'PREVIEW';

  @override
  String get onboardingPeriodLength => 'Period length';

  @override
  String get onboardingCycleLength => 'Cycle length';

  @override
  String get onboardingAddDateAbove => 'Add date above';

  @override
  String get onboardingDidYouKnow => '💡 Did you know?';

  @override
  String get onboardingDidYouKnowBody => 'Only 13% of people have exactly 28-day cycles. Real data gives you real predictions.';

  @override
  String get onboardingSaving => 'Saving…';

  @override
  String get onboardingGetStarted => 'Get started →';

  @override
  String get onboardingContinue => 'Continue →';

  @override
  String get onboardingBack => '← Back';

  @override
  String get onboardingSkip => 'Skip →';

  @override
  String get onboardingAllSet => 'You\'re all set!';

  @override
  String get onboardingCompletionSubtitle => 'Luna is ready to track your cycle.\nYour data stays private on your device.';

  @override
  String get onboardingLastPeriodStarted => 'Last period started';

  @override
  String get onboardingStartTracking => 'Start tracking →';

  @override
  String get onboardingTapToSelect => 'Tap to select';

  @override
  String get onboardingOptional => 'optional';

  @override
  String onboardingDayPeriod(int count) {
    return '$count day period — got it!';
  }

  @override
  String onboardingDays(int count) {
    return '$count days';
  }

  @override
  String onboardingDayCycleCalculated(int count) {
    return '$count day cycle — calculated from your data ✓';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsUpgradeToPremium => 'Upgrade to Premium';

  @override
  String get settingsUpgradeSubtitle => 'Analytics, widget, backup and more';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsCycle => 'Cycle';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsDebug => 'Debug';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsBiometricsPin => 'Biometrics / PIN';

  @override
  String get settingsCreateBackup => 'Create backup';

  @override
  String get settingsEncryptedFile => 'Encrypted .luna file';

  @override
  String get settingsRestoreFromBackup => 'Restore from backup';

  @override
  String get settingsCycleSettings => 'Cycle settings';

  @override
  String get settingsCycleLengthSubtitle => 'Average length, period length';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsResetProfile => 'Reset profile';

  @override
  String get settingsDeleteAllData => 'Delete all cycle data';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsResetProfileQuestion => 'Reset profile?';

  @override
  String get settingsResetDialogBody => 'All cycle entries, symptom logs and pregnancies will be deleted. This cannot be undone.';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsReset => 'Reset';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get paywallLunaPremium => 'Luna Premium';

  @override
  String get paywallSubtitle => 'Unlock the full Luna experience';

  @override
  String get paywallAdvancedAnalytics => 'Advanced analytics';

  @override
  String get paywallAnalyticsSubtitle => 'Charts, trends, symptoms by phase';

  @override
  String get paywallCustomSymptoms => 'Custom symptoms';

  @override
  String get paywallCustomSymptomsSubtitle => 'Add your own symptoms';

  @override
  String get paywallPregnancyTracker => 'Pregnancy tracker';

  @override
  String get paywallPregnancySubtitle => 'Week by week';

  @override
  String get paywallHomeWidget => 'Home screen widget';

  @override
  String get paywallHomeWidgetSubtitle => 'Cycle day at a glance';

  @override
  String get paywallEncryptedBackup => 'Encrypted backup';

  @override
  String get paywallBackupSubtitle => 'Your data, safe and private';

  @override
  String get paywallYearly => 'Yearly';

  @override
  String get paywallSave44 => 'Save 44%';

  @override
  String get paywallMonthly => 'Monthly';

  @override
  String get paywallRestorePurchases => 'Restore purchases';

  @override
  String paywallFailed(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get paywallTitle => 'Luna Premium';

  @override
  String get paywallTrialBadge => '7-day free trial — cancel anytime';

  @override
  String get paywallFeatureAnalytics => 'Advanced Analytics';

  @override
  String get paywallFeatureAnalyticsSubtitle => 'Charts, patterns, insights';

  @override
  String get paywallFeatureWidget => 'Home Screen Widget';

  @override
  String get paywallFeatureWidgetSubtitle => 'Cycle at a glance';

  @override
  String get paywallFeaturePregnancy => 'Pregnancy Tracker';

  @override
  String get paywallFeaturePregnancySubtitle => 'Week by week journey';

  @override
  String get paywallFeatureExport => 'Export PDF';

  @override
  String get paywallFeatureExportSubtitle => 'Share with your doctor';

  @override
  String get paywallBestValue => 'BEST VALUE';

  @override
  String get paywallPerMonth => '/ mo';

  @override
  String paywallFinePrint(String price) {
    return 'After free trial, $price. Cancel anytime in App Store / Google Play.';
  }

  @override
  String get paywallCta => 'Start 7-Day Free Trial';

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallPrivacyPolicy => 'Privacy Policy';

  @override
  String get paywallTerms => 'Terms of Use';

  @override
  String get paywallSuccessTitle => 'Welcome to Premium!';

  @override
  String get paywallSuccessSubtitle => 'All features are now unlocked.\nEnjoy your Luna Premium experience.';

  @override
  String get paywallContinue => 'Continue →';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsPremiumTitle => 'Analytics — Premium';

  @override
  String get analyticsPremiumBody => 'Cycle charts, phase symptoms and predictions are available with a Premium subscription.';

  @override
  String get analyticsTryPremium => 'Try Premium';

  @override
  String get analyticsComingSoon => 'Cycle charts — coming soon';

  @override
  String get logPeriod => 'Period';

  @override
  String get logFirstDayOngoing => 'First day / ongoing';

  @override
  String get logFlowIntensity => 'Flow intensity';

  @override
  String get logSave => 'Save';

  @override
  String get logFlowSpotting => 'Spotting';

  @override
  String get logFlowLight => 'Light';

  @override
  String get logFlowHeavy => 'Heavy';

  @override
  String get logFlowVeryHeavy => 'Very\nheavy';

  @override
  String get navCycle => 'Cycle';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navSettings => 'Settings';

  @override
  String get moodLow => 'Low';

  @override
  String get moodOkay => 'Okay';

  @override
  String get moodGood => 'Good';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodAmazing => 'Amazing';

  @override
  String get symptomHappy => 'Happy';

  @override
  String get symptomIrritable => 'Irritable';

  @override
  String get symptomAnxious => 'Anxious';

  @override
  String get symptomSad => 'Sad';

  @override
  String get symptomHighEnergy => 'High energy';

  @override
  String get symptomInsomnia => 'Insomnia';

  @override
  String get symptomDiarrhea => 'Diarrhea';

  @override
  String get symptomConstipation => 'Constipation';

  @override
  String get symptomDrySkin => 'Dry skin';

  @override
  String notificationPeriodReminder(int days) {
    return 'Your period is expected in $days days';
  }

  @override
  String get notificationFertileWindow => 'Your fertile window starts today';

  @override
  String notificationLatePeriod(int days) {
    return 'Your period is $days days late';
  }

  @override
  String get notificationLunaPrivate => 'Luna';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPeriodReminder => 'Period reminder';

  @override
  String get settingsPeriodReminderSubtitle => 'Remind before your period';

  @override
  String get settingsFertileWindow => 'Fertile window';

  @override
  String get settingsFertileWindowSubtitle => 'Notify when fertile window starts';

  @override
  String get settingsLatePeriod => 'Late period';

  @override
  String get settingsLatePeriodSubtitle => 'Notify when period is late';

  @override
  String settingsReminderDays(int days) {
    return '$days days before';
  }
}
