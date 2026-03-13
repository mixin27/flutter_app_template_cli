import '../../domain/entities/phone_otp_challenge.dart';

class PhoneOtpChallengeModel extends PhoneOtpChallenge {
  const PhoneOtpChallengeModel({
    required super.phoneNumber,
    required super.purpose,
    super.challengeId,
    super.maskedPhoneNumber,
    super.resendAfterSeconds,
    super.expiresAt,
  });

  factory PhoneOtpChallengeModel.fromJson(
    Map<String, dynamic> json, {
    required String phoneNumber,
    required PhoneOtpPurpose purpose,
  }) {
    return PhoneOtpChallengeModel(
      phoneNumber: phoneNumber,
      purpose: purpose,
      challengeId: _readString(json, <String>[
        'challengeId',
        'challenge_id',
        'otpId',
        'otp_id',
      ]),
      maskedPhoneNumber: _readString(json, <String>[
        'maskedPhoneNumber',
        'masked_phone_number',
      ]),
      resendAfterSeconds: _readInt(json, <String>[
        'resendAfterSeconds',
        'resend_after_seconds',
        'resend_after',
      ]),
      expiresAt: _readDateTime(json, <String>[
        'expiresAt',
        'expires_at',
        'expiredAt',
        'expired_at',
      ]),
    );
  }

  static String? _readString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  static int? _readInt(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is int) {
        return value;
      }

      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  static DateTime? _readDateTime(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }
}
