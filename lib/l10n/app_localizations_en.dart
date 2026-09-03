// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'sheknows';

  @override
  String get authConfirmEmailNotice =>
      'Check your email to confirm your account.';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authDividerOr => 'or';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authHasAccountPrompt => 'Already have an account?';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authLoginSubtitle => 'Sign in to continue';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authNoAccountPrompt => 'Don\'t have an account?';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String authPasswordRulesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'At least $count characters, with a letter and a number',
      one: 'At least $count character, with a letter and a number',
    );
    return '$_temp0';
  }

  @override
  String get authRegisterSubtitle => 'Sign up with email or Google';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authValidationConfirmPasswordRequired => 'Confirm your password';

  @override
  String get authValidationEmailInvalid => 'Enter a valid email address';

  @override
  String get authValidationEmailRequired => 'Email is required';

  @override
  String get authValidationPasswordNeedsLetterAndNumber =>
      'Password must include at least one letter and one number';

  @override
  String get authValidationPasswordNoSurroundingSpaces =>
      'Password cannot start or end with spaces';

  @override
  String get authValidationPasswordRequired => 'Password is required';

  @override
  String authValidationPasswordTooShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Password must be at least $count characters',
      one: 'Password must be at least $count character',
    );
    return '$_temp0';
  }

  @override
  String get authValidationPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get commonCancel => 'Cancel';

  @override
  String commonDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonGoHome => 'Go home';

  @override
  String get commonNext => 'Next';

  @override
  String get commonNotes => 'Notes';

  @override
  String get commonPageNotFoundBody => 'That link does not lead anywhere.';

  @override
  String get commonPageNotFoundTitle => 'Page not found';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonStartupFailureBody =>
      'Restarting the app usually fixes this. If it keeps happening, send us the details below.';

  @override
  String get commonStartupFailureTitle => 'sheknows couldn\'t start';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get cycleCalendarNextMonth => 'Next month';

  @override
  String get cycleCalendarPreviousMonth => 'Previous month';

  @override
  String get cycleClearThisDay => 'Clear this day';

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
  String get cycleDayCellStateHasNotes => 'has notes';

  @override
  String get cycleDayCellStateIntimacyLogged => 'intimacy logged';

  @override
  String get cycleDayCellStatePeriodLogged => 'period logged';

  @override
  String get cycleDayCellStatePredictedPeriod => 'predicted period';

  @override
  String get cycleDayCellStatePredictedStart => 'predicted period start';

  @override
  String get cycleDayCellStateToday => 'today';

  @override
  String cycleDayHeaderDate(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat.yMMMMEEEEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get cycleDayHowWasYourDay => 'How was your day?';

  @override
  String get cycleDayNoSymptoms => 'No symptoms logged for this day';

  @override
  String get cycleDayNotesHint => 'Anything you want to remember about today';

  @override
  String get cycleDeleteThisPeriod => 'Delete this period';

  @override
  String get cycleEndPeriodButton => 'End period today';

  @override
  String get cycleEndPeriodOnThisDay => 'End period on this day';

  @override
  String get cycleFlowHeavy => 'Heavy';

  @override
  String get cycleFlowLight => 'Light';

  @override
  String get cycleFlowMedium => 'Medium';

  @override
  String get cycleHistoryEmptyBody =>
      'Tap \"My period started today\" to start tracking.';

  @override
  String get cycleHistoryEmptyTitle => 'No periods logged yet';

  @override
  String get cycleHistoryFlowHeavy => 'Heavy flow';

  @override
  String get cycleHistoryFlowLight => 'Light flow';

  @override
  String get cycleHistoryFlowMedium => 'Medium flow';

  @override
  String get cycleHistoryMenuTooltip => 'Period options';

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

    return '$startString – ongoing';
  }

  @override
  String get cycleHistoryReopen => 'Reopen (ongoing)';

  @override
  String get cycleHistorySaving => 'saving…';

  @override
  String get cycleHistoryTitle => 'History';

  @override
  String get cycleInsightsAvgCycleLength => 'Avg cycle length';

  @override
  String get cycleInsightsAvgPeriodLength => 'Avg period length';

  @override
  String cycleInsightsBleedingDay(int day) {
    return 'Day $day of bleeding';
  }

  @override
  String get cycleInsightsCurrentPeriod => 'Current period';

  @override
  String get cycleInsightsLoggedPeriods => 'Logged periods';

  @override
  String get cycleInsightsNextPeriod => 'Next period expected';

  @override
  String get cycleInsightsPredictionHint =>
      'Log at least two periods to see cycle predictions.';

  @override
  String get cycleInsightsTitle => 'Insights';

  @override
  String get cycleIntimacy => 'Intimacy';

  @override
  String get cycleIntimacyProtected => 'Protected';

  @override
  String get cycleIntimacyUnprotected => 'Unprotected';

  @override
  String get cycleLegendLogged => 'Logged';

  @override
  String get cycleLegendPredicted => 'Predicted';

  @override
  String get cycleLegendToday => 'Today';

  @override
  String cycleMoonDayOfTotal(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String get cycleMoonHintFirstQuarter => 'Steady momentum';

  @override
  String get cycleMoonHintFullMoon => 'Peak of your cycle';

  @override
  String get cycleMoonHintLastQuarter => 'Reflect and rest';

  @override
  String get cycleMoonHintNewMoon => 'Your period is here or about to arrive';

  @override
  String get cycleMoonHintWaningCrescent => 'Be gentle with yourself';

  @override
  String get cycleMoonHintWaningGibbous => 'Wind-down begins';

  @override
  String get cycleMoonHintWaxingCrescent => 'Energy is building';

  @override
  String get cycleMoonHintWaxingGibbous => 'Ovulation is approaching';

  @override
  String get cycleMoonPhaseFirstQuarter => 'First quarter';

  @override
  String get cycleMoonPhaseFullMoon => 'Full moon';

  @override
  String get cycleMoonPhaseLastQuarter => 'Last quarter';

  @override
  String cycleMoonPhaseLine(String phase, String hint) {
    return '$phase · $hint';
  }

  @override
  String get cycleMoonPhaseNewMoon => 'New moon';

  @override
  String get cycleMoonPhaseWaningCrescent => 'Waning crescent';

  @override
  String get cycleMoonPhaseWaningGibbous => 'Waning gibbous';

  @override
  String get cycleMoonPhaseWaxingCrescent => 'Waxing crescent';

  @override
  String get cycleMoonPhaseWaxingGibbous => 'Waxing gibbous';

  @override
  String cycleMoonSemantics(int day, int total, String phase, String hint) {
    return 'Cycle day $day of $total. $phase. $hint';
  }

  @override
  String cycleNextPeriodDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get cyclePeriodStartPickerHelp => 'When did your period start?';

  @override
  String get cyclePeriodStartedOnThisDay => 'Period started on this day';

  @override
  String get cyclePhaseFollicular => 'Follicular';

  @override
  String get cyclePhaseLuteal => 'Luteal';

  @override
  String get cyclePhaseMenstrual => 'Menstrual';

  @override
  String get cyclePhaseOvulation => 'Ovulation';

  @override
  String get cyclePhaseUnknown => 'Unknown';

  @override
  String get cycleSaveDay => 'Save day';

  @override
  String get cycleStartPeriodButton => 'My period started today';

  @override
  String cycleStatusBleedingDay(int dayNumber) {
    return 'Bleeding · day $dayNumber of this period';
  }

  @override
  String cycleStatusCycleDay(int cycleDay) {
    return 'Cycle day $cycleDay';
  }

  @override
  String cycleStatusDayOfPeriod(int count, int dayNumber) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Day $dayNumber of a $count-day period',
      one: 'Day $dayNumber of a $count-day period',
    );
    return '$_temp0';
  }

  @override
  String get cycleStatusNoData => 'No period data for this day';

  @override
  String get cycleStatusPredictedStart => 'Predicted period start';

  @override
  String get cycleStatusUpcoming => 'Upcoming';

  @override
  String get cycleTitle => 'Cycle';

  @override
  String get errorAuthGeneric =>
      'That didn\'t work. Check your details and try again.';

  @override
  String get errorNetworkOffline =>
      'You\'re offline. Your changes are saved on this device and will sync when the connection returns.';

  @override
  String get errorServer =>
      'Something went wrong on our end. Please try again in a moment.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get homeAppBarTitle => 'sheknows';

  @override
  String homeLastDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last $count days',
      one: 'Last $count day',
    );
    return '$_temp0';
  }

  @override
  String get homeLogSymptomsButton => 'Log symptoms';

  @override
  String get homeTrackCycleButton => 'Track my cycle';

  @override
  String get navHome => 'Home';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingPatternsHeadline =>
      'Spot your patterns, not just your symptoms.';

  @override
  String get onboardingPatternsSubtext =>
      'Every symptom you log is matched to your cycle phase automatically — see what really happens, phase by phase.';

  @override
  String get onboardingPredictHeadline => 'See your next period coming.';

  @override
  String get onboardingPredictSubtext =>
      'sheknows learns your rhythm and predicts your cycle — so nothing catches you off guard.';

  @override
  String get profileAccountSection => 'Account';

  @override
  String get profileAddName => 'Add your name';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileDeleteAccountDialogBody =>
      'This permanently deletes your account and all of your data. This cannot be undone.';

  @override
  String get profileDeleteAccountDialogTitle => 'Delete account?';

  @override
  String get profileEditName => 'Edit name';

  @override
  String get profileEmailUnconfirmed => 'Email not confirmed yet';

  @override
  String get profileGoPremium => 'Go Premium';

  @override
  String get profileNameFieldLabel => 'Name';

  @override
  String get profileNameHint => 'How should we call you?';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileTitle => 'Profile';

  @override
  String get symptomAddSymptom => 'Add symptom';

  @override
  String symptomBarRowSemanticsLabel(String label, String value) {
    return '$label: $value';
  }

  @override
  String get symptomCategoryDischarge => 'Discharge';

  @override
  String get symptomCategoryMood => 'Mood';

  @override
  String get symptomCategoryOther => 'Other';

  @override
  String get symptomCategoryPain => 'Pain';

  @override
  String get symptomCategoryPhysical => 'Physical';

  @override
  String get symptomEmptyWindowTitle => 'No symptoms in this window';

  @override
  String symptomHistoryTileSubtitle(String severity, String time) {
    return '$severity · $time';
  }

  @override
  String get symptomJustAMoment => 'Just a moment…';

  @override
  String get symptomLoadFailedCloseSheet =>
      'Could not load your symptoms — close and try again';

  @override
  String get symptomLogAction => 'Log';

  @override
  String get symptomLogSheetEditTitle => 'Edit symptom';

  @override
  String get symptomLogSheetNewTitle => 'Log a symptom';

  @override
  String get symptomNotesHint => 'Anything worth remembering';

  @override
  String get symptomPhaseEmptyLogBothBody =>
      'Log symptoms and periods to see phase patterns.';

  @override
  String get symptomPhaseEmptyLogPeriodsBody =>
      'Log your period dates to see phase patterns.';

  @override
  String get symptomPhaseEntriesBarLabel => 'Entries';

  @override
  String get symptomPhaseNoCycleDataTitle => 'No cycle data for this window';

  @override
  String get symptomPhaseNotEnoughCycleData => 'Not enough cycle data';

  @override
  String get symptomPhaseTitle => 'By cycle phase';

  @override
  String symptomPhaseTypeCountChip(String type, int count) {
    return '$type ×$count';
  }

  @override
  String get symptomPickToContinue => 'Pick a symptom to continue';

  @override
  String get symptomRangeAllTime => 'All time';

  @override
  String get symptomSaveChanges => 'Save changes';

  @override
  String get symptomSeverityMild => 'Mild';

  @override
  String get symptomSeverityModerate => 'Moderate';

  @override
  String get symptomSeverityNone => 'None';

  @override
  String get symptomSeveritySectionLabel => 'Severity';

  @override
  String get symptomSeveritySevere => 'Severe';

  @override
  String get symptomTrendsBySeverity => 'By severity';

  @override
  String get symptomTrendsEmptyBody => 'Log symptoms to see your trends.';

  @override
  String symptomTrendsEntriesLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries logged',
      one: '$count entry logged',
    );
    return '$_temp0';
  }

  @override
  String get symptomTrendsMostFrequent => 'Most frequent';

  @override
  String get symptomTrendsTitle => 'Trends';

  @override
  String get symptomTypeAcne => 'Acne';

  @override
  String get symptomTypeAnxiety => 'Anxiety';

  @override
  String get symptomTypeBackache => 'Backache';

  @override
  String get symptomTypeBloating => 'Bloating';

  @override
  String get symptomTypeChestPain => 'Chest pain';

  @override
  String get symptomTypeCramps => 'Cramps';

  @override
  String get symptomTypeEnergy => 'Energy';

  @override
  String get symptomTypeFatigue => 'Fatigue';

  @override
  String get symptomTypeHeadache => 'Headache';

  @override
  String get symptomTypeHighLibido => 'High libido';

  @override
  String get symptomTypeInsomnia => 'Insomnia';

  @override
  String get symptomTypeIrritability => 'Irritability';

  @override
  String get symptomTypeLowLibido => 'Low libido';

  @override
  String get symptomTypeMoodSwings => 'Mood swings';

  @override
  String get symptomTypeMucusDischarge => 'Mucus';

  @override
  String get symptomTypeNausea => 'Nausea';

  @override
  String get symptomTypeSadness => 'Sadness';

  @override
  String get symptomTypeSpottingDischarge => 'Spotting';

  @override
  String get symptomTypeWateryDischarge => 'Watery';

  @override
  String get symptomWhenSectionLabel => 'When';

  @override
  String get symptomsEmptyBody => 'Tap Log to record how you feel.';

  @override
  String get symptomsEmptyTitle => 'No symptoms logged yet';

  @override
  String get symptomsTitle => 'Symptoms';
}
