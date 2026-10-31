import 'package:flutter/material.dart';
import '../models/job_match.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class MatchScoreCard extends StatelessWidget {
  final JobMatch match;

  const MatchScoreCard({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final color = Helpers.getMatchCategoryColor(match.matchCategory);
    final categoryLabel = Helpers.getMatchCategoryLabel(match.matchCategory);
    final categoryMessage = Helpers.getMatchCategoryMessage(match.matchScore);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
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
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(match.matchCategory),
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          categoryMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${match.matchScore}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (match.matchedSkills.isNotEmpty) ...[
                Text(
                  AppStrings.matchedSkills,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: match.matchedSkills.map((skill) {
                    return Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, size: 16, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(skill),
                        ],
                      ),
                      backgroundColor: AppColors.success.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(color: AppColors.success),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              if (match.missingSkills.isNotEmpty) ...[
                Text(
                  AppStrings.missingSkills,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: match.missingSkills.map((skill) {
                    return Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning, size: 16, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(skill),
                        ],
                      ),
                      backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(color: AppColors.warning),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          match.qualificationMatch ? Icons.check_circle : Icons.cancel,
                          color: match.qualificationMatch ? AppColors.success : AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          match.qualificationMatch ? 'Qualification matched' : 'Qualification not matched',
                          style: TextStyle(
                            color: match.qualificationMatch ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          match.experienceMatch ? Icons.check_circle : Icons.cancel,
                          color: match.experienceMatch ? AppColors.success : AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          match.experienceMatch ? 'Experience matched' : 'Experience not matched',
                          style: TextStyle(
                            color: match.experienceMatch ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'strong':
        return Icons.thumb_up;
      case 'partial':
        return Icons.remove_red_eye;
      case 'poor':
        return Icons.thumb_down;
      default:
        return Icons.info;
    }
  }
}
