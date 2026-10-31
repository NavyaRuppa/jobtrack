import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/dashboard_card.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/job_service.dart';
import '../auth/login_screen.dart';
import 'admin_job_management_screen.dart';
import 'admin_job_form_screen.dart';
import 'admin_records_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboard> {
  final _authService = AuthService();
  final _database = DatabaseService();
  final _jobService = JobService();
  int _students = 0;
  int _governmentJobs = 0;
  int _privateJobs = 0;
  int _companies = 0;
  int _applications = 0;

  @override
  void initState() {
    super.initState();
    if (!_authService.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
      return;
    }
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final values = await Future.wait([
      _database.getStudentCount(),
      _jobService.getGovernmentJobs(),
      _jobService.getPrivateJobs(),
      _database.getApplicationCount(),
      _database.getCompanyCount(),
    ]);
    if (!mounted) return;
    setState(() {
      _students = values[0] as int;
      _governmentJobs = (values[1] as List).length;
      _privateJobs = (values[2] as List).length;
      _applications = values[3] as int;
      _companies = values[4] as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.textPrimary,
        actions: [
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
                  colors: [AppColors.textPrimary, AppColors.textSecondary],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JobTrack Administrator',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: const Text('Manage Government Jobs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminJobManagementScreen(government: true),
                  ),
                ).then((_) => _loadStatistics());
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text('Manage Private Jobs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminJobManagementScreen(government: false),
                  ),
                ).then((_) => _loadStatistics());
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center_outlined),
              title: const Text('Manage Companies'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminRecordsScreen(students: false),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outlined),
              title: const Text('Manage Students'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminRecordsScreen(students: true),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Reported Jobs'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to reported jobs
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Send Notifications'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to notifications
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
      body: SingleChildScrollView(
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
                  colors: [AppColors.textPrimary, AppColors.textSecondary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Admin!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage and monitor the JobTrack platform',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics
            const Text(
              'Platform Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                DashboardCard(
                  title: 'Total Students',
                  value: '$_students',
                  icon: Icons.people,
                  iconColor: AppColors.primary,
                ),
                DashboardCard(
                  title: 'Government Jobs',
                  value: '$_governmentJobs',
                  icon: Icons.account_balance,
                  iconColor: AppColors.secondary,
                ),
                DashboardCard(
                  title: 'Private Jobs',
                  value: '$_privateJobs',
                  icon: Icons.business,
                  iconColor: AppColors.accent,
                ),
                DashboardCard(
                  title: 'Companies',
                  value: '$_companies',
                  icon: Icons.business_center,
                  iconColor: AppColors.success,
                ),
                DashboardCard(
                  title: 'Resumes',
                  value: '$_applications',
                  icon: Icons.description,
                  iconColor: AppColors.warning,
                ),
                DashboardCard(
                  title: 'Applications',
                  value: '$_applications',
                  icon: Icons.send,
                  iconColor: AppColors.textSecondary,
                ),
                DashboardCard(
                  title: 'Reported Jobs',
                  value: '3',
                  icon: Icons.report,
                  iconColor: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              Icons.add_circle_outline,
              'Add Government Job',
              () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminJobFormScreen(government: true),
                  ),
                ).then((_) => _loadStatistics());
              },
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildActionCard(Icons.add_circle_outline, 'Add Private Job', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminJobFormScreen(government: false),
                ),
              ).then((_) => _loadStatistics());
            }, AppColors.secondary),
            const SizedBox(height: 12),
            _buildActionCard(Icons.add_business_outlined, 'Add Company', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminRecordsScreen(students: false),
                ),
              );
            }, AppColors.accent),
            const SizedBox(height: 12),
            _buildActionCard(
              Icons.notifications_active_outlined,
              'Send Notification',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Notifications require a configured messaging provider.',
                    ),
                  ),
                );
              },
              AppColors.warning,
            ),
            const SizedBox(height: 12),
            _buildActionCard(Icons.delete_outline, 'Remove Expired Jobs', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Use job management to review and delete expired listings.',
                  ),
                ),
              );
            }, AppColors.error),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    VoidCallback onTap,
    Color color,
  ) {
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
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
