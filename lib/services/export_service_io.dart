import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../core/api_client.dart';
import 'export_service.dart';

class ExportServiceImpl implements ExportService {
  @override
  Future<void> exportSales() async {
    await _downloadAndOpen(
      endpoint: '/export/sales',
      filename: 'sales_report.xlsx',
    );
  }

  @override
  Future<void> exportProducts() async {
    await _downloadAndOpen(
      endpoint: '/export/products',
      filename: 'products.xlsx',
    );
  }

  Future<void> _downloadAndOpen({
    required String endpoint,
    required String filename,
  }) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filePath = '${dir.path}/$filename';

    await apiClient.download(
      endpoint,
      filePath,
      options: Options(responseType: ResponseType.bytes),
    );

    await OpenFilex.open(filePath);
  }
}
