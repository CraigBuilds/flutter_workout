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

class AppState {
  final ValueNotifier<List<Workout?>> workouts;

  AppState(this.workouts);
}

// ----- State -----


void addDummyWorkout(AppState appState, int index) {
  final newWorkout = Workout(
    name: 'Workout ${appState.workouts.value.length + 1}',
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
  final newList = List<Workout?>.from(appState.workouts.value);
  if (index >= newList.length) {
    newList.length = index + 1;
  }
  newList[index] = newWorkout;
  appState.workouts.value = newList;
}

void addExerciseToWorkout(AppState appState, String workoutName, String exerciseName) {
  final newList = List<Workout?>.from(appState.workouts.value);
  final workout = newList.firstWhere((w) => w?.name == workoutName);
  if (workout == null) return;
  workout.exercises.add(Exercise(name: exerciseName, sets: []));
  appState.workouts.value = newList;
}

void addDummySetToExercise(AppState appState, String workoutName, String exerciseName) {
  //remember to replace the workouts field of context so a rebuild is triggered
  final newList = List<Workout?>.from(appState.workouts.value);
  final workout = newList.firstWhere((w) => w?.name == workoutName);
  final exercise = workout!.exercises.firstWhere((e) => e.name == exerciseName);
  exercise.sets.add(ExerciseSet(reps: 10, weight: 50.0));
  appState.workouts.value = newList;
}