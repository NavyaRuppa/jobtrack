import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/government_job.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../utils/url_validator.dart';

class GovernmentJobDetails extends StatelessWidget {
  final GovernmentJob job;

  const GovernmentJobDetails({super.key, required this.job});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final validation = UrlValidator.validateHttpUrl(
      url,
      fieldName: 'External link',
      required: false,
    );
    if (validation != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(validation)));
      }
      return;
    }
    final uri = Uri.tryParse(url.trim());
    if (uri == null ||
        !await canLaunchUrl(uri) ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open this external link.')),
        );
      }
    }
  }

  Future<void> _apply(BuildContext context) async {
    final studentId = AuthService().currentUser?.id;
    if (studentId == null) return;
    final saved = await JobService().applyForJob(
      studentId: studentId,
      jobId: job.id,
      jobType: 'government',
      jobTitle: job.jobTitle,
      companyOrOrganization: job.organization,
      applicationDeadline: job.applicationClosingDate,
    );
    if (!context.mounted) return;
    if (saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application recorded')));
    }
    if (job.applyOnlineUrl.isNotEmpty) {
      await _launchUrl(context, job.applyOnlineUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: AppColors.primary,
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
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.jobTitle,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                job.organization,
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
                        _buildInfoChip(Icons.work_outline, job.jobRole),
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
                Icons.people_outline,
                'Vacancies',
                '${job.vacancies}',
              ),
              _buildInfoRow(
                Icons.school_outlined,
                'Qualification',
                job.educationalQualification,
              ),
              _buildInfoRow(
                Icons.cake_outlined,
                'Age Limit',
                job.ageEligibility,
              ),
              _buildInfoRow(Icons.attach_money_outlined, 'Salary', job.salary),
            ]),
            const SizedBox(height: 20),

            // Important Dates
            _buildSection('Important Dates', [
              _buildInfoRow(
                Icons.event_available_outlined,
                'Application Start',
                Helpers.formatDate(job.applicationStartDate),
              ),
              _buildInfoRow(
                Icons.event_busy_outlined,
                'Last Date',
                Helpers.formatDate(job.applicationClosingDate),
              ),
            ]),
            const SizedBox(height: 20),

            // Job Description
            _buildSection('Job Description', [
              _buildTextSection('Role', job.jobRole),
              _buildTextSection('Responsibilities', job.responsibilities),
            ]),
            const SizedBox(height: 20),

            // Required Skills
            _buildSection('Required Skills', [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.requiredSkills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(color: AppColors.primary),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 20),

            // Selection Process
            _buildSection('Selection Process', [
              _buildTextSection('Process', job.selectionProcess),
              _buildTextSection('Examination Details', job.examinationDetails),
            ]),
            const SizedBox(height: 20),

            // Official Links
            if (job.officialNotificationUrl.isNotEmpty ||
                job.applyOnlineUrl.isNotEmpty)
              _buildSection('Official Links', [
                if (job.officialNotificationUrl.isNotEmpty)
                  _buildLinkRow(
                    context,
                    Icons.description_outlined,
                    'View Official Notification',
                    job.officialNotificationUrl,
                  ),
                if (job.applyOnlineUrl.isNotEmpty)
                  _buildLinkRow(
                    context,
                    Icons.launch_outlined,
                    'Apply Online',
                    job.applyOnlineUrl,
                  ),
              ]),
            if (job.officialNotificationUrl.isNotEmpty ||
                job.applyOnlineUrl.isNotEmpty)
              const SizedBox(height: 32),

            // Action Buttons
            if (job.applyOnlineUrl.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Apply Now',
                      onPressed: () => _apply(context),
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

  Widget _buildLinkRow(
    BuildContext context,
    IconData icon,
    String label,
    String url,
  ) {
    return InkWell(
      onTap: () => _launchUrl(context, url),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
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
