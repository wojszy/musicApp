import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musicapp/model/player_model.dart';
import 'package:musicapp/screens/home_screen.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => PlayerModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              )),
      home: const HomeScreen(),
      getPages: [
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
    );
  }
}
