import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiket Saya'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Order>>(
                future: fetchOrders(), // Mengambil data pesanan
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'),
                    );
                  }

                  final orders = snapshot.data ?? [];

                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/ticket_tiket-saya.png',
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Kamu belum memiliki tiket, silakan beli tiket terlebih dahulu.',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Gambar tiket

                                const SizedBox(width: 16),
                                // Info tiket
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.ticket.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${formatDate(order.ticket.datetime)} | ${order.jumlahPemesanan} Tiket',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pembelian pada ${formatDate(order.ticket.createdAt)}',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 16),
                                      // Status dan tombol
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Chip(
                                            label: Text(
                                              order.ticketDetail.status ==
                                                      'Used'
                                                  ? 'Sudah Digunakan'
                                                  : 'Belum Digunakan',
                                              style: TextStyle(
                                                color:
                                                    order.ticketDetail.status ==
                                                            'Used'
                                                        ? Colors.red
                                                        : Colors.green,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/orderDetail',
                                                arguments: OrderDetailArguments(
                                                    order.id, index),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors.grey[800],
                                            ),
                                            child: const Text('Lihat Detail'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
  }

  String formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    final formattedDate = "${dateTime.day}-${dateTime.month}-${dateTime.year}";
    return formattedDate;
  }

  Future<List<Order>> fetchOrders() async {
    // Simulasikan pengambilan data
    await Future.delayed(const Duration(seconds: 2)); // Simulasi loading
    return [
      Order(
        id: 1,
        ticket: Ticket(
            name: 'Konser Musik',
            image: 'image.jpg',
            datetime: '2024-11-30T20:00:00',
            createdAt: '2024-11-10T10:00:00'),
        ticketDetail: TicketDetail(status: 'Used'),
        jumlahPemesanan: 2,
      ),
      // Tambahkan data lainnya sesuai kebutuhan
    ];
  }
}

// Kelas untuk data order dan tiket
class Order {
  final int id;
  final Ticket ticket;
  final TicketDetail ticketDetail;
  final int jumlahPemesanan;

  Order({
    required this.id,
    required this.ticket,
    required this.ticketDetail,
    required this.jumlahPemesanan,
  });
}

class Ticket {
  final String name;
  final String image;
  final String datetime;
  final String createdAt;

  Ticket({
    required this.name,
    required this.image,
    required this.datetime,
    required this.createdAt,
  });
}

class TicketDetail {
  final String status;

  TicketDetail({required this.status});
}

class OrderDetailArguments {
  final int orderId;
  final int qrIndex;

  OrderDetailArguments(this.orderId, this.qrIndex);
}
