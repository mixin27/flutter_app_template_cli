import '../../domain/entities/home_summary.dart';

class HomeSummaryModel extends HomeSummary {
  const HomeSummaryModel({
    required super.greeting,
    required super.focus,
    required super.openTasks,
    required super.completedToday,
  });

  factory HomeSummaryModel.fromJson(Map<String, dynamic> json) {
    return HomeSummaryModel(
      greeting: json['greeting'] as String? ?? 'Welcome back',
      focus: json['focus'] as String? ?? 'Pick your top task',
      openTasks: (json['openTasks'] as num?)?.toInt() ?? 0,
      completedToday: (json['completedToday'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'greeting': greeting,
      'focus': focus,
      'openTasks': openTasks,
      'completedToday': completedToday,
    };
  }
}
