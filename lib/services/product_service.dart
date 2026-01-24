import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/api_client.dart';

class ProductService {
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final res = await apiClient.get('/products');
    return List<Map<String, dynamic>>.from(res.data);
  }

  Future<void> createProduct({
    required String name,
    required double price,
    required int stock,
    File? image,
    Uint8List? webImageBytes,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'price': price,
      'stock': stock,
      if (kIsWeb && webImageBytes != null)
        'image': MultipartFile.fromBytes(
          webImageBytes,
          filename: 'product.png',
        ),
      if (!kIsWeb && image != null)
        'image': await MultipartFile.fromFile(image.path),
    });

    await apiClient.post('/products', data: formData);
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required double price,
    required int stock,
    File? image,
    Uint8List? webImageBytes,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'price': price,
      'stock': stock,
      if (kIsWeb && webImageBytes != null)
        'image': MultipartFile.fromBytes(
          webImageBytes,
          filename: 'product.png',
        ),
      if (!kIsWeb && image != null)
        'image': await MultipartFile.fromFile(image.path),
    });

    await apiClient.put('/products/$id', data: formData);
  }

  Future<void> deleteProduct(int id) async {
    await apiClient.delete('/products/$id');
  }
}
