import 'package:flutter/foundation.dart';
import 'dart:collection'; //for UnmodifiableMapView
import 'package:hive/hive.dart'; //for decorators and Box class
import 'models.dart';

class AppState {

  final ValueNotifier<Map<Date, Workout>> _workouts;

  AppState(this._workouts);

  factory AppState.fromHiveBox(Box<Workout> database) {
    final loadedWorkouts = <Date, Workout>{};
    //load all workouts from the database
    for (var key in database.keys) {
      final workout = database.get(key)!;
      final date = Date.fromString(key as String);
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

    // save all workouts to the database
    for (var entry in newWorkouts.entries) {
      final key = entry.key.toString(); // "yyyy-mm-dd"
      box.put(key, entry.value);
    }

    _workouts.value = Map<Date, Workout>.from(newWorkouts);
  }

  ValueNotifier<Map<Date, Workout>> get workoutsNotifier => _workouts;

  // Workout CRUD Operations

  void createEmptyWorkout(Date workoutDate) {
    final dataCopy = Map<Date, Workout>.from(workouts);
    dataCopy[workoutDate] = Workout(date: workoutDate, exercises: []);
    workouts = dataCopy;
  }

  Workout readWorkout(Date workoutDate) {
    return workouts[workoutDate]!;
  }

  void updateWorkout(Date workoutDate, Workout updatedWorkout) {
    final dataCopy = Map<Date, Workout>.from(workouts);
    dataCopy[workoutDate] = updatedWorkout;
    workouts = dataCopy;
  }

  void deleteWorkout(Date workoutDate) {
    final dataCopy = Map<Date, Workout>.from(workouts);
    dataCopy.remove(workoutDate);
    workouts = dataCopy;
  }

  // Exercise CRUD Operations

  void createExerciseInWorkout(Date workoutDate, Exercise exercise) {
    final dataCopy = Map<Date, Workout>.from(workouts);
    dataCopy[workoutDate]!.exercises.add(exercise);
    workouts = dataCopy;
  }

  Exercise readExerciseFromWorkout(Date workoutDate, String exerciseName) {
    return workouts[workoutDate]!.exercises.firstWhere((ex) => ex.name == exerciseName);
  }

  void updateExerciseInWorkout(Date workoutDate, Exercise updatedExercise) {
    final dataCopy = Map<Date, Workout>.from(workouts);
    final workout = dataCopy[workoutDate]!;
    final exerciseIndex = workout.exercises.indexWhere((ex) => ex.name == updatedExercise.name);
    if (exerciseIndex != -1) {
      workout.exercises[exerciseIndex] = updatedExercise;
      workouts = dataCopy;
    }
  }

  void deleteExerciseFromWorkout(Date workoutDate, String exerciseName) {
    final dataCopy = Map<Date, Workout>.from(workouts);
    final workout = dataCopy[workoutDate]!;
    workout.exercises.removeWhere((ex) => ex.name == exerciseName);
    workouts = dataCopy;
  }

  // WorkoutSet CRUD Operations

  void createSetInExercise(Date workoutDate, String exerciseName, ExerciseSet set) {
    final dataCopy = Map<Date, Workout>.from(workouts);
    final workout = dataCopy[workoutDate]!;
    final exercise = workout.exercises.firstWhere((ex) => ex.name == exerciseName);
    exercise.sets.add(set);
    workouts = dataCopy;
  }

  ExerciseSet readSetFromExercise(Date workoutDate, String exerciseName, int setIndex) {
    final workout = workouts[workoutDate]!;
    final exercise = workout.exercises.firstWhere((ex) => ex.name == exerciseName);
    return exercise.sets[setIndex];
  }

  void updateSetInExercise(Date workoutDate, String exerciseName, int setIndex, ExerciseSet updatedSet) {
    final dataCopy = Map<Date, Workout>.from(workouts);
    final workout = dataCopy[workoutDate]!;
    final exercise = workout.exercises.firstWhere((ex) => ex.name == exerciseName);
    if (setIndex >= 0 && setIndex < exercise.sets.length) {
      exercise.sets[setIndex] = updatedSet;
      workouts = dataCopy;
    }
  }

  void deleteSetFromExercise(Date workoutDate, String exerciseName, int setIndex) {
    final dataCopy = Map<Date, Workout>.from(workouts);
    final workout = dataCopy[workoutDate]!;
    final exercise = workout.exercises.firstWhere((ex) => ex.name == exerciseName);
    if (setIndex >= 0 && setIndex < exercise.sets.length) {
      exercise.sets.removeAt(setIndex);
      workouts = dataCopy;
    }
  }

  // Delete all data

  void deleteAllData() {
    workouts = {};
  }
}
