import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screen/add_task_screen.dart';
import '../service/database_service.dart';

class AddTaskController extends GetxController {
  static AddTaskController get to => Get.find();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final formKey = GlobalKey<FormState>();

  final taskRepository = TaskRepository(DatabaseService.instance);

  String? validateTitle(String? value) {
    return (value == null || value.isEmpty) ? 'Please enter a title' : null;
  }

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      startDate.value = DateTime(picked.year, picked.month, picked.day);
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
    if (startDate.value == null) {
      showError('Please select start date first');
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? startDate.value!.add(Duration(days: 1)),
      firstDate: startDate.value!,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      endDate.value = DateTime(picked.year, picked.month, picked.day);
    }
  }


  String getDurationText() {
    if (startDate.value == null || endDate.value == null) return '';
    final duration = endDate.value!.difference(startDate.value!);
    return 'Task Duration: ${duration.inDays} days, ${duration.inHours % 24} hours';
  }

  bool validateForm() {
    if (!formKey.currentState!.validate()) return false;
    if (startDate.value == null || endDate.value == null) {
      showError('Please select both start and end dates');
      return false;
    }
    if (!DateValidatorService.isEndDateAfterStartDate(
      startDate.value!,
      endDate.value!,
    )) {
      showError('End date cannot be before start date');
      return false;
    }
    return true;
  }

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
      Navigator.pop(context, newTask);
    } catch (e) {
      showError('Error saving task: $e');
    }
  }

  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
