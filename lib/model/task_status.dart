import 'package:flutter/material.dart';

enum TaskStatus {
  UPCOMING,
  ONGOING,
  OVERDUE,
  COMPLETED;

  // UI da göstermek için
  String get displayName {
    switch (this) {
      case TaskStatus.UPCOMING:
        return 'Upcoming';
      case TaskStatus.ONGOING:
        return 'Ongoing';
      case TaskStatus.OVERDUE:
        return 'Overdue';
      case TaskStatus.COMPLETED:
        return 'Completed';
    }
  }

  // Renkler
  Color get color {
    switch (this) {
      case TaskStatus.UPCOMING:
        return Colors.blue;
      case TaskStatus.ONGOING:
        return Colors.orange;
      case TaskStatus.OVERDUE:
        return Colors.red;
      case TaskStatus.COMPLETED:
        return Colors.green;
    }
  }
}
