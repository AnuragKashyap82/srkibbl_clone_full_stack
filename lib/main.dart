import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:srkibbl/home_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAm1EQq8zNGJVSpCg7eDQxGaDYP_RXC-y0',
          appId: '1:735678527723:web:79be3b6d356e62529e66ae',
          messagingSenderId: '735678527723',
          projectId: 'srkibbl',
          storageBucket: 'srkibbl.appspot.com',
        )
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Srkibbl',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade200),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}