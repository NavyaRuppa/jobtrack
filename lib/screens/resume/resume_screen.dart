import 'dart:io';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import '../../services/resume_service.dart';
import '../../models/resume.dart';
import 'resume_analysis_screen.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  final _authService = AuthService();
  final _resumeService = ResumeService();
  File? _selectedFile;
  Resume? _existingResume;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingResume();
  }

  Future<void> _checkExistingResume() async {
    final studentId = _authService.currentUser?.id;
    if (studentId != null) {
      final resume = await _resumeService.getStudentResume(studentId);
      if (!mounted) return;
      setState(() => _existingResume = resume);
    }
  }

  Future<void> _deleteExistingResume() async {
    final resume = _existingResume;
    final studentId = _authService.currentUser?.id;
    if (resume == null || studentId == null) return;
    final deleted = await _resumeService.deleteResume(studentId, resume.filePath);
    if (!mounted) return;
    if (deleted) {
      setState(() => _existingResume = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume deleted successfully')),
      );
    }
  }

  Future<void> _pickResume() async {
    final file = await _resumeService.pickResume();
    if (file != null) {
      setState(() {
        _selectedFile = file;
      });
    }
  }

  Future<void> _uploadAndAnalyze() async {
    if (_selectedFile == null) return;

    final studentId = _authService.currentUser?.id;
    if (studentId == null) return;

    setState(() {
      _isUploading = true;
    });

    final resume = await _resumeService.analyzeResume(_selectedFile!, studentId);

    setState(() {
      _isUploading = false;
    });

    if (resume != null && mounted) {
      setState(() => _existingResume = resume);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResumeAnalysisScreen(resume: resume),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to analyze resume'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _useSampleResume() async {
    final studentId = _authService.currentUser?.id;
    if (studentId == null) return;

    setState(() {
      _isUploading = true;
    });

    final resume = await _resumeService.createSampleResume(studentId);

    setState(() {
      _isUploading = false;
    });

    if (resume != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResumeAnalysisScreen(resume: resume),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resumePortal),
        backgroundColor: AppColors.accent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              elevation: 3,
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
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Upload Your Resume',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Upload your resume to get personalized job recommendations based on your skills and qualifications.',
                                  style: TextStyle(
                                    fontSize: 14,
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
            const SizedBox(height: 24),

            if (_existingResume != null) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(_existingResume!.fileName),
                  subtitle: const Text('Saved resume'),
                  trailing: IconButton(
                    tooltip: 'Delete resume',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _deleteExistingResume,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Upload Section
            if (_selectedFile == null) ...[
              _buildUploadCard(),
              const SizedBox(height: 16),
              _buildSampleResumeCard(),
            ] else ...[
              _buildSelectedFileCard(),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Analyze Resume',
                onPressed: _uploadAndAnalyze,
                isLoading: _isUploading,
                backgroundColor: AppColors.accent,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedFile = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Choose Different File'),
              ),
            ],

            const SizedBox(height: 32),

            // How It Works
            const Text(
              'How It Works',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              icon: Icons.upload_file,
              title: 'Upload Resume',
              description: 'Upload your resume in PDF or DOC format',
            ),
            const SizedBox(height: 12),
            _buildStepCard(
              icon: Icons.analytics,
              title: 'Analyze Skills',
              description: 'We extract your skills, qualifications, and experience',
            ),
            const SizedBox(height: 12),
            _buildStepCard(
              icon: Icons.auto_awesome,
              title: 'Get Matched',
              description: 'Receive personalized job recommendations',
            ),
            const SizedBox(height: 12),
            _buildStepCard(
              icon: Icons.trending_up,
              title: 'Improve Profile',
              description: 'Identify skills to improve for better matches',
            ),

            const SizedBox(height: 32),

            // Supported Formats
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
                    const Text(
                      'Supported Formats',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildFormatChip('PDF'),
                        const SizedBox(width: 8),
                        _buildFormatChip('DOC'),
                        const SizedBox(width: 8),
                        _buildFormatChip('DOCX'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: _pickResume,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.primary.withValues(alpha: 0.05),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap to Upload Resume',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'PDF or DOC files only',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleResumeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: _useSampleResume,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.description,
                  color: AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Use Sample Resume',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try with a sample resume for demo',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFileCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description,
                color: AppColors.success,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resume Selected',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedFile?.path.split('/').last ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: AppColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatChip(String format) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        format,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
