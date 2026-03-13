import 'package:app_core/app_core.dart';
import 'package:app_logger/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_session_use_case.dart';
import '../../domain/usecases/login_with_method_use_case.dart';
import '../../domain/usecases/login_with_password_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/request_phone_otp_use_case.dart';
import '../../domain/usecases/verify_phone_otp_use_case.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends ResultBloc<AuthEvent, AuthState> with LoggerMixin {
  AuthBloc(
    this._getCurrentSessionUseCase,
    this._logoutUseCase,
    this._requestPhoneOtpUseCase,
    this._verifyPhoneOtpUseCase,
    this._loginWithPasswordUseCase,
    this._loginWithMethodUseCase, {
    AppLogger? logger,
  }) : _logger = logger ?? AppLogger(enabled: false),
       super(const AuthState()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
    on<SessionExpired>(_onSessionExpired);
    on<PhoneOtpRequested>(_onPhoneOtpRequested);
    on<PhoneOtpVerified>(_onPhoneOtpVerified);
    on<EmailPasswordLoginRequested>(_onEmailPasswordLoginRequested);
    on<MethodLoginRequested>(_onMethodLoginRequested);
  }

  final GetCurrentSessionUseCase _getCurrentSessionUseCase;
  final LogoutUseCase _logoutUseCase;
  final RequestPhoneOtpUseCase _requestPhoneOtpUseCase;
  final VerifyPhoneOtpUseCase _verifyPhoneOtpUseCase;
  final LoginWithPasswordUseCase _loginWithPasswordUseCase;
  final LoginWithMethodUseCase _loginWithMethodUseCase;
  final AppLogger _logger;

  @override
  AppLogger get logger => _logger;

  @override
  LogContext get logContext => const LogContext('AuthBloc');

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    log.info('Checking existing session');
    await executeResult(
      emit: emit,
      loadingState: state.copyWith(
        status: AuthStatus.checking,
        clearErrorMessage: true,
      ),
      request: () => _getCurrentSessionUseCase(const NoParams()),
      onFailure: (failure) {
        log.warning('Session check failed: ${failure.message}');
        return state.copyWith(
          status: AuthStatus.failure,
          clearSession: true,
          clearOtpChallenge: true,
          errorMessage: failure.message,
        );
      },
      onSuccess: (session) {
        final status = session.isAuthenticated
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
        log.info('Session resolved: $status');
        return state.copyWith(
          status: status,
          session: session,
          clearOtpChallenge: true,
          clearErrorMessage: true,
        );
      },
    );
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    log.info('Session marked as logged in');
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        session: event.session,
        clearOtpChallenge: true,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    log.info('Logout requested');
    await executeResult(
      emit: emit,
      loadingState: state.copyWith(
        status: AuthStatus.loggingOut,
        clearErrorMessage: true,
      ),
      request: () =>
          _logoutUseCase(LogoutParams(revokeRemote: event.revokeRemote)),
      onFailure: (failure) {
        log.warning('Logout failed: ${failure.message}');
        return state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        );
      },
      onSuccess: (_) {
        log.info('Logout completed');
        return state.copyWith(
          status: AuthStatus.unauthenticated,
          clearSession: true,
          clearOtpChallenge: true,
          clearErrorMessage: true,
        );
      },
    );
  }

  Future<void> _onSessionExpired(
    SessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    log.warning('Session expired');
    await _logoutUseCase(const LogoutParams(revokeRemote: false));
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        clearSession: true,
        clearOtpChallenge: true,
        errorMessage: 'Session expired. Please sign in again.',
      ),
    );
  }

  Future<void> _onPhoneOtpRequested(
    PhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    log.info('Phone OTP requested (${event.purpose.value})');
    await executeResult(
      emit: emit,
      loadingState: state.copyWith(
        status: AuthStatus.authenticating,
        clearErrorMessage: true,
      ),
      request: () => _requestPhoneOtpUseCase(
        RequestPhoneOtpParams(
          phoneNumber: event.phoneNumber,
          purpose: event.purpose,
        ),
      ),
      onFailure: (failure) {
        log.warning('Phone OTP request failed: ${failure.message}');
        return state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        );
      },
      onSuccess: (challenge) {
        log.info('Phone OTP challenge generated');
        return state.copyWith(
          status: AuthStatus.otpRequested,
          otpChallenge: challenge,
          clearErrorMessage: true,
        );
      },
    );
  }

  Future<void> _onPhoneOtpVerified(
    PhoneOtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    log.info('Verifying phone OTP (${event.purpose.value})');
    await executeResult(
      emit: emit,
      loadingState: state.copyWith(
        status: AuthStatus.authenticating,
        clearErrorMessage: true,
      ),
      request: () => _verifyPhoneOtpUseCase(
        VerifyPhoneOtpParams(
          phoneNumber: event.phoneNumber,
          otpCode: event.otpCode,
          purpose: event.purpose,
          challengeId: event.challengeId,
        ),
      ),
      onFailure: (failure) {
        log.warning('Phone OTP verification failed: ${failure.message}');
        return state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        );
      },
      onSuccess: (session) {
        log.info('Phone OTP login completed');
        return state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          clearOtpChallenge: true,
          clearErrorMessage: true,
        );
      },
    );
  }

  Future<void> _onEmailPasswordLoginRequested(
    EmailPasswordLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    log.info('Email/password login requested');
    await executeResult(
      emit: emit,
      loadingState: state.copyWith(
        status: AuthStatus.authenticating,
        clearErrorMessage: true,
      ),
      request: () => _loginWithPasswordUseCase(
        LoginWithPasswordParams(
          identifier: event.identifier,
          password: event.password,
        ),
      ),
      onFailure: (failure) {
        log.warning('Email/password login failed: ${failure.message}');
        return state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        );
      },
      onSuccess: (session) {
        log.info('Email/password login completed');
        return state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          clearOtpChallenge: true,
          clearErrorMessage: true,
        );
      },
    );
  }

  Future<void> _onMethodLoginRequested(
    MethodLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    log.info('Method-based login requested (${event.method.type.value})');
    await executeResult(
      emit: emit,
      loadingState: state.copyWith(
        status: AuthStatus.authenticating,
        clearErrorMessage: true,
      ),
      request: () =>
          _loginWithMethodUseCase(LoginWithMethodParams(event.method)),
      onFailure: (failure) {
        log.warning('Method-based login failed: ${failure.message}');
        return state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        );
      },
      onSuccess: (session) {
        log.info('Method-based login completed');
        return state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          clearOtpChallenge: true,
          clearErrorMessage: true,
        );
      },
    );
  }
}
