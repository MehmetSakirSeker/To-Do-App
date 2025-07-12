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
    final controller = EditTaskController.to;

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => controller.saveChanges(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInputField(
              controller: controller.titleController,
              label: 'Task Title',
            ),
            SizedBox(height: 16),
            _buildInputField(
              controller: controller.descriptionController,
              label: 'Description',
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Obx(() => _buildDateTile(
              label: 'Start Date',
              date: controller.startDate.value!,
              onTap: () => controller.pickStartDate(context),
            )),
            Obx(() => _buildDateTile(
              label: 'End Date',
              date: controller.endDate.value!,
              onTap: () => controller.pickEndDate(context),
            )
            ),
            Obx(() {
              if (EditTaskController.to.startDate.value != null &&
                  EditTaskController.to.endDate.value != null) {
                return Text(
                  EditTaskController.to.getDurationText(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                );
              }
              return SizedBox.shrink();//for returning nothing like null
            }),

          ],
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
