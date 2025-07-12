import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../screen/add_task_screen.dart';

abstract class BaseTaskController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  final formKey = GlobalKey<FormState>();

  String getDurationText() {
    if (startDate.value == null || endDate.value == null) return '';
    final duration = endDate.value!.difference(startDate.value!);
    return 'Task Duration: ${duration.inDays} days, ${duration.inHours % 24} hours, ${duration.inMinutes % 60} minutes';
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
