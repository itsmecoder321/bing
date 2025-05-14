import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Search App',
      home: AutoSearchScreen(),
    );
  }
}

class AutoSearchScreen extends StatefulWidget {
  @override
  _AutoSearchScreenState createState() => _AutoSearchScreenState();
}

class _AutoSearchScreenState extends State<AutoSearchScreen> {
  List<String> questions = [];
  int currentIndex = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final String fileContent = await rootBundle.loadString('assets/Questions.txt');
    final List<String> lines = fileContent.split('\n').map((e) => e.trim()).toList();
    setState(() {
      questions = lines.where((line) => line.isNotEmpty).toList();
      questions.shuffle();
    });
  }

  void searchQuestion(String query) async {
    final Uri url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void nextQuestion() {
    setState(() {
      if (currentIndex < questions.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0; // Restart if at end
        questions.shuffle();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Auto Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Question ${currentIndex + 1} of ${questions.length}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              question,
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                searchQuestion(question);
                Future.delayed(Duration(seconds: 5), nextQuestion); // Auto-advance after 5 seconds
              },
              child: Text("Search on Google"),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
