import 'package:flutter/foundation.dart';
import 'dart:collection'; //for UnmodifiableMapView
import 'package:hive/hive.dart'; //for decorators and Box class
import 'models.dart';

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
