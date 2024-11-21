import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MissionDetails extends StatefulWidget {
  final String title;
  final String description;
  final String location;
  final String time;
  final String priority;
  final String imagePath;
  final String patrolId;

  const MissionDetails({
    required this.title,
    required this.description,
    required this.location,
    required this.time,
    required this.priority,
    required this.imagePath,
    required this.patrolId,
  });

  @override
  _MissionDetailsState createState() => _MissionDetailsState();
}

class _MissionDetailsState extends State<MissionDetails> {
  bool _hasStarted = false;
  bool _showReportForm = false;
  bool _missionFinished = false;
  final TextEditingController _reportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Details'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  widget.imagePath,
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.lightBlue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _infoSection(Icons.location_on, "Location", widget.location),
                  _infoSection(Icons.access_time, "Time", widget.time),
                  _infoSection(Icons.priority_high, "Priority", widget.priority),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _startButton(),
            if (_showReportForm) _buildReportForm(),
            if (_missionFinished) _missionFinishedText(),
          ],
        ),
      ),
    );
  }

  Widget _infoSection(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.lightBlue),
          const SizedBox(width: 10),
          Text(
            "$label: $value",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.lightBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updatePatrolStatus(String status) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3030/api/patrols/update/${widget.patrolId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({'status': status}),
      );
      if (response.statusCode == 200) {
        print('Patrol status updated');
      } else {
        print('Failed to update patrol status');
      }
    } catch (e) {
      print('Error updating patrol status: $e');
    }
  }

  Widget _startButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (_hasStarted) {
              _showReportForm = true;
              updatePatrolStatus('standby');
            } else {
              _hasStarted = true;
              updatePatrolStatus('on_mission');
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _hasStarted ? Colors.green : Colors.lightBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          minimumSize: const Size(200, 50),
        ),
        child: Text(_hasStarted ? 'Mark as Complete' : 'Start'),
      ),
    );
  }

  Widget _buildReportForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _reportController,
          decoration: InputDecoration(
            labelText: 'Enter your report',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              print('Report submitted: ${_reportController.text}');
              setState(() {
                _showReportForm = false;
                _hasStarted = false;
                _missionFinished = true;
                _reportController.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              minimumSize: const Size(200, 50),
            ),
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  Widget _missionFinishedText() {
    return Center(
      child: const Text(
        'Mission Finished',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.lightBlue,
        ),
      ),
    );
  }
}