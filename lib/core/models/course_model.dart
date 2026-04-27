import 'package:equatable/equatable.dart';

class CourseModel extends Equatable {
  final int courseID;
  final String name;
  final String? nameEn;
  final String? nameAr;
  final int creditHours;

  const CourseModel({
    required this.courseID,
    required this.name,
    this.nameEn,
    this.nameAr,
    required this.creditHours,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final parsedNameEn = _firstNonEmptyString([
      json['nameEn'],
      json['nameEN'],
      json['englishName'],
      json['courseNameEn'],
      json['courseNameEN'],
      json['name_en'],
    ]);
    final parsedNameAr = _firstNonEmptyString([
      json['nameAr'],
      json['nameAR'],
      json['arabicName'],
      json['courseNameAr'],
      json['courseNameAR'],
      json['name_ar'],
    ]);
    final fallbackName = json['name']?.toString() ?? '';

    return CourseModel(
      courseID: _toInt(json['courseID']),
      name: fallbackName,
      nameEn: parsedNameEn,
      nameAr: parsedNameAr,
      creditHours: _toInt(json['creditHours']),
    );
  }

  String localizedName(String languageCode) {
    if (languageCode == 'ar') {
      return (nameAr != null && nameAr!.trim().isNotEmpty)
          ? nameAr!.trim()
          : (nameEn != null && nameEn!.trim().isNotEmpty)
              ? nameEn!.trim()
              : name.trim();
    }
    return (nameEn != null && nameEn!.trim().isNotEmpty)
        ? nameEn!.trim()
        : (nameAr != null && nameAr!.trim().isNotEmpty)
            ? nameAr!.trim()
            : name.trim();
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  @override
  List<Object?> get props => [courseID, name, nameEn, nameAr, creditHours];
}

class SemesterModel extends Equatable {
  final int semester;
  final List<CourseModel> courses;

  const SemesterModel({
    required this.semester,
    required this.courses,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      semester: CourseModel._toInt(json['semester']),
      courses: (json['courses'] as List?)
              ?.map((c) => CourseModel.fromJson(c))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [semester, courses];
}

class LevelModel extends Equatable {
  final int level;
  final List<SemesterModel> semesters;

  const LevelModel({
    required this.level,
    required this.semesters,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      level: CourseModel._toInt(json['level']),
      semesters: (json['semesters'] as List?)
              ?.map((s) => SemesterModel.fromJson(s))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [level, semesters];
}
