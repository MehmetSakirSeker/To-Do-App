import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screen/add_task_screen.dart';
import '../screen/edit_task_screen.dart';
import '../model/task_model.dart';

class EditTaskController extends GetxController {
  static EditTaskController get to => Get.find();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  late TaskResponse task;

  void initialize(TaskResponse taskData) {
    task = taskData;
    titleController.text = task.title;
    descriptionController.text = task.description ?? '';
    startDate.value = task.startDate;
    endDate.value = task.endDate;
  }

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await DateTimePickerService.pickDateTime(
      context,
      startDate.value!,
    );
    if (picked != null) {
      startDate.value = picked;

      // End date geçersiz hale gelirse sıfırla
      if (endDate.value != null &&
          !DateValidatorService.isEndDateAfterStartDate(
            startDate.value!,
            endDate.value!,
          )) {
        endDate.value = null;
      }
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await DateTimePickerService.pickDateTime(
      context,
      endDate.value ?? startDate.value!,
      firstDate: startDate.value!,
    );
    if (picked != null) {
      endDate.value = picked;
    }
  }

  void saveChanges(BuildContext context) {
    final updatedTask = TaskUpdateRequest(
      title: titleController.text,
      description: descriptionController.text,
      startDate: startDate.value!,
      endDate: endDate.value!,
    );

    Navigator.pop(context, updatedTask);
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
