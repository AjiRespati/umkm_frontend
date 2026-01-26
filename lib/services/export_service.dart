import 'export_service_stub.dart'
    if (dart.library.html) 'export_service_web.dart'
    if (dart.library.io) 'export_service_io.dart';

abstract class ExportService {
  Future<void> exportSales();
  Future<void> exportProducts();
}

ExportService getExportService() => ExportServiceImpl();