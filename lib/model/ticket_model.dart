class Ticket {
  final int id; // Tambahkan atribut id
  final String uuid;
  final String kodeTiket;
  final String name;
  final String place;
  final int quantity;
  final double price;
  final String description;
  final String status;
  final DateTime datetime;
  final DateTime expiryDate;
  final String image;
  final String banner;

  Ticket({
    required this.id, // Tambahkan ke konstruktor
    required this.uuid,
    required this.kodeTiket,
    required this.name,
    required this.place,
    required this.quantity,
    required this.price,
    required this.description,
    required this.status,
    required this.datetime,
    required this.expiryDate,
    required this.image,
    required this.banner,
  });

  // Mengonversi objek Ticket ke Map<String, dynamic> untuk keperluan serialisasi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Tambahkan id ke dalam Map
      'uuid': uuid,
      'kode_tiket': kodeTiket,
      'name': name,
      'place': place,
      'quantity': quantity,
      'price': price,
      'description': description,
      'status': status,
      'datetime': datetime.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'image': image,
      'banner': banner,
    };
  }

  String get fullImageUrl => 'http://192.168.2.153:8000/storage/$image';

  // Konstruktor fromJson untuk membuat objek Ticket dari Map<String, dynamic>
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? 0, // Pastikan id diambil dari JSON
      uuid: json['uuid'] ?? '',
      kodeTiket: json['kode_tiket'] ?? '',
      name: json['name'] ?? '',
      place: json['place'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price'] != null
          ? (json['price'] is String)
              ? double.tryParse(json['price']) ?? 0.0
              : json['price'].toDouble()
          : 0.0,
      description: json['description'] ?? '',
      status: json['status'] ?? 'unknown',
      datetime: DateTime.tryParse(json['datetime'] ?? '') ?? DateTime.now(),
      expiryDate:
          DateTime.tryParse(json['expiry_date'] ?? '') ?? DateTime.now(),
      image: json['image'] ?? '',
      banner: json['banner'] ?? '',
    );
  }
}
