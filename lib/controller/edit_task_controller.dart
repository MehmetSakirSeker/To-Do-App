import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../model/task_response.dart';
import '../model/task_update_request.dart';
import 'base_task_controller.dart';

class EditTaskController extends BaseTaskController {
  static EditTaskController get to => Get.find();

  final durationText = ''.obs;
  late TaskResponse task;

  void initialize(TaskResponse taskData) {
    task = taskData;
    titleController.text = task.title;
    descriptionController.text = task.description;
    startDate.value = task.startDate;
    endDate.value = task.endDate;
    durationText.value = getDurationText();


    ever(startDate, (_) => durationText.value = getDurationText());
    ever(endDate, (_) => durationText.value = getDurationText());
  }

  void saveChanges(BuildContext context) {
    if (!validateForm()) return;

    final updatedTask = TaskUpdateRequest(
      title: titleController.text,
      description: descriptionController.text,
      startDate: startDate.value!,
      endDate: endDate.value!,
    );

    Navigator.pop(context, updatedTask);
  }
}
