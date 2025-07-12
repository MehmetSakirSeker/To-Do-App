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
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(startDate.value ?? DateTime.now()),
      );

      if (pickedTime != null) {
        startDate.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Eğer bitiş tarihi varsa ve artık geçersizse sıfırla
        if (endDate.value != null &&
            !DateValidatorService.isEndDateAfterStartDate(
              startDate.value!,
              endDate.value!,
            )) {
          endDate.value = null;
        }
      }
    }
  }


  Future<void> pickEndDate(BuildContext context) async {
    if (startDate.value == null) {
      showError('Please select start date first');
      return;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? startDate.value!.add(Duration(days: 1)),
      firstDate: startDate.value!,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(endDate.value ?? DateTime.now()),
      );

      if (pickedTime != null) {
        endDate.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }



  String getDurationText() {
    if (startDate.value == null || endDate.value == null) return '';
    final duration = endDate.value!.difference(startDate.value!);
    return 'Task Duration: ${duration.inDays} days, ${duration.inHours % 24} hours, ${duration.inMinutes % 60} minutes';
  }


  bool validateForm() {
    if (!formKey.currentState!.validate()) return false;

    if (startDate.value == null || endDate.value == null) {
      showError('Please select both start and end dates');
      return false;
    }

    if (!DateValidatorService.isStartDateTodayOrLater(startDate.value!)) {
      showError('Start date cannot be before today');
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
