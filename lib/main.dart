import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:splitwise_pro/main_page.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb){
    final auth = FirebaseAuth.instanceFor(app: Firebase.app());
    auth.setPersistence(Persistence.LOCAL);
  }
  if (kIsWeb){
    final auth = FirebaseAuth.instanceFor(app: Firebase.app());
    auth.setPersistence(Persistence.LOCAL);
  }
  runApp(const MyApp());
}

var kColorScheme =
    ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 2, 69, 125));

var kDarkColorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 0, 46, 67),
    brightness: Brightness.dark
  
  );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
            backgroundColor: kDarkColorScheme.onPrimaryContainer,
            foregroundColor: kDarkColorScheme.onPrimary),
        textTheme: const TextTheme().copyWith(
          titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kDarkColorScheme.onPrimary),
        ),
      ),
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
            backgroundColor: kColorScheme.onPrimaryContainer,
            foregroundColor: kColorScheme.onPrimary),
        textTheme: const TextTheme().copyWith(
          titleLarge: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: kColorScheme.secondary),
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const MainPage(),
    );
  }
}
