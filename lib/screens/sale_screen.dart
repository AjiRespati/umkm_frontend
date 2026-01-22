import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/sale_service.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final _productService = ProductService();
  final _saleService = SaleService();

  List<Product> _products = [];
  Product? _selectedProduct;
  final _qtyController = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  List<Map<String, dynamic>> _salesHistory = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadSales();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await _productService.fetchProducts();
      setState(() {
        _products = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _loadSales() async {
    try {
      final sales = await _saleService.getSales();
      setState(() => _salesHistory = sales);
    } catch (e) {
      debugPrint('Error loading sales: $e');
    }
  }

  double _calculateTotal() {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    final price = _selectedProduct?.price ?? 0;
    return qty * price;
  }

  Future<void> _recordSale() async {
    if (_selectedProduct == null || _qtyController.text.isEmpty) return;

    final qty = int.tryParse(_qtyController.text) ?? 0;
    if (qty <= 0) return;

    setState(() => _submitting = true);

    try {
      await _saleService.recordSale(_selectedProduct!.id, qty);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale recorded successfully!')),
      );
      _qtyController.clear();
      setState(() => _selectedProduct = null);
      await _loadProducts();
      await _loadSales();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording sale: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSales,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: isWide
                  ? Row(
                      children: [
                        Expanded(flex: 2, child: _buildSaleForm()),
                        const SizedBox(width: 20),
                        Expanded(flex: 3, child: _buildSalesHistory()),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSaleForm(),
                          const SizedBox(height: 24),
                          _buildSalesHistory(),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildSaleForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Record Sale',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<Product>(
              value: _selectedProduct,
              decoration: InputDecoration(
                labelText: 'Select Product',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _products
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text('${p.name} (Stock: ${p.stock})'),
                      ))
                  .toList(),
              onChanged: (p) => setState(() => _selectedProduct = p),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.numbers_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            if (_selectedProduct != null && _qtyController.text.isNotEmpty)
              Text(
                'Total: Rp ${_calculateTotal().toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _recordSale,
                icon: _submitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check),
                label: const Text('Record Sale'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSalesHistory() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Sales',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _salesHistory.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No sales recorded yet.'),
                    ),
                  )
                : SizedBox(
                    height: 400,
                    child: ListView.separated(
                      itemCount: _salesHistory.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 10, color: Colors.grey),
                      itemBuilder: (context, i) {
                        final s = _salesHistory[i];
                        return ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: Text(
                            'Product ID: ${s['product_id']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Qty: ${s['qty']} | Total: Rp ${s['total']}',
                          ),
                          trailing: Text(
                            s['date'] != null
                                ? DateTime.parse(s['date'])
                                    .toLocal()
                                    .toString()
                                    .split('.')[0]
                                : '',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}