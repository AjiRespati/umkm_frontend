import 'package:flutter/material.dart';
import 'error_mapper.dart';

class UX {
  static void snack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static void error(BuildContext context, dynamic error) {
    final msg = ErrorMapper.from(error);
    snack(context, msg);
  }
}
