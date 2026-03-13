import 'package:app_core/app_core.dart';

import '../entities/home_summary.dart';

abstract class HomeRepository {
  Future<Result<HomeSummary>> getSummary();
}
