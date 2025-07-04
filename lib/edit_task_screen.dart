import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'task_model.dart';

// Handles date and time picking logic
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

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final TaskResponse task;

  const EditTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _startDate = widget.task.startDate;
    _endDate = widget.task.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final pickedDate = await DateTimePickerService.pickDateTime(
      context,
      _startDate,
    );
    if (pickedDate != null) {
      setState(() => _startDate = pickedDate);
    }
  }

  Future<void> _selectEndDate() async {
    final pickedDate = await DateTimePickerService.pickDateTime(
      context,
      _endDate,
      firstDate: _startDate,
    );
    if (pickedDate != null) {
      setState(() => _endDate = pickedDate);
    }
  }

  void _saveChanges() {
    Navigator.pop(context, TaskUpdateRequest(
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate,
      endDate: _endDate,
    ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInputField(
              controller: _titleController,
              label: 'Task Title',
            ),
            SizedBox(height: 16),
            _buildInputField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 3,
            ),
            SizedBox(height: 16),
            _buildDateTile(
              label: 'Start Date',
              date: _startDate,
              onTap: _selectStartDate,
            ),
            _buildDateTile(
              label: 'End Date',
              date: _endDate,
              onTap: _selectEndDate,
            ),
          ],
        ),
      ),
    );
  }
}