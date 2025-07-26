import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/navigation_wrapper.dart';
import 'screens/login_screen.dart';

class JobLinkApp extends StatelessWidget {
  const JobLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthGate(),
      routes: {
        '/home': (context) => const NavigationWrapper(), // Worker view
        '/employer-dashboard': (context) =>
            const NavigationWrapper(), // Employer view
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> _getUserRole(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      return doc.data()?['role'] ?? 'worker';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // Logged in: determine role
        final user = snapshot.data!;
        return FutureBuilder<String?>(
          future: _getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;

            if (role == 'employer') {
              return const NavigationWrapper(); // Employer dashboard can be inside wrapper
            } else if (role == 'worker') {
              return const NavigationWrapper(); // Worker flow
            } else {
              return const Scaffold(
                body: Center(child: Text("User role not set or unknown.")),
              );
            }
          },
        );
      },
    );
  }
}
