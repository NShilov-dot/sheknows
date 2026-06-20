import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_starter_kit/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.avatarUrl,
    super.emailConfirmed,
  });

  factory UserModel.fromSupabase(User user) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: metadata['full_name'] as String? ??
          metadata['name'] as String? ??
          metadata['display_name'] as String?,
      avatarUrl: metadata['avatar_url'] as String? ?? metadata['picture'] as String?,
      emailConfirmed: user.emailConfirmedAt != null,
    );
  }
}
