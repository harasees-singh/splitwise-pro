import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_pro/screens/auth/auth.dart';
import 'package:splitwise_pro/screens/auth/verify_email.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  bool _releaseLock = false;

  late Widget authScreen;
  late Widget verifyEmailScreen;

  void _releaseLockPostSuccessfulSignUp() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      _releaseLock = true;
    });
  }

  @override
  void initState() {
    super.initState();
    authScreen = AuthScreen(releaseLockPostSuccessfulSignUp: _releaseLockPostSuccessfulSignUp);
    verifyEmailScreen = const VerifyEmailScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && (FirebaseAuth.instance.currentUser!.emailVerified || _releaseLock)) {
            return verifyEmailScreen;
          }
          return authScreen;
        },
      ),
    );
  }
}
