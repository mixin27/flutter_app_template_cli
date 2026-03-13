import 'package:app_network/app_network.dart';

import '../models/home_summary_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeSummaryModel> getSummary();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<HomeSummaryModel> getSummary() async {
    final payload = await _apiClient.postMap('/home/summary');
    return HomeSummaryModel.fromJson(payload);
  }
}
