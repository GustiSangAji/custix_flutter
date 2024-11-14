class Ticket {
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

  // Mengonversi objek Ticket ke Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
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

  // Anda juga bisa menambahkan konstruktor fromJson untuk membuat objek Ticket dari Map
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      uuid: json['uuid'],
      kodeTiket: json['kode_tiket'],
      name: json['name'],
      place: json['place'],
      quantity: json['quantity'],
      price: json['price'],
      description: json['description'],
      status: json['status'],
      datetime: DateTime.parse(json['datetime']),
      expiryDate: DateTime.parse(json['expiry_date']),
      image: json['image'],
      banner: json['banner'],
    );
  }
}
