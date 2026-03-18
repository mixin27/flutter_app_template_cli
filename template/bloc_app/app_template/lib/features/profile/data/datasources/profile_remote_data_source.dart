import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client);

  final ApiClient _client;

  Future<ProfileModel> fetchProfile({required String token}) async {
    final response = await _client.getJson('/profile', token: token);
    return ProfileModel.fromJson(response);
  }
}
