import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchAppliedJobs(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('appliedJobs')
        .orderBy('appliedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No user is currently logged in",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final uid = user.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Info
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    "Error loading profile: ${snapshot.error}",
                    style: const TextStyle(color: Colors.redAccent),
                  );
                }

                final userData = snapshot.data?.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return const Text(
                    "User data is missing.",
                    style: TextStyle(color: Colors.white),
                  );
                }

                return Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.person, size: 50, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Name: ${userData['fullName'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${userData['email'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await AuthService().signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Logout'),
                    ),
                    const Divider(color: Colors.white30, height: 40),
                  ],
                );
              },
            ),

            // Applied Jobs Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Applied Jobs",
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchAppliedJobs(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    "Error loading applied jobs: ${snapshot.error}",
                    style: const TextStyle(color: Colors.redAccent),
                  );
                }

                final jobs = snapshot.data ?? [];

                if (jobs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "You haven’t applied for any jobs yet.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          job['title'] ?? 'Untitled Job',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${job['location'] ?? 'Unknown Location'} • ${job['wage'] ?? 'N/A'}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
