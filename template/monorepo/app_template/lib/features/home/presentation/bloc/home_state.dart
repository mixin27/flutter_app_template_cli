import 'package:equatable/equatable.dart';

import '../../domain/entities/home_summary.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.summary,
    this.errorMessage,
  });

  final HomeStatus status;
  final HomeSummary? summary;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    HomeSummary? summary,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage];
}
