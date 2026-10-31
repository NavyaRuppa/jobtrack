import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/match_score_card.dart';
import '../../widgets/job_card.dart';
import '../../services/matching_service.dart';
import '../../services/job_service.dart';
import '../../services/resume_service.dart';
import '../../services/auth_service.dart';
import '../../models/government_job.dart';
import '../../models/private_job.dart';
import '../../models/job_match.dart';
import '../government/government_job_details.dart';
import '../private/private_job_details.dart';

class RecommendedJobsScreen extends StatefulWidget {
  const RecommendedJobsScreen({super.key});

  @override
  State<RecommendedJobsScreen> createState() => _RecommendedJobsScreenState();
}

class _RecommendedJobsScreenState extends State<RecommendedJobsScreen> {
  final _matchingService = MatchingService();
  final _jobService = JobService();
  final _resumeService = ResumeService();
  final _authService = AuthService();
  List<JobMatch> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    final studentId = _authService.currentUser?.id;
    if (studentId == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Get all jobs
    final govJobs = await _jobService.getGovernmentJobs();
    final privateJobs = await _jobService.getPrivateJobs();

    final matches = <JobMatch>[];

    // Get student resume
    final resume = await _resumeService.getStudentResume(studentId);

    if (resume != null) {
      // Match with government jobs
      for (final job in govJobs) {
        final match = await _matchingService.matchWithGovernmentJob(
          resume,
          job,
        );
        matches.add(match);
      }

      // Match with private jobs
      for (final job in privateJobs) {
        final match = await _matchingService.matchWithPrivateJob(resume, job);
        matches.add(match);
      }

      // Sort by match score
      matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    } else {
      // If no resume, show all jobs with default match score
      for (final job in govJobs) {
        matches.add(
          JobMatch(
            id: DateTime.now().millisecondsSinceEpoch.toString() + job.id,
            studentId: studentId,
            jobId: job.id,
            jobType: 'government',
            matchScore: 50,
            matchCategory: 'partial',
            matchedSkills: [],
            missingSkills: [],
            qualificationMatch: false,
            experienceMatch: false,
            explanation: 'Upload a resume to calculate a personalized match.',
            calculatedAt: DateTime.now(),
          ),
        );
      }

      for (final job in privateJobs) {
        matches.add(
          JobMatch(
            id: DateTime.now().millisecondsSinceEpoch.toString() + job.id,
            studentId: studentId,
            jobId: job.id,
            jobType: 'private',
            matchScore: 50,
            matchCategory: 'partial',
            matchedSkills: [],
            missingSkills: [],
            qualificationMatch: false,
            experienceMatch: false,
            explanation: 'Upload a resume to calculate a personalized match.',
            calculatedAt: DateTime.now(),
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _matches = matches;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.recommendedJobs),
        backgroundColor: AppColors.primaryDark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recommendations yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your resume to get personalized recommendations',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MatchScoreCard(match: match),
                      const SizedBox(height: 16),
                      // Show job card based on type
                      if (match.jobType == 'government')
                        _buildGovernmentJobCard(match)
                      else
                        _buildPrivateJobCard(match),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildGovernmentJobCard(JobMatch match) {
    return FutureBuilder<GovernmentJob?>(
      future: _jobService.getGovernmentJobById(match.jobId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return JobCard(
            job: snapshot.data!,
            jobType: 'government',
            matchScore: match.matchScore,
            onViewDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GovernmentJobDetails(job: snapshot.data!),
                ),
              );
            },
            onSave: () {},
            onApply: () {},
            isSaved: false,
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildPrivateJobCard(JobMatch match) {
    return FutureBuilder<PrivateJob?>(
      future: _jobService.getPrivateJobById(match.jobId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return JobCard(
            job: snapshot.data!,
            jobType: 'private',
            matchScore: match.matchScore,
            onViewDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivateJobDetails(job: snapshot.data!),
                ),
              );
            },
            onSave: () {},
            onApply: () {},
            isSaved: false,
          );
        }
        return const SizedBox();
      },
    );
  }
}
