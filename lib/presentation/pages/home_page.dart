import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../domain/entities/task.dart';
import '../cubits/task_cubit.dart';
import '../cubits/task_state.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/empty_tasks_widget.dart';
import '../widgets/task_list_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().watchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(RouteConstants.settings),
          ),
        ],
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, taskState) {
          return taskState.when(
            initial: () => const Center(child: Text('Start loading...')),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            loaded: (todayTasks, upcomingTasks, inboxTasks, completedTasks) {
              final hasAnyTasks =
                  todayTasks.isNotEmpty ||
                  upcomingTasks.isNotEmpty ||
                  inboxTasks.isNotEmpty ||
                  completedTasks.isNotEmpty;

              if (!hasAnyTasks) {
                return const EmptyTasksWidget();
              }

              return ListView(
                padding: EdgeInsets.symmetric(vertical: 16.r),
                children: [
                  if (todayTasks.isNotEmpty)
                    TaskListSection(
                      title: 'home.today'.tr(),
                      tasks: todayTasks,
                      onTaskTap: (task) =>
                          context.push(RouteConstants.taskDetail, extra: task),
                      onToggle: (taskId) => context
                          .read<TaskCubit>()
                          .toggleTaskCompletion(taskId),
                      onDelete: (taskId) =>
                          context.read<TaskCubit>().deleteTask(taskId),
                    ),
                  if (upcomingTasks.isNotEmpty)
                    TaskListSection(
                      title: 'home.upcoming'.tr(),
                      tasks: upcomingTasks,
                      onTaskTap: (task) =>
                          context.push(RouteConstants.taskDetail, extra: task),
                      onToggle: (taskId) => context
                          .read<TaskCubit>()
                          .toggleTaskCompletion(taskId),
                      onDelete: (taskId) =>
                          context.read<TaskCubit>().deleteTask(taskId),
                    ),
                  if (inboxTasks.isNotEmpty)
                    TaskListSection(
                      title: 'home.inbox'.tr(),
                      tasks: inboxTasks,
                      onTaskTap: (task) =>
                          context.push(RouteConstants.taskDetail, extra: task),
                      onToggle: (taskId) => context
                          .read<TaskCubit>()
                          .toggleTaskCompletion(taskId),
                      onDelete: (taskId) =>
                          context.read<TaskCubit>().deleteTask(taskId),
                    ),
                  if (completedTasks.isNotEmpty)
                    TaskListSection(
                      title: 'home.completed'.tr(),
                      tasks: completedTasks,
                      onTaskTap: (task) =>
                          context.push(RouteConstants.taskDetail, extra: task),
                      onToggle: (taskId) => context
                          .read<TaskCubit>()
                          .toggleTaskCompletion(taskId),
                      onDelete: (taskId) =>
                          context.read<TaskCubit>().deleteTask(taskId),
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final task = await showDialog<Task>(
            context: context,
            builder: (context) => const AddTaskDialog(),
          );
          if (task != null) {
            if (!context.mounted) return;
            context.read<TaskCubit>().addTask(task);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Task added: ${task.title}'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
