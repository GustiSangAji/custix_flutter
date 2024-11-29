import 'package:custix/screen/constants.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isNotificationsEnabled = true; // Menyimpan status notifikasi

  final List<String> notifications = [
    'You have a new message.',
    'Berhasil Login!.',
    'Pemesanan pending.',
  ];

  // Fungsi untuk mengubah status notifikasi
  void _toggleNotifications(bool value) {
    setState(() {
      _isNotificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
        backgroundColor:
            kprimaryColor, // Menggunakan konstanta warna untuk background
        foregroundColor: Colors.white, // Mengubah warna teks menjadi putih
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPaddin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul untuk pengaturan notifikasi

            const SizedBox(height: 20),

            // Switch untuk mengaktifkan atau menonaktifkan notifikasi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    color: kTextLightColor,
                  ),
                ),
                Switch(
                  value: _isNotificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeColor: kprimaryColor,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Daftar notifikasi jika aktif
            if (_isNotificationsEnabled) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading:
                          const Icon(Icons.notifications, color: kprimaryColor),
                      title: Text(notifications[index]),
                      subtitle: const Text('Just now'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Aksi saat notifikasi diklik
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Telah Dibaca ${index + 1}')),
                        );
                      },
                    );
                  },
                ),
              ),
            ] else ...[
              // Menampilkan pesan jika notifikasi dimatikan
              Center(
                child: Text(
                  'Notifications are turned off.',
                  style: TextStyle(
                    fontSize: 16,
                    color: kTextLightColor,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
