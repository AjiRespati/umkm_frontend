import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../core/auth_storage.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'product_screen.dart';
import 'sale_screen.dart';
import 'report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _dashboardService = DashboardService();

  bool _loading = true;
  int totalProducts = 0;
  int totalSales = 0;
  double revenue = 0;

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await _dashboardService.getSummary();
      setState(() {
        totalProducts = data['totalProducts'] ?? 0;
        totalSales = data['totalSalesToday'] ?? 0;
        revenue = (data['totalRevenue'] ?? 0).toDouble();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Dashboard fetch error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UMKM Sederhana Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Here’s your live business summary:',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Summary Cards
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildStatCard(
                        title: 'Total Products',
                        value: '$totalProducts',
                        icon: Icons.inventory_2_outlined,
                        color: Colors.blueAccent,
                      ),
                      _buildStatCard(
                        title: 'Sales Today',
                        value: '$totalSales',
                        icon: Icons.point_of_sale,
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        title: 'Revenue',
                        value: 'Rp ${revenue.toStringAsFixed(0)}',
                        icon: Icons.attach_money_rounded,
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: isWide ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isWide ? 1.5 : 1.2,
                      children: [
                        _buildNavCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Products',
                          color: Colors.blueAccent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProductScreen()),
                          ),
                        ),
                        _buildNavCard(
                          icon: Icons.point_of_sale,
                          label: 'Sales',
                          color: Colors.green,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SaleScreen()),
                          ),
                        ),
                        _buildNavCard(
                          icon: Icons.bar_chart,
                          label: 'Reports',
                          color: Colors.orangeAccent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReportScreen()),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color.darken(0.1),
                  ),
                ),
                Text(title, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: color.darken(0.2),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}