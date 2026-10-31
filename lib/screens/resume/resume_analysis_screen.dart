import 'package:flutter/material.dart';
import '../../models/resume.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';

class ResumeAnalysisScreen extends StatelessWidget {
  final Resume resume;

  const ResumeAnalysisScreen({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resumeAnalysis),
        backgroundColor: AppColors.accent,
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent.withValues(alpha: 0.1),
                      AppColors.accent.withValues(alpha: 0.05),
                    ],
                  ),
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
                              color: AppColors.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.accent,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resume.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  resume.qualification,
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
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Education
            _buildSection('Education', [
              _buildInfoRow(
                Icons.school,
                'Qualification',
                resume.qualification,
              ),
              _buildInfoRow(Icons.menu_book, 'Degree', resume.degree),
              _buildInfoRow(Icons.category, 'Branch', resume.branch),
              _buildInfoRow(
                Icons.calendar_today,
                'Graduation Year',
                resume.graduationYear,
              ),
            ]),
            const SizedBox(height: 20),

            // Experience
            _buildSection('Experience', [
              _buildInfoRow(Icons.work, 'Experience Level', resume.experience),
            ]),
            const SizedBox(height: 20),

            // Technical Skills
            _buildSection('Technical Skills', [
              if (resume.technicalSkills.isEmpty)
                Text(
                  'No technical skills found',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: resume.technicalSkills.map((skill) {
                    return Chip(
                      label: Text(skill),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      labelStyle: TextStyle(color: AppColors.primary),
                    );
                  }).toList(),
                ),
            ]),
            const SizedBox(height: 20),

            // Soft Skills
            _buildSection('Soft Skills', [
              if (resume.softSkills.isEmpty)
                Text(
                  'No soft skills found',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: resume.softSkills.map((skill) {
                    return Chip(
                      label: Text(skill),
                      backgroundColor: AppColors.secondary.withValues(
                        alpha: 0.1,
                      ),
                      labelStyle: TextStyle(color: AppColors.secondary),
                    );
                  }).toList(),
                ),
            ]),
            const SizedBox(height: 20),

            // Certifications
            if (resume.certifications.isNotEmpty) ...[
              _buildSection('Certifications', [
                ...resume.certifications.map(
                  (cert) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cert,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
            ],

            // Projects
            if (resume.projects.isNotEmpty) ...[
              _buildSection('Projects', [
                ...resume.projects.map(
                  (project) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.folder_open,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            project,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
            ],

            // Analysis Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.accent),
                        const SizedBox(width: 8),
                        const Text(
                          'Analysis Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.upload_file,
                      'Uploaded At',
                      Helpers.formatDateTime(resume.uploadedAt),
                    ),
                    _buildInfoRow(
                      Icons.analytics,
                      'Analyzed At',
                      Helpers.formatDateTime(resume.analyzedAt),
                    ),
                    _buildInfoRow(
                      Icons.description,
                      'File Type',
                      resume.fileType.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            CustomButton(
              text: 'View Recommended Jobs',
              onPressed: () {
                Navigator.pop(context);
                // Navigate to recommended jobs
              },
              backgroundColor: AppColors.accent,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
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
}
