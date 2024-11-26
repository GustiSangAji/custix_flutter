class StockIn {
  final String uuid;
  final String kodeTiket;
  final int jumlah;
  final String deskripsi;
  final DateTime datetime; // Ubah menjadi DateTime

  StockIn({
    required this.uuid,
    required this.kodeTiket,
    required this.jumlah,
    required this.deskripsi,
    required this.datetime, // Terima DateTime
  });

  // Mengubah JSON menjadi objek StockIn
  factory StockIn.fromJson(Map<String, dynamic> json) {
    return StockIn(
      uuid: json['uuid'],
      kodeTiket: json['kode_tiket'],
      jumlah: json['jumlah'],
      deskripsi: json['deskripsi'],
      datetime:
          DateTime.parse(json['datetime']), // Parse string menjadi DateTime
    );
  }

  // Mengubah objek StockIn menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'kode_tiket': kodeTiket,
      'jumlah': jumlah,
      'deskripsi': deskripsi,
      'datetime': datetime
          .toIso8601String(), // Ubah DateTime menjadi string saat mengirim ke API
    };
  }

  // Mendapatkan waktu lokal
  DateTime get localDatetime => datetime.toLocal();
}
