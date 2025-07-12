import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/add_task_controller.dart';
import '../model/task_model.dart';

// for  date validation logic
class DateValidatorService {
  static bool isEndDateAfterStartDate(DateTime startDate, DateTime endDate) {
    return endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);
  }
  static bool isStartDateTodayOrLater(DateTime startDate) {
    final today = DateTime.now();
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedToday = DateTime(today.year, today.month, today.day);

    return normalizedStart.isAtSameMomentAs(normalizedToday) || normalizedStart.isAfter(normalizedToday);
  }
}

// Mapper service for task create request
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

class AddTaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(AddTaskController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => AddTaskController.to.saveTask(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: AddTaskController.to.formKey,
          child: ListView(
            children: [
              _buildTitleField(),
              SizedBox(height: 16),
              _buildDescriptionField(),
              SizedBox(height: 16),
              Obx(() => _buildStartDateTile(context)),
              Obx(() => _buildEndDateTile(context)),
              SizedBox(height: 24),
              Obx(() {
                if (AddTaskController.to.startDate.value != null &&
                    AddTaskController.to.endDate.value != null) {
                  return Text(
                    AddTaskController.to.getDurationText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  );
                }
                return SizedBox.shrink();//for returning nothing like null
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: AddTaskController.to.titleController,
      decoration: InputDecoration(
        labelText: 'Task Title',
        border: OutlineInputBorder(),
      ),
      validator: AddTaskController.to.validateTitle,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: AddTaskController.to.descriptionController,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildStartDateTile(BuildContext context) {
    return ListTile(
      title: Text('Start Date *'),
      subtitle: Text(
        AddTaskController.to.startDate.value == null
            ? 'Not Selected'
            : DateFormat('dd/MM/yyyy').format(AddTaskController.to.startDate.value!),
      ),
      trailing: Icon(Icons.calendar_today),
      onTap: () => AddTaskController.to.pickStartDate(context),
    );
  }

  Widget _buildEndDateTile(BuildContext context) {
    return ListTile(
      title: Text('End Date *'),
      subtitle: Text(
        AddTaskController.to.endDate.value == null
            ? 'Not Selected'
            : DateFormat('dd/MM/yyyy').format(AddTaskController.to.endDate.value!),
      ),
      trailing: Icon(Icons.calendar_today),
      onTap: () => AddTaskController.to.pickEndDate(context),
    );
  }
}
