import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';
import '../../widgets/job_card.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/saved_job.dart';
import 'government_job_details.dart';

class GovernmentJobsScreen extends StatefulWidget {
  const GovernmentJobsScreen({super.key});

  @override
  State<GovernmentJobsScreen> createState() => _GovernmentJobsScreenState();
}

class _GovernmentJobsScreenState extends State<GovernmentJobsScreen> {
  final _jobService = JobService();
  final _authService = AuthService();
  final _database = DatabaseService();
  final _searchController = TextEditingController();
  List<dynamic> _jobs = [];
  List<dynamic> _filteredJobs = [];
  bool _isLoading = true;
  String _selectedOrganization = 'All';
  String _selectedQualification = 'All';

  final List<String> _organizations = [
    'All',
    'SSC',
    'UPSC',
    'SBI',
    'IBPS',
    'RRB',
  ];

  final List<String> _qualifications = [
    'All',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    '12th Pass',
    '10th Pass',
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

    final jobs = await _jobService.getGovernmentJobs();
    
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
            job.jobTitle.toLowerCase().contains(query) ||
            job.organization.toLowerCase().contains(query);
        
        final matchesOrganization = _selectedOrganization == 'All' ||
            job.organization.contains(_selectedOrganization);
        
        final matchesQualification = _selectedQualification == 'All' ||
            job.educationalQualification.contains(_selectedQualification);
        
        return matchesSearch && matchesOrganization && matchesQualification;
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

  Future<void> _saveJob(String jobId, String jobTitle, String organization) async {
    final studentId = _authService.currentUser?.id;
    if (studentId == null) return;

    final savedJob = SavedJob(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: studentId,
      jobId: jobId,
      jobType: 'government',
      jobTitle: jobTitle,
      companyOrOrganization: organization,
      location: 'All India',
      deadline: DateTime.now().add(const Duration(days: 30)),
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
        title: const Text(AppStrings.governmentJobs),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search government jobs...',
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
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedOrganization,
                    decoration: InputDecoration(
                      labelText: 'Organization',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: _organizations.map((org) {
                      return DropdownMenuItem(
                        value: org,
                        child: Text(org),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedOrganization = value ?? 'All';
                      });
                      _filterJobs();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedQualification,
                    decoration: InputDecoration(
                      labelText: 'Qualification',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: _qualifications.map((qual) {
                      return DropdownMenuItem(
                        value: qual,
                        child: Text(qual),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedQualification = value ?? 'All';
                      });
                      _filterJobs();
                    },
                  ),
                ),
              ],
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
                              'No government jobs found',
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
                              jobType: 'government',
                              onSave: () => _saveJob(job.id, job.jobTitle, job.organization),
                              onApply: () => _applyToJob(job.officialApplicationLink),
                              onViewDetails: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GovernmentJobDetails(job: job),
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
