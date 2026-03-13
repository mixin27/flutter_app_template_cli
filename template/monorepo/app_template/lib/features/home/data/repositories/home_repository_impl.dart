import 'package:app_core/app_core.dart';
import 'package:app_logger/app_logger.dart';

import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl with LoggerMixin implements HomeRepository {
  HomeRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource, {
    AppLogger? logger,
  }) : _logger = logger ?? AppLogger(enabled: false);

  final HomeLocalDataSource _localDataSource;
  final HomeRemoteDataSource _remoteDataSource;
  final AppLogger _logger;

  @override
  AppLogger get logger => _logger;

  @override
  LogContext get logContext => const LogContext('HomeRepo');

  @override
  Future<Result<HomeSummary>> getSummary() async {
    try {
      final cached = await _localDataSource.getSummary();
      if (cached != null) {
        log.debug('Loaded home summary from cache');
      }

      try {
        log.debug('Refreshing home summary from remote source');
        final remote = await _remoteDataSource.getSummary();
        await _localDataSource.saveSummary(remote);
        return Result.success(remote);
      } catch (error) {
        if (cached != null) {
          log.warning('Remote sync failed, using cached summary');
          return Result.success(cached);
        }

        log.error('Failed to load home summary', error: error);
        return Result.failure(FailureMapper.from(error));
      }
    } catch (error) {
      log.error('Home summary read failed', error: error);
      return Result.failure(FailureMapper.from(error));
    }
  }
}
