import 'package:app_network/app_network.dart';

import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<UserProfileModel> getProfile() async {
    final payload = await _apiClient.postMap('/profile');
    return UserProfileModel.fromJson(payload);
  }
}
