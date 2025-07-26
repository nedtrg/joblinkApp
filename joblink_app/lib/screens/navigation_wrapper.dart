import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'post_job_screen.dart';
import 'profile_screen.dart';
import 'employer_home_screen.dart';
import 'home_screen.dart'; // Worker job list

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final role = await AuthService().getUserRole();
      setState(() {
        _userRole = role;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
        ),
      );
    }

    if (_userRole == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Unable to determine user role",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Screens & FAB logic based on role
    final isEmployer = _userRole == 'employer';

    final List<Widget> screens = isEmployer
        ? [const EmployerHomeScreen(), const ProfileScreen()]
        : [const HomeScreen(), const ProfileScreen()];

    return Scaffold(
      backgroundColor: Colors.black,
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white70,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),

      // Show FAB only for employer
      floatingActionButton: isEmployer
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostJobScreen()),
                );
              },
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              tooltip: 'Post a Job',
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
