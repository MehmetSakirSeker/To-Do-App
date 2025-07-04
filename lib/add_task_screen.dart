import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'task_model.dart';
import 'database_service.dart';

// for  date validation logic
class DateValidatorService {
  static bool isEndDateAfterStartDate(DateTime startDate, DateTime endDate) {
    return endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);
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

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final DatabaseService dbService = DatabaseService.instance;
  final TaskRepository taskRepository = TaskRepository(DatabaseService.instance);

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _updateStartDate(picked);
    }
  }

  void _updateStartDate(DateTime pickedDate) {
    setState(() {
      _startDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      if (_endDate != null && !DateValidatorService.isEndDateAfterStartDate(_startDate!, _endDate!)) {
        _endDate = null;
      }
    });
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()).add(Duration(days: 1)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _updateEndDate(picked);
    }
  }

  void _updateEndDate(DateTime pickedDate) {
    setState(() {
      _endDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    });
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  //Box checking method
  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_startDate == null || _endDate == null) {
      showErrorMessage('Please select both start and end dates');
      return false;
    }

    if (!DateValidatorService.isEndDateAfterStartDate(_startDate!, _endDate!)) {
      showErrorMessage('End date cannot be before start date');
      return false;
    }

    return true;
  }

  Future<void> _saveTask() async {
    if (!_validateForm()) return;

    try {
      final newTask = await taskRepository.createTask(
        TaskRequestMapper.mapToTaskCreateRequest(
          title: _titleController.text,
          description: _descriptionController.text,
          startDate: _startDate!,
          endDate: _endDate!,
        ),
      );

      Navigator.pop(context, newTask);
    } catch (e) {
      showErrorMessage('Error saving task: ${e.toString()}');
    }
  }

  String _formatDate() {
    if (_startDate == null || _endDate == null) return '';

    final duration = _endDate!.difference(_startDate!);
    return 'Task Duration: ${duration.inDays} days, ${duration.inHours % 24} hours';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTitleField(),
              SizedBox(height: 16),
              _buildDescriptionField(),
              SizedBox(height: 16),
              _buildStartDateTile(context),
              _buildEndDateTile(context),
              SizedBox(height: 24),
              if (_startDate != null && _endDate != null)
                _buildDurationText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Task Title',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
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
        _startDate == null ? 'Not Selected' : DateFormat('dd/MM/yyyy').format(_startDate!),
      ),
      trailing: Icon(Icons.calendar_today),
      onTap: () => _selectStartDate(context),
    );
  }

  Widget _buildEndDateTile(BuildContext context) {
    return ListTile(
      title: Text('End Date *'),
      subtitle: Text(
        _endDate == null ? 'Not Selected' : DateFormat('dd/MM/yyyy').format(_endDate!),
      ),
      trailing: Icon(Icons.calendar_today),
      onTap: _startDate == null
          ? () => showErrorMessage('Please select start date first')
          : () => _selectEndDate(context),
    );
  }

  Widget _buildDurationText() {
    return Text(
      _formatDate(),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    );
  }
}