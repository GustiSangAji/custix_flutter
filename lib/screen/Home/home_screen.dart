import 'package:flutter/material.dart';
import 'package:custix/screen/Home/Widget/image_slider.dart';
import 'package:custix/screen/Home/Widget/product_cart.dart';
import 'package:custix/screen/Home/Widget/search_bar.dart';
import 'package:custix/model/product_model.dart';
import 'Widget/home_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentSlider = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 35),
              // Custom AppBar
              CustomAppBar(),
              SizedBox(height: 20),
              // Search Bar
              MySearchBAR(),
              SizedBox(height: 20),
              // Image Slider
              ImageSlider(
                currentSlide: currentSlider,
                onChange: (value) {
                  setState(() {
                    currentSlider = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Spesial untuk anda",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    "Lihat semua",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Horizontal Scrollable Cards
              SizedBox(
                height: 300, // Adjusted height for larger card size
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: PageScrollPhysics(), 
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: 10,
                        left: index == 0 ? 0 : 10, // Remove left padding for first card
                      ),
                      child: ProductCard(product: products[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
