import 'package:app/pages/exercise_selector_page.dart';
import 'package:flutter/material.dart';
import '../backend/models.dart';
import '../backend/crud.dart' as crud;
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
    buildAppBarMenuButton(appState, context)
  ]
);

Widget buildAppBarMenuButton(AppState appState, BuildContext context) => IconButton(
  icon: Icon(Icons.more_vert),
  onPressed: () => handleAppBarMenuButtonPressed(appState, context)
);

Future<void> handleAppBarMenuButtonPressed(AppState appState, BuildContext context) async {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final navigator = Navigator.of(context);
  final result = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      overlay.size.width,
      kToolbarHeight,
      0,
      0,
    ),
    items: buildAppBarMenuItems(),
  );
  if (result == 'settings') {
    navigator.push(MaterialPageRoute(builder: (_) => buildSettingsPage(context, appState)),);
  }
}

List<PopupMenuEntry<String>> buildAppBarMenuItems() => [
  for (var item in [
    ['settings', Icons.settings, 'Settings'],
    ['createRoutine', Icons.create, 'Create Workout Routine'],
    ['browseRoutines', Icons.search, 'Browse Workout Routines'],
    ['cancel', Icons.cancel, 'Cancel'],
  ])
    PopupMenuItem<String>(
      value: item[0] as String,
      child: Row(
        children: [
          Icon(item[1] as IconData, size: 20),
          SizedBox(width: 8),
          Text(item[2] as String),
        ],
      ),
    ),
];

Widget buildHomeBody(AppState appState, BuildContext context) => PageView.builder(
  scrollDirection: Axis.horizontal,
  controller: PageController(
    viewportFraction: 0.95,
    initialPage: getIndexOfTodayWorkout(appState),
  ),
  itemCount: appState.workouts.length + 1, // +1 for "Plan New Workout" pane
  itemBuilder: (_, i) => buildWorkoutPane(
    appState,
    appState.workouts.values.elementAtOrNull(i),
    context,
  ),
);

int getIndexOfTodayWorkout(AppState appState) {
  final today = Date.today();
  final workoutDates = appState.workouts.keys.toList();
  for (int i = 0; i < workoutDates.length; i++) {
    if (workoutDates[i] >= today) {
      return i;
    }
  }
  return appState.workouts.length; // If all workouts are in the past, return the index for "Plan New Workout" pane
}

// ----- Workout Pane -----

Widget buildWorkoutPane(AppState appState, Workout? workout, BuildContext context) => Card(
  child: Column(
    children: [
      buildWorkoutPaneHeader(workout, appState),
      buildWorkoutPaneContent(appState, workout, context),
    ],
  ),
);

Widget buildWorkoutPaneHeader(Workout? workout, AppState appState) {
  final today = Date.today();
  if (workout != null) {
    final dateText = workout.date.toString();
    final isToday = workout.date == today;
    final isFuture = workout.date > today;
    String displayText;
    if (isToday) {
      displayText = '$dateText (today)';
    } else if (isFuture) {
      displayText = '$dateText (planned)';
    } else {
      displayText ='$dateText (past)';
    }
    return ListTile(
      title: Text(displayText),
    );
  //if workout is null, this is the end page
  } else {
    final workoutExistsForToday = appState.workouts.containsKey(today);
    final title = workoutExistsForToday
        ? 'Plan new workout'
        : 'Add new workout for today';
    return ListTile(
      title: Text(title),
    );
  }
}

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
    onTap: () => {
      if (workout != null) {
        handleAddExerciseToExistingWorkoutButtonTap(appState, workout, context)
      }
      else {
        handleAddExerciseToNewWorkoutButtonTap(appState, context)
      }
    }
  ),
);

void handleAddExerciseToExistingWorkoutButtonTap(AppState appState, Workout selectedWorkout, BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => buildExerciseSelectorPage(context, appState, selectedWorkout)),);
}

Future handleAddExerciseToNewWorkoutButtonTap(AppState appState, BuildContext context) async {
  // Store a callback that uses BuildContext before the async gap
  void navigateToAddExercise(Workout selectedWorkout) {
    handleAddExerciseToExistingWorkoutButtonTap(appState, selectedWorkout, context);
  }

  Date today = Date.today();
  bool workoutExistsForToday = appState.workouts.containsKey(today);
  Workout selectedWorkout;
  if (!workoutExistsForToday) {
    crud.createEmptyWorkout(appState, today);
    selectedWorkout = crud.readWorkout(appState, today);
    navigateToAddExercise(selectedWorkout);
  }
  else {
    Date? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    ).then((dateTime) => dateTime != null ? Date(dateTime.year, dateTime.month, dateTime.day) : null);
    if (selectedDate == null) {
      return; //user cancelled date picker
    }
    //check if workout exists for selected date, if not create it
    if (!appState.workouts.containsKey(selectedDate)) {
      crud.createEmptyWorkout(appState, selectedDate);
    }
    selectedWorkout = crud.readWorkout(appState, selectedDate);
    navigateToAddExercise(selectedWorkout);
  }
}

// ----- Exercise Tile -----

Widget buildExerciseTile(AppState appState, Exercise exercise, Workout workout, BuildContext context) => Card(
  color: Colors.grey[200],
  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  child: ListTile(
    title: Text(exercise.name),
    subtitle: buildExerciseSets(exercise),
    onTap: () => handleExerciseTileTap(appState, exercise, workout, context),
    onLongPress: () => handleExerciseTileLongPress(appState, exercise, workout, context),
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

Future handleExerciseTileLongPress(AppState appState, Exercise exercise, Workout workout, BuildContext context) async {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final result = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      overlay.size.width / 2,
      overlay.size.height / 2,
      overlay.size.width / 2,
      overlay.size.height / 2,
    ),
    items: [
      PopupMenuItem<String>(
        value: 'delete',
        child: Text('Delete Exercise'),
      ),
      PopupMenuItem<String>(
        value: 'cancel',
        child: Text('Cancel'),
      ),
    ],
  );

  if (result == 'delete') {
    crud.deleteExerciseFromWorkout(appState, workout.date, exercise.name);
  }
}