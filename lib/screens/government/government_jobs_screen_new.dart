import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../services/job_service.dart';
import '../../models/government_job.dart';
import 'government_job_details.dart';

class GovernmentJobsScreen extends StatefulWidget {
  const GovernmentJobsScreen({super.key});

  @override
  State<GovernmentJobsScreen> createState() => _GovernmentJobsScreenState();
}

class _GovernmentJobsScreenState extends State<GovernmentJobsScreen> {
  final _jobService = JobService();
  final _searchController = TextEditingController();

  List<GovernmentJob> _allJobs = [];
  List<GovernmentJob> _filteredJobs = [];
  bool _isLoading = true;

  String? _selectedOrganization;
  String? _selectedQualification;
  String? _selectedLocation;
  String _sortBy = 'deadline';

  List<String> _organizations = [];
  List<String> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    try {
      _allJobs = await _jobService.getGovernmentJobs();
      _organizations = await _jobService.getAllOrganizations();
      _locations = await _jobService.getAllLocations();
      _filteredJobs = _allJobs;
    } catch (_) {
    }
    setState(() => _isLoading = false);
  }

  void _filterAndSearch() {
    final query = _searchController.text.toLowerCase();

    _filteredJobs = _allJobs.where((job) {
      // Search filter
      final matchesSearch =
          query.isEmpty ||
          job.jobTitle.toLowerCase().contains(query) ||
          job.organization.toLowerCase().contains(query) ||
          job.jobRole.toLowerCase().contains(query);

      // Organization filter
      final matchesOrg =
          _selectedOrganization == null ||
          _selectedOrganization!.isEmpty ||
          job.organization == _selectedOrganization;

      // Qualification filter
      final matchesQual =
          _selectedQualification == null ||
          _selectedQualification!.isEmpty ||
          job.educationalQualification.contains(_selectedQualification!);

      // Location filter
      final matchesLoc =
          _selectedLocation == null ||
          _selectedLocation!.isEmpty ||
          job.location.contains(_selectedLocation!);

      return matchesSearch && matchesOrg && matchesQual && matchesLoc;
    }).toList();

    // Apply sorting
    if (_sortBy == 'deadline') {
      _filteredJobs.sort(
        (a, b) => a.applicationClosingDate.compareTo(b.applicationClosingDate),
      );
    } else if (_sortBy == 'newest') {
      _filteredJobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortBy == 'vacancies') {
      _filteredJobs.sort((a, b) => b.vacancies.compareTo(a.vacancies));
    }

    setState(() {});
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter Jobs',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Organization filter
              DropdownButtonFormField<String>(
                initialValue: _selectedOrganization,
                hint: const Text('Select Organization'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Organizations'),
                  ),
                  ..._organizations.map(
                    (org) =>
                        DropdownMenuItem<String>(value: org, child: Text(org)),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedOrganization = value);
                  Navigator.pop(context);
                  _filterAndSearch();
                },
                decoration: InputDecoration(
                  labelText: 'Organization',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Qualification filter
              TextField(
                onChanged: (value) {
                  _selectedQualification = value.isEmpty ? null : value;
                  _filterAndSearch();
                },
                decoration: InputDecoration(
                  labelText: 'Qualification',
                  hintText: 'e.g., B.Tech, M.Tech',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Location filter
              DropdownButtonFormField<String>(
                initialValue: _selectedLocation,
                hint: const Text('Select Location'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Locations'),
                  ),
                  ..._locations.map(
                    (loc) =>
                        DropdownMenuItem<String>(value: loc, child: Text(loc)),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedLocation = value);
                  Navigator.pop(context);
                  _filterAndSearch();
                },
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Sort
              DropdownButtonFormField<String>(
                initialValue: _sortBy,
                items: [
                  const DropdownMenuItem(
                    value: 'deadline',
                    child: Text('Sort by Deadline'),
                  ),
                  const DropdownMenuItem(
                    value: 'newest',
                    child: Text('Sort by Newest'),
                  ),
                  const DropdownMenuItem(
                    value: 'vacancies',
                    child: Text('Sort by Vacancies'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _sortBy = value);
                    Navigator.pop(context);
                    _filterAndSearch();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Sort By',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Clear filters
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedOrganization = null;
                    _selectedQualification = null;
                    _selectedLocation = null;
                    _sortBy = 'deadline';
                  });
                  Navigator.pop(context);
                  _filterAndSearch();
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Jobs'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _filterAndSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search jobs, organizations...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _showFilterPanel,
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Active Filters
          if (_selectedOrganization != null ||
              _selectedQualification != null ||
              _selectedLocation != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedOrganization != null)
                    Chip(
                      label: Text(_selectedOrganization!),
                      onDeleted: () {
                        setState(() => _selectedOrganization = null);
                        _filterAndSearch();
                      },
                    ),
                  if (_selectedQualification != null)
                    Chip(
                      label: Text(_selectedQualification!),
                      onDeleted: () {
                        setState(() => _selectedQualification = null);
                        _filterAndSearch();
                      },
                    ),
                  if (_selectedLocation != null)
                    Chip(
                      label: Text(_selectedLocation!),
                      onDeleted: () {
                        setState(() => _selectedLocation = null);
                        _filterAndSearch();
                      },
                    ),
                ],
              ),
            ),

          // Jobs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No jobs found',
                          style: TextStyle(
                            fontSize: 16,
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GovernmentJobDetails(job: job),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            job.jobTitle,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            job.organization,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Details
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _DetailRow(
                                            icon: Icons.location_on_outlined,
                                            label: job.location,
                                          ),
                                          const SizedBox(height: 8),
                                          _DetailRow(
                                            icon: Icons.school_outlined,
                                            label: job.educationalQualification,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _DetailRow(
                                            icon: Icons.people_outline,
                                            label:
                                                'Vacancies: ${job.vacancies}',
                                          ),
                                          const SizedBox(height: 8),
                                          _DetailRow(
                                            icon: Icons.currency_rupee,
                                            label: job.salary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Deadline
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Deadline: ${DateFormat('dd/MM/yyyy').format(job.applicationClosingDate)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
