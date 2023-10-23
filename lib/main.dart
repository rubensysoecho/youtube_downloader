import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Youtube Downloader',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  void userTapped() {
    print('Clickado');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Youtube Downloader'),
        leading: Icon(Icons.menu),
      ),
      body: Center(
        child: GestureDetector(
          onTap: userTapped,
          child: Container(
            height: 300,
            width: 300,
            color: Colors.blueAccent,
            child: Center(child: Text('Haz click aqui')),
          ),
        ),
      )
    );
    // Column is also a layout widget. It takes a list of children and
  }
}
