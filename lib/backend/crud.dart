import 'app_state.dart';
import 'models.dart';

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
