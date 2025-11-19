import 'package:flutter/material.dart';
import '../backend/models.dart';
import '../backend/my_router.dart';

Widget buildHome(AppState appState) => Scaffold(
  appBar: AppBar(
    title: Text('Workouts'),
    actions: [
      Builder(builder: (context) => IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {Navigator.pushNamed(context, '/settings');},
      ),
      ),
    ],
  ),
  //PageView.builder is used to dynamically create pages for each workout
  body: PageView.builder(
    scrollDirection: Axis.horizontal,
    controller: PageController(viewportFraction: 0.95),
    itemCount: appState.workouts.length + 1, // +1 for the extra page with no workout
    itemBuilder: (_, i) => buildWorkoutPane(appState, appState.workouts.values.elementAtOrNull(i)), 
  )
);

// ----- Workout Pane -----

Widget buildWorkoutPane(AppState appState, Workout? workout) => Card(
  child: Column(
    children: [
      ListTile(
        title: Text(workout?.date.toString() ?? 'Add New Workout'),
      ),
      buildWorkoutPaneExerciseTilesAndButton(appState, workout),
    ],
  ),
);

Widget buildWorkoutPaneExerciseTilesAndButton(AppState appState, Workout? workout) => Expanded(
  child: SingleChildScrollView(
    child: Column(
      children: [
        // Exercise Tiles
        if (workout != null)
          ...workout.exercises.map((exercise) => buildExerciseTile(appState, exercise, workout)),
        //+button
        buildAddExerciseButton(appState, workout)

      ],
    ),
  ),
);

Widget buildAddExerciseButton(AppState appState, Workout? workout) => Card(
  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  child: Builder(
    builder: (context) => ListTile(
      leading: Icon(Icons.add),
      title: Text('Add Exercise'),
      onTap: () {
        //create a new workout if null
        if (workout == null) {
          //if no workout exists for today, create one
          if (!appState.workouts.containsKey(Date.today())) {
            final today = Date.today();
            createEmptyWorkout(appState, today);
            workout = readWorkout(appState, today);
          }
          //if they have already created a workout for today, plan a workout for tomorrow
          else {
            final tomorrow = Date.tomorrow();
            createEmptyWorkout(appState, tomorrow);
            workout = readWorkout(appState, tomorrow);
          }
        }
        //navigate to exercise selector
        Navigator.of(context).pushNamed('/exercise_selector', arguments: RouteArgs(
          appState: appState,
          exerciseName: '',
          workout: workout!,
        ));
      },
    ),
  ),
);

// // ----- Exercise Tile -----

Widget buildExerciseTile(AppState appState, Exercise exercise, Workout workout) => Card(
  color: Colors.grey[200], // Add background color
  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  child: Builder(
    builder: (context) => ListTile(
      title: Text(exercise.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: exercise.sets.map((set) {
          return Text('Set: ${set.reps} reps @ ${set.weight} kg');
        }).toList(),
      ),
      onTap: () {
        Navigator.of(context).pushNamed('/set_logging', arguments: RouteArgs(
          appState: appState,
          exerciseName: exercise.name,
          workout: workout,
        ));
      },
    ),
  ),
);