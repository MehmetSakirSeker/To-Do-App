import 'package:intl/intl.dart';
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
  final TaskStatus status;

  TaskResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory TaskResponse.fromMap(Map<String, dynamic> map) {
    return TaskResponse(
      id: map['id'].toString(),
      title: map['title'],
      description: map['description'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      status: TaskStatus.fromString(map['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  String get formattedStartDate => DateFormat('dd/MM/yyyy HH:mm').format(startDate);
  String get formattedEndDate => DateFormat('dd/MM/yyyy HH:mm').format(endDate);
}