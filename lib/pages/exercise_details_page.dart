import 'package:flutter/material.dart';
import '../backend.dart';
import '../my_router.dart';

// This view allows the user to add sets to this exercise (for today's workout), and also view historical data.
Widget buildExerciseDetailsPage(RouteArgs args) {
  final exercise = args.workout.exercises.firstWhere((e) => e.name == args.exerciseName);

  return DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: Text('Exercise Details for ${args.exerciseName} in ${args.workout.date}'),
        bottom: TabBar(
          tabs: [
            Tab(text: 'Track'),
            Tab(text: 'History'),
          ],
        ),
        leading: Builder (builder: (context) => 
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        )
      ),
      body: TabBarView(
        children: [
          // Track Tab: Add/view sets for this workout
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: exercise.sets.length,
                  itemBuilder: (context, index) {
                    final set = exercise.sets[index];
                    return buildExerciseSetTile(index, set, null);
                  },
                ),
              ),
              Builder(
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Add Set'),
                      onPressed: () {
                        openNewSetDialog(context, args);
                      },
                    )
                  );
                }
              )
            ],
          ),
          // History Tab: Show all sets for this exercise across all workouts
          Builder(
            builder: (context) {
              final allSets = args.appState.workouts.values
                  .where((workout) => workout.exercises.any((ex) => ex.name == args.exerciseName))
                  .expand((workout) {
                    final exercise = workout.exercises.firstWhere((ex) => ex.name == args.exerciseName);
                    return exercise.sets.map((set) => MapEntry(set, workout.date));
                  })
                  .toList();

              if (allSets.isEmpty) {
                return Center(child: Text('No historical sets found.'));
              }

              return ListView.builder(
                itemCount: allSets.length,
                itemBuilder: (context, index) {
                  final entry = allSets[index];
                  final set = entry.key;
                  final date = entry.value;
                  return buildExerciseSetTile(index, set, date);
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}

void openNewSetDialog(BuildContext context, RouteArgs args) {
  final repsController = TextEditingController();
  final weightController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add New Set'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: repsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Reps'),
          ),
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Weight (kg)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final reps = int.tryParse(repsController.text) ?? 0;
            final weight = double.tryParse(weightController.text) ?? 0.0;

            createSetInExercise(
              args.appState,
              args.workout.date,
              args.exerciseName,
              ExerciseSet(reps: reps, weight: weight),
            );

            Navigator.of(context).pop();
          },
          child: Text('Add Set'),
        ),
      ],
    ),
  );
}

void openEditSetDialog() {

}

Widget buildExerciseSetTile(int index, ExerciseSet set, Date? date) => Card(
  child: ExpansionTile(
    title: date != null ? Text(date.toString()) : Text('Set ${index + 1}'),
    subtitle: Text('${set.reps} reps @ ${set.weight} kg'), //todo add some icons to show extra info, e.g that partials were done. It does not need details here.
    //details
    children: [
      ElevatedButton(
        child: Text('Edit Set'),
        onPressed: () {
          openEditSetDialog();
        },
      ),
      ListTile(
        title: Text('Reps'),
        subtitle: Text('${set.reps}'),
      ),
      ListTile(
        title: Text('Weight'),
        subtitle: Text('${set.weight} kg'),
      ),
      ListTile(
        title: Text('RIR'),
        subtitle: Text('3'),
      ),
      ListTile(
        title: Text('Partial reps (50%)'),
        subtitle: Text('0'),
      ),
      ListTile(
        title: Text('Partial reps (25%)'),
        subtitle: Text('0'),
      ),
      ListTile(
        title: Text('Drop reps (Drop 1)'),
        subtitle: Text('0 reps at 0kg'),
      ),
      ListTile(
        title: Text('Drop reps (Drop 2)'),
        subtitle: Text('0 reps at 0kg'),
      ),
      ListTile(
        title: Text('Drop reps (Drop 3)'),
        subtitle: Text('0 reps at 0kg'),
      ),
      ListTile(
        title: Text('Cheat reps'),
        subtitle: Text('0'),
      ),
      ListTile(
        title: Text('Myo reps'),
        subtitle: Text('0'),
      ),
      ListTile(
        title: Text('Overload Score'),
        subtitle: Text('0'),
      ),
    ],
  ),
);

