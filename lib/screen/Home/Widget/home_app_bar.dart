import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:custix/api/ticket.dart';
import 'package:custix/model/ticket_model.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Image.asset(
        "assets/images/custiket.png", // Logo
        height: 100,
        width: 100,
      ),
      actions: <Widget>[
        // Tombol pencarian
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SearchPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
          icon: SvgPicture.asset(
            "assets/images/icon/Search-01.svg",
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
            "assets/images/icon/Notification.svg", // Ganti dengan ikon notifikasi yang sesuai
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

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  final TicketRepository _ticketRepository = TicketRepository();

  // Fungsi untuk mencari tiket
  void _searchTickets(String query) async {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
            if (query.isNotEmpty) {
              _searchTickets(query);
            } else {
              setState(() {
                _searchResults.clear();
              });
            }
          },
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: _searchResults.isEmpty
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
                final String baseUrl = 'http://192.168.2.153:8000/';
                return ListTile(
                  leading: Image.network(
                    Uri.parse('$baseUrl/${ticket['image']}').toString(),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                  title: Text(ticket['name']),
                  subtitle: Text('${ticket['place']} - ${ticket['datetime']}'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/ticket_detail',
                      arguments: Ticket,
                    );
                  },
                );
              },
            ),
    );
  }
}
