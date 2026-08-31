// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'sheknows';

  @override
  String get authConfirmEmailNotice =>
      'Hisobingizni tasdiqlash uchun emailingizni tekshiring.';

  @override
  String get authConfirmPasswordLabel => 'Parolni tasdiqlang';

  @override
  String get authContinueWithGoogle => 'Google bilan davom etish';

  @override
  String get authDividerOr => 'yoki';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authHasAccountPrompt => 'Hisobingiz bormi?';

  @override
  String get authHidePassword => 'Parolni yashirish';

  @override
  String get authLoginSubtitle => 'Davom etish uchun tizimga kiring';

  @override
  String get authLoginTitle => 'Xush kelibsiz';

  @override
  String get authNoAccountPrompt => 'Hisobingiz yoʻqmi?';

  @override
  String get authPasswordLabel => 'Parol';

  @override
  String authPasswordRulesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kamida $count ta belgi, harf va raqam bilan',
    );
    return '$_temp0';
  }

  @override
  String get authRegisterSubtitle =>
      'Email yoki Google orqali roʻyxatdan oʻting';

  @override
  String get authRegisterTitle => 'Hisob yaratish';

  @override
  String get authShowPassword => 'Parolni koʻrsatish';

  @override
  String get authSignIn => 'Kirish';

  @override
  String get authSignUp => 'Roʻyxatdan oʻtish';

  @override
  String get authValidationConfirmPasswordRequired => 'Parolni tasdiqlang';

  @override
  String get authValidationEmailInvalid => 'Toʻgʻri email manzilini kiriting';

  @override
  String get authValidationEmailRequired => 'Emailni kiriting';

  @override
  String get authValidationPasswordNeedsLetterAndNumber =>
      'Parolda kamida bitta harf va bitta raqam boʻlishi kerak';

  @override
  String get authValidationPasswordNoSurroundingSpaces =>
      'Parol boʻsh joy bilan boshlanmasligi va tugamasligi kerak';

  @override
  String get authValidationPasswordRequired => 'Parolni kiriting';

  @override
  String authValidationPasswordTooShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Parol kamida $count ta belgidan iborat boʻlishi kerak',
    );
    return '$_temp0';
  }

  @override
  String get authValidationPasswordsDoNotMatch => 'Parollar mos kelmaydi';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String commonDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kun',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Oʻchirish';

  @override
  String get commonGoHome => 'Bosh sahifaga';

  @override
  String get commonNext => 'Keyingi';

  @override
  String get commonNotes => 'Eslatmalar';

  @override
  String get commonPageNotFoundBody => 'Bu havola hech qayerga olib bormaydi.';

  @override
  String get commonPageNotFoundTitle => 'Sahifa topilmadi';

  @override
  String get commonSkip => 'Oʻtkazib yuborish';

  @override
  String get commonStartupFailureBody =>
      'Koʻpincha ilovani qayta ishga tushirish yetarli boʻladi. Agar muammo takrorlansa, quyidagi maʼlumotlarni bizga yuboring.';

  @override
  String get commonStartupFailureTitle => 'sheknows ishga tushmadi';

  @override
  String get commonTryAgain => 'Qayta urinish';

  @override
  String get cycleCalendarNextMonth => 'Keyingi oy';

  @override
  String get cycleCalendarPreviousMonth => 'Oldingi oy';

  @override
  String get cycleClearThisDay => 'Bu kunni tozalash';

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
  String get cycleDayCellStateHasNotes => 'eslatmalar bor';

  @override
  String get cycleDayCellStateIntimacyLogged => 'yaqinlik belgilangan';

  @override
  String get cycleDayCellStatePeriodLogged => 'hayz belgilangan';

  @override
  String get cycleDayCellStatePredictedPeriod => 'hayz prognozi';

  @override
  String get cycleDayCellStatePredictedStart => 'hayzning taxminiy boshlanishi';

  @override
  String get cycleDayCellStateToday => 'bugun';

  @override
  String cycleDayHeaderDate(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat.yMMMMEEEEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get cycleDayHowWasYourDay => 'Kuningiz qanday oʻtdi?';

  @override
  String get cycleDayNoSymptoms => 'Bu kun uchun simptomlar belgilanmagan';

  @override
  String get cycleDayNotesHint =>
      'Bugun haqida eslab qolmoqchi boʻlgan narsalar';

  @override
  String get cycleDeleteThisPeriod => 'Bu hayzni oʻchirish';

  @override
  String get cycleEndPeriodButton => 'Bugun yakunlash';

  @override
  String get cycleEndPeriodOnThisDay => 'Hayzni shu kuni tugatish';

  @override
  String get cycleFlowHeavy => 'Kuchli';

  @override
  String get cycleFlowLight => 'Kam';

  @override
  String get cycleFlowMedium => 'Oʻrtacha';

  @override
  String get cycleHistoryEmptyBody =>
      'Kuzatishni boshlash uchun «Hayzim bugun boshlandi» tugmasini bosing.';

  @override
  String get cycleHistoryEmptyTitle => 'Hali hayz qayd etilmagan';

  @override
  String get cycleHistoryFlowHeavy => 'Kuchli qon ketishi';

  @override
  String get cycleHistoryFlowLight => 'Kam qon ketishi';

  @override
  String get cycleHistoryFlowMedium => 'Oʻrtacha qon ketishi';

  @override
  String get cycleHistoryMenuTooltip => 'Yozuv amallari';

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

    return '$startString – davom etmoqda';
  }

  @override
  String get cycleHistoryReopen => 'Qayta ochish (davom etmoqda)';

  @override
  String get cycleHistorySaving => 'saqlanmoqda…';

  @override
  String get cycleHistoryTitle => 'Tarix';

  @override
  String get cycleInsightsAvgCycleLength => 'Oʻrtacha tsikl uzunligi';

  @override
  String get cycleInsightsAvgPeriodLength => 'Oʻrtacha hayz davomiyligi';

  @override
  String cycleInsightsBleedingDay(int day) {
    return 'Qon ketishning $day-kuni';
  }

  @override
  String get cycleInsightsCurrentPeriod => 'Hozirgi hayz';

  @override
  String get cycleInsightsLoggedPeriods => 'Qayd etilgan hayzlar';

  @override
  String get cycleInsightsNextPeriod => 'Hayz prognozi';

  @override
  String get cycleInsightsPredictionHint =>
      'Tsikl prognozini koʻrish uchun kamida ikki hayzni qayd eting.';

  @override
  String get cycleInsightsTitle => 'Statistika';

  @override
  String get cycleIntimacy => 'Yaqinlik';

  @override
  String get cycleIntimacyProtected => 'Himoyalangan';

  @override
  String get cycleIntimacyUnprotected => 'Himoyasiz';

  @override
  String get cycleLegendLogged => 'Belgilangan';

  @override
  String get cycleLegendPredicted => 'Prognoz';

  @override
  String get cycleLegendToday => 'Bugun';

  @override
  String cycleMoonDayOfTotal(int day, int total) {
    return '$total kundan $day-kun';
  }

  @override
  String get cycleMoonHintFirstQuarter => 'Barqaror surʼat';

  @override
  String get cycleMoonHintFullMoon => 'Tsiklning eng yuqori nuqtasi';

  @override
  String get cycleMoonHintLastQuarter => 'Oʻylash va dam olish vaqti';

  @override
  String get cycleMoonHintNewMoon =>
      'Hayz boshlangan yoki tez orada boshlanadi';

  @override
  String get cycleMoonHintWaningCrescent => 'Oʻzingizga mehribon boʻling';

  @override
  String get cycleMoonHintWaningGibbous => 'Pasayish boshlanadi';

  @override
  String get cycleMoonHintWaxingCrescent => 'Energiya toʻplanib bormoqda';

  @override
  String get cycleMoonHintWaxingGibbous => 'Ovulyatsiya yaqinlashmoqda';

  @override
  String get cycleMoonPhaseFirstQuarter => 'Birinchi chorak';

  @override
  String get cycleMoonPhaseFullMoon => 'Toʻlin oy';

  @override
  String get cycleMoonPhaseLastQuarter => 'Oxirgi chorak';

  @override
  String cycleMoonPhaseLine(String phase, String hint) {
    return '$phase · $hint';
  }

  @override
  String get cycleMoonPhaseNewMoon => 'Yangi oy';

  @override
  String get cycleMoonPhaseWaningCrescent => 'Soʻnuvchi yarim oy';

  @override
  String get cycleMoonPhaseWaningGibbous => 'Kamayayotgan oy';

  @override
  String get cycleMoonPhaseWaxingCrescent => 'Oʻsuvchi yarim oy';

  @override
  String get cycleMoonPhaseWaxingGibbous => 'Toʻlishayotgan oy';

  @override
  String cycleMoonSemantics(int day, int total, String phase, String hint) {
    return 'Tsiklning $day-kuni, jami $total. $phase. $hint';
  }

  @override
  String cycleNextPeriodDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get cyclePeriodStartPickerHelp => 'Hayz qachon boshlandi?';

  @override
  String get cyclePeriodStartedOnThisDay => 'Hayz shu kuni boshlandi';

  @override
  String get cyclePhaseFollicular => 'Follikulyar faza';

  @override
  String get cyclePhaseLuteal => 'Lyuteal faza';

  @override
  String get cyclePhaseMenstrual => 'Hayz';

  @override
  String get cyclePhaseOvulation => 'Ovulyatsiya';

  @override
  String get cyclePhaseUnknown => 'Aniqlanmagan';

  @override
  String get cycleSaveDay => 'Kunni saqlash';

  @override
  String get cycleStartPeriodButton => 'Hayzim bugun boshlandi';

  @override
  String cycleStatusBleedingDay(int dayNumber) {
    return 'Qon ketishi · hayzning $dayNumber-kuni';
  }

  @override
  String cycleStatusCycleDay(int cycleDay) {
    return 'Tsiklning $cycleDay-kuni';
  }

  @override
  String cycleStatusDayOfPeriod(int count, int dayNumber) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kunlik hayzning $dayNumber-kuni',
    );
    return '$_temp0';
  }

  @override
  String get cycleStatusNoData => 'Bu kun uchun hayz maʼlumotlari yoʻq';

  @override
  String get cycleStatusPredictedStart => 'Hayzning taxminiy boshlanishi';

  @override
  String get cycleStatusUpcoming => 'Kelgusi kun';

  @override
  String get cycleTitle => 'Tsikl';

  @override
  String get errorAuthGeneric =>
      'Boʻlmadi. Maʼlumotlarni tekshirib, qayta urinib koʻring.';

  @override
  String get errorNetworkOffline =>
      'Internet aloqasi yoʻq. Oʻzgarishlar shu qurilmada saqlandi va aloqa tiklanganda sinxronlanadi.';

  @override
  String get errorServer =>
      'Bizning tomonda xatolik yuz berdi. Bir ozdan soʻng qayta urinib koʻring.';

  @override
  String get errorUnknown => 'Xatolik yuz berdi. Qayta urinib koʻring.';

  @override
  String get homeAppBarTitle => 'sheknows';

  @override
  String get homeDeleteAccountButton => 'Hisobni oʻchirish';

  @override
  String get homeDeleteAccountDialogBody =>
      'Hisobingiz va barcha maʼlumotlaringiz butunlay oʻchiriladi. Buni bekor qilib boʻlmaydi.';

  @override
  String get homeDeleteAccountDialogTitle => 'Hisob oʻchirilsinmi?';

  @override
  String get homeEmailConfirmedNo => 'E-pochta tasdiqlangan: Yoʻq';

  @override
  String get homeEmailConfirmedYes => 'E-pochta tasdiqlangan: Ha';

  @override
  String homeEmailLabel(String email) {
    return 'E-pochta: $email';
  }

  @override
  String get homeGoPremiumButton => 'Premiumga oʻtish';

  @override
  String get homeLogSymptomsButton => 'Simptomlarni belgilash';

  @override
  String get homeProfileLoadedFromDatabase => 'profiles jadvalidan yuklandi.';

  @override
  String homeProfileNameLabel(String name) {
    return 'Ism: $name';
  }

  @override
  String get homeProfileNameNotSet => 'Koʻrsatilmagan';

  @override
  String get homeProfileNoRowFound =>
      'Profil yozuvi topilmadi (autentifikatsiya metamaʼlumotlari koʻrsatilmoqda).';

  @override
  String get homeProfileSectionTitle => 'Profil';

  @override
  String get homeSignOutTooltip => 'Chiqish';

  @override
  String get homeSignedIn => 'Tizimga kirdingiz';

  @override
  String get homeTrackCycleButton => 'Tsiklni kuzatish';

  @override
  String get onboardingGetStarted => 'Boshlash';

  @override
  String get onboardingPatternsHeadline =>
      'Nafaqat simptomlarni, balki qonuniyatlarni ham koʻring.';

  @override
  String get onboardingPatternsSubtext =>
      'Siz qayd etgan har bir simptom tsikl fazasiga avtomatik moslanadi — nima sodir boʻlayotganini faza boʻyicha koʻring.';

  @override
  String get onboardingPredictHeadline =>
      'Keyingi hayz kunlarini oldindan bilib oling.';

  @override
  String get onboardingPredictSubtext =>
      'sheknows sizning ritmingizni oʻrganib, tsiklni oldindan aytadi — hech narsa sizni kutilmaganda ushlamaydi.';

  @override
  String get symptomAddSymptom => 'Simptomni qo\'shish';

  @override
  String symptomBarRowSemanticsLabel(String label, String value) {
    return '$label: $value';
  }

  @override
  String get symptomCategoryDischarge => 'Ajralmalar';

  @override
  String get symptomCategoryMood => 'Kayfiyat';

  @override
  String get symptomCategoryOther => 'Boshqa';

  @override
  String get symptomCategoryPain => 'Og\'riq';

  @override
  String get symptomCategoryPhysical => 'Tana';

  @override
  String get symptomEmptyWindowTitle => 'Bu davrda simptomlar yo\'q';

  @override
  String symptomHistoryTileSubtitle(String severity, String time) {
    return '$severity · $time';
  }

  @override
  String get symptomJustAMoment => 'Bir lahza…';

  @override
  String get symptomLoadFailedCloseSheet =>
      'Simptomlarni yuklab bo\'lmadi — oynani yopib, qaytadan urinib ko\'ring';

  @override
  String get symptomLogAction => 'Qoʻshish';

  @override
  String get symptomLogSheetEditTitle => 'Simptomni tahrirlash';

  @override
  String get symptomLogSheetNewTitle => 'Simptom qo\'shish';

  @override
  String get symptomNotesHint => 'Eslab qolishga arziydigan narsa';

  @override
  String get symptomPhaseEmptyLogBothBody =>
      'Fazalar bo\'yicha o\'zgarishlarni ko\'rish uchun simptomlar va hayz kunlarini belgilang.';

  @override
  String get symptomPhaseEmptyLogPeriodsBody =>
      'Fazalar bo\'yicha o\'zgarishlarni ko\'rish uchun hayz kunlarini belgilang.';

  @override
  String get symptomPhaseEntriesBarLabel => 'Yozuvlar';

  @override
  String get symptomPhaseNoCycleDataTitle =>
      'Bu davr uchun tsikl ma\'lumotlari yo\'q';

  @override
  String get symptomPhaseNotEnoughCycleData =>
      'Tsikl haqida ma\'lumot yetarli emas';

  @override
  String get symptomPhaseTitle => 'Tsikl fazalari bo\'yicha';

  @override
  String symptomPhaseTypeCountChip(String type, int count) {
    return '$type — $count';
  }

  @override
  String get symptomPickToContinue => 'Davom etish uchun simptomni tanlang';

  @override
  String get symptomRangeAllTime => 'Butun davr';

  @override
  String get symptomSaveChanges => 'O\'zgarishlarni saqlash';

  @override
  String get symptomSeverityMild => 'Yengil';

  @override
  String get symptomSeverityModerate => 'O\'rtacha';

  @override
  String get symptomSeverityNone => 'Yo\'q';

  @override
  String get symptomSeveritySectionLabel => 'Darajasi';

  @override
  String get symptomSeveritySevere => 'Kuchli';

  @override
  String get symptomTrendsBySeverity => 'Daraja bo\'yicha';

  @override
  String get symptomTrendsEmptyBody =>
      'Dinamikani ko\'rish uchun simptomlarni yozib boring.';

  @override
  String symptomTrendsEntriesLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta yozuv',
    );
    return '$_temp0';
  }

  @override
  String get symptomTrendsMostFrequent => 'Eng ko\'p uchraydigan';

  @override
  String get symptomTrendsTitle => 'Dinamika';

  @override
  String get symptomTypeAcne => 'Husnbuzar';

  @override
  String get symptomTypeAnxiety => 'Xavotir';

  @override
  String get symptomTypeBackache => 'Bel og\'rig\'i';

  @override
  String get symptomTypeBloating => 'Dam bo\'lish';

  @override
  String get symptomTypeChestPain => 'Ko\'krak og\'rig\'i';

  @override
  String get symptomTypeCramps => 'Spazmlar';

  @override
  String get symptomTypeEnergy => 'Tetiklik';

  @override
  String get symptomTypeFatigue => 'Holsizlik';

  @override
  String get symptomTypeHeadache => 'Bosh og\'rig\'i';

  @override
  String get symptomTypeHighLibido => 'Libido baland';

  @override
  String get symptomTypeInsomnia => 'Uyqusizlik';

  @override
  String get symptomTypeIrritability => 'Asabiylik';

  @override
  String get symptomTypeLowLibido => 'Libido past';

  @override
  String get symptomTypeMoodSwings => 'Kayfiyat o\'zgarishi';

  @override
  String get symptomTypeMucusDischarge => 'Shilimshiq';

  @override
  String get symptomTypeNausea => 'Ko\'ngil aynishi';

  @override
  String get symptomTypeSadness => 'G\'amginlik';

  @override
  String get symptomTypeSpottingDischarge => 'Dog\'lanish';

  @override
  String get symptomTypeWateryDischarge => 'Suvsimon';

  @override
  String get symptomWhenSectionLabel => 'Qachon';

  @override
  String get symptomsEmptyBody =>
      'Oʻzingizni qanday his qilayotganingizni yozish uchun «Qoʻshish»ni bosing.';

  @override
  String get symptomsEmptyTitle => 'Hali hech qanday simptom yozilmagan';

  @override
  String get symptomsTitle => 'Simptomlar';
}
