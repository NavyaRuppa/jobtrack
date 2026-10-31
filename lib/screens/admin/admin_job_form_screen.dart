import 'package:flutter/material.dart';
import '../../models/government_job.dart';
import '../../models/private_job.dart';
import '../../services/job_service.dart';
import '../../utils/url_validator.dart';

class AdminJobFormScreen extends StatefulWidget {
  final bool government;
  final GovernmentJob? governmentJob;
  final PrivateJob? privateJob;

  const AdminJobFormScreen({
    super.key,
    required this.government,
    this.governmentJob,
    this.privateJob,
  });

  @override
  State<AdminJobFormScreen> createState() => _AdminJobFormScreenState();
}

class _AdminJobFormScreenState extends State<AdminJobFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = JobService();
  final Map<String, TextEditingController> _fields = {};
  bool _saving = false;

  bool get _editing => widget.government
      ? widget.governmentJob != null
      : widget.privateJob != null;

  @override
  void initState() {
    super.initState();
    final values = widget.government
        ? _governmentValues(widget.governmentJob)
        : _privateValues(widget.privateJob);
    for (final entry in values.entries) {
      _fields[entry.key] = TextEditingController(text: entry.value);
    }
  }

  Map<String, String> _governmentValues(GovernmentJob? job) => {
    'organization': job?.organization ?? '',
    'recruitingOrganization': job?.recruitingOrganization ?? '',
    'jobTitle': job?.jobTitle ?? '',
    'jobRole': job?.jobRole ?? '',
    'location': job?.location ?? '',
    'educationalQualification': job?.educationalQualification ?? '',
    'ageEligibility': job?.ageEligibility ?? '',
    'vacancies': job?.vacancies.toString() ?? '',
    'salary': job?.salary ?? '',
    'responsibilities': job?.responsibilities ?? '',
    'requiredSkills': job?.requiredSkills.join(', ') ?? '',
    'applicationStartDate': _dateText(job?.applicationStartDate),
    'applicationClosingDate': _dateText(job?.applicationClosingDate),
    'selectionProcess': job?.selectionProcess ?? '',
    'examinationDetails': job?.examinationDetails ?? '',
    'officialNotificationUrl': job?.officialNotificationUrl ?? '',
    'applyOnlineUrl': job?.applyOnlineUrl ?? '',
    'jobType': job?.jobType ?? 'Full Time',
  };

  Map<String, String> _privateValues(PrivateJob? job) => {
    'companyName': job?.companyName ?? '',
    'jobRole': job?.jobRole ?? '',
    'location': job?.location ?? '',
    'educationalQualification': job?.educationalQualification ?? '',
    'technicalSkills': job?.technicalSkills.join(', ') ?? '',
    'softSkills': job?.softSkills.join(', ') ?? '',
    'experience': job?.experience ?? '',
    'salary': job?.salary ?? '',
    'jobDescription': job?.jobDescription ?? '',
    'applicationDeadline': _dateText(job?.applicationDeadline),
    'officialApplicationLink': job?.officialApplicationLink ?? '',
    'jobType': job?.jobType ?? 'Full-time',
  };

  String _dateText(DateTime? date) =>
      date == null ? '' : date.toIso8601String().split('T').first;

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _value(String name) => _fields[name]!.text.trim();

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  String? _dateValidator(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    return DateTime.tryParse(value!.trim()) == null ? 'Use YYYY-MM-DD' : null;
  }

  String? _vacanciesValidator(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    final vacancies = int.tryParse(value!.trim());
    return vacancies == null || vacancies < 1
        ? 'Enter a positive whole number'
        : null;
  }

  String? _urlValidator(String? value) => UrlValidator.validateHttpUrl(
        value,
        fieldName: 'URL',
      );

  Widget _field(
    String name,
    String label, {
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _fields[name],
        validator: validator ?? _required,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _organizationField() {
    const organizations = [
      'SSC',
      'UPSC',
      'IBPS',
      'SBI',
      'RRB',
      'APPSC',
      'India Post',
      'DRDO',
      'ISRO',
      'Other',
    ];
    final current = _fields['recruitingOrganization']!.text;
    final value = organizations.contains(current) ? current : null;
    const websites = {
      'SSC': 'https://ssc.gov.in/',
      'UPSC': 'https://upsc.gov.in/',
      'IBPS': 'https://www.ibps.in/',
      'SBI': 'https://sbi.co.in/web/careers',
      'RRB': 'https://indianrailways.gov.in/',
      'APPSC': 'https://psc.ap.gov.in/',
      'India Post': 'https://www.indiapost.gov.in/',
      'DRDO': 'https://www.drdo.gov.in/',
      'ISRO': 'https://www.isro.gov.in/',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(
              labelText: 'Recruiting organization',
              helperText: 'Admin-provided source; verify the notification URL.',
            ),
            items: organizations
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            validator: (value) =>
                value == null || value.isEmpty ? 'This field is required' : null,
            onChanged: (value) {
              if (value != null) {
                _fields['recruitingOrganization']!.text = value;
                setState(() {});
              }
            },
          ),
          if (websites[current] != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Text(
                'Reference website: ${websites[current]}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final id =
          widget.governmentJob?.id ??
          widget.privateJob?.id ??
          '${widget.government ? 'gov' : 'priv'}_${now.millisecondsSinceEpoch}';
      final success = widget.government
          ? (_editing
                ? await _service.updateGovernmentJob(_governmentJob(id, now))
                : await _service.saveGovernmentJob(_governmentJob(id, now)))
          : (_editing
                ? await _service.updatePrivateJob(_privateJob(id, now))
                : await _service.savePrivateJob(_privateJob(id, now)));
      if (!success) {
        throw Exception('The existing database rejected the job.');
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to save job: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  GovernmentJob _governmentJob(String id, DateTime now) {
    final previous = widget.governmentJob;
    return GovernmentJob(
      id: id,
      organization: _value('organization'),
      recruitingOrganization: _value('recruitingOrganization'),
      jobTitle: _value('jobTitle'),
      vacancies: int.parse(_value('vacancies')),
      educationalQualification: _value('educationalQualification'),
      ageEligibility: _value('ageEligibility'),
      salary: _value('salary'),
      jobRole: _value('jobRole'),
      responsibilities: _value('responsibilities'),
      requiredSkills: _value('requiredSkills')
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      applicationStartDate: DateTime.parse(_value('applicationStartDate')),
      applicationClosingDate: DateTime.parse(_value('applicationClosingDate')),
      selectionProcess: _value('selectionProcess'),
      examinationDetails: _value('examinationDetails'),
      officialNotificationUrl: UrlValidator.normalize(_value('officialNotificationUrl')),
      applyOnlineUrl: UrlValidator.normalize(_value('applyOnlineUrl')),
      location: _value('location'),
      jobType: _value('jobType'),
      createdAt: previous?.createdAt ?? now,
      updatedAt: now,
    );
  }

  PrivateJob _privateJob(String id, DateTime now) {
    final previous = widget.privateJob;
    final companyId =
        previous?.companyId ??
        'company_${_value('companyName').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';
    return PrivateJob(
      id: id,
      companyId: companyId,
      companyName: _value('companyName'),
      jobRole: _value('jobRole'),
      educationalQualification: _value('educationalQualification'),
      technicalSkills: _value('technicalSkills')
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      softSkills: _value('softSkills')
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      experience: _value('experience'),
      salary: _value('salary'),
      location: _value('location'),
      jobDescription: _value('jobDescription'),
      applicationDeadline: DateTime.parse(_value('applicationDeadline')),
      officialApplicationLink: _value('officialApplicationLink'),
      jobType: _value('jobType'),
      createdAt: previous?.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.government
        ? [
            _field('organization', 'Organization'),
            _organizationField(),
            _field('jobTitle', 'Job title'),
            _field('jobRole', 'Job role'),
            _field('location', 'Location'),
            _field('educationalQualification', 'Educational qualification'),
            _field('ageEligibility', 'Age eligibility'),
            _field(
              'vacancies',
              'Vacancies',
              validator: _vacanciesValidator,
              keyboardType: TextInputType.number,
            ),
            _field('salary', 'Salary'),
            _field('responsibilities', 'Responsibilities', maxLines: 3),
            _field('requiredSkills', 'Required skills (comma separated)'),
            _field(
              'applicationStartDate',
              'Application start date',
              validator: _dateValidator,
            ),
            _field(
              'applicationClosingDate',
              'Application closing date',
              validator: _dateValidator,
            ),
            _field('selectionProcess', 'Selection process'),
            _field('examinationDetails', 'Examination details'),
            _field(
              'officialNotificationUrl',
              'Official notification URL',
              validator: _urlValidator,
            ),
            _field(
              'applyOnlineUrl',
              'Apply online URL',
              validator: _urlValidator,
            ),
            _field('jobType', 'Job type'),
          ]
        : [
            _field('companyName', 'Company name'),
            _field('jobRole', 'Job title / role'),
            _field('location', 'Location'),
            _field('educationalQualification', 'Educational qualification'),
            _field('technicalSkills', 'Technical skills (comma separated)'),
            _field('softSkills', 'Soft skills (comma separated)'),
            _field('experience', 'Experience'),
            _field('salary', 'Salary'),
            _field('jobDescription', 'Job description', maxLines: 4),
            _field(
              'applicationDeadline',
              'Application deadline',
              validator: _dateValidator,
            ),
            _field('officialApplicationLink', 'Official application link'),
            _field('jobType', 'Job type'),
          ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_editing ? 'Edit' : 'Add'} '
          '${widget.government ? 'Government' : 'Private'} Job',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ...fields,
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save Job'),
            ),
          ],
        ),
      ),
    );
  }
}
