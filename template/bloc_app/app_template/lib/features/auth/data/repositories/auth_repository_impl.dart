import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<AuthSession?> getSession() async {
    final tokenRecord = await _local.getToken();
    if (tokenRecord == null) {
      return null;
    }

    return AuthSession(
      token: tokenRecord.token,
      user: User(
        id: tokenRecord.userId,
        name: tokenRecord.userName,
        email: tokenRecord.userEmail,
      ),
    );
  }

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure(message: 'Email and password are required.'),
      );
    }

    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      final cachedSession = await getSession();
      if (cachedSession != null) {
        return Result.success(cachedSession);
      }
      return Result.failure(
        const ValidationFailure(message: 'No network connection available.'),
      );
    }

    try {
      final session = await _remote.login(
        email: email.trim(),
        password: password.trim(),
      );

      await _local.saveToken(
        token: session.token,
        userId: session.user.id,
        userName: session.user.name,
        userEmail: session.user.email,
      );

      return Result.success(session.toEntity());
    } catch (error) {
      return Result.failure(DatabaseFailure(message: 'Sign-in failed: $error'));
    }
  }

  @override
  Future<void> signOut() async {
    await _local.clearToken();
  }
}
