import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atask/api/task_api.dart';
import 'package:atask/models/task_model.dart';
import 'package:atask/screens/task_edit_screen.dart'; // Import TaskEditScreen

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Task? _taskDetail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTaskDetail();
  }

  Future<void> _fetchTaskDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await TaskApi.fetchTask(token, widget.task.id);

      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        setState(() {
          _taskDetail = Task.fromJson(response['data']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch task detail: $e')),
      );
      print(e);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != null && confirm) {
      await _deleteTask();
    }
  }

  Future<void> _deleteTask() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await TaskApi.deleteTask(token, widget.task.id);

      if (response['success']) {
        Navigator.of(context).pop(); // Close detail screen after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
      print(e);
    }
  }

  void _navigateToEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskEditScreen(task: _taskDetail!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditScreen,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _taskDetail != null
              ? _buildTaskDetail()
              : const Center(child: Text('Failed to load task detail')),
    );
  }

  Widget _buildTaskDetail() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Title: ${_taskDetail!.title}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Description: ${_taskDetail!.description}'),
          const SizedBox(height: 8),
          Text('Date: ${_taskDetail!.date.toString().substring(0, 10)}'),
          const SizedBox(height: 8),
          Text('Priority: ${_taskDetail!.priority}'),
        ],
      ),
    );
  }
}
