import 'package:app_core/app_core.dart';
import 'package:app_network/app_network.dart';
import 'package:equatable/equatable.dart';

import '../repositories/auth_repository.dart';

class RefreshSessionUseCase
    implements UseCase<AuthTokens, RefreshSessionParams> {
  const RefreshSessionUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthTokens>> call(RefreshSessionParams params) {
    return _repository.refreshTokens(params.refreshToken);
  }
}

class RefreshSessionParams extends Equatable {
  const RefreshSessionParams(this.refreshToken);

  final String refreshToken;

  @override
  List<Object> get props => [refreshToken];
}
