enum TaskStatus {
  UPCOMING,
  ONGOING,
  OVERDUE,
  COMPLETED;

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
          (e) => e.toString().split('.').last == value,
      orElse: () => TaskStatus.UPCOMING,
    );
  }
}