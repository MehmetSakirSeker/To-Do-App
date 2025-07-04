import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/task_status.dart';
import 'edit_task_screen.dart';
import 'task_model.dart';
import 'database_service.dart';
import 'add_task_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final DatabaseService dbService = DatabaseService.instance;
  List<TaskResponse> tasks = [];
  TaskStatus? currentFilter;
  final TaskRepository taskRepository = TaskRepository(DatabaseService.instance);
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final allTasks = await taskRepository.getAllTasks();
    setState(() => tasks = allTasks);
  }

  Future<void> _filterTasks(TaskStatus? status) async {
    setState(() => currentFilter = status);

    if (status == null) {
      _loadTasks();
    } else {
      final filteredTasks = await taskRepository.getTasksByStatus(status);
      setState(() => tasks = filteredTasks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton(null, 'All'),
                _buildFilterButton(TaskStatus.UPCOMING, 'Upcoming'),
                _buildFilterButton(TaskStatus.ONGOING, 'Ongoing'),
                _buildFilterButton(TaskStatus.OVERDUE, 'Overdue'),
                _buildFilterButton(TaskStatus.COMPLETED, 'Completed'),
              ],
            ),
          ),
          Divider(),

          Expanded(
            child: tasks.isEmpty
                ? Center(child: Text('No To-Do Found'))
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskCard(task);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterButton(TaskStatus? status, String text) {
    final isActive = currentFilter == status;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: isActive ? Colors.white : Colors.black, backgroundColor: isActive ? _getStatusColor(status) : Colors.grey[300],
        ),
        onPressed: () => _filterTasks(status),
        child: Text(text),
      ),
    );
  }

  Widget _buildTaskCard(TaskResponse task) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
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
              onPressed: () => _editTask(task),
            ),
            if (task.status != TaskStatus.COMPLETED)
              IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                onPressed: () => _completeTask(task.id),
              ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTask(task.id),
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

  Future<void> _editTask(TaskResponse task) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: task),
      ),
    );

    if (updatedTask != null) {
      await taskRepository.updateTask(task.id, updatedTask);
      _filterTasks(currentFilter);
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

  Future<void> _completeTask(String taskId) async {
    await taskRepository.completeTask(taskId,true);
    _filterTasks(currentFilter);
  }

  Future<void> _deleteTask(String taskId) async {
    await taskRepository.deleteTask(taskId);
    _filterTasks(currentFilter);
  }

  Future<void> _navigateToAddTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen()),
    );

    if (newTask != null) {
      _filterTasks(currentFilter);
    }
  }
}