import 'package:flutter/foundation.dart';
import 'dart:collection'; //for UnmodifiableMapView

class Date {
  final int year;
  final int month;
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
}

// ----- Data Models -----
class Workout {
  final Date date;
  final List<Exercise> exercises;

  Workout({required this.date, required this.exercises});
}

class Exercise {
  final String name;
  final List<ExerciseSet> sets;
  Exercise({required this.name, required this.sets});
}

class ExerciseSet {
  final int reps;
  final double weight;

  ExerciseSet({required this.reps, required this.weight});
}

class AppState {

  final ValueNotifier<Map<Date, Workout>> _workouts;

  AppState(this._workouts);

  UnmodifiableMapView<Date, Workout> get workouts => UnmodifiableMapView(_workouts.value);

  set workouts(Map<Date, Workout> newWorkouts) {
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
