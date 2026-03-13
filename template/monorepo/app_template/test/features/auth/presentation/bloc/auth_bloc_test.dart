import 'package:__APP_NAME__/features/auth/domain/entities/auth_login_method.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/auth_session.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/phone_otp_challenge.dart';
import 'package:__APP_NAME__/features/auth/domain/repositories/auth_repository.dart';
import 'package:__APP_NAME__/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:__APP_NAME__/features/auth/domain/usecases/login_with_method_use_case.dart';
import 'package:__APP_NAME__/features/auth/domain/usecases/login_with_password_use_case.dart';
import 'package:__APP_NAME__/features/auth/domain/usecases/logout_use_case.dart';
import 'package:__APP_NAME__/features/auth/domain/usecases/request_phone_otp_use_case.dart';
import 'package:__APP_NAME__/features/auth/domain/usecases/verify_phone_otp_use_case.dart';
import 'package:__APP_NAME__/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:__APP_NAME__/features/auth/presentation/bloc/auth_event.dart';
import 'package:__APP_NAME__/features/auth/presentation/bloc/auth_state.dart';
import 'package:app_core/app_core.dart';
import 'package:app_network/app_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppStarted emits unauthenticated when no session', () async {
    final repository = _FakeAuthRepository(
      currentSession: const AuthSession.unauthenticated(),
    );
    final bloc = _buildBloc(repository);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthState>().having(
          (state) => state.status,
          'status',
          AuthStatus.checking,
        ),
        isA<AuthState>().having(
          (state) => state.status,
          'status',
          AuthStatus.unauthenticated,
        ),
      ]),
    );

    bloc.add(const AppStarted());
    await expectation;
    await bloc.close();
  });

  test('EmailPasswordLoginRequested emits authenticated state', () async {
    final repository = _FakeAuthRepository(
      methodLoginSession: const AuthSession.authenticated(
        accessToken: 'access',
        refreshToken: 'refresh',
      ),
    );
    final bloc = _buildBloc(repository);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthState>().having(
          (state) => state.status,
          'status',
          AuthStatus.authenticating,
        ),
        isA<AuthState>().having(
          (state) => state.status,
          'status',
          AuthStatus.authenticated,
        ),
      ]),
    );

    bloc.add(
      const EmailPasswordLoginRequested(
        identifier: 'hello@example.com',
        password: 'password123',
      ),
    );
    await expectation;
    await bloc.close();
  });
}

AuthBloc _buildBloc(_FakeAuthRepository repository) {
  return AuthBloc(
    GetCurrentSessionUseCase(repository),
    LogoutUseCase(repository),
    RequestPhoneOtpUseCase(repository),
    VerifyPhoneOtpUseCase(repository),
    LoginWithPasswordUseCase(repository),
    LoginWithMethodUseCase(repository),
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.currentSession = const AuthSession.unauthenticated(),
    this.methodLoginSession = const AuthSession.authenticated(
      accessToken: 'access',
      refreshToken: 'refresh',
    ),
  });

  final AuthSession currentSession;
  final AuthSession methodLoginSession;

  @override
  Future<Result<AuthSession>> getCurrentSession() async {
    return Result.success(currentSession);
  }

  @override
  Future<Result<AuthSession>> loginWithMethod(AuthLoginMethod method) async {
    return Result.success(methodLoginSession);
  }

  @override
  Future<Result<void>> logout({bool revokeRemote = true}) async {
    return Result.success(null);
  }

  @override
  Future<Result<AuthTokens>> refreshTokens(String refreshToken) async {
    return Result.success(
      const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
    );
  }

  @override
  Future<Result<PhoneOtpChallenge>> requestPhoneOtp({
    required String phoneNumber,
    required PhoneOtpPurpose purpose,
  }) async {
    return Result.success(
      PhoneOtpChallenge(
        phoneNumber: phoneNumber,
        purpose: purpose,
        challengeId: 'challenge',
      ),
    );
  }

  @override
  Future<Result<AuthSession>> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
    required PhoneOtpPurpose purpose,
    String? challengeId,
  }) async {
    return Result.success(methodLoginSession);
  }
}
