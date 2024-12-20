import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:custix/api/ticket.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showLogo;
  final String? titleText;
  final bool showNotificationIcon;
  final TextStyle? titleStyle;
  final EdgeInsets? actionPadding;

  const CustomAppBar({
    super.key,
    this.showLogo = true,
    this.titleText,
    this.showNotificationIcon = true,
    this.titleStyle,
    this.actionPadding,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leadingWidth: 25,
      leading: showLogo
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.black,
            ),
      title: showLogo
          ? Image.asset(
              "assets/images/custiket.png",
              height: 100,
              width: 100,
            )
          : Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                titleText ?? "",
                style: titleStyle ??
                    const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
              ),
            ),
      actions: <Widget>[
        Padding(
          padding: actionPadding ?? const EdgeInsets.only(right: 8.0),
          child: Hero(
            tag: 'search-icon',
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              child: SvgPicture.asset(
                "assets/images/icon/Search-01.svg",
                height: 24,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        if (showNotificationIcon)
          Padding(
            padding: actionPadding ?? const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                // Add notification logic here
              },
              icon: SvgPicture.asset(
                "assets/images/icon/Notification.svg",
                height: 24,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  bool _isLoading = false; // To track loading state
  final TicketRepository _ticketRepository = TicketRepository();

  void _searchTickets(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _ticketRepository.searchTickets(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Hero(
              tag: 'search-icon',
              child: Material(
                color: Colors.transparent,
                child: SvgPicture.asset(
                  "assets/images/icon/Search-01.svg",
                  height: 30,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0), // Adjust padding here if needed
                  child: TextField(
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                      _searchTickets(query);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                      isDense: true, // Ensures the content is compact
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14, // Make the text smaller
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? Center(
                  child: Text(
                    'No results found for "$_searchQuery"',
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final ticket = _searchResults[index];
                    final String baseUrl = 'http://192.168.2.140:8000';
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gambar poster
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              Uri.parse(
                                      '$baseUrl/${ticket['image'].replaceFirst(RegExp(r'^/'), '')}')
                                  .toString(),
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error, size: 80),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Kolom teks
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama tiket
                                Text(
                                  ticket['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Row untuk detail
                                Row(
                                  children: [
                                    // Place
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ticket['place'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // DateTime
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        DateFormat('dd MMM yyyy', 'id').format(
                                          DateTime.parse(ticket['datetime']),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Tambahkan elemen lainnya seperti rating atau format
                                Row(
                                  children: [
                                    // Durasi atau jam dari datetime
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ticket['duration'] ??
                                            DateFormat('HH:mm', 'id').format(
                                              DateTime.parse(
                                                  ticket['datetime']),
                                            ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Rating
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ticket['rating'] ?? 'R13+',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Format
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ticket['format'] ?? '2D',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
