import 'package:app_core/app_core.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class GetCurrentSessionUseCase implements UseCase<AuthSession, NoParams> {
  const GetCurrentSessionUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthSession>> call(NoParams params) {
    return _repository.getCurrentSession();
  }
}
