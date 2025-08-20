import 'package:flutter/material.dart';
import 'data_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final context = Context(ValueNotifier<List<Workout?>>([]));
  runApp(buildRoot(context));
}

// ----- Root -----

Widget buildRoot(Context context) => ValueListenableBuilder<List<Workout?>>(
  valueListenable: context.workouts,
  builder: (_, __, ___) => buildApp(context),
);

// ----- App -----

//This is rebuilt by root whenever context.workouts changes
Widget buildApp(Context context) => MaterialApp(
  title: 'Functional Workout App',
  home: buildHome(context),
  routes: {
    '/about': (_) => buildAboutPage(),
  },
  onGenerateRoute: (settings) {
    if (settings.name == '/exercise_selector') {
      final workoutToAddTo = settings.arguments as Workout;
      return MaterialPageRoute(
        builder: (_) => buildExerciseSelectorPage(workoutToAddTo),
      );
    } else if (settings.name == '/exercise_view') {
      final args = settings.arguments as ExerciseViewArgs;
      return MaterialPageRoute(
        builder: (_) => buildExerciseViewPage(args),
      );
    }
    return null; // Handle other routes or return null
  },
);

// ----- Home Page -----

Widget buildHome(Context context) => Scaffold(
  appBar: AppBar(title: Text('Workouts')),
  //PageView.builder is used to dynamically create pages for each workout
  body: PageView.builder(
    scrollDirection: Axis.horizontal,
    controller: PageController(viewportFraction: 0.95),
    itemCount: (context.workouts.value.isNotEmpty) ? context.workouts.value.length + 10 : 10,
    itemBuilder: (_, i) {
      final workouts = context.workouts.value;
      final isWorkoutPane = i < workouts.length && workouts[i] != null;
      return isWorkoutPane ? buildWorkoutPane(context, i) : buildBlankPane(context, i);
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

Widget buildWorkoutPane(Context context, int index) => Card(
  child: Column(
    children: [
      ListTile(
        title: Text(context.workouts.value[index]!.name),
      ),
      buildWorkoutPaneChildren(context, index),
    ],
  ),
);

Widget buildWorkoutPaneChildren(Context context, int index) => 
  Expanded(
    child: SingleChildScrollView(
      child: Column(
        children: [
          ...context.workouts.value[index]!.exercises
              .map((exercise) => buildExerciseTile(exercise, context.workouts.value[index]!)),
          buildAddExerciseButton(context.workouts.value[index]!),
        ],
      ),
    ),
  );

Widget buildAddExerciseButton(Workout workoutToAddTo) => Builder(
  builder: (context) => Card(
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    child: ListTile(
      leading: Icon(Icons.add),
      title: Text('Add Exercise'),
      onTap: () {
        Navigator.of(context).pushNamed('/exercise_selector', arguments: workoutToAddTo);
      },
    ),
  ),
);

Widget buildBlankPane(Context context, int index) => Card(
  child: Center(
    child: ElevatedButton(
      onPressed: () => addDummyWorkout(context, index),
      child: Text('Add Workout'),
    ),
  ),
);

// ----- Exercise Tile -----

Widget buildExerciseTile(Exercise exercise, Workout workoutToAddTo) => Card(
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
        Navigator.of(context).pushNamed('/exercise_view', arguments: ExerciseViewArgs(
          exerciseName: exercise.name,
          workout: workoutToAddTo,
        ));
      },
    ),
  ),
);

// ----- Exercise Selector Page -----

// This view allows users to select exercises from a tree structure. It is a new page in the app.
Widget buildExerciseSelectorPage(Workout workoutToAddTo) => Scaffold(
  appBar: AppBar(title: Text('Select Exercise')),
  body: Builder(
    builder: (context) => ListView(
      children: [
        ListTile(
          title: Text('Push Ups'),
          onTap: () {
            Navigator.of(context).pushNamed('/exercise_view', arguments: ExerciseViewArgs(
              exerciseName: 'Push Ups',
              workout: workoutToAddTo,
            ));
          },
        )
        // Add more exercises here
      ],
    ),
  ),
);

// ----- Exercise View Page -----

class ExerciseViewArgs {
  String exerciseName;
  Workout workout;

  ExerciseViewArgs({
    required this.exerciseName,
    required this.workout,
  });
}

// This view allows the user to add sets to this exercise (for todays workout), and also view historical data.
Widget buildExerciseViewPage(ExerciseViewArgs args) => Scaffold(
  appBar: AppBar(title: Text('Exercise Details')),
  body: Center(
    child: Text('Exercise Main View Placeholder for ${args.exerciseName} in ${args.workout.name}'),
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