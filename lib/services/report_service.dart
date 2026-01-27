import '../core/api_client.dart';

class ReportService {
  // =============================
  // DAILY SALES
  // =============================
  Future<List<dynamic>> getDailySales() async {
    final response = await apiClient.get('/reports/daily-sales');
    return List<dynamic>.from(response.data);
  }

  // =============================
  // MONTHLY SALES
  // =============================
  Future<List<dynamic>> getMonthlySales() async {
    final response = await apiClient.get('/reports/monthly-sales');
    return List<dynamic>.from(response.data);
  }

  // =============================
  // LOW STOCK ALERTS
  // =============================
  Future<List<dynamic>> getLowStockAlerts() async {
    final response = await apiClient.get('/reports/alerts/low-stock');
    return List<dynamic>.from(response.data);
  }

  // =============================
  // LARGE SALES ALERTS
  // =============================
  Future<List<dynamic>> getLargeSalesAlerts() async {
    final response = await apiClient.get('/reports/alerts/large-sales');
    return List<dynamic>.from(response.data);
  }
}
