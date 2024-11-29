import 'dart:io';
import 'package:custix/screen/notif/notif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:custix/screen/constants.dart';
import 'package:custix/screen/Profile/edit_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Definisi kelas CustomListTile
class CustomListTile {
  final IconData icon;
  final String title;

  CustomListTile({
    required this.icon,
    required this.title,
  });
}

// Daftar CustomListTiles
List<CustomListTile> customListTiles = [
  CustomListTile(
    icon: CupertinoIcons.moon,
    title: "Theme",
  ),
  CustomListTile(
    icon: Icons.location_on_outlined,
    title: "Location",
  ),
  CustomListTile(
    title: "Notifications",
    icon: CupertinoIcons.bell,
  ),
  CustomListTile(
    title: "Dashboard",
    icon: Icons.space_dashboard_outlined,
  ),
  CustomListTile(
    title: "Logout",
    icon: CupertinoIcons.arrow_right_arrow_left,
  ),
];

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  String userRole = ""; // Variabel untuk menyimpan role pengguna
  File? _profileImage;
  String userName = "";
  String userEmail = "";
  String photo = "";
  bool isLoggedIn = false;
  bool isLoading = true; // Tambahkan variabel isLoading

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('isLoggedIn', false); // Mengubah status login
    Navigator.pushReplacementNamed(context, '/home');
  }

  // Fungsi untuk mengambil data user dari SharedPreferences
  Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "User Name";
      userEmail = prefs.getString('user_email') ?? "User Email";
      userRole = prefs.getString('user_role') ?? "user";
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      photo = prefs.getString('photo') ?? "photo";
      isLoading = false; // Setelah selesai, ubah loading ke false
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData(); // Ambil data user saat halaman dimuat
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika sedang loading, tampilkan indikator loading
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: kprimaryColor,
          ),
        ),
      );
    }

    // Jika pengguna belum login
    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Belum login, login dulu yuk!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signin');
                },
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      );
    }

    // Filter menu berdasarkan role
    List<CustomListTile> filteredListTiles = customListTiles.where((tile) {
      if (tile.title == "Dashboard" && userRole != "admin") {
        return false;
      }
      return true;
    }).toList();

    // Jika pengguna sudah login
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            "Profile",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfile()),
                );
              },
              icon: const Icon(Icons.settings_outlined),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Column(
            children: [
              // Profil pengguna
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      'http://192.168.2.101:8000$photo',
                    ),
                    backgroundColor:
                        Colors.grey[200], // Untuk background warna jika loading
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: kprimaryColor,
                        child: const Icon(
                          Icons.mode_edit_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(userEmail),
            ],
          ),
          const SizedBox(height: 45),
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 15),
            child: Text(
              "Settings",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          ...List.generate(
            filteredListTiles.length,
            (index) {
              final tile = filteredListTiles[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: Icon(
                      tile.icon,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                  title: Text(
                    tile.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                  onTap: () {
                    if (tile.title == "Notifications") {
                      // Navigasi ke halaman Notifications
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsScreen()),
                      );
                    } else if (tile.title == "Dashboard") {
                      Navigator.pushNamed(context, '/dashboard');
                    } else if (tile.title == "Logout") {
                      logout();
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
