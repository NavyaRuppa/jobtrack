import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/job_service.dart';
import '../../widgets/dashboard_card.dart';
import '../government/government_jobs_screen.dart';
import '../private/private_jobs_screen.dart';
import '../resume/resume_screen.dart';
import '../recommendations/recommended_jobs_screen.dart';
import '../saved/saved_jobs_screen.dart';
import '../applications/application_history_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _database = DatabaseService();
  final _jobService = JobService();
  int _recommendedCount = 0;
  int _savedCount = 0;
  int _applicationsCount = 0;
  int _matchScore = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final studentId = _authService.currentUser?.id;
    if (studentId == null) return;
    final results = await Future.wait([
      _jobService.getGovernmentJobs(),
      _jobService.getPrivateJobs(),
      _database.getSavedJobs(studentId),
      _database.getApplications(studentId),
    ]);
    if (!mounted) return;
    setState(() {
      _recommendedCount =
          (results[0] as List).length + (results[1] as List).length;
      _savedCount = (results[2] as List).length;
      _applicationsCount = (results[3] as List).length;
      _matchScore = _recommendedCount == 0 ? 0 : 100;
    });
  }

  void _showNotifications() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                title: Text('You are all caught up'),
                subtitle: Text(
                  'New job alerts and application updates will appear here.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = _authService.currentStudent;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    student?.fullName ?? 'Student',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: const Text(AppStrings.governmentJobs),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GovernmentJobsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text(AppStrings.privateJobs),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivateJobsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text(AppStrings.resumePortal),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResumeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text(AppStrings.recommendedJobs),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecommendedJobsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outlined),
              title: const Text(AppStrings.savedJobs),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedJobsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text(AppStrings.applicationHistory),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ApplicationHistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outlined),
              title: const Text(AppStrings.profile),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                AppStrings.logout,
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                await _authService.logout();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.welcome}, ${student?.fullName.split(' ').first ?? 'Student'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.welcomeMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  DashboardCard(
                    title: 'Recommended',
                    value: '$_recommendedCount',
                    icon: Icons.auto_awesome,
                    iconColor: AppColors.primaryDark,
                  ),
                  DashboardCard(
                    title: 'Saved Jobs',
                    value: '$_savedCount',
                    icon: Icons.bookmark,
                    iconColor: AppColors.success,
                  ),
                  DashboardCard(
                    title: 'Applications',
                    value: '$_applicationsCount',
                    icon: Icons.send,
                    iconColor: AppColors.warning,
                  ),
                  DashboardCard(
                    title: 'Profile Match',
                    value: '$_matchScore%',
                    icon: Icons.insights,
                    iconColor: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Modules
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildModuleCard(
                icon: Icons.account_balance,
                title: AppStrings.governmentJobs,
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GovernmentJobsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildModuleCard(
                icon: Icons.business,
                title: AppStrings.privateJobs,
                color: AppColors.secondary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivateJobsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildModuleCard(
                icon: Icons.description,
                title: AppStrings.resumePortal,
                color: AppColors.accent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResumeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildModuleCard(
                icon: Icons.auto_awesome,
                title: AppStrings.recommendedJobs,
                color: AppColors.primaryDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendedJobsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildModuleCard(
                icon: Icons.bookmark,
                title: AppStrings.savedJobs,
                color: AppColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedJobsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildModuleCard(
                icon: Icons.history,
                title: AppStrings.applicationHistory,
                color: AppColors.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ApplicationHistoryScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildModuleCard(
                icon: Icons.person,
                title: AppStrings.profile,
                color: AppColors.textSecondary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
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
}
