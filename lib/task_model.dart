import 'task_status.dart';

class TaskCreateRequest {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  TaskCreateRequest({
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

class TaskResponse {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;

  TaskResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.isCompleted,
  });

  TaskStatus get status {
    if (isCompleted) return TaskStatus.COMPLETED;

    final now = DateTime.now();
    if (endDate.isBefore(now)) return TaskStatus.OVERDUE;
    if (startDate.isBefore(now)) return TaskStatus.ONGOING;
    return TaskStatus.UPCOMING;
  }

  factory TaskResponse.fromMap(Map<String, dynamic> map) {
    return TaskResponse(
      id: map['id'].toString(),
      title: map['title'],
      description: map['description'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      isCompleted: map['isCompleted'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}