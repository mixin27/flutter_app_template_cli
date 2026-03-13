import 'package:app_core/app_core.dart';
import 'package:equatable/equatable.dart';

import '../entities/auth_session.dart';
import '../entities/phone_otp_challenge.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneOtpUseCase
    implements UseCase<AuthSession, VerifyPhoneOtpParams> {
  const VerifyPhoneOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthSession>> call(VerifyPhoneOtpParams params) {
    return _repository.verifyPhoneOtp(
      phoneNumber: params.phoneNumber,
      otpCode: params.otpCode,
      purpose: params.purpose,
      challengeId: params.challengeId,
    );
  }
}

class VerifyPhoneOtpParams extends Equatable {
  const VerifyPhoneOtpParams({
    required this.phoneNumber,
    required this.otpCode,
    required this.purpose,
    this.challengeId,
  });

  final String phoneNumber;
  final String otpCode;
  final PhoneOtpPurpose purpose;
  final String? challengeId;

  @override
  List<Object?> get props => [phoneNumber, otpCode, purpose, challengeId];
}
