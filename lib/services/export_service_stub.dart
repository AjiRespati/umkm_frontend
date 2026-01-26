import 'export_service.dart';

class ExportServiceImpl implements ExportService {
  @override
  Future<void> exportSales() {
    throw UnsupportedError('Export not supported on this platform');
  }

  @override
  Future<void> exportProducts() {
    throw UnsupportedError('Export not supported on this platform');
  }
}