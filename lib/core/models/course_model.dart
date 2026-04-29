import 'package:equatable/equatable.dart';

/// Represents a single course with localization support
class CourseModel extends Equatable {
  /// Unique identifier for the course
  final String courseID;

  /// Course name in English (primary field from API)
  final String courseNameEn;

  /// Course name in Arabic (nullable - may not be provided by API)
  final String? courseNameAr;

  /// Credit hours for the course
  final int creditHours;

  const CourseModel({
    required this.courseID,
    required this.courseNameEn,
    this.courseNameAr,
    required this.creditHours,
  });

  /// Parse CourseModel from JSON API response
  /// Handles multiple field name variations and safe type conversion
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse courseID - keep as String
      final courseID = _safeToString(json['courseID'] ?? json['id'] ?? '');

      // Parse English course name (required from API)
      final courseNameEn = _safeToString(
        json['courseNameEn'] ??
            json['courseNameEN'] ??
            json['englishName'] ??
            json['name_en'] ??
            json['nameEn'] ??
            '',
      );

      // Parse Arabic course name (nullable - may be missing or null from API)
      final courseNameAr = _safeToStringNullable(
        json['courseNameAr'] ??
            json['courseNameAR'] ??
            json['arabicName'] ??
            json['name_ar'] ??
            json['nameAr'],
      );

      // Parse credit hours - safe conversion from any type
      final creditHours = _safeToInt(
        json['creditHours'] ?? json['credit_hours'] ?? 0,
      );

      return CourseModel(
        courseID: courseID,
        courseNameEn: courseNameEn,
        courseNameAr: courseNameAr,
        creditHours: creditHours,
      );
    } catch (e) {
      // Fallback with defaults to prevent crashes
      return CourseModel(
        courseID: _safeToString(json['courseID'] ?? json['id'] ?? 'unknown'),
        courseNameEn: _safeToString(json['courseNameEn'] ?? 'Unknown Course'),
        courseNameAr: null,
        creditHours: 0,
      );
    }
  }

  /// Get localized course name based on language code
  /// Priority: Requested language > Fallback to English
  String localizedName(String languageCode) {
    if (languageCode == 'ar') {
      // Arabic requested: use Arabic name if available, otherwise English
      return (courseNameAr != null && courseNameAr!.trim().isNotEmpty)
          ? courseNameAr!.trim()
          : courseNameEn.trim();
    }
    // English or other: use English name
    return courseNameEn.trim();
  }

  /// Safe conversion to int from any type
  /// Handles: null, int, double, String, other types
  static int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      return parsed ?? 0;
    }
    return 0;
  }

  /// Safe conversion to non-null String
  static String _safeToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    return value.toString().trim();
  }

  /// Safe conversion to nullable String
  static String? _safeToStringNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isNotEmpty ? trimmed : null;
    }
    final stringValue = value.toString().trim();
    return stringValue.isNotEmpty ? stringValue : null;
  }

  @override
  List<Object?> get props => [
    courseID,
    courseNameEn,
    courseNameAr,
    creditHours,
  ];
}

/// Represents a semester with multiple courses
class SemesterModel extends Equatable {
  /// Semester number (1, 2, 3, etc.)
  final int semester;

  /// List of courses in this semester
  final List<CourseModel> courses;

  const SemesterModel({required this.semester, required this.courses});

  /// Parse SemesterModel from JSON API response
  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse semester number - safe conversion from any type
      final semester = CourseModel._safeToInt(json['semester'] ?? 0);

      // Parse courses list
      final courses = <CourseModel>[];
      final coursesList = json['courses'];

      if (coursesList is List) {
        for (final courseJson in coursesList) {
          if (courseJson is Map<String, dynamic>) {
            try {
              courses.add(CourseModel.fromJson(courseJson));
            } catch (e) {
              // Skip malformed course entries
              continue;
            }
          }
        }
      }

      return SemesterModel(semester: semester, courses: courses);
    } catch (e) {
      // Fallback to empty semester if parsing fails
      return SemesterModel(semester: 0, courses: []);
    }
  }

  @override
  List<Object?> get props => [semester, courses];
}

/// Represents a level (year) with multiple semesters
class LevelModel extends Equatable {
  /// Level/Year number (1, 2, 3, 4, etc.)
  final int level;

  /// List of semesters in this level
  final List<SemesterModel> semesters;

  const LevelModel({required this.level, required this.semesters});

  /// Parse LevelModel from JSON API response
  factory LevelModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse level number - safe conversion from any type
      final level = CourseModel._safeToInt(json['level'] ?? 0);

      // Parse semesters list
      final semesters = <SemesterModel>[];
      final semestersList = json['semesters'];

      if (semestersList is List) {
        for (final semesterJson in semestersList) {
          if (semesterJson is Map<String, dynamic>) {
            try {
              semesters.add(SemesterModel.fromJson(semesterJson));
            } catch (e) {
              // Skip malformed semester entries
              continue;
            }
          }
        }
      }

      return LevelModel(level: level, semesters: semesters);
    } catch (e) {
      // Fallback to empty level if parsing fails
      return LevelModel(level: 0, semesters: []);
    }
  }

  @override
  List<Object?> get props => [level, semesters];
}
