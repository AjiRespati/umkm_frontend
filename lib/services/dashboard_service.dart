import '../core/api_client.dart';

class DashboardService {
  Future<Map<String, dynamic>> getSummary() async {
    final res = await apiClient.get('/dashboard/summary');
    return res.data;
  }
}