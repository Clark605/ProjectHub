import 'package:flutter/material.dart';

Future<DateTime?> showTaskDatePicker(
  BuildContext context, {
  DateTime? initialDate,
}) async {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: now.subtract(const Duration(days: 365)),
    lastDate: now.add(const Duration(days: 365 * 5)),
  );
}
