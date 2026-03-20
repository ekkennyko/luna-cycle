import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ru')];

  /// No description provided for @homeAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Luna'**
  String get homeAppTitle;

  /// No description provided for @homeCycleTracker.
  ///
  /// In en, this message translates to:
  /// **'CYCLE TRACKER'**
  String get homeCycleTracker;

  /// No description provided for @homeDayLabel.
  ///
  /// In en, this message translates to:
  /// **'DAY'**
  String get homeDayLabel;

  /// No description provided for @homeTapToLog.
  ///
  /// In en, this message translates to:
  /// **'Tap to log'**
  String get homeTapToLog;

  /// No description provided for @homeYourFirstPeriod.
  ///
  /// In en, this message translates to:
  /// **'your first period'**
  String get homeYourFirstPeriod;

  /// No description provided for @homePeriodActive.
  ///
  /// In en, this message translates to:
  /// **'Period active'**
  String get homePeriodActive;

  /// No description provided for @homePeriodExpectedToday.
  ///
  /// In en, this message translates to:
  /// **'Period expected today'**
  String get homePeriodExpectedToday;

  /// No description provided for @homeEndPeriod.
  ///
  /// In en, this message translates to:
  /// **'End Period'**
  String get homeEndPeriod;

  /// No description provided for @homeLogPeriod.
  ///
  /// In en, this message translates to:
  /// **'Log period'**
  String get homeLogPeriod;

  /// No description provided for @homePeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get homePeriod;

  /// No description provided for @homeMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get homeMood;

  /// No description provided for @homeSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get homeSymptoms;

  /// No description provided for @homePhaseSuffix.
  ///
  /// In en, this message translates to:
  /// **' PHASE'**
  String get homePhaseSuffix;

  /// No description provided for @homeCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle length'**
  String get homeCycleLength;

  /// No description provided for @homePeriodStat.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get homePeriodStat;

  /// No description provided for @homeAvgLength.
  ///
  /// In en, this message translates to:
  /// **'Avg length'**
  String get homeAvgLength;

  /// No description provided for @homeLongerThanUsual.
  ///
  /// In en, this message translates to:
  /// **'Your period is longer than usual.'**
  String get homeLongerThanUsual;

  /// No description provided for @homeLogToKeepAccurate.
  ///
  /// In en, this message translates to:
  /// **'Did your period start? Log it to keep predictions accurate.'**
  String get homeLogToKeepAccurate;

  /// No description provided for @homeNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get homeNotYet;

  /// No description provided for @homeLogPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Period'**
  String get homeLogPeriodTitle;

  /// No description provided for @homeFlowIntensity.
  ///
  /// In en, this message translates to:
  /// **'FLOW INTENSITY'**
  String get homeFlowIntensity;

  /// No description provided for @homeStartPeriodButton.
  ///
  /// In en, this message translates to:
  /// **'🩸 Start Period'**
  String get homeStartPeriodButton;

  /// No description provided for @homeEndPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'End Period?'**
  String get homeEndPeriodTitle;

  /// No description provided for @homeWhenDidPeriodEnd.
  ///
  /// In en, this message translates to:
  /// **'When did your period end?'**
  String get homeWhenDidPeriodEnd;

  /// No description provided for @homeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get homeYesterday;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homePickADate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get homePickADate;

  /// No description provided for @homeTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get homeTapToSelect;

  /// No description provided for @homeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeCancel;

  /// No description provided for @homeSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get homeSaving;

  /// No description provided for @homeEndPeriodButton.
  ///
  /// In en, this message translates to:
  /// **'✓ End Period'**
  String get homeEndPeriodButton;

  /// No description provided for @homeHowAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get homeHowAreYouFeeling;

  /// No description provided for @homeLogSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log Symptoms'**
  String get homeLogSymptoms;

  /// No description provided for @homeSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get homeSave;

  /// No description provided for @homePhaseMenstrual.
  ///
  /// In en, this message translates to:
  /// **'Menstrual'**
  String get homePhaseMenstrual;

  /// No description provided for @homePhaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get homePhaseFollicular;

  /// No description provided for @homePhaseOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get homePhaseOvulation;

  /// No description provided for @homePhaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get homePhaseLuteal;

  /// No description provided for @homeMenstrualTip.
  ///
  /// In en, this message translates to:
  /// **'Your body is releasing. Rest, use warmth, and be gentle with yourself. Iron-rich foods like spinach and lentils can help replenish.'**
  String get homeMenstrualTip;

  /// No description provided for @homeFollicularTip.
  ///
  /// In en, this message translates to:
  /// **'Estrogen is rising — your energy and creativity are building. Great time to start new projects and try challenging workouts.'**
  String get homeFollicularTip;

  /// No description provided for @homeOvulationTip.
  ///
  /// In en, this message translates to:
  /// **'Peak energy and confidence! You\'re magnetic right now. Ideal for social events, big presentations, and high-intensity exercise.'**
  String get homeOvulationTip;

  /// No description provided for @homeLutealTip.
  ///
  /// In en, this message translates to:
  /// **'Progesterone peaks then drops. Prioritize sleep, magnesium-rich foods, and reduce caffeine. Self-care is not optional.'**
  String get homeLutealTip;

  /// No description provided for @homeIntensityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get homeIntensityLight;

  /// No description provided for @homeIntensityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get homeIntensityMedium;

  /// No description provided for @homeIntensityHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get homeIntensityHeavy;

  /// No description provided for @homeIntensityVeryHeavy.
  ///
  /// In en, this message translates to:
  /// **'Very Heavy'**
  String get homeIntensityVeryHeavy;

  /// No description provided for @homeSymptomCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get homeSymptomCramps;

  /// No description provided for @homeSymptomBloating.
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get homeSymptomBloating;

  /// No description provided for @homeSymptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get homeSymptomHeadache;

  /// No description provided for @homeSymptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get homeSymptomFatigue;

  /// No description provided for @homeSymptomBreastTenderness.
  ///
  /// In en, this message translates to:
  /// **'Breast tenderness'**
  String get homeSymptomBreastTenderness;

  /// No description provided for @homeSymptomMoodSwings.
  ///
  /// In en, this message translates to:
  /// **'Mood swings'**
  String get homeSymptomMoodSwings;

  /// No description provided for @homeSymptomSpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get homeSymptomSpotting;

  /// No description provided for @homeSymptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get homeSymptomNausea;

  /// No description provided for @homeSymptomBackPain.
  ///
  /// In en, this message translates to:
  /// **'Back pain'**
  String get homeSymptomBackPain;

  /// No description provided for @homeSymptomAcne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get homeSymptomAcne;

  /// No description provided for @homeDayOfPeriod.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String homeDayOfPeriod(int day, int total);

  /// No description provided for @homeDayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String homeDayNumber(int day);

  /// No description provided for @homeDaysLate.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, one{day} other{days}} late'**
  String homeDaysLate(int count);

  /// No description provided for @homePeriodInDays.
  ///
  /// In en, this message translates to:
  /// **'Period in {count} {count, plural, one{day} other{days}}'**
  String homePeriodInDays(int count);

  /// No description provided for @homeSymptomsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} symptoms'**
  String homeSymptomsCount(int count);

  /// No description provided for @homeSaveCount.
  ///
  /// In en, this message translates to:
  /// **'Save ({count} selected)'**
  String homeSaveCount(int count);

  /// No description provided for @homePeriodLate.
  ///
  /// In en, this message translates to:
  /// **'Your period is {count} days late. This is normal — cycles vary.'**
  String homePeriodLate(int count);

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarCycleHistory.
  ///
  /// In en, this message translates to:
  /// **'CYCLE HISTORY'**
  String get calendarCycleHistory;

  /// No description provided for @calendarLegendPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get calendarLegendPeriod;

  /// No description provided for @calendarLegendPredicted.
  ///
  /// In en, this message translates to:
  /// **'Predicted'**
  String get calendarLegendPredicted;

  /// No description provided for @calendarLegendFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get calendarLegendFollicular;

  /// No description provided for @calendarLegendOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get calendarLegendOvulation;

  /// No description provided for @calendarLegendLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get calendarLegendLuteal;

  /// No description provided for @calendarPhaseSuffix.
  ///
  /// In en, this message translates to:
  /// **' phase'**
  String get calendarPhaseSuffix;

  /// No description provided for @calendarPredictedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Predicted period'**
  String get calendarPredictedPeriod;

  /// No description provided for @calendarPeriodBadge.
  ///
  /// In en, this message translates to:
  /// **'🩸 Period'**
  String get calendarPeriodBadge;

  /// No description provided for @calendarNothingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged this day'**
  String get calendarNothingLogged;

  /// No description provided for @calendarMoodLabel.
  ///
  /// In en, this message translates to:
  /// **'MOOD'**
  String get calendarMoodLabel;

  /// No description provided for @calendarSymptomsLabel.
  ///
  /// In en, this message translates to:
  /// **'SYMPTOMS'**
  String get calendarSymptomsLabel;

  /// No description provided for @onboardingAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Luna'**
  String get onboardingAppTitle;

  /// No description provided for @onboardingStep0Title.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your\nlast period'**
  String get onboardingStep0Title;

  /// No description provided for @onboardingStep0Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the start and end dates — Luna will calculate everything automatically.'**
  String get onboardingStep0Subtitle;

  /// No description provided for @onboardingWhenDidItStart.
  ///
  /// In en, this message translates to:
  /// **'When did it start?'**
  String get onboardingWhenDidItStart;

  /// No description provided for @onboardingWhenDidItEnd.
  ///
  /// In en, this message translates to:
  /// **'When did it end?'**
  String get onboardingWhenDidItEnd;

  /// No description provided for @onboardingStillOngoing.
  ///
  /// In en, this message translates to:
  /// **'Still ongoing'**
  String get onboardingStillOngoing;

  /// No description provided for @onboardingPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored only on your device. Luna never sends it anywhere.'**
  String get onboardingPrivacyNotice;

  /// No description provided for @onboardingStartFreshLink.
  ///
  /// In en, this message translates to:
  /// **'I don\'t remember — start fresh'**
  String get onboardingStartFreshLink;

  /// No description provided for @onboardingStartFreshDialogBody.
  ///
  /// In en, this message translates to:
  /// **'You can always log your first period later.\nLuna will start tracking from your next period.'**
  String get onboardingStartFreshDialogBody;

  /// No description provided for @onboardingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get onboardingCancel;

  /// No description provided for @onboardingStartFresh.
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get onboardingStartFresh;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'One more for accuracy'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'When did the period before that start? Luna will calculate your cycle length from real dates.'**
  String get onboardingStep1Subtitle;

  /// No description provided for @onboardingPrevPeriodStart.
  ///
  /// In en, this message translates to:
  /// **'Previous period — start date'**
  String get onboardingPrevPeriodStart;

  /// No description provided for @onboardingPrevPeriodEnd.
  ///
  /// In en, this message translates to:
  /// **'Previous period — end date'**
  String get onboardingPrevPeriodEnd;

  /// No description provided for @onboardingPreview.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW'**
  String get onboardingPreview;

  /// No description provided for @onboardingPeriodLength.
  ///
  /// In en, this message translates to:
  /// **'Period length'**
  String get onboardingPeriodLength;

  /// No description provided for @onboardingCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle length'**
  String get onboardingCycleLength;

  /// No description provided for @onboardingAddDateAbove.
  ///
  /// In en, this message translates to:
  /// **'Add date above'**
  String get onboardingAddDateAbove;

  /// No description provided for @onboardingDidYouKnow.
  ///
  /// In en, this message translates to:
  /// **'💡 Did you know?'**
  String get onboardingDidYouKnow;

  /// No description provided for @onboardingDidYouKnowBody.
  ///
  /// In en, this message translates to:
  /// **'Only 13% of people have exactly 28-day cycles. Real data gives you real predictions.'**
  String get onboardingDidYouKnowBody;

  /// No description provided for @onboardingSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get onboardingSaving;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started →'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue →'**
  String get onboardingContinue;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'← Back'**
  String get onboardingBack;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip →'**
  String get onboardingSkip;

  /// No description provided for @onboardingAllSet.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get onboardingAllSet;

  /// No description provided for @onboardingCompletionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Luna is ready to track your cycle.\nYour data stays private on your device.'**
  String get onboardingCompletionSubtitle;

  /// No description provided for @onboardingLastPeriodStarted.
  ///
  /// In en, this message translates to:
  /// **'Last period started'**
  String get onboardingLastPeriodStarted;

  /// No description provided for @onboardingStartTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking →'**
  String get onboardingStartTracking;

  /// No description provided for @onboardingTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get onboardingTapToSelect;

  /// No description provided for @onboardingOptional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get onboardingOptional;

  /// No description provided for @onboardingDayPeriod.
  ///
  /// In en, this message translates to:
  /// **'{count} day period — got it!'**
  String onboardingDayPeriod(int count);

  /// No description provided for @onboardingDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String onboardingDays(int count);

  /// No description provided for @onboardingDayCycleCalculated.
  ///
  /// In en, this message translates to:
  /// **'{count} day cycle — calculated from your data ✓'**
  String onboardingDayCycleCalculated(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsUpgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get settingsUpgradeToPremium;

  /// No description provided for @settingsUpgradeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics, widget, backup and more'**
  String get settingsUpgradeSubtitle;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get settingsCycle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settingsDebug;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// No description provided for @settingsBiometricsPin.
  ///
  /// In en, this message translates to:
  /// **'Biometrics / PIN'**
  String get settingsBiometricsPin;

  /// No description provided for @settingsCreateBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get settingsCreateBackup;

  /// No description provided for @settingsEncryptedFile.
  ///
  /// In en, this message translates to:
  /// **'Encrypted .luna file'**
  String get settingsEncryptedFile;

  /// No description provided for @settingsRestoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get settingsRestoreFromBackup;

  /// No description provided for @settingsCycleSettings.
  ///
  /// In en, this message translates to:
  /// **'Cycle settings'**
  String get settingsCycleSettings;

  /// No description provided for @settingsCycleLengthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Average length, period length'**
  String get settingsCycleLengthSubtitle;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsResetProfile.
  ///
  /// In en, this message translates to:
  /// **'Reset profile'**
  String get settingsResetProfile;

  /// No description provided for @settingsDeleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all cycle data'**
  String get settingsDeleteAllData;

  /// No description provided for @settingsPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get settingsPremium;

  /// No description provided for @settingsResetProfileQuestion.
  ///
  /// In en, this message translates to:
  /// **'Reset profile?'**
  String get settingsResetProfileQuestion;

  /// No description provided for @settingsResetDialogBody.
  ///
  /// In en, this message translates to:
  /// **'All cycle entries, symptom logs and pregnancies will be deleted. This cannot be undone.'**
  String get settingsResetDialogBody;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsReset;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @paywallLunaPremium.
  ///
  /// In en, this message translates to:
  /// **'Luna Premium'**
  String get paywallLunaPremium;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full Luna experience'**
  String get paywallSubtitle;

  /// No description provided for @paywallAdvancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced analytics'**
  String get paywallAdvancedAnalytics;

  /// No description provided for @paywallAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Charts, trends, symptoms by phase'**
  String get paywallAnalyticsSubtitle;

  /// No description provided for @paywallCustomSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Custom symptoms'**
  String get paywallCustomSymptoms;

  /// No description provided for @paywallCustomSymptomsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your own symptoms'**
  String get paywallCustomSymptomsSubtitle;

  /// No description provided for @paywallPregnancyTracker.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy tracker'**
  String get paywallPregnancyTracker;

  /// No description provided for @paywallPregnancySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Week by week'**
  String get paywallPregnancySubtitle;

  /// No description provided for @paywallHomeWidget.
  ///
  /// In en, this message translates to:
  /// **'Home screen widget'**
  String get paywallHomeWidget;

  /// No description provided for @paywallHomeWidgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle day at a glance'**
  String get paywallHomeWidgetSubtitle;

  /// No description provided for @paywallEncryptedBackup.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup'**
  String get paywallEncryptedBackup;

  /// No description provided for @paywallBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data, safe and private'**
  String get paywallBackupSubtitle;

  /// No description provided for @paywallYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get paywallYearly;

  /// No description provided for @paywallSave44.
  ///
  /// In en, this message translates to:
  /// **'Save 44%'**
  String get paywallSave44;

  /// No description provided for @paywallMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallMonthly;

  /// No description provided for @paywallRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestorePurchases;

  /// No description provided for @paywallFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String paywallFailed(String error);

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Luna Premium'**
  String get paywallTitle;

  /// No description provided for @paywallTrialBadge.
  ///
  /// In en, this message translates to:
  /// **'7-day free trial — cancel anytime'**
  String get paywallTrialBadge;

  /// No description provided for @paywallFeatureAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get paywallFeatureAnalytics;

  /// No description provided for @paywallFeatureAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Charts, patterns, insights'**
  String get paywallFeatureAnalyticsSubtitle;

  /// No description provided for @paywallFeatureWidget.
  ///
  /// In en, this message translates to:
  /// **'Home Screen Widget'**
  String get paywallFeatureWidget;

  /// No description provided for @paywallFeatureWidgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle at a glance'**
  String get paywallFeatureWidgetSubtitle;

  /// No description provided for @paywallFeaturePregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Tracker'**
  String get paywallFeaturePregnancy;

  /// No description provided for @paywallFeaturePregnancySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Week by week journey'**
  String get paywallFeaturePregnancySubtitle;

  /// No description provided for @paywallFeatureExport.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get paywallFeatureExport;

  /// No description provided for @paywallFeatureExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share with your doctor'**
  String get paywallFeatureExportSubtitle;

  /// No description provided for @paywallBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get paywallBestValue;

  /// No description provided for @paywallPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ mo'**
  String get paywallPerMonth;

  /// No description provided for @paywallFinePrint.
  ///
  /// In en, this message translates to:
  /// **'After free trial, {price}. Cancel anytime in App Store / Google Play.'**
  String paywallFinePrint(String price);

  /// No description provided for @paywallCta.
  ///
  /// In en, this message translates to:
  /// **'Start 7-Day Free Trial'**
  String get paywallCta;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// No description provided for @paywallPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get paywallPrivacyPolicy;

  /// No description provided for @paywallTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get paywallTerms;

  /// No description provided for @paywallSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium!'**
  String get paywallSuccessTitle;

  /// No description provided for @paywallSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All features are now unlocked.\nEnjoy your Luna Premium experience.'**
  String get paywallSuccessSubtitle;

  /// No description provided for @paywallContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue →'**
  String get paywallContinue;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics — Premium'**
  String get analyticsPremiumTitle;

  /// No description provided for @analyticsPremiumBody.
  ///
  /// In en, this message translates to:
  /// **'Cycle charts, phase symptoms and predictions are available with a Premium subscription.'**
  String get analyticsPremiumBody;

  /// No description provided for @analyticsTryPremium.
  ///
  /// In en, this message translates to:
  /// **'Try Premium'**
  String get analyticsTryPremium;

  /// No description provided for @analyticsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Cycle charts — coming soon'**
  String get analyticsComingSoon;

  /// No description provided for @logPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get logPeriod;

  /// No description provided for @logFirstDayOngoing.
  ///
  /// In en, this message translates to:
  /// **'First day / ongoing'**
  String get logFirstDayOngoing;

  /// No description provided for @logFlowIntensity.
  ///
  /// In en, this message translates to:
  /// **'Flow intensity'**
  String get logFlowIntensity;

  /// No description provided for @logSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get logSave;

  /// No description provided for @logFlowSpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get logFlowSpotting;

  /// No description provided for @logFlowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get logFlowLight;

  /// No description provided for @logFlowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get logFlowHeavy;

  /// No description provided for @logFlowVeryHeavy.
  ///
  /// In en, this message translates to:
  /// **'Very\nheavy'**
  String get logFlowVeryHeavy;

  /// No description provided for @navCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get navCycle;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @moodLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get moodLow;

  /// No description provided for @moodOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get moodOkay;

  /// No description provided for @moodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moodGood;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodAmazing.
  ///
  /// In en, this message translates to:
  /// **'Amazing'**
  String get moodAmazing;

  /// No description provided for @symptomHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get symptomHappy;

  /// No description provided for @symptomIrritable.
  ///
  /// In en, this message translates to:
  /// **'Irritable'**
  String get symptomIrritable;

  /// No description provided for @symptomAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get symptomAnxious;

  /// No description provided for @symptomSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get symptomSad;

  /// No description provided for @symptomHighEnergy.
  ///
  /// In en, this message translates to:
  /// **'High energy'**
  String get symptomHighEnergy;

  /// No description provided for @symptomInsomnia.
  ///
  /// In en, this message translates to:
  /// **'Insomnia'**
  String get symptomInsomnia;

  /// No description provided for @symptomDiarrhea.
  ///
  /// In en, this message translates to:
  /// **'Diarrhea'**
  String get symptomDiarrhea;

  /// No description provided for @symptomConstipation.
  ///
  /// In en, this message translates to:
  /// **'Constipation'**
  String get symptomConstipation;

  /// No description provided for @symptomDrySkin.
  ///
  /// In en, this message translates to:
  /// **'Dry skin'**
  String get symptomDrySkin;

  /// No description provided for @notificationPeriodReminder.
  ///
  /// In en, this message translates to:
  /// **'Your period is expected in {days} days'**
  String notificationPeriodReminder(int days);

  /// No description provided for @notificationFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Your fertile window starts today'**
  String get notificationFertileWindow;

  /// No description provided for @notificationLatePeriod.
  ///
  /// In en, this message translates to:
  /// **'Your period is {days} days late'**
  String notificationLatePeriod(int days);

  /// No description provided for @notificationLunaPrivate.
  ///
  /// In en, this message translates to:
  /// **'Luna'**
  String get notificationLunaPrivate;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPeriodReminder.
  ///
  /// In en, this message translates to:
  /// **'Period reminder'**
  String get settingsPeriodReminder;

  /// No description provided for @settingsPeriodReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remind before your period'**
  String get settingsPeriodReminderSubtitle;

  /// No description provided for @settingsFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Fertile window'**
  String get settingsFertileWindow;

  /// No description provided for @settingsFertileWindowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify when fertile window starts'**
  String get settingsFertileWindowSubtitle;

  /// No description provided for @settingsLatePeriod.
  ///
  /// In en, this message translates to:
  /// **'Late period'**
  String get settingsLatePeriod;

  /// No description provided for @settingsLatePeriodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify when period is late'**
  String get settingsLatePeriodSubtitle;

  /// No description provided for @settingsReminderDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days before'**
  String settingsReminderDays(int days);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError('AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
