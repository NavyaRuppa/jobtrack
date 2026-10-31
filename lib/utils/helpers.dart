import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatSalary(String salary) {
    // Format salary string if needed
    return salary;
  }

  static String getMatchCategory(int score) {
    if (score >= 75) return 'strong';
    if (score >= 50) return 'partial';
    return 'poor';
  }

  static String getMatchCategoryLabel(String category) {
    switch (category) {
      case 'strong':
        return 'Strong Match';
      case 'partial':
        return 'Partial Match';
      case 'poor':
        return 'Poor Match';
      default:
        return 'Unknown';
    }
  }

  static String getMatchCategoryMessage(int score) {
    if (score >= 75) return 'Highly Recommended';
    if (score >= 50) return 'Some Skills Missing';
    return 'Qualification Requirement Not Met';
  }

  static Color getMatchCategoryColor(String category) {
    switch (category) {
      case 'strong':
        return const Color(0xFF10B981); // Green
      case 'partial':
        return const Color(0xFFF59E0B); // Yellow/Orange
      case 'poor':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF64748B); // Gray
    }
  }

  static List<String> extractSkills(String text) {
    // Common technical skills to look for
    final skillKeywords = [
      'java', 'python', 'javascript', 'typescript', 'c++', 'c#', 'php', 'ruby',
      'flutter', 'dart', 'react', 'angular', 'vue', 'nodejs', 'spring boot',
      'sql', 'mongodb', 'postgresql', 'mysql', 'oracle',
      'html', 'css', 'bootstrap', 'tailwind', 'sass',
      'android', 'ios', 'swift', 'kotlin', 'react native',
      'aws', 'azure', 'gcp', 'docker', 'kubernetes',
      'git', 'jenkins', 'ci/cd', 'agile', 'scrum',
      'machine learning', 'ai', 'data science', 'analytics',
      'rest api', 'graphql', 'microservices', 'json', 'xml',
      '.net', 'asp.net', 'mvc', 'entity framework',
      'linux', 'unix', 'windows', 'macos',
      'testing', 'junit', 'selenium', 'cypress',
    ];

    final lowerText = text.toLowerCase();
    final foundSkills = <String>[];

    for (final skill in skillKeywords) {
      if (lowerText.contains(skill)) {
        foundSkills.add(skill);
      }
    }

    return foundSkills;
  }

  static String extractQualification(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('b.tech') || lowerText.contains('btech')) {
      return 'B.Tech';
    } else if (lowerText.contains('m.tech') || lowerText.contains('mtech')) {
      return 'M.Tech';
    } else if (lowerText.contains('bca')) {
      return 'BCA';
    } else if (lowerText.contains('mca')) {
      return 'MCA';
    } else if (lowerText.contains('b.sc') || lowerText.contains('bsc')) {
      return 'B.Sc';
    } else if (lowerText.contains('m.sc') || lowerText.contains('msc')) {
      return 'M.Sc';
    } else if (lowerText.contains('b.com') || lowerText.contains('bcom')) {
      return 'B.Com';
    } else if (lowerText.contains('m.com') || lowerText.contains('mcom')) {
      return 'M.Com';
    } else if (lowerText.contains('ba')) {
      return 'BA';
    } else if (lowerText.contains('ma')) {
      return 'MA';
    } else if (lowerText.contains('mba')) {
      return 'MBA';
    }
    
    return 'Not specified';
  }

  static String extractDegree(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('computer science') || lowerText.contains('cse')) {
      return 'Computer Science';
    } else if (lowerText.contains('information technology') || lowerText.contains('it')) {
      return 'Information Technology';
    } else if (lowerText.contains('electronics') || lowerText.contains('ece')) {
      return 'Electronics';
    } else if (lowerText.contains('electrical') || lowerText.contains('eee')) {
      return 'Electrical';
    } else if (lowerText.contains('mechanical')) {
      return 'Mechanical';
    } else if (lowerText.contains('civil')) {
      return 'Civil';
    } else if (lowerText.contains('chemical')) {
      return 'Chemical';
    }
    
    return 'General';
  }

  static String extractBranch(String text) {
    return extractDegree(text);
  }

  static String extractGraduationYear(String text) {
    final yearRegex = RegExp(r'(20\d{2})');
    final matches = yearRegex.allMatches(text);
    
    if (matches.isNotEmpty) {
      // Return the most recent year found
      return matches.last.group(1) ?? 'Not specified';
    }
    
    return 'Not specified';
  }

  static String extractExperience(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('fresher') || lowerText.contains('entry level') || lowerText.contains('0 years')) {
      return 'Fresher';
    } else if (lowerText.contains('1 year') || lowerText.contains('1-2 years')) {
      return '1-2 years';
    } else if (lowerText.contains('2-3 years')) {
      return '2-3 years';
    } else if (lowerText.contains('3-5 years')) {
      return '3-5 years';
    } else if (lowerText.contains('5+ years') || lowerText.contains('5 years')) {
      return '5+ years';
    }
    
    return 'Fresher';
  }
}
