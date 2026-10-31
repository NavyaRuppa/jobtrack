import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/private_job.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';

class PrivateJobDetails extends StatelessWidget {
  final PrivateJob job;

  const PrivateJobDetails({super.key, required this.job});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _apply(BuildContext context) async {
    final studentId = AuthService().currentUser?.id;
    if (studentId == null) return;
    final saved = await JobService().applyForJob(
      studentId: studentId,
      jobId: job.id,
      jobType: 'private',
      jobTitle: job.jobRole,
      companyOrOrganization: job.companyName,
      applicationDeadline: job.applicationDeadline,
    );
    if (!context.mounted) return;
    if (saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application recorded')));
    }
    await _launchUrl(job.officialApplicationLink);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.business,
                            color: AppColors.secondary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.jobRole,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                job.companyName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoChip(Icons.work_outline, job.jobType),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.location_on_outlined,
                          job.location,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Job Information
            _buildSection('Job Information', [
              _buildInfoRow(
                Icons.school_outlined,
                'Qualification',
                job.educationalQualification,
              ),
              _buildInfoRow(Icons.work_outline, 'Experience', job.experience),
              _buildInfoRow(Icons.attach_money_outlined, 'Salary', job.salary),
            ]),
            const SizedBox(height: 20),

            // Important Dates
            _buildSection('Important Dates', [
              _buildInfoRow(
                Icons.event_busy_outlined,
                'Application Deadline',
                Helpers.formatDate(job.applicationDeadline),
              ),
            ]),
            const SizedBox(height: 20),

            // Job Description
            _buildSection('Job Description', [
              _buildTextSection('Description', job.jobDescription),
            ]),
            const SizedBox(height: 20),

            // Technical Skills
            _buildSection('Technical Skills', [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.technicalSkills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(color: AppColors.secondary),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 20),

            // Soft Skills
            _buildSection('Soft Skills', [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.softSkills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(color: AppColors.primary),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 20),

            // Official Links
            _buildSection('Apply Now', [
              _buildLinkRow(
                Icons.launch_outlined,
                'Official Application Link',
                job.officialApplicationLink,
              ),
            ]),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Apply Now',
                    onPressed: () => _apply(context),
                    backgroundColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(IconData icon, String label, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Icon(Icons.open_in_new, size: 16, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
