import 'package:app_core/app_core.dart';
import 'package:equatable/equatable.dart';

import '../entities/phone_otp_challenge.dart';
import '../repositories/auth_repository.dart';

class RequestPhoneOtpUseCase
    implements UseCase<PhoneOtpChallenge, RequestPhoneOtpParams> {
  const RequestPhoneOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<PhoneOtpChallenge>> call(RequestPhoneOtpParams params) {
    return _repository.requestPhoneOtp(
      phoneNumber: params.phoneNumber,
      purpose: params.purpose,
    );
  }
}

class RequestPhoneOtpParams extends Equatable {
  const RequestPhoneOtpParams({
    required this.phoneNumber,
    required this.purpose,
  });

  final String phoneNumber;
  final PhoneOtpPurpose purpose;

  @override
  List<Object> get props => [phoneNumber, purpose];
}
