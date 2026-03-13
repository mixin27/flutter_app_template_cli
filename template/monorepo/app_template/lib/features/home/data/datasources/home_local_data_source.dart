import '../models/home_summary_model.dart';

abstract class HomeLocalDataSource {
  Future<HomeSummaryModel?> getSummary();

  Future<void> saveSummary(HomeSummaryModel summary);

  Future<void> seedSampleDataIfEmpty();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  HomeSummaryModel? _cached;

  @override
  Future<HomeSummaryModel?> getSummary() async {
    return _cached;
  }

  @override
  Future<void> saveSummary(HomeSummaryModel summary) async {
    _cached = summary;
  }

  @override
  Future<void> seedSampleDataIfEmpty() async {
    _cached ??= const HomeSummaryModel(
      greeting: 'Welcome back, Alex',
      focus: 'Plan the day in 3 steps',
      openTasks: 4,
      completedToday: 2,
    );
  }
}
