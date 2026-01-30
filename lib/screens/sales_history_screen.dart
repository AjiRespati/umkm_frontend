import 'package:flutter/material.dart';
import 'package:umkm_frontend/core/ux.dart';

import '../services/sale_service.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final SaleService _saleService = SaleService();

  bool _loading = true;
  List<Map<String, dynamic>> _sales = [];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _loading = true);
    try {
      _sales = await _saleService.fetchSales();
    } catch (e) {
      if (mounted) {
        UX.error(context, e);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(String utcString) {
    final utc = DateTime.parse(utcString).toUtc();
    final local = utc.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  void _showReceipt(Map<String, dynamic> sale) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sale Receipt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sale ID: ${sale['id']}'),
              const SizedBox(height: 8),
              Text('Date: ${_formatDate(sale['createdAt'])}'),
              const Divider(height: 24),
              Text('Product: ${sale['Product']['name']}'),
              Text('Quantity: ${sale['qty']}'),
              Text('Price: Rp ${sale['Product']['price']}'),
              const Divider(height: 24),
              Text(
                'Total: Rp ${sale['total']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSales,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sales.isEmpty
              ? const Center(child: Text('No sales found'))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Total')),
                      DataColumn(label: Text('Receipt')),
                    ],
                    rows: _sales.map((sale) {
                      return DataRow(cells: [
                        DataCell(Text('${sale['id']}')),
                        DataCell(Text(_formatDate(sale['createdAt']))),
                        DataCell(Text(sale['Product']['name'])),
                        DataCell(Text('${sale['qty']}')),
                        DataCell(Text('Rp ${sale['total']}')),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.receipt_long),
                            onPressed: () => _showReceipt(sale),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
    );
  }
}