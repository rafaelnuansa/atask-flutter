
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atask/models/task_model.dart';
import 'package:atask/api/task_api.dart';

class TaskEditScreen extends StatefulWidget {
  final Task task;

  const TaskEditScreen({super.key, required this.task});

  @override
  TaskEditScreenState createState() => TaskEditScreenState();
}

class TaskEditScreenState extends State<TaskEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.task.title;
    _descriptionController.text = widget.task.description;
    _dateController.text = widget.task.date.toString().substring(0, 10);
  }

  Future<void> _updateTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final title = _titleController.text;
    final description = _descriptionController.text;
    final date = DateTime.parse(_dateController.text);
    final priority = widget.task.priority.toString().split('.').last;

    final response = await TaskApi.updateTask(token, widget.task.id, title, description, date.toIso8601String(), priority);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
      Navigator.pop(context); // Pop back to previous screen after update
    } else {
      String errorMessage = response['message'];
      if (response.containsKey('errors')) {
        errorMessage = _parseErrors(response['errors']);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = picked.toString().substring(0, 10);
      });
    }
  }

  String _parseErrors(Map<String, dynamic> errors) {
    String errorMessage = 'Validation errors:\n';
    errors.forEach((key, value) {
      errorMessage += '$key: ${value[0]}\n'; // Assuming backend sends array of errors
    });
    return errorMessage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
              onTap: () => _selectDate(context),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}
