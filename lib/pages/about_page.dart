import 'package:flutter/material.dart';

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