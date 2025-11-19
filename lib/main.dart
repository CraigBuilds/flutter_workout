import 'package:flutter/material.dart';
import 'models.dart';
import 'pages/home_page.dart';
import 'my_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initializes Hive for Flutter
  Hive.registerAdapter(DateAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(ExerciseSetAdapter());
  final database = await Hive.openBox<Workout>('workout_database'); // Creates if missing
  final appState = AppState.fromHiveBox(database);
  runApp(root(appState));
}

// ----- Root (The main Widget)-----

Widget root(AppState appState) => ValueListenableBuilder<Map<Date, Workout>>(
  valueListenable: appState.workoutsNotifier,
  builder: (_, __, ___) => buildApp(appState), //this function is called whenever appState.workouts changes
);

// ----- App -----

//This is rebuilt by root whenever appState.workouts changes
Widget buildApp(AppState appState) => MaterialApp(
  title: 'Functional Workout App',
  home: buildHome(appState),
  routes: MyRouter.routes,
  onGenerateRoute: MyRouter.onGenerateRoute,
);