import 'dart:typed_data';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;

import '../core/api_client.dart';
import 'export_service.dart';

class ExportServiceImpl implements ExportService {
  @override
  Future<void> exportSales() async {
    await _download(
      endpoint: '/export/sales',
      filename: 'sales_report.xlsx',
    );
  }

  @override
  Future<void> exportProducts() async {
    await _download(
      endpoint: '/export/products',
      filename: 'products.xlsx',
    );
  }

  Future<void> _download({
    required String endpoint,
    required String filename,
  }) async {
    final Response<Uint8List> response = await apiClient.get<Uint8List>(
      endpoint,
      options: Options(responseType: ResponseType.bytes),
    );

    final Uint8List bytes = response.data!;

    // ✅ Convert Dart Uint8List → JS Uint8Array
    final jsBytes = bytes.toJS;

    // ✅ Blob expects JSArray<BlobPart>
    final blob = web.Blob(
      [jsBytes].toJS,
      web.BlobPropertyBag(
        type:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ),
    );

    final url = web.URL.createObjectURL(blob);

    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';

    web.document.body!.append(anchor);
    anchor.click();
    anchor.remove();

    web.URL.revokeObjectURL(url);
  }
}