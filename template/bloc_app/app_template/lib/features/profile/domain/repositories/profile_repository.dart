import '../../../../core/result/result.dart';
import '../entities/profile.dart';

class ProfileResult {
  const ProfileResult({required this.profile, required this.isFromCache});

  final Profile profile;
  final bool isFromCache;
}

abstract class ProfileRepository {
  Future<Result<ProfileResult>> fetchProfile({bool forceRefresh = false});
}
