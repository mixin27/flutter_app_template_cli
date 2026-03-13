import 'package:app_core/app_core.dart';
import 'package:app_logger/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_home_summary_use_case.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends ResultBloc<HomeEvent, HomeState> with LoggerMixin {
  HomeBloc(this._getHomeSummaryUseCase, {AppLogger? logger})
      : _logger = logger ?? AppLogger(enabled: false),
        super(const HomeState()) {
    on<HomeRequested>(_onHomeRequested);
  }

  final GetHomeSummaryUseCase _getHomeSummaryUseCase;
  final AppLogger _logger;

  @override
  AppLogger get logger => _logger;

  @override
  LogContext get logContext => const LogContext('HomeBloc');

  Future<void> _onHomeRequested(
    HomeRequested event,
    Emitter<HomeState> emit,
  ) async {
    log.info('Home summary requested');
    await executeResult(
      emit: emit,
      loadingState: state.copyWith(status: HomeStatus.loading),
      request: () => _getHomeSummaryUseCase(const NoParams()),
      onFailure: (failure) {
        log.warning('Failed to load home summary: ${failure.message}');
        return state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        );
      },
      onSuccess: (summary) {
        log.info('Home summary loaded');
        return state.copyWith(
          status: HomeStatus.success,
          summary: summary,
        );
      },
    );
  }
}
