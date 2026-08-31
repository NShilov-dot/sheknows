import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz')
  ];

  /// The application name, shown in the OS task switcher and the app bar. Product name — never translated or transliterated.
  ///
  /// In en, this message translates to:
  /// **'sheknows'**
  String get appTitle;

  /// Snack bar shown after a successful sign-up when the account still needs email confirmation; the user is then sent back to the login page.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account.'**
  String get authConfirmEmailNotice;

  /// Floating label of the third field on the register form, where the password is typed a second time.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// Label of the Google sign-in outlined button, shown on both the login and register pages. 'Google' is a brand name — never translate or transliterate it.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// Single word between two horizontal rules, separating the email form from the Google button. Lowercase, one word.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authDividerOr;

  /// Floating label of the email text field on the login and register forms. Keep short — it is a Material floating label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// Footer prompt on the register page, immediately followed by the 'Sign in' text button in a Wrap. Must read as a standalone question.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHasAccountPrompt;

  /// Tooltip / accessibility label of the eye icon in a password field while the password is visible. Tapping it hides the password. Second half of the ternary at auth_text_field.dart:111.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Subtitle under the login page headline.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authLoginSubtitle;

  /// Headline of the login page.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// Footer prompt on the login page, immediately followed by the 'Sign up' text button in a Wrap. Must read as a standalone question — the two are separate widgets, not one sentence.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccountPrompt;

  /// Floating label of the password field on the login and register forms.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Small helper line under the password field on the register form, stating the strength rules before the user submits. count is AuthValidators.minPasswordLength (currently 8).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{At least {count} character, with a letter and a number} other{At least {count} characters, with a letter and a number}}'**
  String authPasswordRulesHint(int count);

  /// Subtitle under the register page headline. 'Google' stays as-is.
  ///
  /// In en, this message translates to:
  /// **'Sign up with email or Google'**
  String get authRegisterSubtitle;

  /// Headline of the register page.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterTitle;

  /// Tooltip / accessibility label of the eye icon in a password field while the password is hidden. Tapping it reveals the password.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Sign-in action. Used twice with the same wording: the submit button of the login form, and the footer link on the register page that goes back to login. Keep short — it is a full-width filled button in one of the two places.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// Sign-up action. Used twice with the same wording: the footer link on the login page, and the submit button of the register form. Keep short — it is a full-width filled button in one of the two places.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// Validation error under the confirm-password field on the register form when it is left empty. Distinct from the field's own label (authConfirmPasswordLabel).
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get authValidationConfirmPasswordRequired;

  /// Field validation error shown under the email field when the value does not look like an email address.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authValidationEmailInvalid;

  /// Field validation error shown under the email field when it is left empty.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authValidationEmailRequired;

  /// Registration-only password validation error, shown when the password has no letter or no digit.
  ///
  /// In en, this message translates to:
  /// **'Password must include at least one letter and one number'**
  String get authValidationPasswordNeedsLetterAndNumber;

  /// Registration-only password validation error, shown when the value has leading or trailing whitespace.
  ///
  /// In en, this message translates to:
  /// **'Password cannot start or end with spaces'**
  String get authValidationPasswordNoSurroundingSpaces;

  /// Field validation error shown under the password field when it is left empty (both sign-in and sign-up).
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authValidationPasswordRequired;

  /// Registration-only password validation error, shown when the password is shorter than the minimum. count is AuthValidators.minPasswordLength (currently 8).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Password must be at least {count} character} other{Password must be at least {count} characters}}'**
  String authValidationPasswordTooShort(int count);

  /// Validation error under the confirm-password field on the register form when the two passwords differ.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authValidationPasswordsDoNotMatch;

  /// Generic dismiss button in dialogs. Shared across features — keep as a single common key.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Time-window option in the symptom analytics range selector. Used for both the 30-day and 90-day options - call it with count: 30 and count: 90. Renders inside a small segmented/chip selector, so keep it to the number plus the noun.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String commonDaysCount(int count);

  /// Destructive button in the symptom log sheet that deletes the entry being edited. The period feature and the delete-account dialog have their own 'Delete' literals (see notes) — dedupe candidates.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Button on the 'Page not found' screen that navigates to /home. Keep short — it is a filled button.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get commonGoHome;

  /// Advances to the next onboarding page. Keep short — it is a filled button.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// Free-text notes. Calendar legend label for the notes dot, and the notes section heading in the day sheet. Also used by the symptom log sheet (another agent's file).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// Body copy under the 'Page not found' title on the router fallback screen.
  ///
  /// In en, this message translates to:
  /// **'That link does not lead anywhere.'**
  String get commonPageNotFoundBody;

  /// Title of the router fallback screen shown when a deep link or push matches no route.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get commonPageNotFoundTitle;

  /// Skips the onboarding pitch and goes straight to sign-in.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// Body copy on the start-up failure screen. One key on purpose — the two sentences must not be split, the raw error text is rendered separately below it.
  ///
  /// In en, this message translates to:
  /// **'Restarting the app usually fixes this. If it keeps happening, send us the details below.'**
  String get commonStartupFailureBody;

  /// Title of the last-resort screen shown when app start-up (DI/Supabase/local store) failed. 'sheknows' is the product name — keep it in Latin script, do not transliterate.
  ///
  /// In en, this message translates to:
  /// **'sheknows couldn\'t start'**
  String get commonStartupFailureTitle;

  /// Retry button in error states. Shared across at least four screens — canonical common key, do not fork per feature.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// Tooltip on the right chevron above the calendar grid.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get cycleCalendarNextMonth;

  /// Tooltip on the left chevron above the calendar grid.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get cycleCalendarPreviousMonth;

  /// Text button that deletes all tracking recorded for the tapped day.
  ///
  /// In en, this message translates to:
  /// **'Clear this day'**
  String get cycleClearThisDay;

  /// Screen-reader label for a calendar day square that has at least one state: the date followed by a comma-joined list of states (built in Dart from the cycleDayCellState* keys). Translators may reorder date and states.
  ///
  /// In en, this message translates to:
  /// **'{date}, {states}'**
  String cycleDayCellSemantics(DateTime date, String states);

  /// Screen-reader label for a calendar day square with no states at all — just the date. Separate from cycleDayCellSemantics so a plain day does not read as 'August 27, ' with a dangling comma.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String cycleDayCellSemanticsDateOnly(DateTime date);

  /// Calendar day-cell screen-reader fragment, joined mid-sentence — keep lowercase. This day has a free-text note.
  ///
  /// In en, this message translates to:
  /// **'has notes'**
  String get cycleDayCellStateHasNotes;

  /// Calendar day-cell screen-reader fragment, joined mid-sentence — keep lowercase. Sexual activity recorded on this day.
  ///
  /// In en, this message translates to:
  /// **'intimacy logged'**
  String get cycleDayCellStateIntimacyLogged;

  /// Calendar day-cell screen-reader fragment, joined mid-sentence — keep lowercase. A past/current day covered by a logged period.
  ///
  /// In en, this message translates to:
  /// **'period logged'**
  String get cycleDayCellStatePeriodLogged;

  /// Calendar day-cell screen-reader fragment, joined mid-sentence — keep lowercase. A future day inside a predicted period.
  ///
  /// In en, this message translates to:
  /// **'predicted period'**
  String get cycleDayCellStatePredictedPeriod;

  /// Calendar day-cell screen-reader fragment, joined mid-sentence — keep lowercase. This day is the predicted next period start. Deliberately separate from the sentence-case cycleStatusPredictedStart.
  ///
  /// In en, this message translates to:
  /// **'predicted period start'**
  String get cycleDayCellStatePredictedStart;

  /// Calendar day-cell screen-reader fragment, joined mid-sentence — keep lowercase. Distinct from the sentence-case legend label cycleLegendToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get cycleDayCellStateToday;

  /// Date line at the top of the day details sheet, e.g. 'Monday, August 27, 2026'. Replaces the hand-rolled weekday/month tables in day_header.dart.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String cycleDayHeaderDate(DateTime date);

  /// Heading of the day tracking editor (intimacy, symptoms, notes) in the day details sheet.
  ///
  /// In en, this message translates to:
  /// **'How was your day?'**
  String get cycleDayHowWasYourDay;

  /// Empty state of the symptoms section inside the day details sheet.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged for this day'**
  String get cycleDayNoSymptoms;

  /// Placeholder text in the day notes text field. Keep it short — it must fit one or two lines.
  ///
  /// In en, this message translates to:
  /// **'Anything you want to remember about today'**
  String get cycleDayNotesHint;

  /// Destructive text button in the day sheet: delete the whole logged period covering the tapped day.
  ///
  /// In en, this message translates to:
  /// **'Delete this period'**
  String get cycleDeleteThisPeriod;

  /// Secondary button shown while a period is ongoing; marks today as the last day of bleeding.
  ///
  /// In en, this message translates to:
  /// **'End period today'**
  String get cycleEndPeriodButton;

  /// Secondary button in the day sheet: mark the tapped day as the last day of the ongoing period.
  ///
  /// In en, this message translates to:
  /// **'End period on this day'**
  String get cycleEndPeriodOnThisDay;

  /// Standalone user-facing name for FlowLevel.heavy. See cycleFlowLight.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get cycleFlowHeavy;

  /// Standalone user-facing name for FlowLevel.light (bleeding intensity), e.g. in a chooser or chip. ru/uz forms are plural/invariant adjectives agreeing with «выделения» / «qon ketishi»; do NOT interpolate them into another sentence — use cycleHistoryFlow* for the history subtitle.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get cycleFlowLight;

  /// Standalone user-facing name for FlowLevel.medium. See cycleFlowLight.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get cycleFlowMedium;

  /// Body line of the period history empty state; it quotes the primary button. The button text is inlined per language (not a placeholder) so each locale can use its own quotation marks and word order — keep it in sync with cycleStartPeriodButton if that label changes.
  ///
  /// In en, this message translates to:
  /// **'Tap \"My period started today\" to start tracking.'**
  String get cycleHistoryEmptyBody;

  /// Title of the empty state shown in place of the period history list.
  ///
  /// In en, this message translates to:
  /// **'No periods logged yet'**
  String get cycleHistoryEmptyTitle;

  /// History row subtitle fragment for FlowLevel.heavy. See cycleHistoryFlowLight.
  ///
  /// In en, this message translates to:
  /// **'Heavy flow'**
  String get cycleHistoryFlowHeavy;

  /// History row subtitle fragment for FlowLevel.light. A complete fragment, not a label interpolated into '{flow} flow' — noun and adjective must agree, so the applier switches on FlowLevel to pick cycleHistoryFlowLight/Medium/Heavy. Stays lowercase-free of sentence punctuation: it is one item in a ' · ' separated list.
  ///
  /// In en, this message translates to:
  /// **'Light flow'**
  String get cycleHistoryFlowLight;

  /// History row subtitle fragment for FlowLevel.medium. See cycleHistoryFlowLight.
  ///
  /// In en, this message translates to:
  /// **'Medium flow'**
  String get cycleHistoryFlowMedium;

  /// Tooltip / accessibility label of the overflow menu button on a period history row.
  ///
  /// In en, this message translates to:
  /// **'Period options'**
  String get cycleHistoryMenuTooltip;

  /// Title of a finished period in the history list: the date span from first to last day of bleeding. Replaces a hand-built 'd/M – d/M', which had no year and is ambiguous between locales (d/M vs M/d). Uses the intl MMMd skeleton. The separator is an en dash.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String cycleHistoryRange(DateTime start, DateTime end);

  /// Title of a still-ongoing period in the history list: start date and an open end. ru «продолжаются» agrees with the plural «месячные».
  ///
  /// In en, this message translates to:
  /// **'{start} – ongoing'**
  String cycleHistoryRangeOngoing(DateTime start);

  /// Menu item that clears the end date of a finished period so it counts as still ongoing. Keep the ru wording of 'ongoing' identical to cycleHistoryRangeOngoing.
  ///
  /// In en, this message translates to:
  /// **'Reopen (ongoing)'**
  String get cycleHistoryReopen;

  /// History row subtitle fragment shown while an optimistic (not yet synced) period entry is being written. One item in a ' · ' separated list, so it is lowercase on purpose — do not sentence-case it. Ends with a single ellipsis character.
  ///
  /// In en, this message translates to:
  /// **'saving…'**
  String get cycleHistorySaving;

  /// Section heading above the list of past logged periods on the cycle screen.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get cycleHistoryTitle;

  /// Insights row label; value is an average number of days between period starts. Keep short — it shares a row with the value.
  ///
  /// In en, this message translates to:
  /// **'Avg cycle length'**
  String get cycleInsightsAvgCycleLength;

  /// Insights row label; value is an average bleeding duration in days.
  ///
  /// In en, this message translates to:
  /// **'Avg period length'**
  String get cycleInsightsAvgPeriodLength;

  /// Value of the 'Current period' insights row: which day of the ongoing period today is. NOT a plural — {day} is an ordinal position, and in ru the masculine ordinal suffix -й plus nominative singular «день» is correct for every number (1-й, 2-й, 5-й, 21-й день); Uzbek '-kuni' likewise.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of bleeding'**
  String cycleInsightsBleedingDay(int day);

  /// Insights row label shown only while a period is ongoing; the value is the bleeding day number.
  ///
  /// In en, this message translates to:
  /// **'Current period'**
  String get cycleInsightsCurrentPeriod;

  /// Insights row label; the value is the number of period entries the user has logged.
  ///
  /// In en, this message translates to:
  /// **'Logged periods'**
  String get cycleInsightsLoggedPeriods;

  /// Insights row label; the value is the predicted start date of the next period.
  ///
  /// In en, this message translates to:
  /// **'Next period expected'**
  String get cycleInsightsNextPeriod;

  /// Hint under the insights rows shown while the user has fewer than two logged periods, so no prediction is possible.
  ///
  /// In en, this message translates to:
  /// **'Log at least two periods to see cycle predictions.'**
  String get cycleInsightsPredictionHint;

  /// Card title above the computed cycle statistics rows.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get cycleInsightsTitle;

  /// Sexual activity. Used both as the calendar legend label for the intimacy dot and as the section heading in the day sheet.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get cycleIntimacy;

  /// Intimacy choice chip: protected sex. Keep short — it is a chip.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get cycleIntimacyProtected;

  /// Intimacy choice chip: unprotected sex. Keep short — it is a chip.
  ///
  /// In en, this message translates to:
  /// **'Unprotected'**
  String get cycleIntimacyUnprotected;

  /// Calendar legend: the solid band marking days logged as period days.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get cycleLegendLogged;

  /// Calendar legend: the soft circle marking the predicted next period start.
  ///
  /// In en, this message translates to:
  /// **'Predicted'**
  String get cycleLegendPredicted;

  /// Calendar legend: the ring marking today's date.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get cycleLegendToday;

  /// The large visible line under the moon: which day of the cycle out of the cycle length. Was two TextSpans ('Day $day' + ' of $_cycleLength') and must become one message so ru/uz can reorder.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String cycleMoonDayOfTotal(int day, int total);

  /// Moon indicator hint for the first-quarter phase. Sentence case.
  ///
  /// In en, this message translates to:
  /// **'Steady momentum'**
  String get cycleMoonHintFirstQuarter;

  /// Moon indicator hint for the full-moon phase. Sentence case.
  ///
  /// In en, this message translates to:
  /// **'Peak of your cycle'**
  String get cycleMoonHintFullMoon;

  /// Moon indicator hint for the last-quarter phase. Sentence case.
  ///
  /// In en, this message translates to:
  /// **'Reflect and rest'**
  String get cycleMoonHintLastQuarter;

  /// Moon indicator hint for the new-moon phase. Sentence case — used as-is in the visible line and in the screen-reader label (the old .toLowerCase() must be removed).
  ///
  /// In en, this message translates to:
  /// **'Your period is here or about to arrive'**
  String get cycleMoonHintNewMoon;

  /// Moon indicator hint for the waning-crescent phase. Sentence case.
  ///
  /// In en, this message translates to:
  /// **'Be gentle with yourself'**
  String get cycleMoonHintWaningCrescent;

  /// Moon indicator hint for the waning-gibbous phase. Sentence case.
  ///
  /// In en, this message translates to:
  /// **'Wind-down begins'**
  String get cycleMoonHintWaningGibbous;

  /// Moon indicator hint for the waxing-crescent phase. Sentence case.
  ///
  /// In en, this message translates to:
  /// **'Energy is building'**
  String get cycleMoonHintWaxingCrescent;

  /// Moon indicator hint for the waxing-gibbous phase. Sentence case.
  ///
  /// In en, this message translates to:
  /// **'Ovulation is approaching'**
  String get cycleMoonHintWaxingGibbous;

  /// Moon indicator phase name, 3rd eighth of the cycle.
  ///
  /// In en, this message translates to:
  /// **'First quarter'**
  String get cycleMoonPhaseFirstQuarter;

  /// Moon indicator phase name, 5th eighth of the cycle (ovulation).
  ///
  /// In en, this message translates to:
  /// **'Full moon'**
  String get cycleMoonPhaseFullMoon;

  /// Moon indicator phase name, 7th eighth of the cycle.
  ///
  /// In en, this message translates to:
  /// **'Last quarter'**
  String get cycleMoonPhaseLastQuarter;

  /// The small visible line under the moon: phase name and hint, both already translated. Keep the hint in its own sentence case — do not lowercase it.
  ///
  /// In en, this message translates to:
  /// **'{phase} · {hint}'**
  String cycleMoonPhaseLine(String phase, String hint);

  /// Moon indicator phase name, 1st eighth of the cycle (period days).
  ///
  /// In en, this message translates to:
  /// **'New moon'**
  String get cycleMoonPhaseNewMoon;

  /// Moon indicator phase name, 8th eighth of the cycle (just before the next period).
  ///
  /// In en, this message translates to:
  /// **'Waning crescent'**
  String get cycleMoonPhaseWaningCrescent;

  /// Moon indicator phase name, 6th eighth of the cycle.
  ///
  /// In en, this message translates to:
  /// **'Waning gibbous'**
  String get cycleMoonPhaseWaningGibbous;

  /// Moon indicator phase name, 2nd eighth of the cycle.
  ///
  /// In en, this message translates to:
  /// **'Waxing crescent'**
  String get cycleMoonPhaseWaxingCrescent;

  /// Moon indicator phase name, 4th eighth of the cycle (approaching ovulation).
  ///
  /// In en, this message translates to:
  /// **'Waxing gibbous'**
  String get cycleMoonPhaseWaxingGibbous;

  /// Screen-reader label for the whole moon indicator: cycle day, cycle length, phase name and hint. phase and hint arrive already translated from the cycleMoonPhase*/cycleMoonHint* keys. No plural: day is an ordinal and total has no noun after it.
  ///
  /// In en, this message translates to:
  /// **'Cycle day {day} of {total}. {phase}. {hint}'**
  String cycleMoonSemantics(int day, int total, String phase, String hint);

  /// Value of the 'Next period expected' row: a medium-length date. Replaces the hand-rolled '${day} ${Mon} ${year}' formatter and its English month-abbreviation table. Uses the intl yMMMd skeleton so Russian gets the genitive month («15 сент. 2026 г.») instead of a nominative month name.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String cycleNextPeriodDate(DateTime date);

  /// helpText (header) of the date picker for choosing the first day of a period.
  ///
  /// In en, this message translates to:
  /// **'When did your period start?'**
  String get cyclePeriodStartPickerHelp;

  /// Primary button in the day sheet: log the tapped day as a period start.
  ///
  /// In en, this message translates to:
  /// **'Period started on this day'**
  String get cyclePeriodStartedOnThisDay;

  /// Cycle phase name (post-period, pre-ovulation). ru/uz add the noun 'фаза'/'faza' because a bare adjective dangles. Part of the five-phase series.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get cyclePhaseFollicular;

  /// Cycle phase name (after ovulation, before the next period). ru/uz add the noun 'фаза'/'faza'. Part of the five-phase series.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get cyclePhaseLuteal;

  /// OUT OF MY ASSIGNED DIRS (utils/symptom_labels.dart, switches on the period feature's CyclePhase) — cycle phase name, used as a card heading. Russian adjectives agree with «фаза» (feminine). Likely also minted by the period agent — dedupe.
  ///
  /// In en, this message translates to:
  /// **'Menstrual'**
  String get cyclePhaseMenstrual;

  /// OUT OF MY ASSIGNED DIRS (utils/symptom_labels.dart) — cycle phase name. Dedupe with the period agent.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get cyclePhaseOvulation;

  /// OUT OF MY ASSIGNED DIRS (utils/symptom_labels.dart) — fallback cycle phase name. Note the symptom phase screen replaces this with symptomPhaseNotEnoughCycleData in its own cards. Dedupe with the period agent.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get cyclePhaseUnknown;

  /// Confirm button of the day tracking editor.
  ///
  /// In en, this message translates to:
  /// **'Save day'**
  String get cycleSaveDay;

  /// Primary button on the cycle screen; opens the start-date picker. Keep short — it is a filled button with a leading icon.
  ///
  /// In en, this message translates to:
  /// **'My period started today'**
  String get cycleStartPeriodButton;

  /// Day sheet status line for a day inside the period that is still ongoing. dayNumber is an ordinal (1st, 2nd day), so no plural agreement is needed in ru.
  ///
  /// In en, this message translates to:
  /// **'Bleeding · day {dayNumber} of this period'**
  String cycleStatusBleedingDay(int dayNumber);

  /// Day sheet status line for a day between the last period start and today. cycleDay is an ordinal — no plural agreement.
  ///
  /// In en, this message translates to:
  /// **'Cycle day {cycleDay}'**
  String cycleStatusCycleDay(int cycleDay);

  /// Day sheet status line for a day inside a finished period: which day it was and how long the period lasted. count = total period length (governs the noun, hence the plural); dayNumber = ordinal day inside it. Russian note: «из» takes the genitive, so one → «дня», all other categories → «дней».
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Day {dayNumber} of a {count}-day period} other{Day {dayNumber} of a {count}-day period}}'**
  String cycleStatusDayOfPeriod(int count, int dayNumber);

  /// Day sheet status line for a past day with nothing logged and no cycle context.
  ///
  /// In en, this message translates to:
  /// **'No period data for this day'**
  String get cycleStatusNoData;

  /// Day sheet status line when the tapped day is the predicted next period start. Sentence case, a standalone line — deliberately separate from the lowercase mid-sentence cycleDayCellStatePredictedStart.
  ///
  /// In en, this message translates to:
  /// **'Predicted period start'**
  String get cycleStatusPredictedStart;

  /// Day sheet status line for a future day about which nothing is known.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get cycleStatusUpcoming;

  /// AppBar title of the cycle tracker screen.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycleTitle;

  /// Snack-bar copy for any AuthFailure. Deliberately flow-neutral: the same message is shown for failed sign-in and failed sign-up, so do NOT name the sign-in verb.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work. Check your details and try again.'**
  String get errorAuthGeneric;

  /// Snack-bar copy for any NetworkFailure. Reassuring on purpose — the app is offline-first, nothing is lost.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Your changes are saved on this device and will sync when the connection returns.'**
  String get errorNetworkOffline;

  /// Snack-bar copy for any ServerFailure. Replaces raw Postgrest/Supabase text, which must never reach the UI.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end. Please try again in a moment.'**
  String get errorServer;

  /// Snack-bar copy for any unclassified Failure (the default branch of failureMessage).
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// App bar title on the home screen. Product/brand name — must stay identical in every locale, do not translate or transliterate.
  ///
  /// In en, this message translates to:
  /// **'sheknows'**
  String get homeAppBarTitle;

  /// Destructive text button at the bottom of the home screen that opens the delete-account confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get homeDeleteAccountButton;

  /// Body text of the delete-account confirmation dialog. Health data is involved, so the warning must stay explicit that the deletion is permanent.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and all of your data. This cannot be undone.'**
  String get homeDeleteAccountDialogBody;

  /// Title of the confirmation dialog shown before permanently deleting the user's account.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get homeDeleteAccountDialogTitle;

  /// Shown on the home screen when the user's email address has not been confirmed. DEBUG COPY — recommend deleting rather than translating.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed: No'**
  String get homeEmailConfirmedNo;

  /// Shown on the home screen when the user's email address has been confirmed. DEBUG COPY — recommend deleting rather than translating.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed: Yes'**
  String get homeEmailConfirmedYes;

  /// Label and value showing the signed-in user's email address on the home screen. {email} is the raw address and is never translated.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String homeEmailLabel(String email);

  /// Button on the home screen that presents the RevenueCat paywall. Keep short — it sits next to an icon on one line.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get homeGoPremiumButton;

  /// Button on the home screen that opens the symptom logging screen. Keep short — it sits next to an icon on one line.
  ///
  /// In en, this message translates to:
  /// **'Log symptoms'**
  String get homeLogSymptomsButton;

  /// Caption under the profile name when the profile came from the database. DEBUG COPY — recommend deleting rather than translating. 'profiles' is a database table name and must stay untranslated.
  ///
  /// In en, this message translates to:
  /// **'Loaded from the profiles table.'**
  String get homeProfileLoadedFromDatabase;

  /// Label and value showing the user's display name in the profile section of the home screen. {name} holds either the user's own display name or the localized homeProfileNameNotSet fallback, so it is not always a person's name.
  ///
  /// In en, this message translates to:
  /// **'Name: {name}'**
  String homeProfileNameLabel(String name);

  /// Fallback value passed into homeProfileNameLabel when the user has no display name. Must read naturally as the value after 'Name:'.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get homeProfileNameNotSet;

  /// Caption under the profile name when no database profile row exists and auth metadata is displayed instead. DEBUG COPY — recommend deleting rather than translating.
  ///
  /// In en, this message translates to:
  /// **'No profile row found (showing auth metadata).'**
  String get homeProfileNoRowFound;

  /// Section heading above the profile details block on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeProfileSectionTitle;

  /// Tooltip / accessibility label for the logout icon button in the home app bar.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get homeSignOutTooltip;

  /// Heading on the home screen shown once the user is authenticated. DEBUG COPY — recommend deleting rather than translating.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get homeSignedIn;

  /// Primary button on the home screen that opens the menstrual cycle tracker. Keep short — it sits next to an icon on one line.
  ///
  /// In en, this message translates to:
  /// **'Track my cycle'**
  String get homeTrackCycleButton;

  /// Primary button on the last onboarding page; leads to sign-in.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// Headline of the second onboarding page — the phase-analytics value pitch.
  ///
  /// In en, this message translates to:
  /// **'Spot your patterns, not just your symptoms.'**
  String get onboardingPatternsHeadline;

  /// Body copy under the second onboarding headline.
  ///
  /// In en, this message translates to:
  /// **'Every symptom you log is matched to your cycle phase automatically — see what really happens, phase by phase.'**
  String get onboardingPatternsSubtext;

  /// Headline of the first onboarding page — the prediction value pitch.
  ///
  /// In en, this message translates to:
  /// **'See your next period coming.'**
  String get onboardingPredictHeadline;

  /// Body copy under the first onboarding headline. "sheknows" is the product name — never translated.
  ///
  /// In en, this message translates to:
  /// **'sheknows learns your rhythm and predicts your cycle — so nothing catches you off guard.'**
  String get onboardingPredictSubtext;

  /// Submit button of the symptom log sheet when creating a new entry.
  ///
  /// In en, this message translates to:
  /// **'Add symptom'**
  String get symptomAddSymptom;

  /// Screen-reader label collapsing one chart bar (its label, painted bar and count) into a single announcement. {label} is an already-localized symptom type, severity or 'Entries' label. {value} is the count ALREADY FORMATTED by the caller via NumberFormat, so the announcement matches the digits on screen — passing a raw int would make a screen reader say "1234" where the eye reads "1,234".
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String symptomBarRowSemanticsLabel(String label, String value);

  /// Section header grouping discharge symptoms. Supplies the noun that the Watery/Mucus/Spotting labels omit, so it must stay a noun.
  ///
  /// In en, this message translates to:
  /// **'Discharge'**
  String get symptomCategoryDischarge;

  /// Section header grouping symptoms in the log sheet. Part of the five parallel category headers.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get symptomCategoryMood;

  /// Section header for symptoms that fit no other group. Part of the five parallel category headers.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get symptomCategoryOther;

  /// Section header grouping symptoms in the log sheet. One of five short bare nouns (Pain / Mood / Physical / Discharge / Other) - keep them parallel in form and length.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get symptomCategoryPain;

  /// Section header grouping bodily symptoms (fatigue, energy, insomnia). ru/uz use the short noun «Тело»/«Tana» to stay parallel with the other four bare-noun headers; a literal adjective would dangle without a noun.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get symptomCategoryPhysical;

  /// Headline of the empty state on both analytics screens when nothing was logged in the selected time range. One key, two call sites; the body copy under it differs per screen and stays separate.
  ///
  /// In en, this message translates to:
  /// **'No symptoms in this window'**
  String get symptomEmptyWindowTitle;

  /// Subtitle line of a symptom entry in the history list: the localized severity label and the entry time, separated by a middle dot. {time} is already formatted by TimeOfDay.format(context). Keep it one key — do not split the separator out.
  ///
  /// In en, this message translates to:
  /// **'{severity} · {time}'**
  String symptomHistoryTileSubtitle(String severity, String time);

  /// Hint under the temporarily disabled submit button in the log sheet while a load or another write is in flight. Keep the ellipsis character.
  ///
  /// In en, this message translates to:
  /// **'Just a moment…'**
  String get symptomJustAMoment;

  /// Hint under the disabled submit button in the log sheet when the underlying load failed; the retry button is behind the sheet, so the user must close it. Keep the dash separator.
  ///
  /// In en, this message translates to:
  /// **'Could not load your symptoms — close and try again'**
  String get symptomLoadFailedCloseSheet;

  /// Label of the extended FAB on the symptoms list that opens the log sheet. Must stay very short. The same word is quoted inside symptomsEmptyBody — keep them identical per language.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get symptomLogAction;

  /// Title of the symptom log bottom sheet when editing an existing entry.
  ///
  /// In en, this message translates to:
  /// **'Edit symptom'**
  String get symptomLogSheetEditTitle;

  /// Title of the symptom log bottom sheet when creating a new entry.
  ///
  /// In en, this message translates to:
  /// **'Log a symptom'**
  String get symptomLogSheetNewTitle;

  /// hintText of the free-text notes field in the symptom log sheet.
  ///
  /// In en, this message translates to:
  /// **'Anything worth remembering'**
  String get symptomNotesHint;

  /// Body copy of the phase-screen empty state when neither symptoms nor period dates exist in the window.
  ///
  /// In en, this message translates to:
  /// **'Log symptoms and periods to see phase patterns.'**
  String get symptomPhaseEmptyLogBothBody;

  /// Body copy of the phase-screen empty state when symptoms exist but period dates are missing.
  ///
  /// In en, this message translates to:
  /// **'Log your period dates to see phase patterns.'**
  String get symptomPhaseEmptyLogPeriodsBody;

  /// Label of the bar showing how many symptom entries fall in one cycle phase. Keep the noun consistent with symptomTrendsEntriesLogged.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get symptomPhaseEntriesBarLabel;

  /// Headline of the phase-screen empty state when symptoms exist in the window but no period dates place them in a phase.
  ///
  /// In en, this message translates to:
  /// **'No cycle data for this window'**
  String get symptomPhaseNoCycleDataTitle;

  /// Card heading used in place of a phase name for symptoms the app could not attribute to a cycle phase.
  ///
  /// In en, this message translates to:
  /// **'Not enough cycle data'**
  String get symptomPhaseNotEnoughCycleData;

  /// AppBar title of the cycle-phase breakdown screen, and the tooltip of the icon button on the trends screen that opens it. Same phrase in both places.
  ///
  /// In en, this message translates to:
  /// **'By cycle phase'**
  String get symptomPhaseTitle;

  /// Chip listing a top symptom type and how many times it occurred in a phase. {type} is an already-localized symptom type label. The English multiplication sign is not idiomatic in Russian or Uzbek, so both use an em dash. Deliberately NOT an ICU plural: it is a numeric badge with no noun for the number to agree with — do not convert it.
  ///
  /// In en, this message translates to:
  /// **'{type} ×{count}'**
  String symptomPhaseTypeCountChip(String type, int count);

  /// Hint under the disabled submit button in the log sheet when no symptom type is selected yet.
  ///
  /// In en, this message translates to:
  /// **'Pick a symptom to continue'**
  String get symptomPickToContinue;

  /// Time-window option in the symptom analytics range selector meaning no lower bound - all history. Sits next to the '30 days'/'90 days' options in the same small selector, so keep it equally short.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get symptomRangeAllTime;

  /// Submit button of the symptom log sheet when editing an existing entry.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get symptomSaveChanges;

  /// Symptom severity option. Shown as a chip and mid-sentence in list subtitles («Слабо · 14:30»), so ru/uz use gender-neutral adverbial forms - do NOT change to adjectives such as «Слабая», there is no noun to agree with.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get symptomSeverityMild;

  /// Symptom severity option. Adverbial form on purpose - it appears standalone in a chip and mid-sentence in list subtitles with no noun to agree with.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get symptomSeverityModerate;

  /// Symptom severity option: the symptom was absent (user recording that they did not have it). Shown as a chip and also mid-sentence in a list subtitle like «Нет · 14:30», so ru/uz deliberately use gender-neutral adverbial forms - do NOT change to adjectives, there is no controlling noun to agree with.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get symptomSeverityNone;

  /// Section heading above the severity chips in the symptom log sheet.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get symptomSeveritySectionLabel;

  /// Symptom severity option (strongest). Adverbial form on purpose - standalone chip and mid-sentence list subtitle, no noun to agree with.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get symptomSeveritySevere;

  /// Section heading above the severity bar chart on the trends screen.
  ///
  /// In en, this message translates to:
  /// **'By severity'**
  String get symptomTrendsBySeverity;

  /// Body copy of the trends-screen empty state.
  ///
  /// In en, this message translates to:
  /// **'Log symptoms to see your trends.'**
  String get symptomTrendsEmptyBody;

  /// Summary card on the trends screen: how many symptom entries fall in the selected window. Russian drops the English verb 'logged' so the noun alone carries agreement (adding a verb would force verb agreement into every plural branch). Uzbek uses the counter word 'ta'. Keep the noun consistent with symptomPhaseEntriesBarLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} entry logged} other{{count} entries logged}}'**
  String symptomTrendsEntriesLogged(int count);

  /// Section heading above the frequency bar chart on the trends screen.
  ///
  /// In en, this message translates to:
  /// **'Most frequent'**
  String get symptomTrendsMostFrequent;

  /// AppBar title of the symptom trends screen, and the tooltip of the icon button on the symptoms list that opens it. Same word in both places.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get symptomTrendsTitle;

  /// Symptom name (other category): breakouts/pimples. Short - renders in chips and chart labels.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get symptomTypeAcne;

  /// OUT OF MY ASSIGNED DIRS (utils/symptom_labels.dart) — symptom type label.
  ///
  /// In en, this message translates to:
  /// **'Anxiety'**
  String get symptomTypeAnxiety;

  /// Symptom name (pain category): lower-back pain. Short - renders in chips and chart labels.
  ///
  /// In en, this message translates to:
  /// **'Backache'**
  String get symptomTypeBackache;

  /// Symptom name (other category): abdominal bloating. Kept short for chips; the abdomen is implied by context.
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get symptomTypeBloating;

  /// Symptom name (pain category). Translate the English as written; the source literal says 'Chest pain' and the ru/uz keep the same breast/chest ambiguity. See notes - product should confirm whether this means breast tenderness before translators are asked to disambiguate.
  ///
  /// In en, this message translates to:
  /// **'Chest pain'**
  String get symptomTypeChestPain;

  /// Symptom name (pain category): period cramps. Renders inside selection chips, list titles and bar-chart labels - must stay short or it truncates.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get symptomTypeCramps;

  /// Symptom name (physical category): feeling energetic - the positive counterpart of Fatigue, not 'energy' as a substance. Short - renders in chips and chart labels.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get symptomTypeEnergy;

  /// Symptom name (physical category). Short - renders in chips and chart labels.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomTypeFatigue;

  /// OUT OF MY ASSIGNED DIRS (utils/symptom_labels.dart) — symptom type label.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomTypeHeadache;

  /// Symptom name (other category): increased sex drive. Pairs with symptomTypeLowLibido - keep the two parallel.
  ///
  /// In en, this message translates to:
  /// **'High libido'**
  String get symptomTypeHighLibido;

  /// Symptom name (physical category). Short - renders in chips and chart labels.
  ///
  /// In en, this message translates to:
  /// **'Insomnia'**
  String get symptomTypeInsomnia;

  /// OUT OF MY ASSIGNED DIRS (utils/symptom_labels.dart) — symptom type label.
  ///
  /// In en, this message translates to:
  /// **'Irritability'**
  String get symptomTypeIrritability;

  /// Symptom name (other category): reduced sex drive. Pairs with symptomTypeHighLibido - keep the two parallel.
  ///
  /// In en, this message translates to:
  /// **'Low libido'**
  String get symptomTypeLowLibido;

  /// OUT OF MY ASSIGNED DIRS (utils/symptom_labels.dart) — symptom type label.
  ///
  /// In en, this message translates to:
  /// **'Mood swings'**
  String get symptomTypeMoodSwings;

  /// Symptom name (discharge category): mucus discharge. Adjective alone; the noun comes from the section header. ru agrees with plural «выделения».
  ///
  /// In en, this message translates to:
  /// **'Mucus'**
  String get symptomTypeMucusDischarge;

  /// Symptom name (other category). Short - renders in chips and chart labels.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomTypeNausea;

  /// OUT OF MY ASSIGNED DIRS (utils/symptom_labels.dart) — symptom type label.
  ///
  /// In en, this message translates to:
  /// **'Sadness'**
  String get symptomTypeSadness;

  /// Symptom name (discharge category): light spotting between periods. ru «Мажущие» agrees with plural «выделения» from the section header.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get symptomTypeSpottingDischarge;

  /// Symptom name (discharge category): watery discharge. The noun ('выделения'/'ajralmalar') is supplied by the section header symptomCategoryDischarge, so keep the adjective alone. ru form agrees with plural «выделения».
  ///
  /// In en, this message translates to:
  /// **'Watery'**
  String get symptomTypeWateryDischarge;

  /// Section heading above the date/time buttons in the symptom log sheet.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get symptomWhenSectionLabel;

  /// Body copy of the symptoms empty state. It quotes the log button's own label, so the quoted word MUST equal symptomLogAction in the same language.
  ///
  /// In en, this message translates to:
  /// **'Tap Log to record how you feel.'**
  String get symptomsEmptyBody;

  /// Headline of the empty state on the symptoms list when the user has never logged anything.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged yet'**
  String get symptomsEmptyTitle;

  /// Section heading for the day's symptom entries. Same literal as the symptoms page app-bar title (owned by another agent) — one key for both.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptomsTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

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
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
