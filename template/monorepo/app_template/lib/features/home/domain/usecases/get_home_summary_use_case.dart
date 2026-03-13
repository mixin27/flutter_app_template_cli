import 'package:app_core/app_core.dart';

import '../entities/home_summary.dart';
import '../repositories/home_repository.dart';

class GetHomeSummaryUseCase extends UseCase<HomeSummary, NoParams> {
  GetHomeSummaryUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Result<HomeSummary>> call(NoParams params) {
    return _repository.getSummary();
  }
}
