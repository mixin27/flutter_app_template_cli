import '../../../../core/network/api_client.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.postJson(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    return AuthSessionModel.fromJson(response);
  }
}
