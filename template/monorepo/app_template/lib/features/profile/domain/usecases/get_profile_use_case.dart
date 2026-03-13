import 'package:app_core/app_core.dart';

import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase extends UseCase<UserProfile, NoParams> {
  GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Result<UserProfile>> call(NoParams params) {
    return _repository.getProfile();
  }
}
