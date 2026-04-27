import 'package:equatable/equatable.dart';

/// User model representing student data
class UserModel extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String email;
  final String? phone;
  final String? studentId;
  final String? major;
  final String? year;
  final double? gpa;
  final int? completedCreditHours;
  final int? remainingCreditHours;
  final int? totalCreditHours;
  final double? overallProgress;

  const UserModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    required this.email,
    this.phone,
    this.studentId,
    this.major,
    this.year,
    this.gpa,
    this.completedCreditHours,
    this.remainingCreditHours,
    this.totalCreditHours,
    this.overallProgress,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['studentID']?.toString() ?? '',
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? json['userName']?.toString() ?? '',
      nameAr: json['nameAr']?.toString(),
      nameEn: json['nameEn']?.toString(),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      studentId: json['studentId']?.toString() ?? json['studentCode']?.toString() ?? json['studentID']?.toString(),
      major: json['major']?.toString() ?? json['department']?.toString(),
      year: json['year']?.toString() ?? json['level']?.toString(),
      gpa: _toDouble(json['gpa'] ?? json['GPA'] ?? json['gba']),
      completedCreditHours: _toInt(json['completedCreditHours'] ?? json['completedHours']),
      remainingCreditHours: _toInt(json['remainingCreditHours'] ?? json['remainingHours']),
      totalCreditHours: _toInt(json['totalCreditHours'] ?? json['totalHours']),
      overallProgress: _toDouble(json['overallProgress']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'email': email,
      'phone': phone,
      'studentId': studentId,
      'major': major,
      'year': year,
      'gpa': gpa,
      'completedCreditHours': completedCreditHours,
      'remainingCreditHours': remainingCreditHours,
      'totalCreditHours': totalCreditHours,
      'overallProgress': overallProgress,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? nameEn,
    String? email,
    String? phone,
    String? studentId,
    String? major,
    String? year,
    double? gpa,
    int? completedCreditHours,
    int? remainingCreditHours,
    int? totalCreditHours,
    double? overallProgress,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      studentId: studentId ?? this.studentId,
      major: major ?? this.major,
      year: year ?? this.year,
      gpa: gpa ?? this.gpa,
      completedCreditHours: completedCreditHours ?? this.completedCreditHours,
      remainingCreditHours: remainingCreditHours ?? this.remainingCreditHours,
      totalCreditHours: totalCreditHours ?? this.totalCreditHours,
      overallProgress: overallProgress ?? this.overallProgress,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        nameEn,
        email,
        phone,
        studentId,
        major,
        year,
        gpa,
        completedCreditHours,
        remainingCreditHours,
        totalCreditHours,
        overallProgress,
      ];

  String getLocalizedName(String langCode) {
    if (langCode == 'ar') {
      return (nameAr != null && nameAr!.isNotEmpty) ? nameAr! : name;
    }
    return (nameEn != null && nameEn!.isNotEmpty) ? nameEn! : name;
  }
}
