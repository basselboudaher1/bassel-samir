import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportPage extends StatefulWidget {
  final int userId;

  ReportPage({required this.userId});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List completedTasks = [];

  // Fetch completed tasks from the backend
  Future<void> fetchCompletedTasks() async {
    final response = await http.get(
      Uri.parse('http://bassel.atwebpages.com/add_task.php'),
    );

    if (response.statusCode == 200) {
      setState(() {
        completedTasks = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task History')),
      body: completedTasks.isEmpty
          ? Center(child: CircularProgressIndicator())  // Show loading indicator while fetching data
          : ListView.builder(
        itemCount: completedTasks.length,
        itemBuilder: (context, index) {
          final task = completedTasks[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['task'] ?? 'No Task Description', // Display task description
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Status: ${task['status'] ?? 'Unknown'}'),  // Display task status
                  SizedBox(height: 8),
                  Text('Priority: ${task['priority'] ?? 'Not Set'}'),  // Display task priority
                  SizedBox(height: 8),
                  Text('Completed on: ${task['completed_at'] ?? 'Not Available'}'), // Display task completion date if available
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
