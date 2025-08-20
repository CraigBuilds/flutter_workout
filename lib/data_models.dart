import 'package:flutter/foundation.dart';

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