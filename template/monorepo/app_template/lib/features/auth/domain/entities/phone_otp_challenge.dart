import 'package:equatable/equatable.dart';

enum PhoneOtpPurpose {
  login('login'),
  registration('registration');

  const PhoneOtpPurpose(this.value);

  final String value;
}

class PhoneOtpChallenge extends Equatable {
  const PhoneOtpChallenge({
    required this.phoneNumber,
    required this.purpose,
    this.challengeId,
    this.maskedPhoneNumber,
    this.resendAfterSeconds,
    this.expiresAt,
  });

  final String phoneNumber;
  final PhoneOtpPurpose purpose;
  final String? challengeId;
  final String? maskedPhoneNumber;
  final int? resendAfterSeconds;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [
    phoneNumber,
    purpose,
    challengeId,
    maskedPhoneNumber,
    resendAfterSeconds,
    expiresAt,
  ];
}
