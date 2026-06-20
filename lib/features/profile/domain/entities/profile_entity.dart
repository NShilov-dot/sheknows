import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.id,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String? displayName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, displayName, avatarUrl];
}
