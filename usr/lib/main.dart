import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/kmeans_screen.dart';
import 'screens/linear_regression_screen.dart';

void main() {
  runApp(const MLVisualizerApp());
}

class MLVisualizerApp extends StatelessWidget {
  const MLVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Visualizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/kmeans': (context) => const KMeansScreen(),
        '/linear_regression': (context) => const LinearRegressionScreen(),
      },
    );
  }
}
