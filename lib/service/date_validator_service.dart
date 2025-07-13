class DateValidatorService {
  static bool isEndDateAfterStartDate(DateTime startDate, DateTime endDate) {
    return endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);
  }
  static bool isStartDateTodayOrLater(DateTime startDate) {
    final now = DateTime.now();
    return startDate.isAfter(now) || startDate.isAtSameMomentAs(now);
  }

}