import 'package:flutter/material.dart';
import 'models.dart';
import '../pages/about_page.dart';
import '../pages/exercise_selector_page.dart';
import '../pages/set_logging_page.dart';
import 'app_state.dart';

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

class MyRouter {
  static Map<String, Widget Function(BuildContext)> routes = {
    '/about': (_) => buildAboutPage(),
  };

  static Route<dynamic>? Function(RouteSettings)? onGenerateRoute =
  (settings) {
      final RouteArgs args = settings.arguments as RouteArgs;
      switch (settings.name) {
        case '/exercise_selector':
          return MaterialPageRoute(
            builder: (_) => buildExerciseSelectorPage(args),
          );
        case '/set_logging':
          return MaterialPageRoute(
            builder: (_) => buildSetLoggingPage(args),
          );
      }
      return null;
    };
}
