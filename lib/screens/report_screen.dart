import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:umkm_frontend/core/ux.dart';

import '../services/report_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _reportService = ReportService();

  bool _loading = true;

  List<dynamic> _dailySales = [];
  List<dynamic> _monthlySales = [];
  List<dynamic> _lowStock = [];
  List<dynamic> _largeSales = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    try {
      _dailySales = await _reportService.getDailySales();
      _monthlySales = await _reportService.getMonthlySales();
      _lowStock = await _reportService.getLowStockAlerts();
      _largeSales = await _reportService.getLargeSalesAlerts();
    } catch (_) {
      UX.snack(context, 'Failed to load reports');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // =============================
  // UI HELPERS
  // =============================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // =====================
                  // DAILY SALES
                  // =====================
                  _sectionTitle('Daily Sales'),
                  if (_dailySales.isEmpty)
                    const Text('No sales today')
                  else
                    Column(
                      children: _dailySales.map((d) {
                        return ListTile(
                          leading: const Icon(Icons.today),
                          title: Text(
                            DateFormat('dd MMM yyyy')
                                .format(DateTime.parse(d['date'])),
                          ),
                          trailing: Text(
                            'Rp ${d['total']}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),

                  // =====================
                  // MONTHLY SALES
                  // =====================
                  _sectionTitle('Monthly Sales'),
                  if (_monthlySales.isEmpty)
                    const Text('No sales this month')
                  else
                    Column(
                      children: _monthlySales.map((m) {
                        return ListTile(
                          leading: const Icon(Icons.calendar_month),
                          title: Text(
                            DateFormat('MMMM yyyy')
                                .format(DateTime.parse(m['month']?? '2026-01-01')),
                          ),
                          trailing: Text(
                            'Rp ${m['total']}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),

                  // =====================
                  // LOW STOCK ALERTS
                  // =====================
                  _sectionTitle('Low Stock Alerts'),
                  if (_lowStock.isEmpty)
                    const Text('No low stock products 🎉')
                  else
                    Column(
                      children: _lowStock.map((p) {
                        return ListTile(
                          leading: const Icon(Icons.warning,
                              color: Colors.orange),
                          title: Text(p['name']),
                          trailing: Text(
                            'Stock: ${p['stock']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),

                  // =====================
                  // LARGE SALES ALERTS
                  // =====================
                  _sectionTitle('Large Transactions'),
                  if (_largeSales.isEmpty)
                    const Text('No large transactions')
                  else
                    Column(
                      children: _largeSales.map((s) {
                        return ListTile(
                          leading: const Icon(Icons.attach_money,
                              color: Colors.green),
                          title: Text('Rp ${s['total']}'),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy HH:mm')
                                .format(DateTime.parse(s['created_at'])),
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