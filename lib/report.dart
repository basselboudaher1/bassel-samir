import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Map<String, dynamic>> _tasks = []; // Store task data as maps

  @override
  void initState() {
    super.initState();
    fetchTasks(); // Fetch tasks when the page loads
  }

  // Fetch tasks from the server
  Future<void> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('http://bassel.atwebpages.com/get_all_tasks.php'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            _tasks = List<Map<String, dynamic>>.from(data['tasks']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _tasks.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final task = _tasks[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['description'] ?? 'No Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Status: ${task['status'] ?? 'Unknown'}'),
                    Text(
                      'Time Taken: ${task['time_taken'] != null ? "${task['time_taken']} seconds" : "N/A"}',
                    ), // Display time taken
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
