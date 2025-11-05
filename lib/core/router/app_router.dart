import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/task.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/task_detail_page.dart';
import '../constants/route_constants.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteConstants.home,
  routes: [
    GoRoute(
      path: RouteConstants.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: RouteConstants.taskDetail,
      builder: (context, state) {
        final task = state.extra as Task;
        return TaskDetailPage(task: task);
      },
    ),
    GoRoute(
      path: RouteConstants.settings,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri.path}'))),
);
