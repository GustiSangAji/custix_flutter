import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class WaitingRoomPage extends StatefulWidget {
  @override
  _WaitingRoomPageState createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  bool accessGranted = false;
  int? queuePosition;
  Timer? _timer;
  String? ticketId;
  String? ticketName;

  @override
  void initState() {
    super.initState();
    ticketId = Uri.base.queryParameters['id'];
    ticketName = Uri.base.queryParameters['name']?.replaceAll(' ', '-');
    _checkStatus(); // Check status when the page loads
    _timer = Timer.periodic(
        Duration(seconds: 5), (_) => _checkStatus()); // Check every 5 seconds
  }

  Future<void> _checkStatus() async {
    try {
      var response = await Dio().get(
        'http://192.168.2.101:8000/api/waiting-room-status',
        queryParameters: {'ticket_id': ticketId},
      );

      setState(() {
        accessGranted = response.data['accessGranted'];
        queuePosition = response.data['queuePosition'];
      });

      if (accessGranted) {
        _timer?.cancel();
        await _removeFromQueue();

        // Redirect to ticket detail page (you can use Navigator.pushNamed for this)
        Navigator.pushReplacementNamed(
          context,
          '/ticket-detail',
          arguments: {'name': ticketName},
        );
      }
    } catch (error) {
      print('Error checking status: $error');
    }
  }

  Future<void> _removeFromQueue() async {
    try {
      var userId = await _getUserId();
      if (userId != null) {
        var response = await Dio().post(
          'http://192.168.2.101:8000/api/clear-access',
          data: {'user_id': userId},
        );
        print('User removed from ticket queue: ${response.data['message']}');
      } else {
        print('User ID not found.');
      }
    } catch (error) {
      print('Error removing from queue: $error');
    }
  }

  Future<String?> _getUserId() async {
    // Replace this with your actual logic to retrieve user ID from local storage
    return 'userId'; // Simulated user ID
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Waiting Room...',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 20),
                if (accessGranted)
                  Column(
                    children: [
                      Text(
                        'Slot tersedia! Anda akan segera diarahkan...',
                        style: TextStyle(color: Colors.green),
                      ),
                      SizedBox(height: 20),
                      CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Text(
                        'Terlalu banyak pengguna mengakses halaman ini. Antrian Anda:',
                        style: TextStyle(color: Colors.blue),
                      ),
                      Text(
                        queuePosition != null
                            ? queuePosition.toString()
                            : 'Loading...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Silakan tunggu hingga pengguna selesai.'),
                      SizedBox(height: 10),
                      Text('Estimasi 5 Menit'),
                      SizedBox(height: 20),
                      CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
