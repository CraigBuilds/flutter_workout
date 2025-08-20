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
    '/exercise_selector': (_) => buildExerciseSelector(),
    '/about': (_) => buildAboutPage(),
  },
);

// ----- Home Page -----

Widget buildHome(Context context) => Scaffold(
  appBar: AppBar(title: Text('Workouts')),
  //PageView.builder is used to dynamically create pages for each workout
  body: PageView.builder(
    scrollDirection: Axis.horizontal,
    controller: PageController(viewportFraction: 0.95),
    itemCount: context.workouts.value.isEmpty ? 10 : context.workouts.value.length + 10,
    itemBuilder: (_, i) {
      if (i >= context.workouts.value.length) {
        return buildBlankPane(context, i);
      }
      if (context.workouts.value[i] == null) {
        return buildBlankPane(context, i);
      }
      return buildWorkoutPane(context, i);
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

Widget buildWorkoutPaneChildren(Context context, int index) => Expanded(
  child: SingleChildScrollView(
    child: Column(
      children: [
        ...context.workouts.value[index]!.exercises
            .map((exercise) => buildExerciseTile(exercise)),
        Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text('Add Exercise'),
            onTap: () {
              // todo: add exercise to workout. This should navigate to exercise selector, and then exercise view
            },
          ),
        ),
      ],
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

Widget buildExerciseTile(Exercise exercise) => Card(
  color: Colors.grey[200], // Add background color
  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  child: ListTile(
    title: Text(exercise.name),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: exercise.sets.map((set) {
        return Text('Set: ${set.reps} reps @ ${set.weight} kg');
      }).toList(),
    ),
  ),
);

// ----- Exercise Selector -----

// This widget allows users to select exercises from a tree structure. It is a new page in the app.
Widget buildExerciseSelector() => Scaffold(
  appBar: AppBar(title: Text('Select Exercise')),
  body: Center(
    child: Text('Exercise Selector Placeholder'),
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