import 'package:todo_app/model/task_create_request.dart';

class TaskUpdateRequest {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  TaskUpdateRequest({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
class TaskRequestMapper {
  static TaskCreateRequest mapToTaskCreateRequest({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return TaskCreateRequest(
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

