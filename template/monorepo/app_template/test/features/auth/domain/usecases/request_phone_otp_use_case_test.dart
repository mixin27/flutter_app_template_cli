import 'package:app_core/app_core.dart';
import 'package:app_network/app_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/auth_login_method.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/auth_session.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/phone_otp_challenge.dart';
import 'package:__APP_NAME__/features/auth/domain/repositories/auth_repository.dart';
import 'package:__APP_NAME__/features/auth/domain/usecases/request_phone_otp_use_case.dart';

void main() {
  test('passes phone number and purpose to repository', () async {
    final repository = _FakeAuthRepository();
    final useCase = RequestPhoneOtpUseCase(repository);

    final result = await useCase(
      const RequestPhoneOtpParams(
        phoneNumber: '+959123456789',
        purpose: PhoneOtpPurpose.registration,
      ),
    );

    expect(result.isSuccess, isTrue);
    expect(repository.receivedPhoneNumber, equals('+959123456789'));
    expect(repository.receivedPurpose, equals(PhoneOtpPurpose.registration));
  });
}

class _FakeAuthRepository implements AuthRepository {
  String? receivedPhoneNumber;
  PhoneOtpPurpose? receivedPurpose;

  @override
  Future<Result<PhoneOtpChallenge>> requestPhoneOtp({
    required String phoneNumber,
    required PhoneOtpPurpose purpose,
  }) async {
    receivedPhoneNumber = phoneNumber;
    receivedPurpose = purpose;
    return Result.success(
      PhoneOtpChallenge(
        phoneNumber: phoneNumber,
        purpose: purpose,
        challengeId: 'challenge',
      ),
    );
  }

  @override
  Future<Result<AuthSession>> getCurrentSession() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSession>> loginWithMethod(AuthLoginMethod method) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> logout({bool revokeRemote = true}) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthTokens>> refreshTokens(String refreshToken) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSession>> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
    required PhoneOtpPurpose purpose,
    String? challengeId,
  }) async {
    throw UnimplementedError();
  }
}
