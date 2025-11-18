import 'package:flutter/foundation.dart';
import 'dart:collection'; //for UnmodifiableMapView
import 'package:hive/hive.dart'; //for decorators and Box class
part 'backend.g.dart';

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

// ----- Data Models -----
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

// ----- Main App State (wrapped map of Date->Workout in a ValueNotifier) -----

class AppState {

  final ValueNotifier<Map<Date, Workout>> _workouts;

  AppState(this._workouts);

  factory AppState.fromHiveBox(Box<Workout> database) {
    final loadedWorkouts = <Date, Workout>{};
    for (var key in database.keys) {
      final workout = database.get(key)!;           // Workout
      final date = Date.fromString(key as String);  // convert key to Date
      loadedWorkouts[date] = workout;
    }
    return AppState(ValueNotifier<Map<Date, Workout>>(loadedWorkouts));
  }

  UnmodifiableMapView<Date, Workout> get workouts => UnmodifiableMapView(_workouts.value);

  set workouts(Map<Date, Workout> newWorkouts) {
    final box = Hive.box<Workout>('workout_database');

    // Clear deleted entries from the database (optional but recommended)
    final currentKeys = box.keys.toSet();
    final newKeys = newWorkouts.keys.map((d) => d.toString()).toSet();
    final removedKeys = currentKeys.difference(newKeys);
    box.deleteAll(removedKeys);

    // Write/update all workouts
    for (var entry in newWorkouts.entries) {
      final key = entry.key.toString(); // "yyyy-mm-dd"
      box.put(key, entry.value);
    }

    _workouts.value = Map<Date, Workout>.from(newWorkouts);
  }

  ValueNotifier<Map<Date, Workout>> get workoutsNotifier => _workouts;

}

// ----- CRUD Operations for AppState -----

// Workout CRUD Operations

void createEmptyWorkout(AppState appState, Date workoutDate) {
  final dataCopy = Map<Date, Workout>.from(appState.workouts);
  dataCopy[workoutDate] = Workout(date: workoutDate, exercises: []);
  appState.workouts = dataCopy;
}

Workout readWorkout(AppState appState, Date workoutDate) {
  return appState.workouts[workoutDate]!;
}

void updateWorkout(AppState appState, Date workoutDate, Workout updatedWorkout) {
  final dataCopy = Map<Date, Workout>.from(appState.workouts);
  dataCopy[workoutDate] = updatedWorkout;
  appState.workouts = dataCopy;
}

void deleteWorkout(AppState appState, Date workoutDate) {
  final dataCopy = Map<Date, Workout>.from(appState.workouts);
  dataCopy.remove(workoutDate);
  appState.workouts = dataCopy;
}

// Exercise CRUD Operations

void createExerciseInWorkout(AppState appState, Date workoutDate, Exercise exercise) {
  final dataCopy = Map<Date, Workout>.from(appState.workouts);
  dataCopy[workoutDate]!.exercises.add(exercise);
  appState.workouts = dataCopy;
}

Exercise readExerciseFromWorkout(AppState appState, Date workoutDate, String exerciseName) {
  return appState.workouts[workoutDate]!.exercises.firstWhere((ex) => ex.name == exerciseName);
}

void updateExerciseInWorkout(AppState appState, Date workoutDate, Exercise updatedExercise) {
  final dataCopy = Map<Date, Workout>.from(appState.workouts);
  final workout = dataCopy[workoutDate]!;
  final exerciseIndex = workout.exercises.indexWhere((ex) => ex.name == updatedExercise.name);
  if (exerciseIndex != -1) {
    workout.exercises[exerciseIndex] = updatedExercise;
    appState.workouts = dataCopy;
  }
}

void deleteExerciseFromWorkout(AppState appState, Date workoutDate, String exerciseName) {
  final dataCopy = Map<Date, Workout>.from(appState.workouts);
  final workout = dataCopy[workoutDate]!;
  workout.exercises.removeWhere((ex) => ex.name == exerciseName);
  appState.workouts = dataCopy;
}

// WorkoutSet CRUD Operations

void createSetInExercise(AppState appState, Date workoutDate, String exerciseName, ExerciseSet set) {
  final dataCopy = Map<Date, Workout>.from(appState.workouts);
  final workout = dataCopy[workoutDate]!;
  final exercise = workout.exercises.firstWhere((ex) => ex.name == exerciseName);
  exercise.sets.add(set);
  appState.workouts = dataCopy;
}

ExerciseSet readSetFromExercise(AppState appState, Date workoutDate, String exerciseName, int setIndex) {
  final workout = appState.workouts[workoutDate]!;
  final exercise = workout.exercises.firstWhere((ex) => ex.name == exerciseName);
  return exercise.sets[setIndex];
}

void updateSetInExercise(AppState appState, Date workoutDate, String exerciseName, int setIndex, ExerciseSet updatedSet) {
  final dataCopy = Map<Date, Workout>.from(appState.workouts);
  final workout = dataCopy[workoutDate]!;
  final exercise = workout.exercises.firstWhere((ex) => ex.name == exerciseName);
  if (setIndex >= 0 && setIndex < exercise.sets.length) {
    exercise.sets[setIndex] = updatedSet;
    appState.workouts = dataCopy;
  }
}

void deleteSetFromExercise(AppState appState, Date workoutDate, String exerciseName, int setIndex) {
  final dataCopy = Map<Date, Workout>.from(appState.workouts);
  final workout = dataCopy[workoutDate]!;
  final exercise = workout.exercises.firstWhere((ex) => ex.name == exerciseName);
  if (setIndex >= 0 && setIndex < exercise.sets.length) {
    exercise.sets.removeAt(setIndex);
    appState.workouts = dataCopy;
  }
}
