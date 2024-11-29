class Tiket {
  final int id;
  final String name;
  final String kodeTiket;
  final String place;
  final DateTime datetime;
  final int quantity;
  final double price;
  final String image;
  final String status;

  Tiket({
    required this.id,
    required this.name,
    required this.kodeTiket,
    required this.place,
    required this.datetime,
    required this.quantity,
    required this.price,
    required this.image,
    required this.status,
  });

  // Properti untuk URL absolut gambar
  String get fullImageUrl => 'http://192.168.2.140:8000/storage/$image';

  factory Tiket.fromJson(Map<String, dynamic> json) {
    return Tiket(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      kodeTiket: json['kode_tiket'] ?? '',
      place: json['place'] ?? '',
      datetime: json['datetime'] != null
          ? DateTime.tryParse(json['datetime']) ?? DateTime.now()
          : DateTime.now(),
      quantity: json['quantity'] ?? 0,
      price: json['price'] != null
          ? (json['price'] is String)
              ? double.tryParse(json['price']) ?? 0.0
              : json['price'] is int
                  ? (json['price'] as int).toDouble()
                  : 0.0
          : 0.0,
      image: json['image'] ?? '',
      status: json['status'] ?? 'unknown',
    );
  }
}
