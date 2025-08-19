import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ----- Data Models -----
class Workout {
  final String name;
  final List<Exercise> exercises;

  Workout({required this.name, required this.exercises});
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

// ----- State -----

/// Workouts is an alias for ValueNotifier`<List<Workout>>`, it notifies listeners when the list (immutable) is rebuilt
typedef Workouts = ValueNotifier<List<Workout?>>;

void addDummyWorkout(Workouts workouts, int index) {
  final newWorkout = Workout(
    name: 'Workout ${workouts.value.length + 1}',
    exercises: [
      Exercise(
        name: 'Bench Press',
        sets: [
          ExerciseSet(reps: 10, weight: 60.0),
          ExerciseSet(reps: 8, weight: 70.0),
        ],
      ),
      Exercise(
        name: 'Squat',
        sets: [
          ExerciseSet(reps: 12, weight: 80.0),
        ],
      ),
    ],
  );

  // Assign a new list to the ValueNotifier value. The newWorkout should be placed at the given index.
  // If the index is greater than the current length, pad with nulls (this is done by increasing the length)
  final newList = List<Workout?>.from(workouts.value);
  if (index >= newList.length) {
    newList.length = index + 1;
  }
  newList[index] = newWorkout;
  workouts.value = newList;
}

// --- Persistence ---



/// Loads workouts from shared preferences asynchronously.
Future<Workouts> loadWorkoutsFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final contents = prefs.getString('workouts');
  if (contents == null) {
    return Workouts([]);
  }
  final List<dynamic> jsonList = jsonDecode(contents);
  final workouts = jsonList.map((w) => Workout(
    name: w['name'],
    exercises: (w['exercises'] as List<dynamic>).map((e) => Exercise(
      name: e['name'],
      sets: (e['sets'] as List<dynamic>).map((s) => ExerciseSet(
        reps: s['reps'],
        weight: s['weight'].toDouble(),
      )).toList(),
    )).toList(),
  )).toList();
  return Workouts(workouts);
}

/// Saves workouts to shared preferences asynchronously.
Future<void> saveWorkoutsToPrefs(Workouts workouts) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonList = workouts.value.map((w) => w == null ? null : {
    'name': w.name,
    'exercises': w.exercises.map((e) => {
      'name': e.name,
      'sets': e.sets.map((s) => {
        'reps': s.reps,
        'weight': s.weight,
      }).toList(),
    }).toList(),
  }).toList();
  await prefs.setString('workouts', jsonEncode(jsonList));
}

/// reset preferences
Future<void> resetWorkoutsPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('workouts');
}