import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/edit_task_controller.dart';
import '../model/task_response.dart';

class EditTaskScreen extends StatelessWidget {
  final TaskResponse task;

  EditTaskScreen({Key? key, required this.task}) : super(key: key) {
    Get.put(EditTaskController());
    EditTaskController.to.initialize(task);
  }

  @override
  Widget build(BuildContext context) {
    final controller = EditTaskController.to;
    final width = Get.width;
    final height = Get.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        title: Text(
          'Update Task',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.blue),
            onPressed: () => controller.saveChanges(context),
            tooltip: "Save changes",
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              _buildInputField(
                controller: controller.titleController,
                label: 'Task Title *',
                validator: controller.validateTitle,
              ),
              SizedBox(height: height * 0.025),
              _buildInputField(
                controller: controller.descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              SizedBox(height: height * 0.03),
              Obx(() => _buildDateTile(
                label: 'Start Date',
                date: controller.startDate.value!,
                onTap: () => controller.pickStartDate(context),
              )),
              SizedBox(height: 12),
              Obx(() => _buildDateTile(
                label: 'End Date',
                date: controller.endDate.value!,
                onTap: () => controller.pickEndDate(context),
              )),
              SizedBox(height: height * 0.04),
              Obx(() {
                if (controller.startDate.value != null &&
                    controller.endDate.value != null) {
                  return Center(
                    child: Text(
                      controller.getDurationText(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(10),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            DateFormat('dd/MM/yyyy HH:mm').format(date),
            style: TextStyle(fontSize: 14),
          ),
        ),
        trailing: Icon(Icons.calendar_today, color: Colors.grey[700]),
      ),
    );
  }
}
