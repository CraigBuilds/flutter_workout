import 'package:flutter/material.dart';
import 'data_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final workouts = Workouts([]);
  runApp(buildApp(workouts));
}

// ----- App -----

Widget buildApp(Workouts workouts) => ValueListenableBuilder<List<Workout?>>(
  valueListenable: workouts,
  builder: (_, workoutList, __) {
    return MaterialApp(
      title: 'Functional Workout App',
      home: buildHome(workouts, workoutList),
    );
  },
);

// ----- Home Page -----

Widget buildHome(Workouts workouts, List<Workout?> workoutList) => Scaffold(
  appBar: AppBar(title: Text('Workouts')),
  body: PageView.builder(
    scrollDirection: Axis.horizontal,
    controller: PageController(viewportFraction: 0.95),
    itemCount: workoutList.isEmpty ? 10 : workoutList.length + 10,
    itemBuilder: (_, i) {
      if (i >= workoutList.length) {
        return buildBlankPane(workouts, i);
      }
      if (workoutList[i] == null) {
        return buildBlankPane(workouts, i);
      }
      return buildWorkoutPane(workouts, i);
    },
  ),
);

// ----- Workout Pane -----

Widget buildWorkoutPane(Workouts workouts, int index) => Card(
  child: Column(
    children: [
      ListTile(
        title: Text(workouts.value[index]!.name),
      ),
      buildWorkoutPaneChildren(workouts, index),
    ],
  ),
);

Widget buildWorkoutPaneChildren(Workouts workouts, int index) => Expanded(
  child: SingleChildScrollView(
    child: Column(
      children: [
        ...workouts.value[index]!.exercises
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

Widget buildBlankPane(Workouts workouts, int index) => Card(
  child: Center(
    child: ElevatedButton(
      onPressed: () => addDummyWorkout(workouts, index),
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