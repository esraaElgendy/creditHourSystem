/// API Constants for the application
class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://credithourssystem.premiumasp.net/api';
  
  // Auth Endpoints
  static const String login = '/Auth/login';
  static const String register = '/Auth/register';
  
  // Student Endpoints
  static const String studentProfile = '/Student/profile';
  static const String editProfile = '/Student/edit';
  static const String dashboard = '/Dashboard';
  
  // Course Endpoints
  static const String allCourses = '/Courses/all';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
