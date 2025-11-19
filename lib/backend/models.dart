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
  final Date date;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<ExerciseSet> sets;

  String get id => '${date.toString()}_$name';

  Workout get parent {
    final box = Hive.box<Workout>('workout_database');
    return box.get(date.toString())!;
  }

  Exercise({required this.name, required this.sets, required this.date});
}

@HiveType(typeId: 3)
class ExerciseSet {

  @HiveField(0)
  final Date date;

  @HiveField(1)
  final String exerciseName;

  @HiveField(2)
  final int reps;

  @HiveField(3)
  final double weight;

  Exercise get parent {
    final box = Hive.box<Workout>('workout_database');
    final workout = box.get(date.toString())!;
    return workout.exercises.firstWhere((ex) => ex.name == exerciseName);
  }

  ExerciseSet({required this.reps, required this.weight, required this.date, required this.exerciseName});
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

  @override
  bool operator == (Object other) {
      return (other is Date &&
      year == other.year &&
      month == other.month &&
      day == other.day);
  }

  bool operator > (Date other) {
      if (year != other.year) {
          return year > other.year;
      }
      if (month != other.month) {
          return month > other.month;
      }
      return day > other.day;
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