import '../models/course_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

class CourseRepository {
  final ApiClient _apiClient;

  CourseRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<LevelModel>> getAllCourses({required String lang}) async {
    final response = await _apiClient.get(
      '${ApiConstants.allCourses}?lang=$lang',
      requiresAuth: true,
    );

    if (response['success'] == true) {
      final List data = response['data'] ?? [];
      return data.map((json) => LevelModel.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load courses');
    }
  }
}
