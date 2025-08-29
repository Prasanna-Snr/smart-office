import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/auth_wrapper.dart';
import 'providers/office_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
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
    
    print('Firebase initialized successfully');
    
    // Initialize Firebase fields
    await FirebaseService.initializeFirebaseFields();
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => OfficeProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Office',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
        );
      },
    );
  }
}
