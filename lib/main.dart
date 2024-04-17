import 'package:chat/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:provider/provider.dart';

import 'app_exports.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: const FirebaseOptions(
    //   apiKey: "AIzaSyC6OzpPly1oGbvYqCQ2uM8ZjCa5WcE8JBk",
    //   appId: "1:1053740152801:android:3c3f2069a069c008c084a0",
    //   messagingSenderId: "1053740152801",
    //   projectId: "chatapp-cb990"
    // ),
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    //const MyApp()
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    setHighRefresh();
  }

  Future<void> setHighRefresh() async {
    await FlutterDisplayMode.setHighRefreshRate();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      routes: {
        '/':(context) => const AuthGate(),
      },
      initialRoute: '/',
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
