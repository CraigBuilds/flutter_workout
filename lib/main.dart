import 'package:flutter/material.dart';
import 'data_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState(ValueNotifier<List<Workout?>>([]));
  runApp(buildRoot(appState));
}

// ----- Root -----

Widget buildRoot(AppState appState) => ValueListenableBuilder<List<Workout?>>(
  valueListenable: appState.workouts,
  builder: (_, __, ___) => buildApp(appState),
);

// ----- App -----

//This is rebuilt by root whenever appState.workouts changes
Widget buildApp(AppState appState) => MaterialApp(
  title: 'Functional Workout App',
  home: buildHome(appState),
  routes: {
    '/about': (_) => buildAboutPage(),
  },
  onGenerateRoute: (settings) {
    final RouteArgs args = settings.arguments as RouteArgs;
    switch (settings.name) {
      case '/exercise_selector':
        return MaterialPageRoute(
          builder: (_) => buildExerciseSelectorPage(args),
        );
      case '/exercise_view':
        return MaterialPageRoute(
          builder: (_) => buildExerciseViewPage(args),
        );
    }
    return null;
  },
);

// ----- Home Page -----

Widget buildHome(AppState appState) => Scaffold(
  appBar: AppBar(title: Text('Workouts')),
  //PageView.builder is used to dynamically create pages for each workout
  body: PageView.builder(
    scrollDirection: Axis.horizontal,
    controller: PageController(viewportFraction: 0.95),
    //Todo instead of having nullable workouts and 10 blank pages, just have one extra page
    itemCount: (appState.workouts.value.isNotEmpty) ? appState.workouts.value.length + 10 : 10,
    itemBuilder: (_, i) {
      final workouts = appState.workouts.value;
      final isWorkoutPane = i < workouts.length && workouts[i] != null;
      return isWorkoutPane ? buildWorkoutPane(appState, i) : buildBlankPane(appState, i);
    },
  ),
  floatingActionButton: Builder(
    builder: (context) => FloatingActionButton(
      onPressed: () => Navigator.of(context).pushNamed('/about'),
      child: Icon(Icons.info),
    ),
  ),
);

// ----- Workout Pane -----

Widget buildWorkoutPane(AppState appState, int index) => Card(
  child: Column(
    children: [
      ListTile(
        title: Text(appState.workouts.value[index]!.name),
      ),
      buildWorkoutPaneChildren(appState, index),
    ],
  ),
);

Widget buildWorkoutPaneChildren(AppState appState, int index) => Expanded(
  child: SingleChildScrollView(
    child: Column(
      children: [
        ...appState.workouts.value[index]!.exercises
            .map((exercise) => buildExerciseTile(appState, exercise, appState.workouts.value[index]!)),
        buildAddExerciseButton(appState, appState.workouts.value[index]!),
      ],
    ),
  ),
);

Widget buildAddExerciseButton(AppState appState, Workout workoutToAddTo) => Card(
  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  child: Builder(
    builder: (context) => ListTile(
      leading: Icon(Icons.add),
      title: Text('Add Exercise'),
      onTap: () {
        Navigator.of(context).pushNamed('/exercise_selector', arguments: RouteArgs(
          appState: appState,
          exerciseName: '',
          workout: workoutToAddTo,
        ));
      },
    ),
  ),
);

Widget buildBlankPane(AppState appState, int index) => Card(
  child: Center(
    child: ElevatedButton(
      onPressed: () => addDummyWorkout(appState, index),
      child: Text('Add Workout'),
    ),
  ),
);

// ----- Exercise Tile -----

Widget buildExerciseTile(AppState appState, Exercise exercise, Workout workoutToAddTo) => Card(
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
        Navigator.of(context).pushNamed('/exercise_view', arguments: RouteArgs(
          appState: appState,
          exerciseName: exercise.name,
          workout: workoutToAddTo,
        ));
      },
    ),
  ),
);

// ----- Pages -----

class RouteArgs {
  AppState appState;
  String exerciseName;
  Workout workout;

  RouteArgs({
    required this.appState,
    required this.exerciseName,
    required this.workout,
  });
}

// ----- Exercise Selector Page -----

// This view allows users to select exercises from a tree structure. It is a new page in the app.
Widget buildExerciseSelectorPage(RouteArgs args) => Scaffold(
  appBar: AppBar(title: Text('Select Exercise')),
  body: Builder(
    builder: (context) => ListView(
      children: [
        ListTile(
          title: Text('Push Ups'),
          onTap: () {
            addExerciseToWorkout(args.appState, args.workout.name, 'Push Ups');
            Navigator.of(context).pushNamed('/exercise_view', arguments: RouteArgs(
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

// ----- Exercise View Page -----

// This view allows the user to add sets to this exercise (for todays workout), and also view historical data.
Widget buildExerciseViewPage(RouteArgs args) => Scaffold(
  appBar: AppBar(title: Text('Exercise Details for ${args.exerciseName} in ${args.workout.name}')),
  body: ListView.builder(
    itemCount: args.workout.exercises
        .firstWhere((e) => e.name == args.exerciseName)
        .sets.length,
    itemBuilder: (context, index) {
      final exercise = args.workout.exercises
          .firstWhere((e) => e.name == args.exerciseName);
      final set = exercise.sets[index];
      return ListTile(
        title: Text('Set ${index + 1}'),
        subtitle: Text('${set.reps} reps @ ${set.weight} kg'),
      );
    },
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      addDummySetToExercise(args.appState, args.workout.name, args.exerciseName);
    },
    child: Icon(Icons.add),
  ),
);

// ----- About Page -----

Widget buildAboutPage() => Scaffold(
  appBar: AppBar(title: Text('About')),
  body: Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Functional Workout App\n\nVersion 1.0\n\nCreated for demonstration purposes.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    ),
  )
);