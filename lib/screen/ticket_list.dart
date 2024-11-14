import 'package:flutter/material.dart';
import 'package:custix/api/api_service.dart';
import 'package:custix/model/ticket_model.dart';
import 'add_Tiket.dart';

class TicketList extends StatefulWidget {
  final String? token;

  // Terima token melalui konstruktor
  TicketList({Key? key, this.token}) : super(key: key);

  @override
  _TicketListState createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  List<Ticket> _tickets = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() async {
    try {
      // Gunakan token yang diteruskan ke sini
      var ticketsData =
          await apiService.fetchTickets('available', token: widget.token);
      setState(() {
        _tickets =
            ticketsData.map<Ticket>((json) => Ticket.fromJson(json)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading tickets')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Tiket')),
      body: ListView.builder(
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return ListTile(
            title: Text(ticket.name),
            subtitle: Text(ticket.place),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => add_Tiket(selectedId: ticket.uuid)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => add_Tiket()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
