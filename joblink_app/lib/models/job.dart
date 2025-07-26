import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String location;
  final String wage;
  final String? postedBy; // Optional, useful for employer dashboard

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.wage,
    this.postedBy,
  });

  factory Job.fromMap(Map<String, dynamic> data, String documentId) {
    return Job(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      wage: data['wage'] ?? '',
      postedBy: data['postedBy'], // Optional
    );
  }

  factory Job.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      wage: data['wage'] ?? '',
      postedBy: data['postedBy'], // Optional
    );
  }
}
