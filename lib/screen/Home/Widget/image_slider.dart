import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
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
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentSlide;
    _pageController = PageController(
      initialPage: widget.images.length * 50,
      viewportFraction: 0.8,
    );
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentIndex = index % widget.images.length;
    });

    if (index == 0) {
      _pageController.jumpToPage(widget.images.length * 50 - 1);
    } else if (index == widget.images.length * 100 - 1) {
      _pageController.jumpToPage(widget.images.length * 50);
    }
    widget.onChange(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _handlePageChange,
        itemCount: widget.images.length * 100,
        itemBuilder: (context, index) {
          final loopedIndex = index % widget.images.length;
          final isSelected = _currentIndex == loopedIndex;

          return TweenAnimationBuilder(
            tween: Tween<double>(begin: isSelected ? 1.0 : 0.9, end: isSelected ? 1.0 : 0.9),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isSelected ? 0.3 : 0.0),
                        blurRadius: isSelected ? 6 : 0,
                        spreadRadius: isSelected ? 2 : 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.images[loopedIndex],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
