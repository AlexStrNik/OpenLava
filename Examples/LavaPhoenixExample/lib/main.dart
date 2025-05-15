import 'package:flutter/material.dart';
import 'package:lava_phoenix/lava_controller.dart';
import 'package:lava_phoenix/lava_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LavaController controller = LavaController();

  @override
  void initState() {
    super.initState();
    controller
        .loadLavaAsset("assets/m13HomepageExperiencesTabInitialAnimationSelectedLavaAssets")
        .then((_) => controller.play());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 128,
          height: 128,
          child: LavaView(controller: controller),
        ),
      ),
    );
  }
}
