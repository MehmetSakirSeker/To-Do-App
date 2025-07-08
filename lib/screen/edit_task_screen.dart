import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/edit_task_controller.dart';
import '../model/task_model.dart';

class DateTimePickerService {
  static Future<DateTime?> pickDateTime(
      BuildContext context,
      DateTime initialDate, {
        DateTime? firstDate,
      }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    return date;
  }
}

class EditTaskScreen extends StatelessWidget {
  final TaskResponse task;

  EditTaskScreen({Key? key, required this.task}) : super(key: key) {
    Get.put(EditTaskController());
    EditTaskController.to.initialize(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => EditTaskController.to.saveChanges(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
              () => ListView(
            children: [
              _buildInputField(
                controller: EditTaskController.to.titleController,
                label: 'Task Title',
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: EditTaskController.to.descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              SizedBox(height: 16),
              _buildDateTile(
                label: 'Start Date',
                date: EditTaskController.to.startDate.value!,
                onTap: () => EditTaskController.to.pickStartDate(context),
              ),
              _buildDateTile(
                label: 'End Date',
                date: EditTaskController.to.endDate.value!,
                onTap: () => EditTaskController.to.pickEndDate(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(label),
      subtitle: Text(DateFormat('dd/MM/yyyy').format(date)),
      trailing: Icon(Icons.calendar_today),
      onTap: onTap,
    );
  }
}
