import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:umkm_frontend/core/ux.dart';

import '../services/report_service.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final ReportService _reportService = ReportService();

  bool _loading = true;

  List<dynamic> _dailySales = [];
  List<dynamic> _monthlySales = [];
  List<dynamic> _lowStock = [];
  List<dynamic> _largeSales = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    try {
      _dailySales = await _reportService.getDailySales();
      _monthlySales = await _reportService.getMonthlySales();
      _lowStock = await _reportService.getLowStockAlerts();
      _largeSales = await _reportService.getLargeSalesAlerts();
    } catch (e) {
      UX.snack(context, "Failed to load dashboard");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // =============================
  // HELPERS
  // =============================

  int _sumSales(List<dynamic> data) {
    return data.fold<int>(0, (sum, e) => sum + (e['total'] as num).toInt());
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    final todayRevenue = _sumSales(_dailySales);
    final monthlyRevenue = _sumSales(_monthlySales);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadDashboard,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // =====================
                    // REVENUE SUMMARY
                    // =====================
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text('Today'),
                                  const SizedBox(height: 8),
                                  Text(
                                    todayRevenue == 0
                                        ? 'No sales yet'
                                        : 'Rp $todayRevenue',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text('This Month'),
                                  const SizedBox(height: 8),
                                  Text(
                                    monthlyRevenue == 0
                                        ? 'No sales yet'
                                        : 'Rp $monthlyRevenue',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // =====================
                    // SALES CHART
                    // =====================
                    _sectionTitle('Daily Sales Trend'),
                    if (_dailySales.isEmpty)
                      const Text('No daily sales data available')
                    else
                      SizedBox(
                        height: 240,
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          primaryYAxis: NumericAxis(
                            numberFormat: NumberFormat.compactCurrency(
                              symbol: 'Rp ',
                            ),
                          ),
                          series: <CartesianSeries>[
                            LineSeries<dynamic, String>(
                              dataSource: _dailySales,
                              xValueMapper: (d, _) {
                                final rawDate = d['date'];
                                if (rawDate == null) return '-';

                                final parsed = DateTime.tryParse(
                                  rawDate.toString(),
                                );
                                if (parsed == null) return rawDate.toString();

                                return DateFormat('dd MMM').format(parsed);
                              },
                              yValueMapper:
                                  (d, _) =>
                                      (d['total'] as num?)?.toDouble() ?? 0,
                              markerSettings: const MarkerSettings(
                                isVisible: true,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // =====================
                    // LOW STOCK ALERTS
                    // =====================
                    _sectionTitle('Low Stock Alerts'),
                    if (_lowStock.isEmpty)
                      const Text('All products have sufficient stock 🎉')
                    else
                      Column(
                        children:
                            _lowStock.map((p) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.warning,
                                  color: Colors.orange,
                                ),
                                title: Text(p['name']),
                                trailing: Text(
                                  'Stock: ${p['stock']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),

                    // =====================
                    // LARGE TRANSACTIONS
                    // =====================
                    _sectionTitle('Large Transactions'),
                    if (_largeSales.isEmpty)
                      const Text('No large transactions')
                    else
                      Column(
                        children:
                            _largeSales.map((s) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.attach_money,
                                  color: Colors.green,
                                ),
                                title: Text('Rp ${s['total']}'),
                                subtitle: Text(
                                  DateFormat(
                                    'dd MMM yyyy HH:mm',
                                  ).format(DateTime.parse(s['created_at'])),
                                ),
                              );
                            }).toList(),
                      ),
                  ],
                ),
              ),
    );
  }
}
