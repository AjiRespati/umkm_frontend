import '../core/api_client.dart';

class SaleService {
  Future<void> createSale({
    required int productId,
    required int qty,
  }) async {
    await apiClient.post('/sales', data: {
      'productId': productId,
      'qty': qty,
    });
  }

  Future<List<Map<String, dynamic>>> fetchSales() async {
    final res = await apiClient.get('/sales');
    return List<Map<String, dynamic>>.from(res.data);
  }
}