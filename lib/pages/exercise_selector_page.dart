import 'package:flutter/material.dart';
import '../backend/models.dart';
import '../backend/my_router.dart';
import '../backend/crud.dart';

// This view allows users to select exercises from a tree structure. It is a new page in the app.
Widget buildExerciseSelectorPage(RouteArgs args, BuildContext context) => Scaffold(
  appBar: AppBar(title: Text('Select Exercise')),
  body: Builder(
    builder: (context) => ListView(
      children: [
        ListTile(
          title: Text('Push Ups'),
          onTap: () {
            //if exercise is not already in workout, add it
            if (!args.workout.exercises.any((ex) => ex.name == 'Push Ups')) {
              createExerciseInWorkout(args.appState, args.workout.date, Exercise(name: 'Push Ups', sets: []));
            }
            Navigator.of(context).pushNamed('/set_logging', arguments: RouteArgs(
              appState: args.appState,
              exerciseName: 'Push Ups',
              workout: args.workout,
            ));
          },
        )
        // Add more exercises here
      ],
    ),
  ),  
);