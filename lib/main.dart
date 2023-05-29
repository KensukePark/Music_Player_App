import 'package:flutter/material.dart';
import '../Screens/all_songs_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music player',
      debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: AllSongs(),
    );
  }
}