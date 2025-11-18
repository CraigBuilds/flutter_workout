import 'package:flutter/material.dart';
import 'backend.dart';
import 'pages/home_page.dart';
import 'my_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState(ValueNotifier<Map<Date, Workout>>({}));
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