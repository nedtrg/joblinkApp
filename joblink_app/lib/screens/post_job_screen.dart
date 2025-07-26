import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _wageController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _postJob() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = "User not authenticated.");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FirebaseFirestore.instance.collection('jobs').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'wage': _wageController.text.trim(),
        'postedBy': user.uid, // ✅ Employer UID
        'posterEmail': user.email, // ✅ Optional employer email
        'createdAt': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _wageController.clear();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          title: const Text("Success", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Job posted successfully.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFFD700),
              ),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _error = "Failed to post job: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Post a Job'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                _buildField(_titleController, "Job Title"),
                const SizedBox(height: 12),
                _buildField(
                  _descriptionController,
                  "Job Description",
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _buildField(_locationController, "Location"),
                const SizedBox(height: 12),
                _buildField(_wageController, "Wage (e.g. ₦5000/day)"),
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                    : ElevatedButton(
                        onPressed: _postJob,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text("Post Job"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFD700)),
        ),
      ),
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.trim().isEmpty ? '$label is required' : null,
    );
  }
}
