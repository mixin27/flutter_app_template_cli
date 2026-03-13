import 'package:app_core/app_core.dart';
import 'package:app_logger/app_logger.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl with LoggerMixin implements ProfileRepository {
  ProfileRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource, {
    AppLogger? logger,
  }) : _logger = logger ?? AppLogger(enabled: false);

  final ProfileLocalDataSource _localDataSource;
  final ProfileRemoteDataSource _remoteDataSource;
  final AppLogger _logger;

  @override
  AppLogger get logger => _logger;

  @override
  LogContext get logContext => const LogContext('ProfileRepo');

  @override
  Future<Result<UserProfile>> getProfile() async {
    try {
      final cached = await _localDataSource.getProfile();
      if (cached != null) {
        log.debug('Loaded profile from cache');
      }

      try {
        log.debug('Refreshing profile from remote source');
        final remote = await _remoteDataSource.getProfile();
        await _localDataSource.saveProfile(remote);
        return Result.success(remote);
      } catch (error) {
        if (cached != null) {
          log.warning('Remote profile fetch failed, using cached');
          return Result.success(cached);
        }

        log.error('Failed to load profile', error: error);
        return Result.failure(FailureMapper.from(error));
      }
    } catch (error) {
      log.error('Profile read failed', error: error);
      return Result.failure(FailureMapper.from(error));
    }
  }
}
