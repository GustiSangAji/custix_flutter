import 'package:flutter/material.dart';
import 'package:custix/widgets/legend_indicator.dart' as legend;
import 'package:custix/widgets/summary_card.dart' as summary;
import 'package:custix/widgets/drawer_menu.dart';
import 'package:custix/model/DashboardData.dart'; // Mengimpor model DashboardData
import 'package:custix/api/dashboard.dart'; // Mengimpor DashboardRepository
import 'package:custix/api/auth.dart'; // Mengimpor AuthRepository
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  bool _isDarkMode = false;
  late PageController _pageController;
  late Future<DashboardData> dashboardData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
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
            return PageView(
              controller: _pageController,
              children: [
                _buildDashboardTab(data),
                _buildStatusTab(data),
              ],
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildDashboardTab(DashboardData data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          summary.SummaryCard(
            title: 'User',
            value: data.pelanggan,
            icon: Icons.person,
            color: Colors.white,
            backgroundColor: Colors.blue,
          ),
          summary.SummaryCard(
            title: 'Total Pendapatan',
            value: data.pendapatan,
            icon: Icons.attach_money,
            color: Colors.white,
            backgroundColor: Colors.green,
          ),
          summary.SummaryCard(
            title: 'Total Tiket',
            value: data.tiket,
            icon: Icons.confirmation_num,
            color: Colors.white,
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(DashboardData data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Ringkasan Statistik',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.cyan,
                            value: data.pendapatan.toDouble(),
                            title: 'Rp ${data.pendapatan}',
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: data.tiket.toDouble(),
                            title: data.tiket.toString(),
                          ),
                          PieChartSectionData(
                            color: Colors.blue,
                            value: data.pelanggan.toDouble(),
                            title: data.pelanggan.toString(),
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
                          title: 'Total Penjualan', color: Colors.cyan),
                      legend.LegendIndicator(
                          title: 'Total Tiket', color: Colors.red),
                      legend.LegendIndicator(title: 'User', color: Colors.blue),
                      legend.LegendIndicator(
                          title: 'Total Pendapatan', color: Colors.green),
                    ],
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
