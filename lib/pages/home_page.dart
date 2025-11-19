import 'package:app/pages/exercise_selector_page.dart';
import 'package:flutter/material.dart';
import '../backend/models.dart';
import '../backend/crud.dart';
import '../backend/app_state.dart';
import 'settings_page.dart';
import 'set_logging_page.dart';

// ----- Home Page -----

Widget buildHome(AppState appState, BuildContext context) => Scaffold(
  appBar: buildHomeAppBar(appState, context),
  body: buildHomeBody(appState, context),
);

// ----- Controls -----

PreferredSizeWidget buildHomeAppBar(AppState appState, BuildContext context) => AppBar(
  title: Text('Workouts'),
  actions: [
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => buildSettingsPage(context, appState)),),
    ),
  ],
);

Widget buildHomeBody(AppState appState, BuildContext context) => PageView.builder(
  scrollDirection: Axis.horizontal,
  controller: PageController(viewportFraction: 0.95),
  itemCount: appState.workouts.length + 1,
  itemBuilder: (_, i) => buildWorkoutPane(
    appState,
    appState.workouts.values.elementAtOrNull(i),
    context,
  ),
);

// ----- Workout Pane -----

Widget buildWorkoutPane(AppState appState, Workout? workout, BuildContext context) => Card(
  child: Column(
    children: [
      buildWorkoutPaneHeader(workout),
      buildWorkoutPaneContent(appState, workout, context),
    ],
  ),
);

Widget buildWorkoutPaneHeader(Workout? workout) => ListTile(
  title: Text(workout?.date.toString() ?? 'Add New Workout'),
);

Widget buildWorkoutPaneContent(AppState appState, Workout? workout, BuildContext context) => Expanded(
  child: SingleChildScrollView(
    child: Column(
      children: [
        if (workout != null) ...buildExerciseTiles(appState, workout, context),
        buildAddExerciseButton(appState, workout, context),
      ],
    ),
  ),
);

List<Widget> buildExerciseTiles(AppState appState, Workout workout, BuildContext context) =>
  workout.exercises.map((exercise) => buildExerciseTile(appState, exercise, workout, context)).toList();

Widget buildAddExerciseButton(AppState appState, Workout? workout, BuildContext context) => Card(
  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  child: ListTile(
    leading: Icon(Icons.add),
    title: Text('Add Exercise'),
    onTap: () => handleAddExerciseButtonTap(appState, workout, context),
  ),
);

void handleAddExerciseButtonTap(AppState appState, Workout? workout, BuildContext context) {
  Workout? targetWorkout = workout;
  if (targetWorkout == null) {
    final today = Date.today();
    if (!appState.workouts.containsKey(today)) {
      createEmptyWorkout(appState, today);
      targetWorkout = readWorkout(appState, today);
    }else {
      final tomorrow = Date.tomorrow();
      createEmptyWorkout(appState, tomorrow);
      targetWorkout = readWorkout(appState, tomorrow);
    }
  }
  Navigator.push(context, MaterialPageRoute(builder: (_) => buildExerciseSelectorPage(context, appState, targetWorkout!)),);
}

// ----- Exercise Tile -----

Widget buildExerciseTile(AppState appState, Exercise exercise, Workout workout, BuildContext context) => Card(
  color: Colors.grey[200],
  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  child: ListTile(
    title: Text(exercise.name),
    subtitle: buildExerciseSets(exercise),
    onTap: () => handleExerciseTileTap(appState, exercise, workout, context)
  ),
);

Widget buildExerciseSets(Exercise exercise) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: exercise.sets
      .map((set) => Text('Set: ${set.reps} reps @ ${set.weight} kg'))
      .toList(),
);

void handleExerciseTileTap(AppState appState, Exercise exercise, Workout workout, BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => buildSetLoggingPage(context, appState, exercise)),);
}