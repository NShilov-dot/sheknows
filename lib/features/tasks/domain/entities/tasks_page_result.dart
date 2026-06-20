import 'package:equatable/equatable.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/task_entity.dart';

class TasksPageResult extends Equatable {
  const TasksPageResult({
    required this.tasks,
    required this.hasMore,
  });

  final List<TaskEntity> tasks;
  final bool hasMore;

  @override
  List<Object?> get props => [tasks, hasMore];
}
