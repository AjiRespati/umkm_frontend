import 'dart:io' show File;
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../core/api_client.dart';

class ReportService {
  Future<Map<String, dynamic>> generateReport(String type) async {
    final res = await apiClient.get('/reports/$type');
    return res.data;
  }

  Future<void> downloadReport(String fileUrl) async {
    final response = await apiClient.get(
      fileUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    final fileName = fileUrl.split('/').last;
    final data = Uint8List.fromList(response.data);

    if (_isWeb) {
      // Convert Dart list -> JSArray<BlobPart>
      final blobParts = [data.buffer.asByteData().toJS].toJS; 
      final blob = web.Blob(blobParts);
      final url = web.URL.createObjectURL(blob);

      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = fileName
        ..click();

      web.URL.revokeObjectURL(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(data);
      print('✅ File saved to: $filePath');
    }
  }

  bool get _isWeb {
    try {
      return identical(0, 0.0); // works on web only
    } catch (_) {
      return false;
    }
  }
}