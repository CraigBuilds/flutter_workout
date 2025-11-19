import 'package:flutter/material.dart';
import '../backend/models.dart';
import '../backend/crud.dart' as crud;
import '../backend/app_state.dart';

// This view allows the user to add sets to this exercise (for today's workout), and also view historical data.
Widget buildSetLoggingPage(BuildContext context, AppState appState, Exercise selectedExercise) => DefaultTabController(
  length: 2,
  child: Scaffold(
    appBar: _buildAppBar(context, selectedExercise),
    body: TabBarView(
      children: [
        _buildTrackTab(context, appState, selectedExercise),
        _buildHistoryTab(context, appState, selectedExercise),
      ],
    ),
  ),
);

// ---------- AppBar ----------

PreferredSizeWidget _buildAppBar(BuildContext context, Exercise selectedExercise) => AppBar(
  title: Text('${selectedExercise.name} ${selectedExercise.parent.date.toString()}'),
  leading: IconButton(
    icon: const Icon(Icons.home),
    onPressed: () {
      Navigator.of(context).popUntil((route) => route.isFirst);
    },
  ),
  bottom: const TabBar(
    tabs: [
      Tab(text: 'Track'),
      Tab(text: 'History'),
    ],
  ),
);

// ---------- Track tab ----------

Widget _buildTrackTab(BuildContext context, AppState appState, Exercise selectedExercise) => Column(
  children: [
    Expanded(
      child: ListView.builder(
        itemCount: selectedExercise.sets.length,
        itemBuilder: (context, index) {
          final set = selectedExercise.sets[index];
          return buildExerciseSetTile(context, appState, set);
        },
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add Set'),
        onPressed: () => openAddNewSetDialog(context, appState, selectedExercise),
      ),
    ),
  ],
);

// ---------- History tab ----------

Widget _buildHistoryTab(BuildContext contexts, AppState appState, Exercise selectedExercise) => ListView.builder(
  itemCount: getHistoricalSets(appState, selectedExercise).length,
  itemBuilder: (context, index) {
    final set = getHistoricalSets(appState, selectedExercise)[index];
    return buildExerciseSetTile(context, appState, set, showDate: true);
  },
);

//get all sets of a particular exercise. Including this workout, past workouts, and future workouts.
List<ExerciseSet> getHistoricalSets(AppState appState, Exercise selectedExercise) => [
  for (final workout in appState.workouts.values)
    for (final exercise in workout.exercises)
      if (exercise.name == selectedExercise.name)
        ...exercise.sets,
];

// ---------- Dialogs ----------

Future openSetDialog({
  required BuildContext context,
  required AppState appState,
  required String title,
  required String initialReps,
  required String initialWeight,
  required void Function(int reps, double weight) onSubmit,
}) =>
    showDialog(
      context: context,
      builder: (context) {
        final repsController = TextEditingController(text: initialReps);
        final weightController = TextEditingController(text: initialWeight);

        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
              ),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reps = int.tryParse(repsController.text) ?? 0;
                final weight = double.tryParse(weightController.text) ?? 0.0;
                onSubmit(reps, weight);
                Navigator.of(context).pop();
              },
              child: Text(title == 'Add New Set' ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );

Future openEditSetDialog(BuildContext context, AppState appState, ExerciseSet set) => openSetDialog(
  context: context,
  appState: appState,
  title: 'Edit Set',
  initialReps: set.reps.toString(),
  initialWeight: set.weight.toString(),
  onSubmit: (reps, weight) {
    crud.updateSetInExercise(
      appState,
      set.parent.parent.date,
      set.parent.name,
      set.parent.sets.indexOf(set),
      ExerciseSet(reps: reps, weight: weight, date: set.parent.date, exerciseName: set.parent.name),
    );
  },
);

Future openAddNewSetDialog(BuildContext context, AppState appState, Exercise selectedExercise) => openSetDialog(
  context: context,
  appState: appState,
  title: 'Add New Set',
  initialReps: '',
  initialWeight: '',
  onSubmit: (reps, weight) {
    crud.createSetInExercise(
      appState,
      selectedExercise.parent.date,
      selectedExercise.name,
      ExerciseSet(reps: reps, weight: weight, date: selectedExercise.parent.date, exerciseName: selectedExercise.name),
    );
  },
);


// ---------- Shared UI helpers ----------

Widget buildExerciseSetTile(BuildContext context, AppState appState, ExerciseSet set, {bool showDate = false}) => Card(
  child: ListTile(
    title: showDate ? Text('Set ${set.parent.sets.indexOf(set) + 1} on ${set.parent.parent.date}') : Text('Set ${set.parent.sets.indexOf(set) + 1}'),
    subtitle: Text('${set.reps} reps @ ${set.weight} kg'),
    onTap: () {
      openEditSetDialog(context, appState, set);
    },
  ),
);
