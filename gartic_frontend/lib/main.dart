//@ application entry point + global theme.
import 'package:flutter/material.dart';
import 'package:x/NameFirst.dart';
import 'package:x/theme/app_theme.dart';

void main() {
  runApp(const MyApps());
}

var singleValue;
var listOfName = [];

class MyApps extends StatelessWidget {
  const MyApps({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Name(),
    );
  }
}
