import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:custix/model/ticket_model.dart'; // Sesuaikan dengan lokasi file model Ticket
import 'package:custix/screen/Home/Widget/home_app_bar.dart'; // Sesuaikan dengan lokasi CustomAppBar
import 'package:custix/screen/Ticket/detail_pesanan.dart'; // Sesuaikan dengan lokasi DetailPesananPage
import 'package:custix/screen/constants.dart';
import 'dart:ui'; // Untuk menggunakan BackdropFilter

class TicketDetail extends StatefulWidget {
  final Ticket ticket;

  const TicketDetail({super.key, required this.ticket});

  @override
  TicketDetailState createState() => TicketDetailState();
}

class TicketDetailState extends State<TicketDetail>
    with SingleTickerProviderStateMixin {
  int ticketCount = 1;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Menambah 2 tab
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    const String baseUrl = 'http://192.168.2.140:8000/storage/';
    final double totalPrice = ticket.price * ticketCount;

    final String formattedTotalPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(totalPrice);

    return Scaffold(appBar: const CustomAppBar(
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Background Image di bagian atas
          Stack(
            children: [
              Container(
                height: 250, // Tinggi gambar background
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('$baseUrl${ticket.banner}'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Efek blur pada background
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 50.0, sigmaY: 50.0), // Tambahkan efek blur
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0), // Transparan
                    ),
                  ),
                ),
              ),
              // Menambahkan gambar tiket kecil dan nama tiket di atas background
              Positioned(
                top: 120,
                left: 16,
                child: Row(
                  children: [
                    // Gambar tiket kecil
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '$baseUrl${ticket.banner}',
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, size: 80),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Nama tiket dan lokasi
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket.place,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Informasi Acara (Durasi, Rating, dll)
                        Row(
                          children: [
                            // Durasi acara
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '2 Jam',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Rating acara
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'R13+',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Tanggal acara
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                DateFormat('dd MMM yyyy', 'id')
                                    .format(ticket.datetime),
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
                  ],
                ),
              ),
            ],
          ),
          // TabBar untuk Detail Tiket
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Deskripsi'),
              Tab(text: 'Tiket'),
            ],
          ),
          // Konten utama di bawah gambar tiket
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  Stack(
                    children: [
                      // Konten utama yang bisa di-scroll
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 80.0), // Beri jarak untuk tombol sticky
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 16.0),
                                child: Text(
                                  'Tentang Tiket',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ticket.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.only(top: 16.0),
                                child: Text(
                                  'Syarat & Ketentuan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'MOHON DIBACA DENGAN SEKSAMA!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'E-TICKET INI TIDAK DAPAT DIPERJUALBELIKAN & HATI-HATI TERHADAP PENIPUAN!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const Text(
                                'E-TICKET CANNOT BE RE-SOLD & BE CAREFUL OF FRAUD!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'E-TICKET INI TIDAK DAPAT DIKEMBALIKAN dan NON-REFUNDABLE',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const Text(
                                'E-TICKET ARE NON-REFUNDABLE!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'KAMI TIDAK BERTANGGUNG JAWAB ATAS KEHILANGAN E-TICKET',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const Text(
                                'WE ARE NOT RESPONSIBLE FOR THE LOST OF THIS E-TICKET',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Tombol sticky di bagian bawah
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.white, // Warna latar tombol
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _tabController
                                    .animateTo(1); // Navigasi ke tab berikutnya
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kprimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Lihat Detail',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Tab Informasi Lain
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Jumlah Tiket',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (ticketCount > 1) ticketCount--;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '$ticketCount',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (ticketCount < 3) ticketCount++;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Harga Satuan Tiket
                          Text(
                            'IDR: $formattedTotalPrice',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Total Harga
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total ($ticketCount pax):',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                formattedTotalPrice,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Tombol Pesan
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPesananPage(
                                      ticket: ticket,
                                      quantity: ticketCount,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kprimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Pesan',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
