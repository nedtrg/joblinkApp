import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../models/job.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedLocation = 'All';

  List<String> _locations = ['All']; // Populated dynamically

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Available Jobs'),
        backgroundColor: Colors.black,
        foregroundColor: Color(0xFFFFD700),
        elevation: 0,
      ),
      body: StreamBuilder<List<Job>>(
        stream: JobService().getJobs(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Job> jobs = snapshot.data!;

            // Extract unique locations for dropdown
            _locations = ['All'];
            _locations.addAll({...jobs.map((job) => job.location).toSet()});

            // Apply filters
            final filteredJobs = jobs.where((job) {
              final matchesQuery = job.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
              final matchesLocation =
                  _selectedLocation == 'All' ||
                  job.location == _selectedLocation;
              return matchesQuery && matchesLocation;
            }).toList();

            return Column(
              children: [
                // Search bar & filter dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search jobs...',
                          hintStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        dropdownColor: Colors.grey[900],
                        iconEnabledColor: Color(0xFFFFD700),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[900],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: _locations.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedLocation = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Job grid
                Expanded(
                  child: filteredJobs.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching jobs found.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 3 / 2,
                              ),
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) {
                            return JobCard(
                              job: filteredJobs[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JobDetailScreen(
                                      job: filteredJobs[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading jobs.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD700)),
          );
        },
      ),
    );
  }
}
