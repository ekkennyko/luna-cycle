// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get homeAppTitle => 'Luna';

  @override
  String get homeCycleTracker => 'ТРЕКЕР ЦИКЛА';

  @override
  String get homeDayLabel => 'ДЕНЬ';

  @override
  String get homeTapToLog => 'Нажми, чтобы';

  @override
  String get homeYourFirstPeriod => 'записать первые месячные';

  @override
  String get homePeriodActive => 'Месячные идут';

  @override
  String get homePeriodExpectedToday => 'Месячные ожидаются сегодня';

  @override
  String get homeEndPeriod => 'Завершить';

  @override
  String get homeLogPeriod => 'Записать';

  @override
  String get homePeriod => 'Месячные';

  @override
  String get homeMood => 'Настроение';

  @override
  String get homeSymptoms => 'Симптомы';

  @override
  String get homePhaseSuffix => ' ФАЗА';

  @override
  String get homeCycleLength => 'Длина цикла';

  @override
  String get homePeriodStat => 'Месячные';

  @override
  String get homeAvgLength => 'Средняя длина';

  @override
  String get homeLongerThanUsual => 'Месячные длятся дольше обычного.';

  @override
  String get homeLogToKeepAccurate => 'Месячные начались? Запиши, чтобы прогнозы были точными.';

  @override
  String get homeNotYet => 'Ещё нет';

  @override
  String get homeLogPeriodTitle => 'Записать месячные';

  @override
  String get homeFlowIntensity => 'ИНТЕНСИВНОСТЬ';

  @override
  String get homeStartPeriodButton => '🩸 Начать месячные';

  @override
  String get homeEndPeriodTitle => 'Завершить месячные?';

  @override
  String get homeWhenDidPeriodEnd => 'Когда месячные закончились?';

  @override
  String get homeYesterday => 'Вчера';

  @override
  String get homeToday => 'Сегодня';

  @override
  String get homePickADate => 'Выбрать дату';

  @override
  String get homeTapToSelect => 'Нажми для выбора';

  @override
  String get homeCancel => 'Отмена';

  @override
  String get homeSaving => 'Сохранение…';

  @override
  String get homeEndPeriodButton => '✓ Завершить';

  @override
  String get homeHowAreYouFeeling => 'Как ты себя чувствуешь?';

  @override
  String get homeLogSymptoms => 'Записать симптомы';

  @override
  String get homeSave => 'Сохранить';

  @override
  String get homePhaseMenstrual => 'Менструальная';

  @override
  String get homePhaseFollicular => 'Фолликулярная';

  @override
  String get homePhaseOvulation => 'Овуляция';

  @override
  String get homePhaseLuteal => 'Лютеиновая';

  @override
  String get homeMenstrualTip =>
      'Твоё тело обновляется. Отдыхай, используй тепло и будь бережна к себе. Продукты, богатые железом — шпинат и чечевица — помогут восстановиться.';

  @override
  String get homeFollicularTip => 'Эстроген растёт — энергия и креативность набирают обороты. Отличное время для новых проектов и интенсивных тренировок.';

  @override
  String get homeOvulationTip => 'Пик энергии и уверенности! Ты притягиваешь внимание. Идеально для встреч, важных презентаций и активных тренировок.';

  @override
  String get homeLutealTip => 'Прогестерон достигает пика, а затем снижается. Высыпайся, ешь продукты с магнием и сократи кофеин. Забота о себе — не роскошь.';

  @override
  String get homeIntensityLight => 'Лёгкие';

  @override
  String get homeIntensityMedium => 'Средние';

  @override
  String get homeIntensityHeavy => 'Сильные';

  @override
  String get homeIntensityVeryHeavy => 'Очень сильные';

  @override
  String get homeSymptomCramps => 'Спазмы';

  @override
  String get homeSymptomBloating => 'Вздутие';

  @override
  String get homeSymptomHeadache => 'Головная боль';

  @override
  String get homeSymptomFatigue => 'Усталость';

  @override
  String get homeSymptomBreastTenderness => 'Чувствительность груди';

  @override
  String get homeSymptomMoodSwings => 'Перепады настроения';

  @override
  String get homeSymptomSpotting => 'Мажущие выделения';

  @override
  String get homeSymptomNausea => 'Тошнота';

  @override
  String get homeSymptomBackPain => 'Боль в спине';

  @override
  String get homeSymptomAcne => 'Акне';

  @override
  String homeDayOfPeriod(int day, int total) {
    return 'День $day из $total';
  }

  @override
  String homeDayNumber(int day) {
    return 'День $day';
  }

  @override
  String homeDaysLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0 задержки';
  }

  @override
  String homePeriodInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return 'Месячные через $_temp0';
  }

  @override
  String homeSymptomsCount(int count) {
    return '$count симпт.';
  }

  @override
  String homeSaveCount(int count) {
    return 'Сохранить ($count выбр.)';
  }

  @override
  String homePeriodLate(int count) {
    return 'Месячные задерживаются на $count дн. Это нормально — циклы варьируются.';
  }

  @override
  String get calendarTitle => 'Календарь';

  @override
  String get calendarCycleHistory => 'ИСТОРИЯ ЦИКЛА';

  @override
  String get calendarLegendPeriod => 'Месячные';

  @override
  String get calendarLegendPredicted => 'Прогноз';

  @override
  String get calendarLegendFollicular => 'Фолликулярная';

  @override
  String get calendarLegendOvulation => 'Овуляция';

  @override
  String get calendarLegendLuteal => 'Лютеиновая';

  @override
  String get calendarPhaseSuffix => ' фаза';

  @override
  String get calendarPredictedPeriod => 'Прогноз месячных';

  @override
  String get calendarPeriodBadge => '🩸 Месячные';

  @override
  String get calendarNothingLogged => 'Нет записей за этот день';

  @override
  String get calendarMoodLabel => 'НАСТРОЕНИЕ';

  @override
  String get calendarSymptomsLabel => 'СИМПТОМЫ';

  @override
  String get onboardingAppTitle => 'Luna';

  @override
  String get onboardingStep0Title => 'Расскажи о\nпоследних месячных';

  @override
  String get onboardingStep0Subtitle => 'Укажи даты начала и конца — Luna рассчитает всё автоматически.';

  @override
  String get onboardingWhenDidItStart => 'Когда они начались?';

  @override
  String get onboardingWhenDidItEnd => 'Когда они закончились?';

  @override
  String get onboardingStillOngoing => 'Ещё идут';

  @override
  String get onboardingPrivacyNotice => 'Твои данные хранятся только на устройстве. Luna никуда их не отправляет.';

  @override
  String get onboardingStartFreshLink => 'Не помню — начать с чистого листа';

  @override
  String get onboardingStartFreshDialogBody => 'Ты всегда сможешь записать первые месячные позже.\nLuna начнёт отслеживание со следующего цикла.';

  @override
  String get onboardingCancel => 'Отмена';

  @override
  String get onboardingStartFresh => 'Начать заново';

  @override
  String get onboardingStep1Title => 'Ещё одна дата для точности';

  @override
  String get onboardingStep1Subtitle => 'Когда начались предыдущие месячные? Luna рассчитает длину цикла по реальным данным.';

  @override
  String get onboardingPrevPeriodStart => 'Предыдущие месячные — начало';

  @override
  String get onboardingPrevPeriodEnd => 'Предыдущие месячные — конец';

  @override
  String get onboardingPreview => 'ПРЕДПРОСМОТР';

  @override
  String get onboardingPeriodLength => 'Длина месячных';

  @override
  String get onboardingCycleLength => 'Длина цикла';

  @override
  String get onboardingAddDateAbove => 'Укажи дату выше';

  @override
  String get onboardingDidYouKnow => '💡 Знаешь ли ты?';

  @override
  String get onboardingDidYouKnowBody => 'Только у 13% людей цикл ровно 28 дней. Реальные данные дают реальные прогнозы.';

  @override
  String get onboardingSaving => 'Сохранение…';

  @override
  String get onboardingGetStarted => 'Начать →';

  @override
  String get onboardingContinue => 'Далее →';

  @override
  String get onboardingBack => '← Назад';

  @override
  String get onboardingSkip => 'Пропустить →';

  @override
  String get onboardingAllSet => 'Всё готово!';

  @override
  String get onboardingCompletionSubtitle => 'Luna готова отслеживать твой цикл.\nТвои данные остаются на устройстве.';

  @override
  String get onboardingLastPeriodStarted => 'Последние месячные начались';

  @override
  String get onboardingStartTracking => 'Начать отслеживание →';

  @override
  String get onboardingTapToSelect => 'Нажми для выбора';

  @override
  String get onboardingOptional => 'необязательно';

  @override
  String onboardingDayPeriod(int count) {
    return '$count дн. месячных — записано!';
  }

  @override
  String onboardingDays(int count) {
    return '$count дн.';
  }

  @override
  String onboardingDayCycleCalculated(int count) {
    return '$count дн. цикл — рассчитано из данных ✓';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsUpgradeToPremium => 'Перейти на Premium';

  @override
  String get settingsUpgradeSubtitle => 'Аналитика, виджет, бэкап и другое';

  @override
  String get settingsPrivacy => 'Приватность';

  @override
  String get settingsData => 'Данные';

  @override
  String get settingsCycle => 'Цикл';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsDebug => 'Отладка';

  @override
  String get settingsAppLock => 'Блокировка';

  @override
  String get settingsBiometricsPin => 'Биометрия / PIN';

  @override
  String get settingsCreateBackup => 'Создать бэкап';

  @override
  String get settingsEncryptedFile => 'Зашифрованный файл .luna';

  @override
  String get settingsRestoreFromBackup => 'Восстановить из бэкапа';

  @override
  String get settingsCycleSettings => 'Настройки цикла';

  @override
  String get settingsCycleLengthSubtitle => 'Средняя длина, длина месячных';

  @override
  String get settingsPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get settingsResetProfile => 'Сбросить профиль';

  @override
  String get settingsDeleteAllData => 'Удалить все данные цикла';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsResetProfileQuestion => 'Сбросить профиль?';

  @override
  String get settingsResetDialogBody => 'Все записи цикла, симптомов и беременности будут удалены. Это нельзя отменить.';

  @override
  String get settingsCancel => 'Отмена';

  @override
  String get settingsReset => 'Сбросить';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get paywallLunaPremium => 'Luna Premium';

  @override
  String get paywallSubtitle => 'Открой полный опыт Luna';

  @override
  String get paywallAdvancedAnalytics => 'Продвинутая аналитика';

  @override
  String get paywallAnalyticsSubtitle => 'Графики, тренды, симптомы по фазам';

  @override
  String get paywallCustomSymptoms => 'Свои симптомы';

  @override
  String get paywallCustomSymptomsSubtitle => 'Добавляй собственные симптомы';

  @override
  String get paywallPregnancyTracker => 'Трекер беременности';

  @override
  String get paywallPregnancySubtitle => 'Неделя за неделей';

  @override
  String get paywallHomeWidget => 'Виджет на экране';

  @override
  String get paywallHomeWidgetSubtitle => 'День цикла одним взглядом';

  @override
  String get paywallEncryptedBackup => 'Зашифрованный бэкап';

  @override
  String get paywallBackupSubtitle => 'Твои данные в безопасности';

  @override
  String get paywallYearly => 'Ежегодная';

  @override
  String get paywallSave44 => 'Экономия 44%';

  @override
  String get paywallMonthly => 'Ежемесячная';

  @override
  String get paywallRestorePurchases => 'Восстановить покупки';

  @override
  String paywallFailed(String error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String get paywallTitle => 'Luna Premium';

  @override
  String get paywallTrialBadge => '7 дней бесплатно — отмена в любое время';

  @override
  String get paywallFeatureAnalytics => 'Продвинутая аналитика';

  @override
  String get paywallFeatureAnalyticsSubtitle => 'Графики, паттерны, инсайты';

  @override
  String get paywallFeatureWidget => 'Виджет на экране';

  @override
  String get paywallFeatureWidgetSubtitle => 'Цикл одним взглядом';

  @override
  String get paywallFeaturePregnancy => 'Трекер беременности';

  @override
  String get paywallFeaturePregnancySubtitle => 'Неделя за неделей';

  @override
  String get paywallFeatureExport => 'Экспорт PDF';

  @override
  String get paywallFeatureExportSubtitle => 'Поделись с врачом';

  @override
  String get paywallBestValue => 'ВЫГОДНО';

  @override
  String get paywallPerMonth => '/ мес';

  @override
  String paywallFinePrint(String price) {
    return 'После пробного периода — $price. Отмена в App Store / Google Play.';
  }

  @override
  String get paywallCta => 'Начать 7 дней бесплатно';

  @override
  String get paywallRestore => 'Восстановить покупки';

  @override
  String get paywallPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get paywallTerms => 'Условия использования';

  @override
  String get paywallSuccessTitle => 'Добро пожаловать в Premium!';

  @override
  String get paywallSuccessSubtitle => 'Все функции теперь доступны.\nПриятного использования Luna Premium.';

  @override
  String get paywallContinue => 'Продолжить →';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get analyticsPremiumTitle => 'Аналитика — Premium';

  @override
  String get analyticsPremiumBody => 'Графики цикла, симптомы по фазам и прогнозы доступны с подпиской Premium.';

  @override
  String get analyticsTryPremium => 'Попробовать Premium';

  @override
  String get analyticsComingSoon => 'Графики цикла — скоро';

  @override
  String get logPeriod => 'Месячные';

  @override
  String get logFirstDayOngoing => 'Первый день / идут';

  @override
  String get logFlowIntensity => 'Интенсивность';

  @override
  String get logSave => 'Сохранить';

  @override
  String get logFlowSpotting => 'Мажущие';

  @override
  String get logFlowLight => 'Лёгкие';

  @override
  String get logFlowHeavy => 'Сильные';

  @override
  String get logFlowVeryHeavy => 'Очень\nсильные';

  @override
  String get navCycle => 'Цикл';

  @override
  String get navCalendar => 'Календарь';

  @override
  String get navAnalytics => 'Аналитика';

  @override
  String get navSettings => 'Настройки';

  @override
  String get moodLow => 'Плохо';

  @override
  String get moodOkay => 'Нормально';

  @override
  String get moodGood => 'Хорошо';

  @override
  String get moodHappy => 'Радостно';

  @override
  String get moodAmazing => 'Отлично';

  @override
  String get symptomHappy => 'Радость';

  @override
  String get symptomIrritable => 'Раздражительность';

  @override
  String get symptomAnxious => 'Тревога';

  @override
  String get symptomSad => 'Грусть';

  @override
  String get symptomHighEnergy => 'Высокий тонус';

  @override
  String get symptomInsomnia => 'Бессонница';

  @override
  String get symptomDiarrhea => 'Диарея';

  @override
  String get symptomConstipation => 'Запор';

  @override
  String get symptomDrySkin => 'Сухость кожи';

  @override
  String notificationPeriodReminder(int days) {
    return 'Ожидается менструация через $days дней';
  }

  @override
  String get notificationFertileWindow => 'Сегодня начинается фертильное окно';

  @override
  String notificationLatePeriod(int days) {
    return 'Задержка менструации $days дней';
  }

  @override
  String get notificationLunaPrivate => 'Luna';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsPeriodReminder => 'Напоминание о периоде';

  @override
  String get settingsPeriodReminderSubtitle => 'Напомнить до начала менструации';

  @override
  String get settingsFertileWindow => 'Фертильное окно';

  @override
  String get settingsFertileWindowSubtitle => 'Уведомить когда начинается фертильное окно';

  @override
  String get settingsLatePeriod => 'Задержка';

  @override
  String get settingsLatePeriodSubtitle => 'Уведомить при задержке';

  @override
  String settingsReminderDays(int days) {
    return 'За $days дней';
  }
}
