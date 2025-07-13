import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/edit_task_controller.dart';
import '../controller/main_controller.dart';
import '../model/task_response.dart';
import '../model/task_status.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key}) {
    Get.put(MainController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('To-Do App', style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.black,

      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) => MainController.to.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final tasks = MainController.to.tasks;
              if (tasks.isEmpty) {
                return Center(child: Text('No To-Do Found', style: TextStyle(fontSize: 16)));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: tasks.length,
                itemBuilder: (context, index) => _buildTaskCard(tasks[index], context),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTask(context),
        icon: Icon(Icons.add,color: Colors.white,),
        label: Text("Add Task",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueGrey,
      ),
      bottomNavigationBar: Obx(
            () => Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white70,
            boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconFilter(TaskStatus.UPCOMING, Icons.calendar_today, size: 30), // biraz büyük
              _buildIconFilter(TaskStatus.ONGOING, Icons.play_arrow, size: 30),       // biraz büyük
              _buildCircleFilter(null, Icons.all_inbox, size: 50),                    // ortadaki daha büyük
              _buildIconFilter(TaskStatus.OVERDUE, Icons.warning_amber, size: 30),    // biraz büyük
              _buildIconFilter(TaskStatus.COMPLETED, Icons.check_circle, size: 30),   // biraz büyük
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildIconFilter(TaskStatus? status, IconData icon, {double size = 24}) {
    return Obx(() {
      final isActive = MainController.to.currentFilter.value == status;
      return GestureDetector(
        onTap: () => MainController.to.filterTasks(status),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? _getStatusColor(status) : Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: isActive ? Colors.white : Colors.blueGrey, size: size),
        ),
      );
    });
  }


  Widget _buildCircleFilter(TaskStatus? status, IconData icon, {double size = 24}) {
    final isActive = MainController.to.currentFilter.value == status;
    return GestureDetector(
      onTap: () => MainController.to.filterTasks(status),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.blueGrey : Colors.grey[300],
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  Widget _buildTaskCard(TaskResponse task, BuildContext context) {
    final isUrgent = MainController.to.isUrgent(task);
    final timeLeftText = getTimeLeftText(task.endDate);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 50,
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: task.status == TaskStatus.COMPLETED ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 13,
                      decoration: task.status == TaskStatus.COMPLETED ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              SizedBox(height: 6),
              Text('Start: ${DateFormat('dd.MM.yyyy HH:mm').format(task.startDate)}'),
              Text('End: ${DateFormat('dd.MM.yyyy HH:mm').format(task.endDate)}'),
              if (isUrgent && task.status != TaskStatus.COMPLETED)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.redAccent),
                      SizedBox(width: 4),
                      Text(
                        timeLeftText,
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editTask(task, context),
                    tooltip: "Edit",
                  ),
                  IconButton(
                    icon: Icon(
                      task.status != TaskStatus.COMPLETED ? Icons.check : Icons.undo,
                      color: task.status != TaskStatus.COMPLETED ? Colors.green : Colors.orange,
                    ),
                    onPressed: () {
                      task.status != TaskStatus.COMPLETED
                          ? MainController.to.completeTask(task.id)
                          : MainController.to.markTaskIncomplete(task.id);
                    },
                    tooltip: task.status != TaskStatus.COMPLETED ? "Complete" : "Undo",
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(context, task.id),
                    tooltip: "Delete",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTimeLeftText(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) return 'Time is over';

    final days = difference.inDays;
    final hours = difference.inHours - days * 24;
    final minutes = difference.inMinutes - (difference.inHours * 60);

    if (days > 0) return '$days d $hours h $minutes m';
    if (hours > 0) return '$hours h $minutes m';
    return '$minutes m';
  }



  Future<void> _editTask(TaskResponse task, BuildContext context) async {
    final editController = Get.put(EditTaskController(), tag: task.id);
    editController.initialize(task);

    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
    );

    if (updatedTask != null) {
      await MainController.to.updateTask(task.id, updatedTask);
    }
  }

  void _showDeleteConfirmation(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure you want to delete?'),
        content: Text('This process cant be reversed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),

            child: Text('Cancel',style: TextStyle(color: Colors.white),),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              MainController.to.deleteTask(taskId);
            },
            child: Text('Delete',style: TextStyle(color: Colors.blueGrey),),
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
      await MainController.to.refreshTasks();
    }
  }

  Color _getStatusColor(TaskStatus? status) {
    switch (status) {
      case TaskStatus.UPCOMING:
        return Colors.blue;
      case TaskStatus.ONGOING:
        return Colors.orange;
      case TaskStatus.OVERDUE:
        return Colors.redAccent;
      case TaskStatus.COMPLETED:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
