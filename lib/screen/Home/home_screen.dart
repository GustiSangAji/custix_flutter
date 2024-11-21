import 'package:flutter/material.dart';
import 'package:custix/screen/Home/Widget/image_slider.dart';
import 'package:custix/screen/Home/Widget/product_cart.dart';
import 'package:custix/model/tiket_model.dart';
import 'package:custix/screen/constants.dart';
import 'Widget/home_app_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentSlider = 0;
  List<Ticket> tickets = [];
  List<String> sliderImages = [];

  @override
  void initState() {
    super.initState();
    fetchTickets();
    fetchSliderImages();
  }

  /// Fungsi untuk mengambil data tiket
  Future<void> fetchTickets() async {
    final url = Uri.parse('http://192.168.2.140:8000/api/tickets/limited');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          tickets = data.map((json) => Ticket.fromJson(json)).toList();
        });
      } else {
        print('Failed to load tickets. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching tickets: $error');
    }
  }

  /// Fungsi untuk mengambil data slider dari API
  Future<void> fetchSliderImages() async {
    final url = Uri.parse('http://192.168.2.140:8000/api/setting');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        String baseUrl = 'http://192.168.2.140:8000'; // Base URL server Anda
        setState(() {
          // Gabungkan base URL dengan path gambar
          sliderImages = [
            if (data['carousel1'] != null) baseUrl + data['carousel1'],
            if (data['carousel2'] != null) baseUrl + data['carousel2'],
            if (data['carousel3'] != null) baseUrl + data['carousel3'],
            if (data['carousel4'] != null) baseUrl + data['carousel4'],
            if (data['carousel5'] != null) baseUrl + data['carousel5'],
            if (data['carousel6'] != null) baseUrl + data['carousel6'],
            if (data['carousel7'] != null) baseUrl + data['carousel7'],
            if (data['carousel8'] != null) baseUrl + data['carousel8'],
            if (data['carousel9'] != null) baseUrl + data['carousel9'],
            if (data['carousel10'] != null) baseUrl + data['carousel10'],
          ];
        });
      } else {
        print('Failed to load slider images. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching slider images: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar(),
                  const SizedBox(height: 20),
                  sliderImages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ImageSlider(
                          currentSlide: currentSlider,
                          onChange: (value) {
                            setState(() {
                              currentSlider = value;
                            });
                          },
                          images: sliderImages, // Kirimkan data slider
                        ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Spesial untuk anda",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "Lihat semua",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 300,
              child: tickets.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const PageScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 15 : 10,
                            right: index == tickets.length - 1 ? 15 : 0,
                          ),
                          child: ProductCard(
                            ticket: tickets[index], // Kirimkan objek Ticket langsung
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.movie_outlined,
                    color: kprimaryColor,
                    size: 35,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "That's all for now",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
