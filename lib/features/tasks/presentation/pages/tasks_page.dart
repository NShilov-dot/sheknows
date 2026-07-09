import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter_starter_kit/core/constants/tasks.dart';
import 'package:supabase_flutter_starter_kit/core/di/injection.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_state.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/task_entity.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/presentation/cubit/tasks_state.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, String?>(
      selector: (state) =>
          state is AuthAuthenticated ? state.user.id : null,
      builder: (context, userId) {
        if (userId == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocProvider(
          create: (_) => sl<TasksCubit>()..loadTasks(userId),
          child: const _TasksView(),
        );
      },
    );
  }
}

class _TasksView extends StatefulWidget {
  const _TasksView();

  @override
  State<_TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<_TasksView> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      context.read<TasksCubit>().loadMore();
    }
  }

  void _addTask() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final title = _titleController.text;
    _titleController.clear();
    context.read<TasksCubit>().addTask(title);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'New task',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: kTaskTitleMaxLength,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _addTask(),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Enter a task title';
                        }
                        if (trimmed.length > kTaskTitleMaxLength) {
                          return 'Title must be at most '
                              '$kTaskTitleMaxLength characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _addTask,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<TasksCubit, TasksState>(
              listenWhen: (previous, current) {
                if (current is! TasksLoaded || current.mutationFailure == null) {
                  return false;
                }
                return previous is! TasksLoaded ||
                    previous.mutationFailure != current.mutationFailure;
              },
              listener: (context, state) {
                if (state is TasksLoaded && state.mutationFailure != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.mutationFailure!.message)),
                  );
                }
              },
              builder: (context, state) {
                return switch (state) {
                  TasksInitial() || TasksLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  TasksLoaded(
                    :final tasks,
                    :final isLoadingMore,
                  ) =>
                    _TaskList(
                      tasks: tasks,
                      isLoadingMore: isLoadingMore,
                      scrollController: _scrollController,
                    ),
                  TasksError(:final failure) =>
                    Center(child: Text(failure.message)),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.tasks,
    required this.isLoadingMore,
    required this.scrollController,
  });

  final List<TaskEntity> tasks;
  final bool isLoadingMore;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks yet. Add one above.'),
      );
    }

    final itemCount = tasks.length + (isLoadingMore ? 1 : 0);

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemCount,
      separatorBuilder: (_, index) {
        if (index >= tasks.length - 1) {
          return const SizedBox.shrink();
        }
        return const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        if (index >= tasks.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final task = tasks[index];
        final isPending = task.id.startsWith('pending-');

        return Dismissible(
          key: ValueKey(task.id),
          direction: isPending ? DismissDirection.none : DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Theme.of(context).colorScheme.error,
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          onDismissed: (_) {
            context.read<TasksCubit>().removeTask(task.id);
          },
          child: CheckboxListTile(
            value: task.isCompleted,
            onChanged: isPending
                ? null
                : (value) {
                    if (value == null) {
                      return;
                    }
                    context.read<TasksCubit>().toggleTask(task.id, value);
                  },
            title: Text(
              task.title,
              style: task.isCompleted
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            secondary: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: isPending
                  ? null
                  : () => context.read<TasksCubit>().removeTask(task.id),
            ),
          ),
        );
      },
    );
  }
}
