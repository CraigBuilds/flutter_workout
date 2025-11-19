import 'package:flutter/material.dart';
import '../backend/models.dart';
import '../backend/my_router.dart';
import '../backend/crud.dart';
import '../backend/app_state.dart';

// This view allows the user to add sets to this exercise (for today's workout), and also view historical data.
Widget buildSetLoggingPage(RouteArgs args, BuildContext context) {
  final exercise = _findExercise(args);

  return Builder(
    builder: (context) => DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(context, args),
        body: TabBarView(
          children: [
            _buildTrackTab(context, args, exercise),
            _buildHistoryTab(context, args),
          ],
        ),
      ),
    ),
  );
}

// ---------- AppBar ----------

PreferredSizeWidget _buildAppBar(BuildContext context, RouteArgs args) {
  return AppBar(
    title: Text(
      'Exercise Details for ${args.exerciseName} in ${args.workout.date}',
    ),
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
}

// ---------- Track tab ----------

Widget _buildTrackTab(
  BuildContext context,
  RouteArgs args,
  Exercise exercise,
) {
  return Column(
    children: [
      Expanded(
        child: ListView.builder(
          itemCount: exercise.sets.length,
          itemBuilder: (context, index) {
            final set = exercise.sets[index];
            return buildExerciseSetTile(
              index: index,
              set: set,
              date: null,
              context: context,
              args: args,
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Set'),
          onPressed: () => openNewSetDialog(context, args),
        ),
      ),
    ],
  );
}

// ---------- History tab ----------

Widget _buildHistoryTab(BuildContext context, RouteArgs args) {
  final allSets = _collectHistoricalSets(
    appState: args.appState,
    exerciseName: args.exerciseName,
  );

  if (allSets.isEmpty) {
    return const Center(child: Text('No historical sets found.'));
  }

  return ListView.builder(
    itemCount: allSets.length,
    itemBuilder: (context, index) {
      final entry = allSets[index];
      return buildExerciseSetTile(
        index: index,
        set: entry.key,
        date: entry.value,
        context: context,
        args: args,
      );
    },
  );
}

// ---------- Dialogs ----------

Future<void> openNewSetDialog(BuildContext context, RouteArgs args) async {
  final repsController = TextEditingController();
  final weightController = TextEditingController();

  final newSet = await showDialog<ExerciseSet>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add New Set'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNumberField(
            controller: repsController,
            label: 'Reps',
          ),
          _buildNumberField(
            controller: weightController,
            label: 'Weight (kg)',
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

            Navigator.of(context).pop(
              ExerciseSet(reps: reps, weight: weight),
            );
          },
          child: const Text('Add Set'),
        ),
      ],
    ),
  );

  if (newSet == null) return;

  createSetInExercise(
    args.appState,
    args.workout.date,
    args.exerciseName,
    newSet,
  );
}

void openEditSetDialog(RouteArgs args, BuildContext context, int setIndex) {
  final exercise = _findExercise(args);
  final set = exercise.sets[setIndex];

  final repsController = TextEditingController(text: set.reps.toString());
  final weightController = TextEditingController(text: set.weight.toString());

  showDialog<ExerciseSet>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Set'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNumberField(
            controller: repsController,
            label: 'Reps',
          ),
          _buildNumberField(
            controller: weightController,
            label: 'Weight (kg)',
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
            final reps = int.tryParse(repsController.text) ?? set.reps;
            final weight = double.tryParse(weightController.text) ?? set.weight;

            Navigator.of(context).pop(
              ExerciseSet(reps: reps, weight: weight),
            );

            updateSetInExercise(
              args.appState,
              args.workout.date,
              args.exerciseName,
              setIndex,
              ExerciseSet(reps: reps, weight: weight),
            );
          },
          child: const Text('Save Changes'),
        ),
      ],
    ),
  );
}

// ---------- Shared UI helpers ----------

Widget buildExerciseSetTile({
  required int index,
  required ExerciseSet set,
  Date? date,
  required BuildContext context,
  required RouteArgs args,
}) {
  return Card(
    child: ExpansionTile(
      title: Text(
        date != null ? date.toString() : 'Set ${index + 1}',
      ),
      subtitle: Text('${set.reps} reps @ ${set.weight} kg'),
      children: [
        ElevatedButton(
          onPressed: () => openEditSetDialog(args, context, index),
          child: Text('Edit Set ${index + 1}'),
        ),
        ExpansionTile(
          title: const Text('Show Extra Details'),
          children: [
            const Divider(),
            _buildDetailTile('Reps', '${set.reps}'),
            _buildDetailTile('Weight', '${set.weight} kg'),
            _buildDetailTile('RIR', '3'),
            _buildDetailTile('Partial reps (50%)', '0'),
            _buildDetailTile('Partial reps (25%)', '0'),
            _buildDetailTile('Drop reps (Drop 1)', '0 reps at 0kg'),
            _buildDetailTile('Drop reps (Drop 2)', '0 reps at 0kg'),
            _buildDetailTile('Drop reps (Drop 3)', '0 reps at 0kg'),
            _buildDetailTile('Cheat reps', '0'),
            _buildDetailTile('Myo reps', '0'),
            _buildDetailTile('Overload Score', '0'),
          ],
        ),
      ],
    ),
  );
}

Widget _buildNumberField({
  required TextEditingController controller,
  required String label,
}) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(labelText: label),
  );
}

Widget _buildDetailTile(String title, String value) {
  return ListTile(
    title: Text(title),
    subtitle: Text(value),
  );
}

// ---------- Data helpers ----------

Exercise _findExercise(RouteArgs args) {
  return args.workout.exercises.firstWhere(
    (e) => e.name == args.exerciseName,
  );
}

List<MapEntry<ExerciseSet, Date>> _collectHistoricalSets({
  required AppState appState,
  required String exerciseName,
}) {
  return appState.workouts.values
      .where(
        (workout) => workout.exercises.any(
          (ex) => ex.name == exerciseName,
        ),
      )
      .expand((workout) {
        final exercise = workout.exercises.firstWhere(
          (ex) => ex.name == exerciseName,
        );
        return exercise.sets.map(
          (set) => MapEntry(set, workout.date),
        );
      })
      .toList();
}
