import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import '../repositories/student_repository.dart';

// Student States
abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {
  final UserModel? previousUser;
  const StudentLoading({this.previousUser});

  @override
  List<Object?> get props => [previousUser];
}

class StudentLoaded extends StudentState {
  final UserModel user;

  const StudentLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class StudentError extends StudentState {
  final String message;
  final UserModel? previousUser;

  const StudentError(this.message, {this.previousUser});

  @override
  List<Object?> get props => [message, previousUser];
}

// Student Cubit
class StudentCubit extends Cubit<StudentState> {
  final StudentRepository _studentRepository;

  StudentCubit({StudentRepository? studentRepository})
      : _studentRepository = studentRepository ?? StudentRepository(),
        super(StudentInitial());

  /// Load student dashboard from API
  Future<void> loadDashboard({String lang = 'en'}) async {
    final currentUser = state is StudentLoaded ? (state as StudentLoaded).user : null;
    emit(StudentLoading(previousUser: currentUser));
    try {
      final user = await _studentRepository.getDashboard();
      emit(StudentLoaded(user));
    } on ApiException catch (e) {
      final cachedUser = await _studentRepository.getCachedProfile();
      if (cachedUser != null) {
        emit(StudentLoaded(cachedUser));
      } else {
        emit(StudentError(e.message, previousUser: currentUser));
      }
    } catch (e) {
      final cachedUser = await _studentRepository.getCachedProfile();
      if (cachedUser != null) {
        emit(StudentLoaded(cachedUser));
      } else {
        emit(StudentError('Failed to load dashboard: ${e.toString()}', previousUser: currentUser));
      }
    }
  }

  /// Load student profile from API
  Future<void> loadProfile({String lang = 'en'}) async {
    final currentUser = state is StudentLoaded ? (state as StudentLoaded).user : null;
    emit(StudentLoading(previousUser: currentUser));
    try {
      final user = await _studentRepository.getProfile(lang: lang);
      emit(StudentLoaded(user));
    } on ApiException catch (e) {
      final cachedUser = await _studentRepository.getCachedProfile();
      if (cachedUser != null) {
        emit(StudentLoaded(cachedUser));
      } else {
        emit(StudentError(e.message, previousUser: currentUser));
      }
    } catch (e) {
      final cachedUser = await _studentRepository.getCachedProfile();
      if (cachedUser != null) {
        emit(StudentLoaded(cachedUser));
      } else {
        emit(StudentError('Failed to load profile: ${e.toString()}', previousUser: currentUser));
      }
    }
  }

  /// Load cached profile (for offline use)
  Future<void> loadCachedProfile() async {
    final cachedUser = await _studentRepository.getCachedProfile();
    if (cachedUser != null) {
      emit(StudentLoaded(cachedUser));
    }
  }

  /// Clear profile data
  void clearProfile() {
    emit(StudentInitial());
  }

  /// Update student profile
  Future<void> updateProfile({
    required String studentID,
    required String name,
    required String email,
    required String major,
    required String year,
    required String phone,
    String lang = 'en',
  }) async {
    final currentUser = state is StudentLoaded ? (state as StudentLoaded).user : null;
    emit(StudentLoading(previousUser: currentUser));
    try {
      final user = await _studentRepository.updateProfile(
        studentID: studentID,
        name: name,
        email: email,
        major: major,
        year: year,
        phone: phone,
        lang: lang,
      );
      emit(StudentLoaded(user));
    } on ApiException catch (e) {
      emit(StudentError(e.message, previousUser: currentUser));
    } catch (e) {
      emit(StudentError('Failed to update profile: ${e.toString()}', previousUser: currentUser));
    }
  }
}
