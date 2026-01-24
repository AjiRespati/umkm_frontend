import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../services/report_service.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final ReportService _reportService = ReportService();

  bool _loading = true;

  List<_DailySales> _dailyData = [];
  List<_MonthlySales> _monthlyData = [];

  List<Map<String, dynamic>> _lowStock = [];
  List<Map<String, dynamic>> _largeSales = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    try {
      final daily = await _reportService.fetchDailySales();
      final monthly = await _reportService.fetchMonthlySales();
      final lowStock = await _reportService.fetchLowStock();
      final largeSales = await _reportService.fetchLargeSales();

      _dailyData =
          daily.map((e) {
            return _DailySales(
              DateTime.parse(e['date']).toLocal(),
              double.parse(e['total'].toString()),
            );
          }).toList();

      _monthlyData =
          monthly.map((e) {
            return _MonthlySales(
              DateTime.parse(e['month']).toLocal(),
              double.parse(e['total'].toString()),
            );
          }).toList();

      _lowStock = lowStock;
      _largeSales = largeSales;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool hasDaily = _dailyData.isNotEmpty;
    final bool isSingleDailyPoint = _dailyData.length == 1;

    final DateTime? minDailyDate = hasDaily ? _dailyData.first.date : null;
    final DateTime? maxDailyDate = hasDaily ? _dailyData.last.date : null;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // DAILY REVENUE
            // =========================
            if (hasDaily)
              SfCartesianChart(
                title: ChartTitle(text: 'Daily Revenue (Last 7 Days)'),
                tooltipBehavior: TooltipBehavior(enable: true),
                primaryXAxis: DateTimeAxis(
                  minimum: minDailyDate!.subtract(const Duration(days: 1)),
                  maximum: maxDailyDate!.add(const Duration(days: 1)),
                  intervalType: DateTimeIntervalType.days,
                  interval: 1,
                  dateFormat: DateFormat.Md(),
                ),
                primaryYAxis: NumericAxis(labelFormat: 'Rp {value}'),
                series: <CartesianSeries<_DailySales, DateTime>>[
                  isSingleDailyPoint
                      ? ColumnSeries<_DailySales, DateTime>(
                        dataSource: _dailyData,
                        xValueMapper: (d, _) => d.date,
                        yValueMapper: (d, _) => d.total,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                        ),
                      )
                      : LineSeries<_DailySales, DateTime>(
                        dataSource: _dailyData,
                        xValueMapper: (d, _) => d.date,
                        yValueMapper: (d, _) => d.total,
                        markerSettings: const MarkerSettings(isVisible: true),
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                        ),
                      ),
                ],
              ),

            const SizedBox(height: 48),

            // =========================
            // MONTHLY REVENUE
            // =========================
            SfCartesianChart(
              title: ChartTitle(text: 'Monthly Revenue'),
              tooltipBehavior: TooltipBehavior(enable: true),
              primaryXAxis: DateTimeAxis(
                intervalType: DateTimeIntervalType.months,
                dateFormat: DateFormat.yMMM(),
              ),
              primaryYAxis: NumericAxis(labelFormat: 'Rp {value}'),
              series: <CartesianSeries<_MonthlySales, DateTime>>[
                ColumnSeries<_MonthlySales, DateTime>(
                  dataSource: _monthlyData,
                  xValueMapper: (d, _) => d.month,
                  yValueMapper: (d, _) => d.total,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // =========================
            // LOW STOCK ALERTS
            // =========================
            const Text(
              'Low Stock Alerts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_lowStock.isEmpty)
              const Text('All products are sufficiently stocked.')
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
                        trailing: Text('Stock: ${p['stock']}'),
                      );
                    }).toList(),
              ),

            const SizedBox(height: 48),

            // =========================
            // LARGE TRANSACTIONS
            // =========================
            const Text(
              'Large Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_largeSales.isEmpty)
              const Text('No large transactions detected.')
            else
              Column(
                children:
                    _largeSales.map((s) {
                      return ListTile(
                        leading: const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                        title: Text('Sale #${s['id']}'),
                        subtitle: Text(
                          DateTime.parse(s['created_at']).toLocal().toString(),
                        ),
                        trailing: Text(
                          'Rp ${s['total']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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

// =========================
// DATA CLASSES
// =========================

class _DailySales {
  final DateTime date;
  final double total;

  _DailySales(this.date, this.total);
}

class _MonthlySales {
  final DateTime month;
  final double total;

  _MonthlySales(this.month, this.total);
}
