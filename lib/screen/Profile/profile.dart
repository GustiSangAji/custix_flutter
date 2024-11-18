import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:custix/screen/constants.dart';
import 'package:custix/screen/Profile/edit_profile.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _profileImage;

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
    return Scaffold(
      appBar: AppBar(
  elevation: 0,
  backgroundColor: Colors.transparent,
  foregroundColor: Colors.black,
  title: Padding(
    padding: const EdgeInsets.only(left: 10.0), // Tambahkan padding ke kiri
    child: const Text(
      "Profile",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 10.0), // Tambahkan padding ke kanan
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const NetworkImage(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQd-SG5jP0A6N_s-VDwKeUiI_JO8wFvEQDN01-R7IMdJJ_fH4j5IoXxG9V1LTqj37Rxhv8&usqp=CAU",
                          ) as ImageProvider,
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
              const Text(
                "Mas Rizky",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text("rizdian229@gmail.com"),
            ],
          ),
          const SizedBox(height: 45),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 15),
            child: const Text(
              "Settings",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          ...List.generate(
            customListTiles.length,
            (index) {
              final tile = customListTiles[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  leading: Container(
                    width: 50, // Diameter lingkaran
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200], // Warna latar lingkaran
                    ),
                    child: Icon(
                      tile.icon,
                      size: 20, // Ukuran ikon
                      color: Colors.black87, // Warna ikon
                    ),
                  ),
                  title: Text(
                    tile.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Warna merah untuk Logout
                    ),
                  ),
                  trailing: Container(
                    width: 40, // Diameter lingkaran
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200], // Warna latar lingkaran
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.black87, // Warna ikon
                      size: 20,
                    ),
                  ),
                  onTap: () {
                    if (tile.title == "Dashboard") {
                      Navigator.pushNamed(context, '/dashboard');
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

class CustomListTile {
  final IconData icon;
  final String title;
  CustomListTile({
    required this.icon,
    required this.title,
  });
}

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
