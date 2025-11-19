import 'package:flutter/material.dart';
import '../backend/app_state.dart';
import '../backend/models.dart';
import '../backend/crud.dart';
import 'set_logging_page.dart';

// This view allows users to select exercises from a tree structure. It is a new page in the app.
// It adds the exercise to the selected workout
Widget buildExerciseSelectorPage(BuildContext context, AppState appState, Workout selectedWorkout) => Scaffold(
  appBar: AppBar(title: Text('Select Exercise')),
  body: ListView(
    children: [
      ListTile(
        title: Text('Push Ups'),
        onTap: () {
          //if exercise is not already in this workout, add it
          if (!selectedWorkout.exercises.any((ex) => ex.name == 'Push Ups')) {
            createExerciseInWorkout(appState, selectedWorkout.date, Exercise(name: 'Push Ups', sets: [], date: selectedWorkout.date));
          }
          final selectedExercise = selectedWorkout.exercises.firstWhere((ex) => ex.name == 'Push Ups');
          Navigator.push(context, MaterialPageRoute(builder: (_) => buildSetLoggingPage(context, appState, selectedExercise)));
        },
      ),
      ListTile(
        title: Text('Squats'),
        onTap: () {
          if (!selectedWorkout.exercises.any((ex) => ex.name == 'Squats')) {
            createExerciseInWorkout(appState, selectedWorkout.date, Exercise(name: 'Squats', sets: [], date: selectedWorkout.date));
          }
          final selectedExercise = selectedWorkout.exercises.firstWhere((ex) => ex.name == 'Squats');
          Navigator.push(context, MaterialPageRoute(builder: (_) => buildSetLoggingPage(context, appState, selectedExercise)));
        },
      )
    ],
  ),
);
