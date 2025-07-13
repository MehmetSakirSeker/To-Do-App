import 'package:flutter/material.dart';

class DateTimePickerService {
  static Future<DateTime?> pickDateTime(
      BuildContext context,
      DateTime initialDate, {
        DateTime? firstDate,
      }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    return date;
  }
}