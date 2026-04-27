import 'dart:convert';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../utils/app_preferences.dart';

/// Repository for student-related data
class StudentRepository {
  final ApiClient _apiClient;
  final AppPreferences _preferences;

  StudentRepository({ApiClient? apiClient, AppPreferences? preferences})
      : _apiClient = apiClient ?? ApiClient(),
        _preferences = preferences ?? AppPreferences();

  /// Get student profile from API
  Future<UserModel> getProfile({String lang = 'en'}) async {
    final response = await _apiClient.get(
      "${ApiConstants.studentProfile}?lang=$lang",
      requiresAuth: true,
    );

    final userData = response['data'] ?? response['user'] ?? response;
    final user = UserModel.fromJson(userData);

    // Merge logic: Preserve fields like GPA that might not be in the profile response
    final cachedData = await getCachedProfile();
    final updatedUser = cachedData != null 
        ? cachedData.copyWith(
            id: user.id.isNotEmpty ? user.id : cachedData.id,
            name: user.name.isNotEmpty ? user.name : cachedData.name,
            nameAr: user.nameAr ?? cachedData.nameAr,
            nameEn: user.nameEn ?? cachedData.nameEn,
            email: user.email.isNotEmpty ? user.email : cachedData.email,
            phone: user.phone ?? cachedData.phone,
            studentId: user.studentId ?? cachedData.studentId,
            major: user.major ?? cachedData.major,
            year: user.year ?? cachedData.year,
            gpa: (user.gpa != null && user.gpa! > 0) ? user.gpa : (cachedData.gpa ?? 0.0),
            completedCreditHours: (user.completedCreditHours != null && user.completedCreditHours! > 0) 
                ? user.completedCreditHours 
                : cachedData.completedCreditHours,
            remainingCreditHours: (user.remainingCreditHours != null && user.remainingCreditHours! > 0)
                ? user.remainingCreditHours
                : cachedData.remainingCreditHours,
            totalCreditHours: user.totalCreditHours ?? cachedData.totalCreditHours,
            overallProgress: (user.overallProgress != null && user.overallProgress! > 0)
                ? user.overallProgress
                : cachedData.overallProgress,
          )
        : user;

    await _preferences.saveUserData(jsonEncode(updatedUser.toJson()));
    return updatedUser;
  }

  /// Get dashboard info from API
  Future<UserModel> getDashboard() async {
    final response = await _apiClient.get(
      ApiConstants.dashboard,
      requiresAuth: true,
    );

    final userData = response['data'] ?? response['user'] ?? response;
    final dashboard = DashboardModel.fromJson(userData);

    // Merge Logic: Connect backend Dashboard data to the unified UserModel
    final cachedData = await getCachedProfile();
    final updatedUser = cachedData != null
        ? cachedData.copyWith(
            nameAr: dashboard.nameAr.isNotEmpty ? dashboard.nameAr : cachedData.nameAr,
            nameEn: dashboard.nameEn.isNotEmpty ? dashboard.nameEn : cachedData.nameEn,
            gpa: dashboard.gpa > 0 ? dashboard.gpa : (cachedData.gpa ?? 0.0),
            completedCreditHours: dashboard.completedCreditHours > 0 
                ? dashboard.completedCreditHours 
                : (cachedData.completedCreditHours ?? 0),
            remainingCreditHours: dashboard.remainingCreditHours > 0 
                ? dashboard.remainingCreditHours 
                : (cachedData.remainingCreditHours ?? 0),
            overallProgress: dashboard.overallProgress > 0 
                ? dashboard.overallProgress 
                : (cachedData.overallProgress ?? 0.0),
            studentId: dashboard.studentID.isNotEmpty ? dashboard.studentID : cachedData.studentId,
          )
        : UserModel(
            id: dashboard.studentID,
            name: dashboard.nameEn.isNotEmpty ? dashboard.nameEn : (dashboard.nameAr.isNotEmpty ? dashboard.nameAr : 'Student'),
            nameAr: dashboard.nameAr,
            nameEn: dashboard.nameEn,
            email: '',
            studentId: dashboard.studentID,
            gpa: dashboard.gpa,
            completedCreditHours: dashboard.completedCreditHours,
            remainingCreditHours: dashboard.remainingCreditHours,
            overallProgress: dashboard.overallProgress,
          );

    await _preferences.saveUserData(jsonEncode(updatedUser.toJson()));
    return updatedUser;
  }

  /// Save student profile to cache
  Future<void> saveProfile(UserModel user) async {
    await _preferences.saveUserData(jsonEncode(user.toJson()));
  }

  /// Get cached student profile
  Future<UserModel?> getCachedProfile() async {
    final userData = await _preferences.getUserData();
    if (userData != null) {
      try {
        return UserModel.fromJson(jsonDecode(userData));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Update student profile
  Future<UserModel> updateProfile({
    required String studentID,
    required String name,
    required String email,
    required String major,
    required String year,
    required String phone,
    String lang = 'en',
  }) async {
    final response = await _apiClient.put(
      "${ApiConstants.editProfile}?lang=$lang",
      body: {
        'studentID': studentID,
        'name': name,
        'email': email,
        'major': major,
        'year': year,
        'phone': phone,
      },
      requiresAuth: true,
    );

    final userData = response['data'] ?? response['user'] ?? response;
    final user = UserModel.fromJson(userData);

    // Merge logic: Prioritize fresh API data first, then user's INPUT data, then fallback to cache
    final cachedData = await getCachedProfile();
    
    // Initial merge with cached data to preserve GPA, progress, etc.
    UserModel merged = cachedData ?? user;
    
    // Explicitly apply the values that were successfully sent to the server
    merged = merged.copyWith(
      id: studentID.isNotEmpty ? studentID : merged.id,
      name: name.isNotEmpty ? name : merged.name,
      email: email.isNotEmpty ? email : merged.email,
      major: major.isNotEmpty ? major : merged.major,
      year: year.isNotEmpty ? year : merged.year,
      phone: phone.isNotEmpty ? phone : merged.phone,
    );

    // Finally Overlay API response data which might contain enriched info or IDs
    final updatedUser = merged.copyWith(
      id: user.id.isNotEmpty ? user.id : merged.id,
      name: user.name.isNotEmpty ? user.name : merged.name,
      nameAr: (user.nameAr != null && user.nameAr!.isNotEmpty) 
          ? user.nameAr 
          : (user.name.isNotEmpty && lang == 'ar' ? user.name : (lang == 'ar' && name.isNotEmpty ? name : merged.nameAr)),
      nameEn: (user.nameEn != null && user.nameEn!.isNotEmpty)
          ? user.nameEn
          : (user.name.isNotEmpty && lang == 'en' ? user.name : (lang == 'en' && name.isNotEmpty ? name : merged.nameEn)),
      email: user.email.isNotEmpty ? user.email : merged.email,
      phone: user.phone ?? merged.phone,
      studentId: user.studentId ?? merged.studentId,
      major: user.major ?? merged.major,
      year: user.year ?? merged.year,
      gpa: (user.gpa != null && user.gpa! > 0) ? user.gpa : (merged.gpa ?? 0.0),
      completedCreditHours: (user.completedCreditHours != null && user.completedCreditHours! > 0) 
          ? user.completedCreditHours 
          : merged.completedCreditHours,
      remainingCreditHours: (user.remainingCreditHours != null && user.remainingCreditHours! > 0)
          ? user.remainingCreditHours
          : merged.remainingCreditHours,
      totalCreditHours: user.totalCreditHours ?? merged.totalCreditHours,
      overallProgress: (user.overallProgress != null && user.overallProgress! > 0)
          ? user.overallProgress
          : merged.overallProgress,
    );

    // Save to preferences
    await _preferences.saveUserData(jsonEncode(updatedUser.toJson()));
    return updatedUser;
  }
}
