import 'package:flutter/material.dart';
import 'package:umkm_frontend/screens/sales_history_screen.dart';

import '../services/product_service.dart';
import '../services/sale_service.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final ProductService _productService = ProductService();
  final SaleService _saleService = SaleService();

  bool _loading = true;
  bool _submitting = false;

  List<Map<String, dynamic>> _products = [];
  Map<String, dynamic>? _selectedProduct;

  final TextEditingController _qtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      _products = await _productService.fetchProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitSale() async {
    if (_selectedProduct == null) return;

    final qty = int.tryParse(_qtyController.text) ?? 0;
    if (qty <= 0) return;

    setState(() => _submitting = true);

    try {
      await _saleService.createSale(
        productId: _selectedProduct!['id'],
        qty: qty,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale recorded successfully')),
      );

      _qtyController.clear();
      _selectedProduct = null;

      await _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sale failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProducts),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Sale',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedProduct,
                      decoration: const InputDecoration(
                        labelText: 'Select Product',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _products.map((product) {
                            return DropdownMenuItem(
                              value: product,
                              child: Row(
                                children: [
                                  if (product['imageUrl'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Image.network(
                                        'http://localhost:3000${product['imageUrl']}',
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Text(
                                    '${product['name']} (Stock: ${product['stock']})',
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProduct = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_selectedProduct != null)
                      Text(
                        'Price: Rp ${_selectedProduct!['price']}',
                        style: const TextStyle(fontSize: 16),
                      ),

                    if (_selectedProduct != null)
                      Text(
                        'Total: Rp ${(int.tryParse(_qtyController.text) ?? 0) * _selectedProduct!['price']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submitSale,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            _submitting
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Confirm Sale',
                                  style: TextStyle(fontSize: 18),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
