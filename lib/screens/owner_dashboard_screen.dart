import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/product_service.dart';
import '../services/sale_service.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final _productService = ProductService();
  final _saleService = SaleService();

  bool _loading = true;
  List<Map<String, dynamic>> _salesData = [];
  List<Map<String, dynamic>> _lowStock = [];
  List<Map<String, dynamic>> _highTransactions = [];
  double _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _loading = true);

    try {
      final products = await _productService.fetchProducts();
      final sales = await _saleService.getSales();

      // Low stock (less than 5 units)
      final lowStock = products
          .where((p) => p.stock <= 5)
          .map((p) => {
                'name': p.name,
                'stock': p.stock,
              })
          .toList();

      // Prepare chart data
      final grouped = <String, double>{};
      double totalRevenue = 0;

      for (final s in sales) {
        final date = DateTime.parse(s['date']).toLocal();
        final day = '${date.year}-${date.month}-${date.day}';
        grouped[day] = (grouped[day] ?? 0) + (s['total'] as num).toDouble();
        totalRevenue += (s['total'] as num).toDouble();
      }

      // Large transactions (Rp > 500,000)
      final bigSales = sales
          .where((s) => (s['total'] as num).toDouble() > 500000)
          .map((s) => ({
                'id': s['id'],
                'total': s['total'],
                'date': s['date'],
              }))
          .toList();

      setState(() {
        _lowStock = lowStock;
        _highTransactions = bigSales;
        _salesData = grouped.entries
            .map((e) => {'date': e.key, 'total': e.value})
            .toList();
        _totalRevenue = totalRevenue;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildChartSection()),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: _buildSidebar()),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildChartSection(),
                          const SizedBox(height: 20),
                          _buildSidebar(),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildChartSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Revenue: Rp ${_totalRevenue.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ChartSeries>[
                  ColumnSeries<Map<String, dynamic>, String>(
                    dataSource: _salesData,
                    xValueMapper: (data, _) => data['date'],
                    yValueMapper: (data, _) => data['total'],
                    color: Colors.blueAccent,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLowStockCard(),
        const SizedBox(height: 20),
        _buildHighTransactionCard(),
      ],
    );
  }

  Widget _buildLowStockCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Low Stock Alerts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _lowStock.isEmpty
                ? const Text('All products sufficiently stocked.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _lowStock.length,
                    itemBuilder: (context, i) {
                      final item = _lowStock[i];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.warning, color: Colors.orange),
                        title: Text(item['name']),
                        trailing: Text('Stock: ${item['stock']}'),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighTransactionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Large Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _highTransactions.isEmpty
                ? const Text('No high-value transactions recorded.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _highTransactions.length,
                    itemBuilder: (context, i) {
                      final tx = _highTransactions[i];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.attach_money,
                            color: Colors.green),
                        title: Text('Rp ${tx['total'].toStringAsFixed(0)}'),
                        subtitle: Text(
                          DateTime.parse(tx['date'])
                              .toLocal()
                              .toString()
                              .split('.')[0],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}