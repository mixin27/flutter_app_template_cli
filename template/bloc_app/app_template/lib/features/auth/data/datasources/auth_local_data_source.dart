import '../../../../data/database/app_database.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._dao);

  final AuthDao _dao;

  Future<AuthTokenRecord?> getToken() => _dao.getToken();

  Future<void> saveToken({
    required String token,
    required String userId,
    required String userName,
    required String userEmail,
  }) {
    return _dao.saveToken(
      token: token,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
    );
  }

  Future<void> clearToken() => _dao.clearToken();
}
