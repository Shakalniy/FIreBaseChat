import 'package:chat/app_exports.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text(
                  "Что-то пошло не так",
                  style: TextStyle(
                    fontFamily: 'RobotoSlab',
                    fontSize: 24
                  ),
                ),
              ),
            );
          }
          else if (snapshot.hasData) {
            return const HomePage();
          }
          // user is NOT logged
          return const LoginOrRegister();
        },
      ),
    );
  }

}