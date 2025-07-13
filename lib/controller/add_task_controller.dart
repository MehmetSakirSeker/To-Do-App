import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../model/task_update_request.dart';
import '../repository/task_repository.dart';
import '../service/database_service.dart';
import 'base_task_controller.dart';

class AddTaskController extends BaseTaskController {
  static AddTaskController get to => Get.find();
  final taskRepository = TaskRepository(DatabaseService.instance);

  Future<void> saveTask(BuildContext context) async {
    if (!validateForm()) return;

    try {
      final newTask = await taskRepository.createTask(
        TaskRequestMapper.mapToTaskCreateRequest(
          title: titleController.text,
          description: descriptionController.text,
          startDate: startDate.value!,
          endDate: endDate.value!,
        ),
      );
      resetFields();
      Navigator.pop(context, newTask);
    } catch (e) {
      showError('Error saving task: $e');
      resetFields();
    }
  }
}
