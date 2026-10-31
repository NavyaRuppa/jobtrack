import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _branchController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _skillsController = TextEditingController();
  final _locationController = TextEditingController();
  String _preferredJobType = 'Any';
  bool _isLoading = false;
  final _authService = AuthService();

  final List<String> _qualifications = [
    'B.Tech',
    'M.Tech',
    'BCA',
    'MCA',
    'B.Sc',
    'M.Sc',
    'B.Com',
    'M.Com',
    'BA',
    'MA',
    'MBA',
  ];

  final List<String> _branches = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Electrical',
    'Mechanical',
    'Civil',
    'Chemical',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _qualificationController.dispose();
    _branchController.dispose();
    _graduationYearController.dispose();
    _skillsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final success = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        educationalQualification: _qualificationController.text,
        graduationBranch: _branchController.text,
        graduationYear: _graduationYearController.text,
        skills: _skillsController.text,
        preferredJobType: _preferredJobType,
        preferredLocation: _locationController.text.trim(),
        role: 'student',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _authService.lastRegistrationError ??
                    'Registration failed. Please try again.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.register),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.fullName,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  validator: Validators.validateFullName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: AppStrings.mobileNumber,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  validator: Validators.validateMobileNumber,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _qualificationController.text.isEmpty
                      ? null
                      : _qualificationController.text,
                  decoration: InputDecoration(
                    labelText: AppStrings.educationalQualification,
                    prefixIcon: const Icon(Icons.school_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  items: _qualifications.map((qualification) {
                    return DropdownMenuItem(
                      value: qualification,
                      child: Text(qualification),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _qualificationController.text = value ?? '';
                  },
                  validator: (value) => Validators.validateRequired(
                    value,
                    AppStrings.educationalQualification,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _branchController.text.isEmpty
                      ? null
                      : _branchController.text,
                  decoration: InputDecoration(
                    labelText: AppStrings.graduationBranch,
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  items: _branches.map((branch) {
                    return DropdownMenuItem(value: branch, child: Text(branch));
                  }).toList(),
                  onChanged: (value) {
                    _branchController.text = value ?? '';
                  },
                  validator: (value) => Validators.validateRequired(
                    value,
                    AppStrings.graduationBranch,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _graduationYearController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: AppStrings.graduationYear,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Graduation year is required';
                    }
                    if (value.length != 4) {
                      return 'Please enter a valid year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _skillsController,
                  decoration: const InputDecoration(
                    labelText: 'Skills',
                    hintText: 'e.g. Dart, Flutter, SQL',
                    prefixIcon: Icon(Icons.star_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Location',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _preferredJobType,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Job Type',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Any', child: Text('Any')),
                    DropdownMenuItem(
                      value: 'Government',
                      child: Text('Government'),
                    ),
                    DropdownMenuItem(value: 'Private', child: Text('Private')),
                  ],
                  onChanged: (value) {
                    setState(() => _preferredJobType = value ?? 'Any');
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppStrings.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: AppStrings.register,
                  onPressed: _register,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppStrings.login,
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
