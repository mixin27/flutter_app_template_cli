import 'package:app_core/app_core.dart';
import 'package:app_logger/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_profile_use_case.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends ResultBloc<ProfileEvent, ProfileState>
    with LoggerMixin {
  ProfileBloc(this._getProfileUseCase, {AppLogger? logger})
      : _logger = logger ?? AppLogger(enabled: false),
        super(const ProfileState()) {
    on<ProfileRequested>(_onProfileRequested);
  }

  final GetProfileUseCase _getProfileUseCase;
  final AppLogger _logger;

  @override
  AppLogger get logger => _logger;

  @override
  LogContext get logContext => const LogContext('ProfileBloc');

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    log.info('Profile requested');
    await executeResult(
      emit: emit,
      loadingState: state.copyWith(status: ProfileStatus.loading),
      request: () => _getProfileUseCase(const NoParams()),
      onFailure: (failure) {
        log.warning('Failed to load profile: ${failure.message}');
        return state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
        );
      },
      onSuccess: (profile) {
        log.info('Profile loaded');
        return state.copyWith(
          status: ProfileStatus.success,
          profile: profile,
        );
      },
    );
  }
}
