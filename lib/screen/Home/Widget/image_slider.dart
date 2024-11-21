import 'package:flutter/material.dart';

class ImageSlider extends StatelessWidget {
  final Function(int) onChange;
  final int currentSlide;
  final List<String> images;

  const ImageSlider({
    super.key,
    required this.currentSlide,
    required this.onChange,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.8), // Membuat gambar samping terlihat
        scrollDirection: Axis.horizontal,
        onPageChanged: onChange,
        physics: const ClampingScrollPhysics(),
        itemCount: images.isEmpty ? 1 : images.length,
        itemBuilder: (context, index) {
          if (images.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          // Cek apakah slide saat ini adalah gambar yang aktif (di tengah)
          final isSelected = currentSlide == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300), // Transisi animasi smooth
            curve: Curves.easeInOut, // Kurva untuk animasi shadow
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              // Shadow hanya untuk gambar di tengah
             
            ),
            child: Transform.scale(
              scale: isSelected ? 1.0 : 0.9, // Efek perbesaran gambar tengah
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
