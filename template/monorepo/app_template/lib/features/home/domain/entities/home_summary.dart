import 'package:equatable/equatable.dart';

class HomeSummary extends Equatable {
  const HomeSummary({
    required this.greeting,
    required this.focus,
    required this.openTasks,
    required this.completedToday,
  });

  final String greeting;
  final String focus;
  final int openTasks;
  final int completedToday;

  @override
  List<Object?> get props => [greeting, focus, openTasks, completedToday];
}
