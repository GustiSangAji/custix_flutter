import 'package:flutter/material.dart';
import 'package:custix/api/auth.dart';
import 'package:custix/screen/ticket_list.dart';
import 'package:custix/screen/dashboard.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF212121), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                    label: "Products",
                    children: [
                      _buildSubDrawerItem(
                        context,
                        label: "Add Product",
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
                        label: "Manage Products",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/manage_products');
                        },
                      ),
                    ],
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
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Color(0xFF6A82FB)),
          ),
          SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "User Name",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "user@example.com",
                style: TextStyle(
                  color: Colors.white70,
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
      leading: Icon(icon, color: Colors.white),
      title: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onTap,
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
      leading: Icon(icon, color: Colors.white),
      title: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      childrenPadding: EdgeInsets.only(left: 20),
      tilePadding: EdgeInsets.symmetric(horizontal: 20),
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
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
          color: Colors.grey[400],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
