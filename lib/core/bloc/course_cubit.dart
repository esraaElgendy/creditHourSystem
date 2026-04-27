import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';

abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<LevelModel> levels;

  const CourseLoaded(this.levels);

  @override
  List<Object?> get props => [levels];
}

class CourseError extends CourseState {
  final String message;

  const CourseError(this.message);

  @override
  List<Object?> get props => [message];
}

class CourseCubit extends Cubit<CourseState> {
  final CourseRepository _courseRepository;

  CourseCubit({CourseRepository? courseRepository})
      : _courseRepository = courseRepository ?? CourseRepository(),
        super(CourseInitial());

  Future<void> fetchCourses({required String lang}) async {
    emit(CourseLoading());
    try {
      final levels = await _courseRepository.getAllCourses(lang: lang);
      emit(CourseLoaded(levels));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }
}
