import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../service/date_validator_service.dart';

abstract class BaseTaskController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  final formKey = GlobalKey<FormState>();

  String getDurationText() {
    if (startDate.value == null || endDate.value == null) return '';

    final duration = endDate.value!.difference(startDate.value!);

    final days = duration.inDays;
    final hours = duration.inHours - (days * 24);
    final minutes = duration.inMinutes - (duration.inHours * 60);

    return 'Task Duration: ${days} day(s), ${hours} hour(s), ${minutes} minute(s)';
  }


  String? validateTitle(String? value) {
    return (value == null || value.isEmpty) ? 'Please enter a title' : null;
  }

  bool validateForm() {
    if (!formKey.currentState!.validate()) return false;

    if (startDate.value == null || endDate.value == null) {
      showError('Please select both start and end dates');
      return false;
    }

    if (!DateValidatorService.isStartDateTodayOrLater(startDate.value!)) {
      showError('Start date cannot be before now');
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
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade700.withAlpha(230),
      colorText: Colors.white,
      margin: EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(Icons.error_outline, color: Colors.white),
      titleText: Text(
        'Error',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(color: Colors.white70, fontSize: 19),
      ),
      duration: Duration(seconds: 4),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
    );
  }


  void resetFields() {
    titleController.clear();
    descriptionController.clear();
    startDate.value = null;
    endDate.value = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
