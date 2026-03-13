import 'package:app_core/app_core.dart';
import 'package:equatable/equatable.dart';

import '../entities/auth_login_method.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginWithMethodUseCase
    implements UseCase<AuthSession, LoginWithMethodParams> {
  const LoginWithMethodUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthSession>> call(LoginWithMethodParams params) {
    return _repository.loginWithMethod(params.method);
  }
}

class LoginWithMethodParams extends Equatable {
  const LoginWithMethodParams(this.method);

  final AuthLoginMethod method;

  @override
  List<Object> get props => [method];
}
