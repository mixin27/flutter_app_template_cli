import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> getProfile();

  Future<void> saveProfile(UserProfileModel profile);

  Future<void> seedSampleDataIfEmpty();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  UserProfileModel? _cached;

  @override
  Future<UserProfileModel?> getProfile() async {
    return _cached;
  }

  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    _cached = profile;
  }

  @override
  Future<void> seedSampleDataIfEmpty() async {
    _cached ??= UserProfileModel(
      id: 'user-001',
      fullName: 'Alex Morgan',
      email: 'alex@example.com',
      role: 'Product Lead',
      joinedAt: DateTime.now().subtract(const Duration(days: 120)),
    );
  }
}
