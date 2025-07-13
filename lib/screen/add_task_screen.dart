import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/add_task_controller.dart';

class AddTaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final height = Get.height;

    Get.put(AddTaskController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Add New Task',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            AddTaskController.to.resetFields();
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.blue),
            onPressed: () => AddTaskController.to.saveTask(context),
            tooltip: "Save Task",
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Form(
          key: AddTaskController.to.formKey,
          child: ListView(
            children: [
              _buildTitleField(),
              SizedBox(height: height * 0.025),
              _buildDescriptionField(),
              SizedBox(height: height * 0.03),
              Obx(() => _buildDateTile(
                context: context,
                title: 'Start Date *',
                date: AddTaskController.to.startDate.value,
                onTap: () => AddTaskController.to.pickStartDate(context),
              )),
              SizedBox(height: 12),
              Obx(() => _buildDateTile(
                context: context,
                title: 'End Date *',
                date: AddTaskController.to.endDate.value,
                onTap: () => AddTaskController.to.pickEndDate(context),
              )),
              SizedBox(height: height * 0.04),
              Obx(() {
                if (AddTaskController.to.startDate.value != null &&
                    AddTaskController.to.endDate.value != null) {
                  return Center(
                    child: Text(
                      AddTaskController.to.getDurationText(),
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

  Widget _buildTitleField() {
    return TextFormField(
      controller: AddTaskController.to.titleController,
      decoration: InputDecoration(
        labelText: 'Task Title *',
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: AddTaskController.to.validateTitle,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: AddTaskController.to.descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDateTile({
    required BuildContext context,
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 1,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: onTap,
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            date == null
                ? 'Not selected'
                : DateFormat('dd/MM/yyyy HH:mm').format(date),
            style: TextStyle(fontSize: 14),
          ),
        ),
        trailing: Icon(Icons.calendar_today, color: Colors.grey[700]),
      ),
    );
  }
}
