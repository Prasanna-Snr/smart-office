import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'providers/office_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAGvq6cW8OMDiWIC1TnQFB96NucnBVX5xA",
      appId: "1:182108935411:android:749f54b3c71d4a8ceb5386",
      messagingSenderId: "182108935411",
      projectId: "iotproject-403ba",
      databaseURL: "https://iotproject-403ba-default-rtdb.firebaseio.com",
      storageBucket: "iotproject-403ba.firebasestorage.app",
    ),
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => OfficeProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Office',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
