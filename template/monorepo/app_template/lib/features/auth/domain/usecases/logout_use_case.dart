import 'package:app_core/app_core.dart';
import 'package:equatable/equatable.dart';

import '../repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, LogoutParams> {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(LogoutParams params) {
    return _repository.logout(revokeRemote: params.revokeRemote);
  }
}

class LogoutParams extends Equatable {
  const LogoutParams({this.revokeRemote = true});

  final bool revokeRemote;

  @override
  List<Object> get props => [revokeRemote];
}
