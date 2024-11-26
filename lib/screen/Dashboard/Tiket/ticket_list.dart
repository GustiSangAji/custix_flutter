import 'package:flutter/material.dart';
import 'package:custix/api/api_service.dart';
import 'package:custix/model/ticket_model.dart';
import 'package:custix/screen/Dashboard/Tiket/add_tiket.dart';
import 'package:custix/widgets/drawer_menu.dart';

class TicketList extends StatefulWidget {
  final String? token;

  const TicketList({super.key, this.token});

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

  void _deleteTicket(String uuid) async {
    try {
      await apiService.deleteTicket(uuid, token: widget.token);
      _loadTickets(); // Refresh data setelah tiket dihapus
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting ticket: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Tiket',
          style:
              TextStyle(color: Colors.white), // Ubah warna teks menjadi putih
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Background app bar biru
        iconTheme:
            IconThemeData(color: Colors.white), // Ubah warna ikon menjadi putih
      ),
      drawer: DrawerMenu(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: _tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = _tickets[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: InkWell(
                          onTap: () async {
                            // Fungsi edit saat seluruh kartu ditekan
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
                          borderRadius: BorderRadius.circular(10.0),
                          splashColor: Colors.blue.withOpacity(0.2),
                          highlightColor: Colors.blue.withOpacity(0.1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gambar tiket
                              Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10.0)),
                                  image: DecorationImage(
                                    image: ticket.image != null
                                        ? NetworkImage(
                                            'http://192.168.2.101:8000/storage/${ticket.image}')
                                        : AssetImage('assets/placeholder.jpg')
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Informasi tiket di bawah gambar
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ticket.name,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      ticket.place,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Rp ${ticket.price}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Tombol hapus di bawah
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Hapus Tiket'),
                                          content: Text(
                                              'Apakah Anda yakin ingin menghapus tiket ini?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _deleteTicket(ticket.uuid);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Hapus'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
        backgroundColor: Colors.blueAccent, // Warna tombol biru
      ),
    );
  }
}
