import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atask/api/task_api.dart';

class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  TaskCreateScreenState createState() => TaskCreateScreenState();
}

class TaskCreateScreenState extends State<TaskCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _priority = 'low'; 
  bool _isLoading = false;

  Future<void> _createTask() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final title = _titleController.text;
    final description = _descriptionController.text;
    final date = DateTime.parse(_dateController.text); 
    final response = await TaskApi.createTask(
      token,
      title,
      description,
      date.toIso8601String(), 
      _priority,
    );

    setState(() {
      _isLoading = false;
    });

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );

      // Navigate back to previous screen (TaskScreen)
      Navigator.pop(context);
      
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

  String _parseErrors(Map<String, dynamic> errors) {
    String errorMessage = 'Validation errors:\n';
    errors.forEach((key, value) {
      errorMessage += '$key: ${value[0]}\n'; // Assuming backend sends array of errors
    });
    return errorMessage;
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
        _dateController.text = picked.toString().substring(0, 10); // Set selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
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
              onTap: () => _selectDate(context), // Open DatePicker on tap
              readOnly: true,
            ),
            DropdownButtonFormField<String>(
              value: _priority,
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
              items: ['low', 'medium', 'high'].map((priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Priority'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: _createTask,
                    child: const Text('Create Task'),
                  ),
          ],
        ),
      ),
    );
  }
}
