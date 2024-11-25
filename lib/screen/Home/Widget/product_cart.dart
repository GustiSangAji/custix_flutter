import 'package:custix/screen/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:custix/model/ticket_model.dart';

class ProductCard extends StatelessWidget {
  final Ticket ticket; // Ganti tipe dari Product ke Ticket
  const ProductCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    // Format harga
    final String formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(ticket.price);

    return GestureDetector(
      onTap: () {
        // Arahkan ke detail tiket ketika container di-tap
        Navigator.pushNamed(context, '/ticket_detail', arguments: ticket);
      },
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              spreadRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar tiket
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    ticket.fullImageUrl, // Gunakan fullImageUrl
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image,
                      size: 180,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama tiket
                      Text(
                        ticket.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      // Harga tiket
                      Text(
                        formattedPrice,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: kprimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Tombol Beli di pojok kanan bawah
            Positioned(
              bottom: 8,
              right: 8,
              child: SizedBox(
                height: 36,
                width: 80,
                child: ElevatedButton(
                  onPressed: () {
                    // Arahkan ke halaman ticket_detail dengan argumen ticket
                    Navigator.pushNamed(context, '/ticket_detail',
                        arguments: ticket);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kprimaryColor, // Warna tombol
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Beli',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
