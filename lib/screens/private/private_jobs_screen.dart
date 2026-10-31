import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';
import '../../widgets/job_card.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/saved_job.dart';
import 'private_job_details.dart';

class PrivateJobsScreen extends StatefulWidget {
  const PrivateJobsScreen({super.key});

  @override
  State<PrivateJobsScreen> createState() => _PrivateJobsScreenState();
}

class _PrivateJobsScreenState extends State<PrivateJobsScreen> {
  final _jobService = JobService();
  final _authService = AuthService();
  final _database = DatabaseService();
  final _searchController = TextEditingController();
  List<dynamic> _jobs = [];
  List<dynamic> _filteredJobs = [];
  bool _isLoading = true;
  String _selectedCompany = 'All';
  String _selectedLocation = 'All';
  String _selectedExperience = 'All';

  final List<String> _companies = [
    'All',
    'TCS',
    'Infosys',
    'Wipro',
    'Accenture',
    'Deloitte',
  ];

  final List<String> _locations = [
    'All',
    'Bangalore',
    'Hyderabad',
    'Pune',
    'Mumbai',
    'Delhi',
  ];

  final List<String> _experiences = [
    'All',
    'Fresher',
    '0-2 years',
    '2-3 years',
    '3-5 years',
    '5+ years',
  ];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
    });

    final jobs = await _jobService.getPrivateJobs();
    
    setState(() {
      _jobs = jobs;
      _filteredJobs = jobs;
      _isLoading = false;
    });
  }

  void _filterJobs() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredJobs = _jobs.where((job) {
        final matchesSearch = query.isEmpty ||
            job.jobRole.toLowerCase().contains(query) ||
            job.companyName.toLowerCase().contains(query);
        
        final matchesCompany = _selectedCompany == 'All' ||
            job.companyName.contains(_selectedCompany);
        
        final matchesLocation = _selectedLocation == 'All' ||
            job.location.contains(_selectedLocation);
        
        final matchesExperience = _selectedExperience == 'All' ||
            job.experience.contains(_selectedExperience);
        
        return matchesSearch && matchesCompany && matchesLocation && matchesExperience;
      }).toList();
    });
  }

  Future<void> _applyToJob(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  Future<void> _saveJob(String jobId, String jobTitle, String companyName) async {
    final studentId = _authService.currentUser?.id;
    if (studentId == null) return;

    final savedJob = SavedJob(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: studentId,
      jobId: jobId,
      jobType: 'private',
      jobTitle: jobTitle,
      companyOrOrganization: companyName,
      location: 'Bangalore',
      deadline: DateTime.now().add(const Duration(days: 15)),
      savedAt: DateTime.now(),
    );

    await _database.saveJob(savedJob);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.privateJobs),
        backgroundColor: AppColors.secondary,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search private jobs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterJobs();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: (value) => _filterJobs(),
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCompany,
                      decoration: InputDecoration(
                        labelText: 'Company',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _companies.map((company) {
                        return DropdownMenuItem(
                          value: company,
                          child: Text(company, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCompany = value ?? 'All';
                        });
                        _filterJobs();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedLocation,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _locations.map((location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLocation = value ?? 'All';
                        });
                        _filterJobs();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedExperience,
                      decoration: InputDecoration(
                        labelText: 'Experience',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _experiences.map((exp) {
                        return DropdownMenuItem(
                          value: exp,
                          child: Text(exp),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExperience = value ?? 'All';
                        });
                        _filterJobs();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Job List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredJobs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No private jobs found',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = _filteredJobs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: JobCard(
                              job: job,
                              jobType: 'private',
                              onSave: () => _saveJob(job.id, job.jobRole, job.companyName),
                              onApply: () => _applyToJob(job.officialApplicationLink),
                              onViewDetails: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PrivateJobDetails(job: job),
                                  ),
                                );
                              },
                              isSaved: false,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
