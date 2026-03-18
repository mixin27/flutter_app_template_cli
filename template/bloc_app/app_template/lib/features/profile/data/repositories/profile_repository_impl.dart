import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/result/result.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required ProfileLocalDataSource local,
    required NetworkInfo networkInfo,
    required AuthLocalDataSource authLocal,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo,
       _authLocal = authLocal;

  final ProfileRemoteDataSource _remote;
  final ProfileLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final AuthLocalDataSource _authLocal;

  @override
  Future<Result<ProfileResult>> fetchProfile({
    bool forceRefresh = false,
  }) async {
    final tokenRecord = await _authLocal.getToken();
    if (tokenRecord == null) {
      return Result.failure(
        const ValidationFailure(message: 'No active session found.'),
      );
    }

    final cached = await _local.getProfile(tokenRecord.userId);
    if (cached != null && !forceRefresh) {
      return Result.success(
        ProfileResult(
          profile: ProfileModel.fromRecord(cached).toEntity(),
          isFromCache: true,
        ),
      );
    }

    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      if (cached != null) {
        return Result.success(
          ProfileResult(
            profile: ProfileModel.fromRecord(cached).toEntity(),
            isFromCache: true,
          ),
        );
      }
      return Result.failure(
        const ValidationFailure(message: 'No network connection available.'),
      );
    }

    try {
      final remoteProfile = await _remote.fetchProfile(
        token: tokenRecord.token,
      );
      await _local.saveProfile(remoteProfile.toRecord());

      return Result.success(
        ProfileResult(profile: remoteProfile.toEntity(), isFromCache: false),
      );
    } catch (error) {
      if (cached != null) {
        return Result.success(
          ProfileResult(
            profile: ProfileModel.fromRecord(cached).toEntity(),
            isFromCache: true,
          ),
        );
      }
      return Result.failure(
        DatabaseFailure(message: 'Unable to load profile: $error'),
      );
    }
  }
}
