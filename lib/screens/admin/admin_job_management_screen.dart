import 'package:flutter/material.dart';
import '../../models/government_job.dart';
import '../../models/private_job.dart';
import '../../services/job_service.dart';
import '../../utils/constants.dart';
import 'admin_job_form_screen.dart';

class AdminJobManagementScreen extends StatefulWidget {
  final bool government;

  const AdminJobManagementScreen({super.key, required this.government});

  @override
  State<AdminJobManagementScreen> createState() =>
      _AdminJobManagementScreenState();
}

class _AdminJobManagementScreenState extends State<AdminJobManagementScreen> {
  final _jobService = JobService();
  final _searchController = TextEditingController();
  late Future<List<dynamic>> _jobsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _jobsFuture = widget.government
        ? _jobService.getGovernmentJobs()
        : _jobService.getPrivateJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filtered(List<dynamic> jobs) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return jobs;
    return jobs.where((job) {
      final title = widget.government
          ? (job as GovernmentJob).jobTitle
          : (job as PrivateJob).jobRole;
      final organization = widget.government
          ? (job as GovernmentJob).organization
          : (job as PrivateJob).companyName;
      return '$title $organization ${job.location}'.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openForm([dynamic job]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminJobFormScreen(
          government: widget.government,
          governmentJob: widget.government && job != null ? job : null,
          privateJob: !widget.government && job != null ? job : null,
        ),
      ),
    );
    if (result == true && mounted) {
      setState(_refresh);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.government ? 'Government' : 'Private'} job saved successfully.')),
      );
    }
  }

  void _showDetails(dynamic job) {
    final title = widget.government
        ? (job as GovernmentJob).jobTitle
        : (job as PrivateJob).jobRole;
    final organization = widget.government
        ? (job as GovernmentJob).organization
        : (job as PrivateJob).companyName;
    final description = widget.government
        ? (job as GovernmentJob).responsibilities
        : (job as PrivateJob).jobDescription;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text('$organization\n${job.location}\n\n$description'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(dynamic job) async {
    final title = widget.government
        ? (job as GovernmentJob).jobTitle
        : (job as PrivateJob).jobRole;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete job?'),
        content: Text('This will permanently remove $title.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      if (widget.government) {
        await _jobService.deleteGovernmentJob(job.id);
      } else {
        await _jobService.deletePrivateJob(job.id);
      }
      if (!mounted) return;
      setState(_refresh);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job deleted')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to delete job: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.government ? 'Manage Government Jobs' : 'Manage Private Jobs',
        ),
        backgroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            tooltip: 'Add job',
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                labelText: 'Search jobs',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _jobsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Unable to load jobs: ${snapshot.error}'));
                }
                final jobs = _filtered(snapshot.data ?? const <dynamic>[]);
                if (jobs.isEmpty) {
                  return const Center(child: Text('No jobs found.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    final title = widget.government
                        ? (job as GovernmentJob).jobTitle
                        : (job as PrivateJob).jobRole;
                    final organization = widget.government
                        ? (job as GovernmentJob).organization
                        : (job as PrivateJob).companyName;
                    return Card(
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(organization),
                        onTap: () => _showDetails(job),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              tooltip: 'Edit job',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openForm(job),
                            ),
                            IconButton(
                              tooltip: 'Delete job',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => _delete(job),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
