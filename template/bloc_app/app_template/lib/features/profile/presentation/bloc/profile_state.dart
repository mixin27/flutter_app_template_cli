part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, ready, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.isFromCache = false,
    this.errorMessage,
  });

  final ProfileStatus status;
  final Profile? profile;
  final bool isFromCache;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    bool? isFromCache,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      isFromCache: isFromCache ?? this.isFromCache,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, isFromCache, errorMessage];
}
