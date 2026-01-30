import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:umkm_frontend/core/ux.dart';

import '../services/product_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      _products = await _productService.fetchProducts();
    } catch (_) {
      UX.snack(context, 'Failed to load products');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // =============================
  // ADD / EDIT PRODUCT DIALOG
  // =============================
  void _showProductDialog({Map<String, dynamic>? product}) {
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final priceController = TextEditingController(
      text: product?['price']?.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?['stock']?.toString() ?? '',
    );

    File? selectedImage;
    Uint8List? webImageBytes;
    bool saving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickImage() async {
              final picked = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              if (picked != null) {
                if (kIsWeb) {
                  webImageBytes = await picked.readAsBytes();
                } else {
                  selectedImage = File(picked.path);
                }
                setModalState(() {});
              }
            }

            Widget imagePreview() {
              if (kIsWeb && webImageBytes != null) {
                return Image.memory(webImageBytes!, fit: BoxFit.cover);
              }
              if (!kIsWeb && selectedImage != null) {
                return Image.file(selectedImage!, fit: BoxFit.cover);
              }
              if (product?['imageUrl'] != null) {
                return Image.network(
                  'http://localhost:3000${product!['imageUrl']}',
                  fit: BoxFit.cover,
                );
              }
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_outlined, size: 40),
                    SizedBox(height: 8),
                    Text('Tap to select image'),
                  ],
                ),
              );
            }

            Future<void> save() async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text);
              final stock = int.tryParse(stockController.text);

              if (name.isEmpty ||
                  price == null ||
                  price <= 0 ||
                  stock == null ||
                  stock < 0) {
                UX.snack(context, 'Please fill all fields correctly');
                return;
              }

              setModalState(() => saving = true);

              try {
                if (product == null) {
                  await _productService.createProduct(
                    name: name,
                    price: price,
                    stock: stock,
                    image: selectedImage,
                    webImageBytes: webImageBytes,
                  );
                } else {
                  await _productService.updateProduct(
                    id: product['id'],
                    name: name,
                    price: price,
                    stock: stock,
                    image: selectedImage,
                    webImageBytes: webImageBytes,
                  );
                }

                if (!mounted) return;
                Navigator.pop(context);
                UX.snack(context, 'Product saved successfully');
                _loadProducts();
              } catch (_) {
                UX.snack(context, 'Failed to save product');
              } finally {
                setModalState(() => saving = false);
              }
            }

            return AlertDialog(
              title: Text(product == null ? 'Add Product' : 'Edit Product'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: saving ? null : pickImage,
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imagePreview(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving ? null : save,
                  child:
                      saving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =============================
  // DELETE PRODUCT
  // =============================
  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Product'),
            content: const Text(
              'Are you sure you want to delete this product?\nThis action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _productService.deleteProduct(id);
      UX.snack(context, 'Product deleted');
      _loadProducts();
    }
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProducts),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(),
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
              ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64),
                    SizedBox(height: 12),
                    Text('No products yet'),
                    Text('Add your first product to start selling'),
                  ],
                ),
              )
              : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Product')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows:
                      _products.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(Text('${p['id']}')),
                            DataCell(
                              Row(
                                children: [
                                  if (p['imageUrl'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Image.network(
                                        'http://localhost:3000${p['imageUrl']}',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Text(p['name'] ?? ''),
                                ],
                              ),
                            ),
                            DataCell(Text('Rp ${p['price']}')),
                            DataCell(Text('${p['stock']}')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                    ),
                                    onPressed:
                                        () => _showProductDialog(product: p),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteProduct(p['id']),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
    );
  }
}
