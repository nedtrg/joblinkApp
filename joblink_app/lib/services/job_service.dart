import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';

class JobService {
  final CollectionReference _jobs = FirebaseFirestore.instance.collection(
    'jobs',
  );

  Stream<List<Job>> getJobs() {
    return _jobs.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Job.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }
}
