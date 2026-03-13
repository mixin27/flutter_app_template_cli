import 'package:equatable/equatable.dart';

enum AuthMethodType {
  password('password'),
  google('google'),
  apple('apple'),
  facebook('facebook'),
  custom('custom');

  const AuthMethodType(this.value);

  final String value;
}

class AuthLoginMethod extends Equatable {
  const AuthLoginMethod._({required this.type, required this.payload});

  factory AuthLoginMethod.password({
    required String identifier,
    required String password,
  }) {
    return AuthLoginMethod._(
      type: AuthMethodType.password,
      payload: <String, dynamic>{
        'identifier': identifier,
        'password': password,
      },
    );
  }

  factory AuthLoginMethod.google({required String idToken}) {
    return AuthLoginMethod._(
      type: AuthMethodType.google,
      payload: <String, dynamic>{'idToken': idToken},
    );
  }

  factory AuthLoginMethod.apple({required String idToken}) {
    return AuthLoginMethod._(
      type: AuthMethodType.apple,
      payload: <String, dynamic>{'idToken': idToken},
    );
  }

  factory AuthLoginMethod.facebook({required String accessToken}) {
    return AuthLoginMethod._(
      type: AuthMethodType.facebook,
      payload: <String, dynamic>{'accessToken': accessToken},
    );
  }

  factory AuthLoginMethod.custom({
    required String method,
    required Map<String, dynamic> payload,
  }) {
    return AuthLoginMethod._(
      type: AuthMethodType.custom,
      payload: <String, dynamic>{'method': method, ...payload},
    );
  }

  final AuthMethodType type;
  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [type, payload];
}
