import 'package:flutter/material.dart';
import '../backend/app_state.dart';
import '../backend/crud.dart' as crud;

Widget buildSettingsPage(BuildContext context, AppState appState) => Scaffold(
  body: buildSettingsBody(context, appState),
  appBar: buildAppBar(),
);

PreferredSizeWidget buildAppBar() => AppBar(
  title: Text('Settings'),
);

Widget buildSettingsBody(BuildContext context, AppState appState) => ListView(
  children: [
    ListTile(
      leading: Icon(Icons.person),
      title: Text('Account'),
      onTap: () {},
    ),
    ListTile(
      leading: Icon(Icons.notifications),
      title: Text('Notifications'),
      onTap: () {},
    ),
    ListTile(
      leading: Icon(Icons.palette),
      title: Text('Theme'),
      onTap: () {},
    ),
    ListTile(
      leading: Icon(Icons.delete_forever, color: Colors.red),
      title: Text('Delete all data', style: TextStyle(color: Colors.red)),
      onTap: () {
        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete All Data'),
            content: Text('Are you sure you want to delete all data? This action cannot be undone.'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  crud.deleteAllData(appState);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    ),
  ],
);