import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final student = _authService.currentStudent;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        backgroundColor: AppColors.textSecondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
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
                      AppColors.textSecondary.withValues(alpha: 0.1),
                      AppColors.textSecondary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.textSecondary,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        student?.fullName ?? 'Student Name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        student?.email ?? 'student@email.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              Icons.phone,
              'Mobile Number',
              student?.mobileNumber ?? 'Not provided',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              Icons.school,
              'Educational Qualification',
              student?.educationalQualification ?? 'Not provided',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              Icons.category,
              'Graduation Branch',
              student?.graduationBranch ?? 'Not provided',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              Icons.calendar_today,
              'Graduation Year',
              student?.graduationYear ?? 'Not provided',
            ),
            const SizedBox(height: 24),

            // Skills
            const Text(
              'Skills',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
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
                    if (student?.skills != null && student!.skills.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: student.skills.map((skill) {
                          return Chip(
                            label: Text(skill),
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            labelStyle: TextStyle(color: AppColors.primary),
                          );
                        }).toList(),
                      )
                    else
                      Text(
                        'No skills added yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Account Actions
            const Text(
              'Account Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              Icons.edit,
              AppStrings.editProfile,
              () => _showEditProfileDialog(),
            ),
            const SizedBox(height: 12),
            _buildActionCard(Icons.psychology, AppStrings.updateSkills, () {
              _showSkillsDialog();
            }),
            const SizedBox(height: 12),
            _buildActionCard(Icons.lock, AppStrings.changePassword, () {
              _showChangePasswordDialog();
            }),
            const SizedBox(height: 12),
            _buildActionCard(Icons.logout, AppStrings.logout, () async {
              await _authService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            }, color: AppColors.error),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 24),
            ),
            const SizedBox(width: 16),
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
                  const SizedBox(height: 4),
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
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (color ?? AppColors.textSecondary).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color ?? AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: color ?? AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color ?? AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final student = _authService.currentStudent;
    if (student == null) return;

    final fullNameController = TextEditingController(text: student.fullName);
    final mobileNumberController = TextEditingController(
      text: student.mobileNumber,
    );
    final qualificationController = TextEditingController(
      text: student.educationalQualification,
    );
    final branchController = TextEditingController(
      text: student.graduationBranch,
    );
    final yearController = TextEditingController(text: student.graduationYear);
    final experienceController = TextEditingController(
      text: student.experience,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mobileNumberController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qualificationController,
                decoration: const InputDecoration(
                  labelText: 'Educational Qualification',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: branchController,
                decoration: const InputDecoration(
                  labelText: 'Graduation Branch',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(
                  labelText: 'Graduation Year',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(
                  labelText: 'Experience',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = await _authService.updateStudentProfile(
                fullName: fullNameController.text,
                mobileNumber: mobileNumberController.text,
                educationalQualification: qualificationController.text,
                graduationBranch: branchController.text,
                graduationYear: yearController.text,
                experience: experienceController.text,
              );

              if (updated && context.mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update profile'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSkillsDialog() {
    final student = _authService.currentStudent;
    if (student == null) return;
    final controller = TextEditingController(text: student.skills.join(', '));
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Skills'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Skills',
            hintText: 'Dart, Flutter, SQL',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final skills = controller.text
                  .split(',')
                  .map((skill) => skill.trim())
                  .where((skill) => skill.isNotEmpty)
                  .toList();
              final updated = await _authService.updateStudentProfile(
                fullName: student.fullName,
                mobileNumber: student.mobileNumber,
                educationalQualification: student.educationalQualification,
                graduationBranch: student.graduationBranch,
                graduationYear: student.graduationYear,
                experience: student.experience,
                skills: skills,
              );
              if (!context.mounted || !dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              if (updated) setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final email = _authService.currentUser?.email;
    if (email == null) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'A password reset link will be sent to your account email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final sent = await _authService.resetPassword(email: email);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    sent
                        ? 'Password reset link sent'
                        : 'Unable to send password reset link',
                  ),
                  backgroundColor: sent ? AppColors.success : AppColors.error,
                ),
              );
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }
}
