import 'package:hive/hive.dart'; //for decorators and Box class
part 'models.g.dart';

@HiveType(typeId: 1)
class Workout {
  @HiveField(0)
  final Date date;
  @HiveField(1)
  final List<Exercise> exercises;

  Workout({required this.date, required this.exercises});
}
@HiveType(typeId: 2)
class Exercise {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final List<ExerciseSet> sets;
  Exercise({required this.name, required this.sets});
}

@HiveType(typeId: 3)
class ExerciseSet {
  @HiveField(0)
  final int reps;
  @HiveField(1)
  final double weight;

  ExerciseSet({required this.reps, required this.weight});
}

@HiveType(typeId: 0)
class Date {
  @HiveField(0)
  final int year;
  @HiveField(1)
  final int month;
  @HiveField(2)
  final int day;

  const Date(this.year, this.month, this.day);

  factory Date.today() {
      final now = DateTime.now();
      return Date(now.year, now.month, now.day);
  }

  factory Date.tomorrow() {
      final tomorrow = DateTime.now().add(Duration(days: 1));
      return Date(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  @override
  bool operator == (Object other) {
      return (other is Date &&
      year == other.year &&
      month == other.month &&
      day == other.day);
  }

  @override
  int get hashCode { return year * 10000 + month * 100 + day; }

  @override
  String toString() {
    return '$year-$month-$day';
  }

  factory Date.fromString(String value) {
    final parts = value.split('-');
    return Date(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

// ----- Main App State (wrapped map of Date->Workout in a ValueNotifier) -----


// ----- CRUD Operations for AppState -----

