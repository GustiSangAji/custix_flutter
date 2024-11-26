import 'package:flutter/material.dart';
import 'package:custix/widgets/legend_indicator.dart' as legend;
import 'package:custix/widgets/summary_card.dart' as summary;
import 'package:custix/widgets/drawer_menu.dart';
import 'package:custix/model/DashboardData.dart';
import 'package:custix/api/dashboard.dart';
import 'package:custix/api/auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isDarkMode = false;
  late Future<DashboardData> dashboardData;

  @override
  void initState() {
    super.initState();
    dashboardData = _fetchDashboardData();
  }

  Future<DashboardData> _fetchDashboardData() async {
    AuthRepository authRepository = AuthRepository();
    String? token = await authRepository.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan");
    }

    DashboardRepository dashboardRepository = DashboardRepository();
    try {
      return await dashboardRepository.fetchDashboardData(token);
    } catch (e) {
      throw Exception('Error fetching dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 10,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: DrawerMenu(),
      body: FutureBuilder<DashboardData>(
        future: dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ringkasan Statistik
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ringkasan Statistik',
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              height: 250,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: const Color.fromARGB(
                                          255, 15, 169, 20),
                                      value: data.pendapatan.toDouble(),
                                      title: '', // Hapus atau kosongkan title
                                      radius: 60,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: data.tiket.toDouble(),
                                      title: '', // Hapus atau kosongkan title
                                      radius: 60,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.blue,
                                      value: data.pelanggan.toDouble(),
                                      title: '', // Hapus atau kosongkan title
                                      radius: 60,
                                    ),
                                  ],
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 50,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 20,
                              runSpacing: 10,
                              children: [
                                legend.LegendIndicator(
                                    title: 'Total Pendapatan',
                                    color:
                                        const Color.fromARGB(255, 20, 203, 47)),
                                legend.LegendIndicator(
                                    title: 'Total Tiket', color: Colors.red),
                                legend.LegendIndicator(
                                    title: 'User', color: Colors.blue),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Ringkasan Data (User dan Total Tiket)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            child: summary.SummaryCard(
                              title: 'User',
                              value: data.pelanggan,
                              icon: Icons.person,
                              color: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            child: summary.SummaryCard(
                              title: 'Total Tiket',
                              value: data.tiket,
                              icon: Icons.confirmation_num,
                              color: Colors.white,
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // Total Pendapatan
                    // Total Pendapatan
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.95, // Ubah dari 0.85 ke 0.95 untuk melebarkan
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: summary.SummaryCard(
                            title: 'Total Pendapatan',
                            value: data.pendapatan,
                            icon: Icons.attach_money,
                            color: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 15, 169, 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
