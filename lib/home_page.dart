import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'report.dart'; // Import the ReportPage
import 'dart:async';

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _tasks = [];
  List<String> _selectedTasks = [];
  List<String> _completedTasks = []; // List to track completed tasks
  Map<String, Stopwatch> _taskTimers = {}; // Timers for each task

  @override
  void initState() {
    super.initState();
    fetchTasks(); // Fetch tasks when the page loads
  }

  // Fetch tasks from the server
  Future<void> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('http://bassel.atwebpages.com/get_tasks.php'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            _tasks = List<String>.from(data['tasks']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Failed to fetch tasks')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> updateTaskStatus(String task) async {
    try {
      // Stop the timer and calculate elapsed time
      Stopwatch? stopwatch = _taskTimers[task];
      stopwatch?.stop();
      int elapsedSeconds = stopwatch?.elapsed.inSeconds ?? 0;

      final response = await http.post(
        Uri.parse('http://bassel.atwebpages.com/update_task.php'),
        body: {
          'task': task,
          'status': 'done',
          'time_taken': elapsedSeconds.toString(), // Send elapsed time to the server
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "$task" marked as done in $elapsedSeconds seconds')),
        );

        setState(() {
          _selectedTasks.remove(task); // Remove task from selected list
          _completedTasks.add(task); // Add task to completed list
          _tasks.remove(task); // Remove task from dropdown options
          _taskTimers.remove(task); // Remove the task's timer
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task "$task"')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome, ${widget.username.isNotEmpty ? widget.username : 'guest'}!')), // Display the username
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${widget.username.isNotEmpty ? widget.username : 'guest'}!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              hint: Text('Select Task'),
              items: _tasks.where((task) {
                return !_completedTasks.contains(task); // Only show tasks that aren't completed
              }).map((task) {
                return DropdownMenuItem<String>(value: task, child: Text(task));
              }).toList(),
              onChanged: (value) {
                if (value != null && !_selectedTasks.contains(value)) {
                  setState(() {
                    _selectedTasks.add(value);
                    // Start a timer for the selected task
                    _taskTimers[value] = Stopwatch()..start();
                  });
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportPage(), // Navigate to ReportPage
                  ),
                );
              },
              child: Text('View Report'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedTasks.length,
                itemBuilder: (context, index) {
                  final task = _selectedTasks[index];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () => updateTaskStatus(task),
                                child: Text('done'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedTasks.remove(task);
                                    _taskTimers.remove(task); // Remove timer for the task
                                  });
                                },
                                child: Text('X'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
