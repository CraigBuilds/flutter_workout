import 'package:flutter/material.dart';
import '../backend/app_state.dart';
import '../backend/models.dart';
import '../backend/crud.dart';
import 'set_logging_page.dart';

Widget buildExerciseSelectorPage(BuildContext context, AppState appState, Workout selectedWorkout) => Scaffold(
  appBar: AppBar(title: Text('Select Exercise')),
  body: ListView(
    children: [
      for (var name in [
          'Flat Barbell Bench Press',
          'Seated Overhead Dumbbell Press',
          'Seated Cable Row',
          'Chin-Ups (Underhand Grip)',
          'Pull-Ups (Overhand Grip)',
          'Pull-Downs (Wide Grip)',
          'Leg Press',
          'Barbell Squats',
          'Conventional Deadlift',
          'Bayesian Cable Curls',
          'Barbell Curls',
          'Tricep Pushdowns (Bar)',
          'Tricep Overhead Extensions (Rope)',
          'Cable Lateral Raises',
          'Machine Chest Flys',
          'Machine Rear Delt Flys',
          'Leg Extensions',
          'Plank',
          'Hanging Leg Raises',
          'Crunches',
        ]
      )
        _buildExerciseTile(context, appState, selectedWorkout, name),
    ],
  ),
);

// Helper function to build exercise ListTile
Widget _buildExerciseTile(BuildContext context, AppState appState, Workout selectedWorkout, String exerciseName) => ListTile(
  title: Text(exerciseName),
  onTap: () {
    if (!selectedWorkout.exercises.any((ex) => ex.name == exerciseName)) {
      createExerciseInWorkout(
        appState,
        selectedWorkout.date,
        Exercise(name: exerciseName, sets: [], date: selectedWorkout.date),
      );
    }
    final selectedExercise = selectedWorkout.exercises.firstWhere((ex) => ex.name == exerciseName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => buildSetLoggingPage(context, appState, selectedExercise),
      ),
    );
  },
);