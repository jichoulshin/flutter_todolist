import 'package:mockito/annotations.dart';
import 'package:flutter_todolist/domain/repositories/task_repository.dart';
import 'package:flutter_todolist/services/notification_service.dart';

@GenerateMocks([TaskRepository, NotificationService])
void main() {}
