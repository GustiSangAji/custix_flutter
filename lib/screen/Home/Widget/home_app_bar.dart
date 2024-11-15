import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // Menggunakan background color sesuai temas
      title: Image.asset(
        "assets/images/custiket.png", // Ganti dengan logo Anda
        height: 100, // Sesuaikan tinggi logo
        width: 100, // Sesuaikan lebar logo
      ),
      actions: <Widget>[
        // Tombol pencarian
        IconButton(
          onPressed: () {
            // Aksi saat ikon pencarian ditekan
          },
          icon: SvgPicture.asset(
            "assets/images/icon/search.svg",
            height: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!,
              BlendMode.srcIn,
            ),
          ),
        ),
        // Tombol notifikasi
        IconButton(
          onPressed: () {
            // Aksi saat ikon notifikasi ditekan
          },
          icon: SvgPicture.asset(
            "assets/images/icon/cart.svg", // Ganti dengan ikon notifikasi yang sesuai
            height: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
