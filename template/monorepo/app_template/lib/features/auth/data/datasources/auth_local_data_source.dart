import 'package:app_network/app_network.dart';

abstract class AuthLocalDataSource {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> saveTokens(AuthTokens tokens);

  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._tokenStore);

  final AuthTokenStore _tokenStore;

  @override
  Future<void> clearTokens() {
    return _tokenStore.clearTokens();
  }

  @override
  Future<String?> readAccessToken() {
    return _tokenStore.readAccessToken();
  }

  @override
  Future<String?> readRefreshToken() {
    return _tokenStore.readRefreshToken();
  }

  @override
  Future<void> saveTokens(AuthTokens tokens) {
    return _tokenStore.saveTokens(tokens);
  }
}
