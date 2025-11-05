import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/database/drift_database.dart';
import 'data/repositories/task_repository_impl.dart';
import 'domain/usecases/add_task_usecase.dart';
import 'domain/usecases/delete_completed_tasks_usecase.dart';
import 'domain/usecases/delete_task_usecase.dart';
import 'domain/usecases/get_tasks_usecase.dart';
import 'domain/usecases/toggle_task_completion_usecase.dart';
import 'domain/usecases/update_task_usecase.dart';
import 'presentation/cubits/settings_cubit.dart';
import 'presentation/cubits/settings_state.dart';
import 'presentation/cubits/task_cubit.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  // 타임존 초기화 - UTC 기준으로 통일
  tz.initializeTimeZones();

  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final database = AppDatabase();
    final taskRepository = TaskRepositoryImpl(database);
    final getTasksUseCase = GetTasksUseCase(taskRepository);
    final addTaskUseCase = AddTaskUseCase(taskRepository);
    final updateTaskUseCase = UpdateTaskUseCase(taskRepository);
    final deleteTaskUseCase = DeleteTaskUseCase(taskRepository);
    final deleteCompletedTasksUseCase = DeleteCompletedTasksUseCase(
      taskRepository,
    );
    final toggleTaskCompletionUseCase = ToggleTaskCompletionUseCase(
      taskRepository,
    );
    final notificationService = NotificationService();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => SettingsCubit()),
            BlocProvider(
              create: (context) => TaskCubit(
                getTasksUseCase: getTasksUseCase,
                addTaskUseCase: addTaskUseCase,
                updateTaskUseCase: updateTaskUseCase,
                deleteTaskUseCase: deleteTaskUseCase,
                deleteCompletedTasksUseCase: deleteCompletedTasksUseCase,
                toggleTaskCompletionUseCase: toggleTaskCompletionUseCase,
                notificationService: notificationService,
              ),
            ),
          ],
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              return MaterialApp.router(
                title: 'Flutter TodoList',
                debugShowCheckedModeBanner: false,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: settingsState.themeMode,
                routerConfig: appRouter,
              );
            },
          ),
        );
      },
    );
  }
}
