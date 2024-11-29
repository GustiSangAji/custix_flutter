import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:custix/model/ticket_model.dart';
import 'package:custix/screen/constants.dart';

class ProductCard extends StatelessWidget {
  final Ticket ticket;
  final bool isCompact; // Tambahkan flag compact untuk grid layout

  const ProductCard({
    super.key,
    required this.ticket,
    this.isCompact = false, // Default tidak compact
  });

  @override
  Widget build(BuildContext context) {
    final String formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(ticket.price);

    final String formattedDate =
        DateFormat('dd MMM yyyy', 'id').format(ticket.datetime);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/ticket_detail', arguments: ticket);
      },
      child: Container(
        width: isCompact ? null : 350, 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Image.network(
                ticket.fullImageUrl,
                width: double.infinity,
                height: isCompact ? 120 : 180, // Sesuaikan tinggi untuk compact
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 120,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.name.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$formattedDate · ${ticket.place}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedPrice,
                    style: const TextStyle(
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
      ),
    );
  }
}
