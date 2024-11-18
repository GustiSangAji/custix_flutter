import 'package:flutter/material.dart';
import 'package:custix/api/api_service.dart';
import 'package:custix/model/ticket_model.dart';
import 'package:custix/screen/add_tiket.dart';

class TicketList extends StatefulWidget {
  final String? token;

  TicketList({Key? key, this.token}) : super(key: key);

  @override
  _TicketListState createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  List<Ticket> _tickets = [];
  final ApiService apiService = ApiService();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() async {
    try {
      var ticketsData = await apiService.fetchTickets(token: widget.token);
      setState(() {
        _tickets = ticketsData.map((json) => Ticket.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading tickets: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Tiket')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _tickets[index];
                    return ListTile(
                      title: Text(ticket.name),
                      subtitle: Text(ticket.place),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  add_Tiket(selectedId: ticket.uuid),
                            ),
                          );
                          if (result == true) {
                            _loadTickets(); // Refresh data jika tiket diubah
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => add_Tiket()),
          );
          if (result == true) {
            _loadTickets(); // Refresh data jika tiket baru dibuat
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
