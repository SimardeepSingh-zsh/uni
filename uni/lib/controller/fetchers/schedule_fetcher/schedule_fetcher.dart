import 'package:uni/controller/fetchers/session_dependant_fetcher.dart';
import 'package:uni/model/entities/lecture.dart';
import 'package:uni/model/entities/profile.dart';
import 'package:uni/model/entities/session.dart';

/// Class for fetching the user's schedule.
abstract class ScheduleFetcher extends SessionDependantFetcher {
  // Returns the user's lectures.
  Future<List<Lecture>> getLectures(Session session, Profile profile);

  /// Returns [Dates].
  Dates getDates() {
    var date = DateTime.now();

    final beginWeek = date.year.toString().padLeft(4, '0') +
        date.month.toString().padLeft(2, '0') +
        date.day.toString().padLeft(2, '0');
    date = date.add(const Duration(days: 6));

    final endWeek = date.year.toString().padLeft(4, '0') +
        date.month.toString().padLeft(2, '0') +
        date.day.toString().padLeft(2, '0');

    final lectiveYear = date.month < 8 ? date.year - 1 : date.year;
    return Dates(beginWeek, endWeek, lectiveYear);
  }
}

/// Stores the start and end dates of the week and the current lective year.
class Dates {
  Dates(this.beginWeek, this.endWeek, this.lectiveYear);
  final String beginWeek;
  final String endWeek;
  final int lectiveYear;
}
