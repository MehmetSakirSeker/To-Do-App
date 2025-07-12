import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../controller/edit_task_controller.dart';
import '../controller/todo_controller.dart';
import '../model/task_model.dart';
import '../model/task_status.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TodoScreen extends StatelessWidget {


  TodoScreen({super.key}) {
    Get.put(TodoController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo App')),
      body: Column(
        children: [
          Divider(),
          Expanded(
            child: Obx(() {
              final tasks = TodoController.to.tasks;
              if (tasks.isEmpty) return Center(child: Text('No To-Do Found'));
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) => _buildTaskCard(tasks[index], context),
              );
            }),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Obx(
            () => Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconFilter(TaskStatus.UPCOMING, Icons.calendar_today),
              _buildIconFilter(TaskStatus.ONGOING, Icons.play_arrow),
              _buildCircleFilter(null, Icons.list_alt), // All
              _buildIconFilter(TaskStatus.OVERDUE, Icons.warning),
              _buildIconFilter(TaskStatus.COMPLETED, Icons.check_circle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconFilter(TaskStatus? status, IconData icon) {
    return Obx(() {
      final isActive = TodoController.to.currentFilter.value == status;
      return InkWell(
        onTap: () => TodoController.to.filterTasks(status),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? _getStatusColor(status) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              color: isActive ? Colors.white : Colors.black),
        ),
      );
    });
  }


  Widget _buildCircleFilter(TaskStatus? status, IconData icon) {
    final isActive = TodoController.to.currentFilter.value == status;
    return InkWell(
      onTap: () => TodoController.to.filterTasks(status),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? _getStatusColor(status) : Colors.grey[400],
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.black,size: 50,),
      ),
    );
  }


  Widget _buildTaskCard(TaskResponse task, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          task.title,
          style: task.status == TaskStatus.COMPLETED
              ? TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                style: task.status == TaskStatus.COMPLETED
                    ? TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
            SizedBox(height: 4),
            Text('Start: ${DateFormat('dd.MM.yyyy').format(task.startDate)}'),
            Text('End: ${DateFormat('dd.MM.yyyy').format(task.endDate)}'),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editTask(task, context),
            ),
            if (task.status != TaskStatus.COMPLETED)
              IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                onPressed: () => TodoController.to.completeTask(task.id),
              )
            else
              IconButton(
                icon: Icon(Icons.undo, color: Colors.orange),
                onPressed: () => TodoController.to.markTaskIncomplete(task.id),
              ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, task.id),
            ),
          ],
        ),


        leading: Container(
          width: 10,
          height: 40,
          color: _getStatusColor(task.status),
        ),
      ),
    );
  }


  Future<void> _editTask(TaskResponse task, BuildContext context) async {
    final editController = Get.put(EditTaskController(), tag: task.id);
    editController.initialize(task);

    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
    );

    if (updatedTask != null) {
      await TodoController.to.updateTask(task.id, updatedTask);
    }
  }
  void _showDeleteConfirmation(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure you want to delete?'),
        content: Text('This action cannot be reversed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              TodoController.to.deleteTask(taskId);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }


  Future<void> _navigateToAddTask(BuildContext context) async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTaskScreen()),
    );

    if (newTask != null) {
      await TodoController.to.refreshTasks();
    }

  }

  Color _getStatusColor(TaskStatus? status) {
    switch (status) {
      case TaskStatus.UPCOMING:
        return Colors.blue;
      case TaskStatus.ONGOING:
        return Colors.orange;
      case TaskStatus.OVERDUE:
        return Colors.red;
      case TaskStatus.COMPLETED:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
