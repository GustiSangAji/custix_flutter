import 'package:flutter/material.dart';
import 'package:custix/api/auth.dart';
import 'package:custix/screen/Dashboard/Tiket/ticket_list.dart';
import 'package:custix/screen/Dashboard/dashboard.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  // Fungsi logout
  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/signin');
  }

  // Mendapatkan token
  Future<String?> getToken() async {
    String? token = await AuthRepository().getToken();
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, // Background putih
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(context),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard_customize,
                    label: "Dashboard",
                    onTap: () {
                      Navigator.pop(context); // Tutup drawer
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                  ),
                  _buildDrawerItemWithChildren(
                    context,
                    icon: Icons.category_outlined,
                    label: "Events",
                    children: [
                      _buildSubDrawerItem(
                        context,
                        label: "TIKET",
                        onTap: () async {
                          String? token = await getToken();
                          if (token != null) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketList(token: token),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Token tidak ditemukan")),
                            );
                          }
                        },
                      ),
                      _buildSubDrawerItem(
                        context,
                        label: "STOCK-IN",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/Stockin');
                        },
                      ),
                    ],
                  ),
                  // Menambahkan menu "Laporan" di bawah menu "Events"
                  _buildDrawerItem(
                    context,
                    icon: Icons.report,
                    label: "Laporan", // Menu Laporan
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/Laporan');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout_rounded,
                    label: "Logout",
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "© 2024 Custix",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header Section
  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blueAccent, // Ganti dengan warna biru terang untuk header
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white, // Background putih pada avatar
            child: Icon(Icons.person, size: 50, color: Colors.blue),
          ),
          SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Admin",
                style: TextStyle(
                  color: Colors.white, // Teks putih di header
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Admin@gmail.com",
                style: TextStyle(
                  color: Colors.white70, // Teks putih dengan transparansi
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Main Drawer Item
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black), // Ikon hitam
      title: Text(
        label,
        style: TextStyle(
          color: Colors.black, // Teks hitam
          fontWeight: FontWeight.w500, // Menambahkan ketebalan pada teks
        ),
      ),
      onTap: onTap,
      tileColor: Colors.grey[100], // Menambahkan warna latar belakang item
    );
  }

  // Main Drawer Item with Children (Expandable)
  Widget _buildDrawerItemWithChildren(
    BuildContext context, {
    required IconData icon,
    required String label,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.black), // Ikon hitam
      title: Text(
        label,
        style: TextStyle(
          color: Colors.black, // Teks hitam
          fontWeight: FontWeight.w500,
        ),
      ),
      childrenPadding: EdgeInsets.only(left: 20),
      tilePadding: EdgeInsets.symmetric(horizontal: 20),
      iconColor: Colors.black,
      collapsedIconColor: Colors.black,
      children: children,
    );
  }

  // Sub Drawer Item
  Widget _buildSubDrawerItem(
    BuildContext context, {
    required String label,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: Colors.grey[600], // Warna teks abu-abu untuk item sub-menu
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      tileColor: Colors.grey[50], // Latar belakang item sub-menu lebih terang
    );
  }
}
