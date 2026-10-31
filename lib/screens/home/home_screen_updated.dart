import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../admin/admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  late Future<void> _checkLoginFuture;

  @override
  void initState() {
    super.initState();
    _checkLoginFuture = _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await _authService.loadSession();

    // If already logged in, navigate to appropriate dashboard
    if (mounted) {
      if (_authService.isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => _authService.isAdmin
                ? const AdminDashboard()
                : const DashboardScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _checkLoginFuture,
      builder: (context, snapshot) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Header
              SliverAppBar(
                expandedHeight: 250,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    AppStrings.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        const Center(
                          child: Icon(
                            Icons.work_outline,
                            size: 100,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero Section
                        Text(
                          AppStrings.tagline,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // CTA Buttons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomButton(
                              text: 'Login to Account',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              backgroundColor: AppColors.primary,
                            ),
                            const SizedBox(height: 12),
                            CustomButton(
                              text: 'Create New Account',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              isOutlined: true,
                              backgroundColor: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),

                        // Features Section
                        Text(
                          'Key Features',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        _FeatureCard(
                          icon: Icons.business_outlined,
                          title: 'Government Jobs',
                          description:
                              'Explore opportunities from SSC, UPSC, SBI, and more',
                        ),
                        const SizedBox(height: 16),

                        _FeatureCard(
                          icon: Icons.corporate_fare_outlined,
                          title: 'Private Jobs',
                          description:
                              'Find positions at leading companies like TCS, Infosys, Wipro',
                        ),
                        const SizedBox(height: 16),

                        _FeatureCard(
                          icon: Icons.description_outlined,
                          title: 'Smart Resume Matching',
                          description:
                              'Upload resume and get job recommendations based on your skills',
                        ),
                        const SizedBox(height: 16),

                        _FeatureCard(
                          icon: Icons.trending_up_outlined,
                          title: 'Match Scores',
                          description:
                              'See how well you match each job and what skills to improve',
                        ),
                        const SizedBox(height: 16),

                        _FeatureCard(
                          icon: Icons.bookmark_outlined,
                          title: 'Save & Track',
                          description:
                              'Save jobs for later and track your applications in one place',
                        ),
                        const SizedBox(height: 48),

                        // Footer
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ready to start your career journey?',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create an account in seconds and explore thousands of job opportunities.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
