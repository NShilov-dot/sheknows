import 'package:purchases_flutter/purchases_flutter.dart';

/// Keeps the RevenueCat app user id in sync with the Supabase auth session.
///
/// Fire-and-forget: identity sync failures must never block the auth flow —
/// entitlements simply stay on the anonymous id until the next sync.
class RevenueCatIdentity {
  const RevenueCatIdentity._();

  static Future<void> logIn(String userId) async {
    try {
      // Native side aborts the process (Swift fatalError) instead of
      // throwing when RevenueCat was never configured — dev mode skips
      // configure(), so the catch below would never see it.
      if (!await Purchases.isConfigured) return;
      final info = await Purchases.getCustomerInfo();
      if (info.originalAppUserId == userId) return;
      await Purchases.logIn(userId);
    } catch (_) {
      // Non-fatal; see class doc. Broad catch also covers
      // MissingPluginException in widget/bloc tests.
    }
  }

  static Future<void> logOut() async {
    try {
      // Native side aborts the process (Swift fatalError) instead of
      // throwing when RevenueCat was never configured — dev mode skips
      // configure(), so the catch below would never see it.
      if (!await Purchases.isConfigured) return;
      final info = await Purchases.getCustomerInfo();
      // logOut on an anonymous user throws — skip it.
      if (info.originalAppUserId.startsWith(r'$RCAnonymousID:')) return;
      await Purchases.logOut();
    } catch (_) {
      // Non-fatal; see class doc.
    }
  }
}
