import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../government/government_jobs_screen.dart';
import '../private/private_jobs_screen.dart';
import '../resume/resume_screen.dart';
import '../recommendations/recommended_jobs_screen.dart';
import '../saved/saved_jobs_screen.dart';
import '../applications/application_history_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';

class DashboardScreenComplete extends StatefulWidget {
  const DashboardScreenComplete({super.key});

  @override
  State<DashboardScreenComplete> createState() =>
      _DashboardScreenCompleteState();
}

class _DashboardScreenCompleteState extends State<DashboardScreenComplete> {
  final _authService = AuthService();
  final _dbService = DatabaseService();

  int _recommendedCount = 0;
  int _savedCount = 0;
  int _applicationsCount = 0;
  int _matchScore = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      if (_authService.currentStudent != null) {
        final applications = await _dbService.getApplications(
          _authService.currentStudent!.id,
        );
        final savedJobs = await _dbService.getSavedJobs(
          _authService.currentStudent!.id,
        );

        setState(() {
          _applicationsCount = applications.length;
          _savedCount = savedJobs.length;
          // These would come from actual data
          _recommendedCount = 5;
          _matchScore = 75;
        });
      }
    } catch (_) {
    }
    setState(() => _isLoading = false);
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = _authService.currentStudent;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Profile')),
              const PopupMenuItem(child: Text('Settings')),
              PopupMenuItem(onTap: _logout, child: const Text('Logout')),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    student?.fullName ?? 'Student',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    student?.email ?? 'student@jobtrack.com',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
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
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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

                  // Statistics Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard Statistics',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: isMobile ? 2 : 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            _StatCard(
                              icon: Icons.recommend_outlined,
                              label: 'Recommended',
                              value: _recommendedCount.toString(),
                              color: AppColors.primary,
                            ),
                            _StatCard(
                              icon: Icons.bookmark_outlined,
                              label: 'Saved Jobs',
                              value: _savedCount.toString(),
                              color: AppColors.secondary,
                            ),
                            _StatCard(
                              icon: Icons.send_outlined,
                              label: 'Applications',
                              value: _applicationsCount.toString(),
                              color: AppColors.accent,
                            ),
                            _StatCard(
                              icon: Icons.trending_up_outlined,
                              label: 'Match Score',
                              value: '$_matchScore%',
                              color: const Color(0xFF8B5CF6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Main Modules Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore Opportunities',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: isMobile ? 1 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _ModuleCard(
                              icon: Icons.business_outlined,
                              title: 'Government Jobs',
                              subtitle: 'SSC, UPSC, SBI, IBPS...',
                              color: AppColors.primary,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GovernmentJobsScreen(),
                                  ),
                                );
                              },
                            ),
                            _ModuleCard(
                              icon: Icons.corporate_fare_outlined,
                              title: 'Private Jobs',
                              subtitle: 'TCS, Infosys, Wipro...',
                              color: AppColors.secondary,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivateJobsScreen(),
                                  ),
                                );
                              },
                            ),
                            _ModuleCard(
                              icon: Icons.description_outlined,
                              title: 'Resume Portal',
                              subtitle: 'Upload & Analyze',
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
                            _ModuleCard(
                              icon: Icons.recommend_outlined,
                              title: 'Recommended',
                              subtitle: 'Jobs for you',
                              color: const Color(0xFF8B5CF6),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RecommendedJobsScreen(),
                                  ),
                                );
                              },
                            ),
                            _ModuleCard(
                              icon: Icons.bookmark_outlined,
                              title: 'Saved Jobs',
                              subtitle: 'Your favorites',
                              color: const Color(0xFF06B6D4),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SavedJobsScreen(),
                                  ),
                                );
                              },
                            ),
                            _ModuleCard(
                              icon: Icons.history_outlined,
                              title: 'Applications',
                              subtitle: 'Track progress',
                              color: const Color(0xFF14B8A6),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ApplicationHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
