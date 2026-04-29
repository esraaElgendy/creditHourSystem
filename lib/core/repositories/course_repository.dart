import '../models/course_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

/// Repository for handling course-related API calls
class CourseRepository {
  final ApiClient _apiClient;

  CourseRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Fetch all courses grouped by level and semester
  ///
  /// Always fetches fresh data from the API (no caching)
  ///
  /// Parameters:
  ///   - lang: Language code ('en' or 'ar') for API response
  ///
  /// Returns:
  ///   List of [LevelModel] containing semesters and courses
  ///
  /// Throws:
  ///   - Exception if the API returns an error
  ///   - Exception if the response is malformed
  Future<List<LevelModel>> getAllCourses({required String lang}) async {
    try {
      // Always fetch fresh data - no caching
      final response = await _apiClient.get(
        '${ApiConstants.allCourses}?lang=$lang',
        requiresAuth: true,
      );

      // Check if response indicates success
      if (response['success'] == true) {
        final List data = response['data'] ?? [];

        // Parse each level from the response
        return data
            .map((json) {
              try {
                return LevelModel.fromJson(json);
              } catch (e) {
                // Skip malformed level entries and log the error
                print('Error parsing level: $e');
                return null;
              }
            })
            .whereType<LevelModel>()
            .toList();
      } else {
        // API indicated failure
        final errorMessage = response['message'] ?? 'Failed to load courses';
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Re-throw with more context
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error fetching courses: ${e.toString()}');
    }
  }
}
