import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/product.dart';

class ProductService {
  Future<List<Product>> fetchProducts() async {
    final res = await apiClient.get('/products');
    return (res.data as List).map((p) => Product.fromJson(p)).toList();
  }

  Future<void> addProduct(String name, double price, int stock, File? image) async {
    final formData = FormData.fromMap({
      'name': name,
      'price': price,
      'stock': stock,
      if (image != null)
        'image': await MultipartFile.fromFile(image.path, filename: image.path.split('/').last)
    });
    await apiClient.post('/products', data: formData);
  }

  Future<void> deleteProduct(int id) async {
    await apiClient.delete('/products/$id');
  }
}