import 'package:app_core/app_core.dart';
import 'package:equatable/equatable.dart';

import '../entities/auth_login_method.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginWithPasswordUseCase
    implements UseCase<AuthSession, LoginWithPasswordParams> {
  const LoginWithPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthSession>> call(LoginWithPasswordParams params) {
    return _repository.loginWithMethod(
      AuthLoginMethod.password(
        identifier: params.identifier,
        password: params.password,
      ),
    );
  }
}

class LoginWithPasswordParams extends Equatable {
  const LoginWithPasswordParams({
    required this.identifier,
    required this.password,
  });

  final String identifier;
  final String password;

  @override
  List<Object> get props => [identifier, password];
}
