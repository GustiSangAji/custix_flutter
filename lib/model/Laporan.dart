class Laporan {
  final String orderId;
  final String ticketName;
  final String ticketPlace;
  final String ticketDatetime;
  final String status;
  final int jumlahPemesanan;
  final double totalHarga;
  final String ticketImage;
  final String ticketDescription;
  final String ticketBanner;
  final String ticketExpiryDate;
  final String createdAt;
  final String updatedAt;

  Laporan({
    required this.orderId,
    required this.ticketName,
    required this.ticketPlace,
    required this.ticketDatetime,
    required this.status,
    required this.jumlahPemesanan,
    required this.totalHarga,
    required this.ticketImage,
    required this.ticketDescription,
    required this.ticketBanner,
    required this.ticketExpiryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Method untuk membuat instance dari JSON
  factory Laporan.fromJson(Map<String, dynamic> json) {
    return Laporan(
      orderId: json['order_id'],
      ticketName: json['ticket']
          ['name'], // Mengambil nama tiket dari nested object 'ticket'
      ticketPlace: json['ticket']['place'], // Tempat dari tiket
      ticketDatetime: json['ticket']['datetime'], // Waktu dari tiket
      status: json['status'],
      jumlahPemesanan: json['jumlah_pemesanan'],
      totalHarga: json['total_harga'].toDouble(),
      ticketImage: json['ticket']['image'],
      ticketDescription: json['ticket']['description'],
      ticketBanner: json['ticket']['banner'],
      ticketExpiryDate: json['ticket']['expiry_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
