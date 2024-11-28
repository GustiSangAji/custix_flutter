import 'package:custix/screen/Profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'constants.dart';
import 'package:custix/screen/Cart/cart_screen.dart';
import 'package:custix/screen/Home/home_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  // Set initial value of _currentIndex to 0 (Home screen)
  int _currentIndex = 0; // Changed from 1 to 0

  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(
      ticketId: '',
      ticketName: '',
    ),
    Profile(),
  ];

  SvgPicture svgIcon(String src, {Color? color}) {
    return SvgPicture.asset(
      src,
      height: 24,
      colorFilter: ColorFilter.mode(
          color ??
              Theme.of(context).iconTheme.color!.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 1),
          BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        selectedItemColor: kprimaryColor,
        unselectedItemColor: Colors.grey.shade400,
        items: [
          BottomNavigationBarItem(
            icon: svgIcon("assets/images/icon/home-01.svg"),
            activeIcon:
                svgIcon("assets/images/icon/home-01.svg", color: kprimaryColor),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: svgIcon("assets/images/icon/Bag.svg"),
            activeIcon:
                svgIcon("assets/images/icon/Bag.svg", color: kprimaryColor),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: svgIcon("assets/images/icon/Profile.svg"),
            activeIcon:
                svgIcon("assets/images/icon/Profile.svg", color: kprimaryColor),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
