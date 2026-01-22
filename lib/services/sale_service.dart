import '../core/api_client.dart';

class SaleService {
  Future<void> recordSale(int productId, int qty) async {
    await apiClient.post('/sales', data: {'product_id': productId, 'qty': qty});
  }

  Future<List<dynamic>> getSales() async {
    final res = await apiClient.get('/sales');
    return res.data;
  }
}