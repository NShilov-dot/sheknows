// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'sheknows';

  @override
  String get authConfirmEmailNotice =>
      'Проверьте почту, чтобы подтвердить аккаунт.';

  @override
  String get authConfirmPasswordLabel => 'Повторите пароль';

  @override
  String get authContinueWithGoogle => 'Продолжить с Google';

  @override
  String get authDividerOr => 'или';

  @override
  String get authEmailLabel => 'Эл. почта';

  @override
  String get authHasAccountPrompt => 'Уже есть аккаунт?';

  @override
  String get authHidePassword => 'Скрыть пароль';

  @override
  String get authLoginSubtitle => 'Войдите, чтобы продолжить';

  @override
  String get authLoginTitle => 'С возвращением';

  @override
  String get authNoAccountPrompt => 'Нет аккаунта?';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String authPasswordRulesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Минимум $count символа, включая букву и цифру',
      many: 'Минимум $count символов, включая букву и цифру',
      few: 'Минимум $count символа, включая букву и цифру',
      one: 'Минимум $count символ, включая букву и цифру',
    );
    return '$_temp0';
  }

  @override
  String get authRegisterSubtitle =>
      'Зарегистрируйтесь по эл. почте или через Google';

  @override
  String get authRegisterTitle => 'Создать аккаунт';

  @override
  String get authShowPassword => 'Показать пароль';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authSignUp => 'Регистрация';

  @override
  String get authValidationConfirmPasswordRequired => 'Подтвердите пароль';

  @override
  String get authValidationEmailInvalid => 'Введите корректный адрес эл. почты';

  @override
  String get authValidationEmailRequired => 'Укажите эл. почту';

  @override
  String get authValidationPasswordNeedsLetterAndNumber =>
      'Пароль должен содержать хотя бы одну букву и одну цифру';

  @override
  String get authValidationPasswordNoSurroundingSpaces =>
      'Пароль не может начинаться или заканчиваться пробелом';

  @override
  String get authValidationPasswordRequired => 'Введите пароль';

  @override
  String authValidationPasswordTooShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Пароль должен содержать минимум $count символа',
      many: 'Пароль должен содержать минимум $count символов',
      few: 'Пароль должен содержать минимум $count символа',
      one: 'Пароль должен содержать минимум $count символ',
    );
    return '$_temp0';
  }

  @override
  String get authValidationPasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get commonCancel => 'Отмена';

  @override
  String commonDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonGoHome => 'На главную';

  @override
  String get commonNext => 'Далее';

  @override
  String get commonNotes => 'Заметки';

  @override
  String get commonPageNotFoundBody => 'Эта ссылка никуда не ведёт.';

  @override
  String get commonPageNotFoundTitle => 'Страница не найдена';

  @override
  String get commonSkip => 'Пропустить';

  @override
  String get commonStartupFailureBody =>
      'Обычно помогает перезапуск приложения. Если проблема повторяется, отправьте нам данные ниже.';

  @override
  String get commonStartupFailureTitle => 'Не удалось запустить sheknows';

  @override
  String get commonTryAgain => 'Повторить';

  @override
  String get cycleCalendarNextMonth => 'Следующий месяц';

  @override
  String get cycleCalendarPreviousMonth => 'Предыдущий месяц';

  @override
  String get cycleClearThisDay => 'Очистить этот день';

  @override
  String cycleDayCellSemantics(DateTime date, String states) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString, $states';
  }

  @override
  String cycleDayCellSemanticsDateOnly(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get cycleDayCellStateHasNotes => 'есть заметки';

  @override
  String get cycleDayCellStateIntimacyLogged => 'близость отмечена';

  @override
  String get cycleDayCellStatePeriodLogged => 'месячные отмечены';

  @override
  String get cycleDayCellStatePredictedPeriod => 'прогноз месячных';

  @override
  String get cycleDayCellStatePredictedStart =>
      'прогнозируемое начало месячных';

  @override
  String get cycleDayCellStateToday => 'сегодня';

  @override
  String cycleDayHeaderDate(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat.yMMMMEEEEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get cycleDayHowWasYourDay => 'Как прошёл день?';

  @override
  String get cycleDayNoSymptoms => 'На этот день симптомы не отмечены';

  @override
  String get cycleDayNotesHint => 'Что хочется запомнить об этом дне';

  @override
  String get cycleDeleteThisPeriod => 'Удалить эти месячные';

  @override
  String get cycleEndPeriodButton => 'Завершить сегодня';

  @override
  String get cycleEndPeriodOnThisDay => 'Завершить месячные в этот день';

  @override
  String get cycleFlowHeavy => 'Обильные';

  @override
  String get cycleFlowLight => 'Скудные';

  @override
  String get cycleFlowMedium => 'Умеренные';

  @override
  String get cycleHistoryEmptyBody =>
      'Нажмите «Месячные начались сегодня», чтобы начать отслеживание.';

  @override
  String get cycleHistoryEmptyTitle => 'Записей о месячных пока нет';

  @override
  String get cycleHistoryFlowHeavy => 'Обильные выделения';

  @override
  String get cycleHistoryFlowLight => 'Скудные выделения';

  @override
  String get cycleHistoryFlowMedium => 'Умеренные выделения';

  @override
  String get cycleHistoryMenuTooltip => 'Действия с записью';

  @override
  String cycleHistoryRange(DateTime start, DateTime end) {
    final intl.DateFormat startDateFormat = intl.DateFormat.MMMd(localeName);
    final String startString = startDateFormat.format(start);
    final intl.DateFormat endDateFormat = intl.DateFormat.MMMd(localeName);
    final String endString = endDateFormat.format(end);

    return '$startString – $endString';
  }

  @override
  String cycleHistoryRangeOngoing(DateTime start) {
    final intl.DateFormat startDateFormat = intl.DateFormat.MMMd(localeName);
    final String startString = startDateFormat.format(start);

    return '$startString – продолжаются';
  }

  @override
  String get cycleHistoryReopen => 'Возобновить (продолжаются)';

  @override
  String get cycleHistorySaving => 'сохранение…';

  @override
  String get cycleHistoryTitle => 'История';

  @override
  String get cycleInsightsAvgCycleLength => 'Средняя длина цикла';

  @override
  String get cycleInsightsAvgPeriodLength => 'Средняя длительность месячных';

  @override
  String cycleInsightsBleedingDay(int day) {
    return '$day-й день кровотечения';
  }

  @override
  String get cycleInsightsCurrentPeriod => 'Текущие месячные';

  @override
  String get cycleInsightsLoggedPeriods => 'Записей о месячных';

  @override
  String get cycleInsightsNextPeriod => 'Прогноз месячных';

  @override
  String get cycleInsightsPredictionHint =>
      'Отметьте хотя бы две менструации, чтобы видеть прогноз цикла.';

  @override
  String get cycleInsightsTitle => 'Статистика';

  @override
  String get cycleIntimacy => 'Близость';

  @override
  String get cycleIntimacyProtected => 'С защитой';

  @override
  String get cycleIntimacyUnprotected => 'Без защиты';

  @override
  String get cycleLegendLogged => 'Отмечено';

  @override
  String get cycleLegendPredicted => 'Прогноз';

  @override
  String get cycleLegendToday => 'Сегодня';

  @override
  String cycleMoonDayOfTotal(int day, int total) {
    return '$day-й день из $total';
  }

  @override
  String get cycleMoonHintFirstQuarter => 'Ровный ритм';

  @override
  String get cycleMoonHintFullMoon => 'Пик цикла';

  @override
  String get cycleMoonHintLastQuarter => 'Время подумать и отдохнуть';

  @override
  String get cycleMoonHintNewMoon => 'Месячные идут или скоро начнутся';

  @override
  String get cycleMoonHintWaningCrescent => 'Будьте добрее к себе';

  @override
  String get cycleMoonHintWaningGibbous => 'Начинается спад';

  @override
  String get cycleMoonHintWaxingCrescent => 'Энергия набирает силу';

  @override
  String get cycleMoonHintWaxingGibbous => 'Овуляция приближается';

  @override
  String get cycleMoonPhaseFirstQuarter => 'Первая четверть';

  @override
  String get cycleMoonPhaseFullMoon => 'Полнолуние';

  @override
  String get cycleMoonPhaseLastQuarter => 'Последняя четверть';

  @override
  String cycleMoonPhaseLine(String phase, String hint) {
    return '$phase · $hint';
  }

  @override
  String get cycleMoonPhaseNewMoon => 'Новолуние';

  @override
  String get cycleMoonPhaseWaningCrescent => 'Убывающий серп';

  @override
  String get cycleMoonPhaseWaningGibbous => 'Убывающая луна';

  @override
  String get cycleMoonPhaseWaxingCrescent => 'Растущий серп';

  @override
  String get cycleMoonPhaseWaxingGibbous => 'Прибывающая луна';

  @override
  String cycleMoonSemantics(int day, int total, String phase, String hint) {
    return '$day-й день цикла из $total. $phase. $hint';
  }

  @override
  String cycleNextPeriodDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get cyclePeriodStartPickerHelp => 'Когда начались месячные?';

  @override
  String get cyclePeriodStartedOnThisDay => 'Месячные начались в этот день';

  @override
  String get cyclePhaseFollicular => 'Фолликулярная фаза';

  @override
  String get cyclePhaseLuteal => 'Лютеиновая фаза';

  @override
  String get cyclePhaseMenstrual => 'Менструация';

  @override
  String get cyclePhaseOvulation => 'Овуляция';

  @override
  String get cyclePhaseUnknown => 'Неизвестно';

  @override
  String get cycleSaveDay => 'Сохранить день';

  @override
  String get cycleStartPeriodButton => 'Месячные начались сегодня';

  @override
  String cycleStatusBleedingDay(int dayNumber) {
    return 'Кровотечение · $dayNumber-й день месячных';
  }

  @override
  String cycleStatusCycleDay(int cycleDay) {
    return '$cycleDay-й день цикла';
  }

  @override
  String cycleStatusDayOfPeriod(int count, int dayNumber) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$dayNumber-й день месячных из $count дней',
      many: '$dayNumber-й день месячных из $count дней',
      few: '$dayNumber-й день месячных из $count дней',
      one: '$dayNumber-й день месячных из $count дня',
    );
    return '$_temp0';
  }

  @override
  String get cycleStatusNoData => 'Нет данных о месячных за этот день';

  @override
  String get cycleStatusPredictedStart => 'Прогнозируемое начало месячных';

  @override
  String get cycleStatusUpcoming => 'Предстоящий день';

  @override
  String get cycleTitle => 'Цикл';

  @override
  String get errorAuthGeneric =>
      'Не получилось. Проверьте данные и попробуйте снова.';

  @override
  String get errorNetworkOffline =>
      'Нет подключения к интернету. Изменения сохранены на этом устройстве и синхронизируются, когда связь появится.';

  @override
  String get errorServer =>
      'Что-то пошло не так на нашей стороне. Попробуйте ещё раз через минуту.';

  @override
  String get errorUnknown => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get homeAppBarTitle => 'sheknows';

  @override
  String get homeDeleteAccountButton => 'Удалить аккаунт';

  @override
  String get homeDeleteAccountDialogBody =>
      'Аккаунт и все ваши данные будут удалены безвозвратно. Отменить это действие нельзя.';

  @override
  String get homeDeleteAccountDialogTitle => 'Удалить аккаунт?';

  @override
  String get homeEmailConfirmedNo => 'Эл. почта подтверждена: Нет';

  @override
  String get homeEmailConfirmedYes => 'Эл. почта подтверждена: Да';

  @override
  String homeEmailLabel(String email) {
    return 'Эл. почта: $email';
  }

  @override
  String get homeGoPremiumButton => 'Оформить Premium';

  @override
  String get homeLogSymptomsButton => 'Отметить симптомы';

  @override
  String get homeProfileLoadedFromDatabase => 'Загружено из таблицы profiles.';

  @override
  String homeProfileNameLabel(String name) {
    return 'Имя: $name';
  }

  @override
  String get homeProfileNameNotSet => 'Не указано';

  @override
  String get homeProfileNoRowFound =>
      'Запись профиля не найдена (показаны метаданные авторизации).';

  @override
  String get homeProfileSectionTitle => 'Профиль';

  @override
  String get homeSignOutTooltip => 'Выйти';

  @override
  String get homeSignedIn => 'Вы вошли';

  @override
  String get homeTrackCycleButton => 'Отслеживать цикл';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get onboardingPatternsHeadline =>
      'Замечайте закономерности, а не только симптомы.';

  @override
  String get onboardingPatternsSubtext =>
      'Каждый отмеченный симптом автоматически сопоставляется с фазой цикла — посмотрите, что происходит на самом деле, фаза за фазой.';

  @override
  String get onboardingPredictHeadline =>
      'Узнайте о следующих месячных заранее.';

  @override
  String get onboardingPredictSubtext =>
      'sheknows изучает ваш ритм и прогнозирует цикл — чтобы ничто не застало вас врасплох.';

  @override
  String get symptomAddSymptom => 'Добавить симптом';

  @override
  String symptomBarRowSemanticsLabel(String label, String value) {
    return '$label: $value';
  }

  @override
  String get symptomCategoryDischarge => 'Выделения';

  @override
  String get symptomCategoryMood => 'Настроение';

  @override
  String get symptomCategoryOther => 'Другое';

  @override
  String get symptomCategoryPain => 'Боль';

  @override
  String get symptomCategoryPhysical => 'Тело';

  @override
  String get symptomEmptyWindowTitle => 'За этот период симптомов нет';

  @override
  String symptomHistoryTileSubtitle(String severity, String time) {
    return '$severity · $time';
  }

  @override
  String get symptomJustAMoment => 'Секунду…';

  @override
  String get symptomLoadFailedCloseSheet =>
      'Не удалось загрузить симптомы — закройте и попробуйте снова';

  @override
  String get symptomLogAction => 'Добавить';

  @override
  String get symptomLogSheetEditTitle => 'Изменить симптом';

  @override
  String get symptomLogSheetNewTitle => 'Записать симптом';

  @override
  String get symptomNotesHint => 'Что-то, что стоит запомнить';

  @override
  String get symptomPhaseEmptyLogBothBody =>
      'Записывайте симптомы и месячные, чтобы увидеть закономерности по фазам.';

  @override
  String get symptomPhaseEmptyLogPeriodsBody =>
      'Отмечайте даты месячных, чтобы увидеть закономерности по фазам.';

  @override
  String get symptomPhaseEntriesBarLabel => 'Записи';

  @override
  String get symptomPhaseNoCycleDataTitle =>
      'За этот период нет данных о цикле';

  @override
  String get symptomPhaseNotEnoughCycleData => 'Недостаточно данных о цикле';

  @override
  String get symptomPhaseTitle => 'По фазам цикла';

  @override
  String symptomPhaseTypeCountChip(String type, int count) {
    return '$type — $count';
  }

  @override
  String get symptomPickToContinue => 'Выберите симптом, чтобы продолжить';

  @override
  String get symptomRangeAllTime => 'Всё время';

  @override
  String get symptomSaveChanges => 'Сохранить изменения';

  @override
  String get symptomSeverityMild => 'Слабо';

  @override
  String get symptomSeverityModerate => 'Умеренно';

  @override
  String get symptomSeverityNone => 'Нет';

  @override
  String get symptomSeveritySectionLabel => 'Интенсивность';

  @override
  String get symptomSeveritySevere => 'Сильно';

  @override
  String get symptomTrendsBySeverity => 'По интенсивности';

  @override
  String get symptomTrendsEmptyBody =>
      'Записывайте симптомы, чтобы увидеть динамику.';

  @override
  String symptomTrendsEntriesLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    return '$_temp0';
  }

  @override
  String get symptomTrendsMostFrequent => 'Чаще всего';

  @override
  String get symptomTrendsTitle => 'Динамика';

  @override
  String get symptomTypeAcne => 'Акне';

  @override
  String get symptomTypeAnxiety => 'Тревожность';

  @override
  String get symptomTypeBackache => 'Боль в спине';

  @override
  String get symptomTypeBloating => 'Вздутие';

  @override
  String get symptomTypeChestPain => 'Боль в груди';

  @override
  String get symptomTypeCramps => 'Спазмы';

  @override
  String get symptomTypeEnergy => 'Энергичность';

  @override
  String get symptomTypeFatigue => 'Усталость';

  @override
  String get symptomTypeHeadache => 'Головная боль';

  @override
  String get symptomTypeHighLibido => 'Высокое либидо';

  @override
  String get symptomTypeInsomnia => 'Бессонница';

  @override
  String get symptomTypeIrritability => 'Раздражительность';

  @override
  String get symptomTypeLowLibido => 'Низкое либидо';

  @override
  String get symptomTypeMoodSwings => 'Смена настроения';

  @override
  String get symptomTypeMucusDischarge => 'Слизистые';

  @override
  String get symptomTypeNausea => 'Тошнота';

  @override
  String get symptomTypeSadness => 'Грусть';

  @override
  String get symptomTypeSpottingDischarge => 'Мажущие';

  @override
  String get symptomTypeWateryDischarge => 'Водянистые';

  @override
  String get symptomWhenSectionLabel => 'Когда';

  @override
  String get symptomsEmptyBody =>
      'Нажмите «Добавить», чтобы отметить самочувствие.';

  @override
  String get symptomsEmptyTitle => 'Пока нет записей о симптомах';

  @override
  String get symptomsTitle => 'Симптомы';
}
