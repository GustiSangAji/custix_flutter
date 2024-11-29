import 'package:flutter/material.dart';
import 'package:custix/model/ticket_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:custix/screen/Home/Widget/product_cart.dart';
import 'home_app_bar.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List<Ticket> tickets = [];
  bool isLoading = true;
  bool hasMore = true;
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchAllTickets();

    // Listen to scroll position
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore) {
        // If scrolled to the bottom and there is more data to load
        fetchAllTickets();
      }
    });
  }

  /// Fetch tickets from API with pagination
  Future<void> fetchAllTickets() async {
    final String baseUrl = 'http://192.168.2.140:8000/api/tickets';
    try {
      final response = await http.get(Uri.parse('$baseUrl?page=$currentPage'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Ticket> newTickets = (data['data'] as List)
            .map((json) => Ticket.fromJson(json))
            .toList();

        setState(() {
          tickets.addAll(newTickets);
          currentPage++;
          hasMore = data['next_page_url'] != null;
          isLoading = false;
        });
      } else {
        print('Failed to load tickets');
      }
    } catch (error) {
      print('Error fetching tickets: $error');
    }
  }

  // Widget to show shimmer placeholder
  Widget buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing:
              60, // Reduced mainAxisSpacing to decrease vertical space
          childAspectRatio: 0.9,
        ),
        itemCount: 6, // Number of shimmer items to show initially
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8.0),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showLogo: false,
        titleText: "Lihat Semua",
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
        showNotificationIcon: false,
        actionPadding:
            EdgeInsets.symmetric(horizontal: 16.0), // Tambahkan padding
      ),
      body: SafeArea(
        child: tickets.isEmpty
            ? buildShimmerGrid()
            : GridView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing:
                      10, // Reduced mainAxisSpacing to decrease vertical space
                  childAspectRatio: 0.9,
                ),
                itemCount: tickets.length +
                    (hasMore
                        ? 6
                        : 0), // Show 6 shimmer items if more data exists
                itemBuilder: (context, index) {
                  if (index < tickets.length) {
                    // Display actual data
                    return ProductCard(
                      ticket: tickets[index],
                      isCompact: true,
                    );
                  } else {
                    // Show shimmer loading while data is being fetched
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: 50.0), // Reduced bottom padding for shimmer
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 220,
                          margin: const EdgeInsets.only(
                              bottom: 10), // Reduced bottom margin for shimmer
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }
}
