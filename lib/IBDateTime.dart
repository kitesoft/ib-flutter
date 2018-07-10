
import 'package:flutter/material.dart';

class IBDateTime {

  static DateTime get dateNow => DateTime.now();

  static double get timestampNow => dateNow.millisecondsSinceEpoch/1000;

  static DateTime get today => DateTime(dateNow.year, dateNow.month, dateNow.day);

  static bool timeOfDateIsAfter(TimeOfDay timeOfDay1, TimeOfDay timeOfDay2) => timeOfDay1.hour > timeOfDay2.hour || timeOfDay1.minute > timeOfDay2.minute;

  static DateTime dateWith({DateTime day, TimeOfDay timeOfDay}) => DateTime(day.year, day.month, day.day, timeOfDay.hour, timeOfDay.minute);

  static DateTime date({double timestamp}) => DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()*1000);

  static int dayDifference(DateTime date1, DateTime date2) {
    if (date1.month == date2.month && date1.year == date2.year) {
      return date1.day - date2.day;
    }
    var daysOfMonth = new DateTime(date1.year, date1.month, 0).day;
    if (date1.isBefore(date2)) {
      var newYear = date1.month + 1 == 13 ? date1.year + 1 : date1.year;
      var newMonth = date1.month + 1 == 13 ? 1 : date1.month + 1;
      return -(daysOfMonth - date1.day) + dayDifference(DateTime(newYear, newMonth, 1), date2);
    }
    else {
      var newYear = date1.month - 1 == 0 ? date1.year - 1 : date1.year;
      var newMonth = date1.month - 1 == 0 ? 12 : date1.month - 1;
      return (date1.day) + dayDifference(DateTime(newYear, newMonth, daysOfMonth), date2);
    }
  }
}