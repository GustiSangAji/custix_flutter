class DashboardData {
  final int pelanggan; // Pastikan ini tipe int
  final int pendapatan; // Pastikan ini tipe int
  final int tiket; // Pastikan ini tipe int

  DashboardData({
    required this.pelanggan,
    required this.pendapatan,
    required this.tiket,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      pelanggan: json['pelanggan'] is String
          ? int.parse(json['pelanggan'])
          : json['pelanggan'], // Pastikan dikonversi ke int
      pendapatan: json['pendapatan'] is String
          ? int.parse(json['pendapatan'])
          : json['pendapatan'], // Pastikan dikonversi ke int
      tiket: json['tiket'] is String
          ? int.parse(json['tiket'])
          : json['tiket'], // Pastikan dikonversi ke int
    );
  }
}
