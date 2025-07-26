import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/job.dart';

class EditJobScreen extends StatefulWidget {
  final Job job;

  const EditJobScreen({super.key, required this.job});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _wageController;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job.title);
    _descriptionController = TextEditingController(
      text: widget.job.description,
    );
    _locationController = TextEditingController(text: widget.job.location);
    _wageController = TextEditingController(text: widget.job.wage);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _wageController.dispose();
    super.dispose();
  }

  Future<void> _updateJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.job.id)
          .update({
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'location': _locationController.text.trim(),
            'wage': _wageController.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job updated successfully.")),
        );
      }
    } catch (e) {
      setState(() => _error = "Failed to update job: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Job'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
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
                      onPressed: _updateJob,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Update Job"),
                    ),
            ],
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
      maxLines: maxLines,
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
      validator: (value) =>
          value == null || value.trim().isEmpty ? '$label is required' : null,
    );
  }
}
