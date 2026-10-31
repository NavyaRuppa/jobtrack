import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';

class AdminRecordsScreen extends StatefulWidget {
  final bool students;

  const AdminRecordsScreen({super.key, required this.students});

  @override
  State<AdminRecordsScreen> createState() => _AdminRecordsScreenState();
}

class _AdminRecordsScreenState extends State<AdminRecordsScreen> {
  final _database = DatabaseService();
  late Future<List<Map<String, dynamic>>> _records;

  @override
  void initState() {
    super.initState();
    _records = widget.students
        ? _database.getStudents()
        : _database.getCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.students ? 'Manage Students' : 'Manage Companies'),
        backgroundColor: AppColors.textPrimary,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _records,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load records: ${snapshot.error}'),
            );
          }
          final records = snapshot.data ?? const <Map<String, dynamic>>[];
          if (records.isEmpty) {
            return const Center(child: Text('No records found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              final title = widget.students
                  ? (record['fullName'] ?? record['full_name'] ?? 'Student')
                  : (record['name'] ?? 'Company');
              final subtitle = widget.students
                  ? (record['email'] ?? '')
                  : '${record['industry'] ?? ''} • ${record['location'] ?? ''}';
              return Card(
                child: ListTile(
                  leading: Icon(
                    widget.students
                        ? Icons.person_outline
                        : Icons.business_outlined,
                  ),
                  title: Text(title.toString()),
                  subtitle: Text(subtitle.toString()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRecordDetails(context, record),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRecordDetails(
    BuildContext context,
    Map<String, dynamic> record,
  ) {
    final details = widget.students
        ? <String, String>{
            'Full name': _value(record, 'fullName', 'full_name'),
            'Email': _value(record, 'email'),
            'Mobile': _value(record, 'mobileNumber', 'mobile_number'),
            'Qualification': _value(
              record,
              'educationalQualification',
              'educational_qualification',
            ),
            'Branch': _value(record, 'graduationBranch', 'graduation_branch'),
            'Graduation year': _value(
              record,
              'graduationYear',
              'graduation_year',
            ),
            'Skills': _listValue(record['skills']),
            'Preferred job type': _value(record, 'preferredJobType'),
            'Preferred location': _value(record, 'preferredLocation'),
          }
        : <String, String>{
            'Company': _value(record, 'name'),
            'Industry': _value(record, 'industry'),
            'Location': _value(record, 'location'),
            'Website': _value(record, 'website'),
            'Description': _value(record, 'description'),
          };

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(widget.students ? 'Student details' : 'Company details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details.entries
                .where((entry) => entry.value.isNotEmpty)
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _value(
    Map<String, dynamic> record,
    String key, [
    String? alternativeKey,
  ]) {
    final value = record[key] ?? (alternativeKey == null ? null : record[alternativeKey]);
    return value?.toString() ?? '';
  }

  String _listValue(dynamic value) {
    if (value is Iterable) return value.join(', ');
    return value?.toString() ?? '';
  }
}
