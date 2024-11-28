import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CartScreen extends StatefulWidget {
  final String ticketId;
  final String ticketName;
  final int? queuePosition; // Menambahkan parameter queuePosition
  final bool accessActive; // Menambahkan parameter accessActive

  const CartScreen({
    Key? key,
    required this.ticketId,
    required this.ticketName,
    this.queuePosition, // Menambahkan parameter opsional queuePosition
    this.accessActive = false, // Menambahkan parameter opsional accessActive
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<CartScreen> {
  bool accessGranted = false;
  Timer? _timer;
  bool isTimeout = false; // Untuk menandakan apakah proses antrian terlalu lama

  @override
  void initState() {
    super.initState();
    checkStatus(); // Check status on initial load
    _timer = Timer.periodic(Duration(seconds: 5), (_) => checkStatus());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer on dispose
    removeFromQueue(); // Remove user from queue
    super.dispose();
  }

  Future<void> checkStatus() async {
    try {
      final response = await Dio().get(
        'https://192.168.2.101:8000/waiting-room-status',
        queryParameters: {'ticket_id': widget.ticketId},
      );

      setState(() {
        accessGranted = response.data['accessGranted'];
      });

      if (accessGranted) {
        _timer?.cancel(); // Stop the timer
        await removeFromQueue();
        Navigator.pushReplacementNamed(
          context,
          '/TicketDetail',
          arguments: {'name': widget.ticketName.replaceAll(' ', '-')},
        );
      }
    } catch (error) {
      print('Error checking status: $error');
      // Handle timeout or network issues
      setState(() {
        isTimeout = true;
      });
    }
  }

  Future<void> removeFromQueue() async {
    try {
      final userId = await getUserId();
      if (userId != null) {
        await Dio().post(
          'https://example.com/clear-access',
          data: {'user_id': userId},
        );
        print('User removed from queue');
      }
    } catch (error) {
      print('Error removing user from queue: $error');
    }
  }

  Future<String?> getUserId() async {
    // Simulate fetching user ID from local storage or other source
    return 'example_user_id';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Center(
        child: Card(
          elevation: 8,
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Waiting Room...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                accessGranted
                    ? Column(
                        children: [
                          Text(
                            'Slot tersedia! Anda akan segera diarahkan...',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          CircularProgressIndicator(
                            color: Colors.green,
                          ),
                        ],
                      )
                    : isTimeout
                        ? Column(
                            children: [
                              Text(
                                'Waktu antrian terlalu lama. Silakan coba lagi nanti.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context); // Kembali ke halaman sebelumnya
                                },
                                child: Text('Kembali'),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Text(
                                'Terlalu banyak pengguna mengakses halaman ini. Antrian Anda: ',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                widget.queuePosition?.toString() ?? '-',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Silakan tunggu hingga pengguna selesai.\nEstimasi 5 Menit',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
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
