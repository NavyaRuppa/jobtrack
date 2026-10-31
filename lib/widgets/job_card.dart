import 'package:flutter/material.dart';
import '../models/government_job.dart';
import '../models/private_job.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'custom_button.dart';

class JobCard extends StatelessWidget {
  final dynamic job; // GovernmentJob or PrivateJob
  final String jobType; // 'government' or 'private'
  final int? matchScore;
  final VoidCallback onSave;
  final VoidCallback onApply;
  final VoidCallback onViewDetails;
  final bool isSaved;

  const JobCard({
    super.key,
    required this.job,
    required this.jobType,
    this.matchScore,
    required this.onSave,
    required this.onApply,
    required this.onViewDetails,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    if (jobType == 'government') {
      return _buildGovernmentJobCard(context, job as GovernmentJob);
    } else {
      return _buildPrivateJobCard(context, job as PrivateJob);
    }
  }

  Widget _buildGovernmentJobCard(BuildContext context, GovernmentJob job) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.jobTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.organization,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (matchScore != null) _buildMatchScore(matchScore!),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.work_outline, job.jobRole),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.school_outlined, job.educationalQualification),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.attach_money_outlined, job.salary),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on_outlined, job.location),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today_outlined, 'Last Date: ${Helpers.formatDate(job.applicationClosingDate)}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppStrings.viewDetails,
                    onPressed: onViewDetails,
                    isOutlined: true,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onSave,
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: AppStrings.apply,
                    onPressed: onApply,
                    height: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateJobCard(BuildContext context, PrivateJob job) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.business,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.jobRole,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.companyName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (matchScore != null) _buildMatchScore(matchScore!),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.school_outlined, job.educationalQualification),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.work_outline, job.experience),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.attach_money_outlined, job.salary),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on_outlined, job.location),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.event_outlined, 'Deadline: ${Helpers.formatDate(job.applicationDeadline)}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.technicalSkills.take(3).map((skill) {
                return Chip(
                  label: Text(
                    skill,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(color: AppColors.primary),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppStrings.viewDetails,
                    onPressed: onViewDetails,
                    isOutlined: true,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onSave,
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: AppStrings.apply,
                    onPressed: onApply,
                    height: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchScore(int score) {
    final category = Helpers.getMatchCategory(score);
    final color = Helpers.getMatchCategoryColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$score%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.star,
            color: color,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
