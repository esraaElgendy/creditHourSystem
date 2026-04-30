import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/course_cubit.dart';
import '../../../../core/bloc/course_registration_cubit.dart';
import '../../../../core/bloc/settings_cubit.dart';
import '../../../../core/models/course_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import 'course_details_screen.dart';
import 'schedule_details_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchCourses() {
    if (!mounted) return;
    final lang = Localizations.localeOf(context).languageCode;
    context.read<CourseCubit>().fetchCourses(lang: lang);
  }

  String _normalizeQuery(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // Arabic diacritics
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _matchesCourse(CourseModel course, String normalizedQuery) {
    if (normalizedQuery.isEmpty) return true;
    final langCode = Localizations.localeOf(context).languageCode;
    final normalizedName = _normalizeQuery(course.localizedName(langCode));
    final normalizedId = course.courseID.toString();
    return normalizedName.contains(normalizedQuery) ||
        normalizedId.contains(normalizedQuery);
  }

  List<LevelModel> _filterLevels(List<LevelModel> levels, String query) {
    final normalizedQuery = _normalizeQuery(query);
    if (normalizedQuery.isEmpty) return levels;

    return levels
        .map((level) {
          final filteredSemesters = level.semesters
              .map((semester) {
                final filteredCourses = semester.courses
                    .where((course) => _matchesCourse(course, normalizedQuery))
                    .toList();
                return SemesterModel(
                  semester: semester.semester,
                  courses: filteredCourses,
                );
              })
              .where((semester) => semester.courses.isNotEmpty)
              .toList();

          return LevelModel(level: level.level, semesters: filteredSemesters);
        })
        .where((level) => level.semesters.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        _fetchCourses();
      },
      child: BlocListener<CourseRegistrationCubit, CourseRegistrationState>(
        listener: (context, state) {
          if (state is CourseRegistrationUpdated && state.lastError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.lastError!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.yourCourses),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchCourses,
            ),
          ],
        ),
        body: BlocBuilder<CourseCubit, CourseState>(
          builder: (context, state) {
            if (state is CourseLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CourseError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchCourses,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is CourseLoaded) {
              final filteredLevels = _filterLevels(state.levels, _searchQuery);
              if (state.levels.isEmpty) {
                return Center(
                  child: Text(l10n.noLectures),
                ); // Fallback if no specific "no courses" key
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth < 360
                      ? 12.0
                      : 16.0;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: l10n.search,
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: isDark
                                    ? AppColors.inputFillDark
                                    : AppColors.cardLight.withValues(
                                        alpha: 0.65,
                                      ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (filteredLevels.isEmpty)
                              Expanded(
                                child: Center(
                                  child: Text(
                                    Localizations.localeOf(
                                              context,
                                            ).languageCode ==
                                            'ar'
                                        ? 'لا توجد نتائج مطابقة'
                                        : 'No matching courses found',
                                    style: theme.textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: ListView.builder(
                                  itemCount: filteredLevels.length,
                                  itemBuilder: (context, index) {
                                    final level = filteredLevels[index];
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${l10n.level} ${level.level}",
                                          style: AppTypography.subheadingL
                                              .copyWith(
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.primaryDark,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: AppTypography.spacingM,
                                        ),
                                        ...level.semesters.map((semester) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: AppTypography
                                                          .spacingS,
                                                    ),
                                                child: Text(
                                                  "${l10n.semester} ${semester.semester}",
                                                  style:
                                                      AppTypography.bodyMMuted(),
                                                ),
                                              ),
                                              ...semester.courses.map(
                                                (course) => _buildCourseItem(
                                                  context,
                                                  course,
                                                  l10n,
                                                  isDark,
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                        const SizedBox(height: 16),
                                      ],
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
}

  Widget _buildCourseItem(
    BuildContext context,
    CourseModel course,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final langCode = Localizations.localeOf(context).languageCode;

    return BlocBuilder<CourseRegistrationCubit, CourseRegistrationState>(
      builder: (context, state) {
        final isRegistered = context.read<CourseRegistrationCubit>().isRegistered(course.courseID);
        
        return Container(
          margin: const EdgeInsets.only(bottom: AppTypography.spacingM),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : const Color(0xffE0E4FF),
            borderRadius: BorderRadius.circular(AppTypography.radiusM),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTypography.spacingL,
              vertical: AppTypography.spacingS,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScheduleDetailsScreen(courseModel: course),
                ),
              );
            },
            title: Text(
              course.localizedName(langCode),
              style: AppTypography.subheadingM.copyWith(
                color: isDark ? Colors.white : AppColors.primaryDark,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.hourglass_bottom,
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
                const SizedBox(width: AppTypography.spacingXS),
                Text(
                  "${course.creditHours} ${l10n.creditHours}",
                  style: AppTypography.captionM.copyWith(
                    color: isDark ? Colors.grey[400] : null,
                  ),
                ),
              ],
            ),
            trailing: isRegistered 
                ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                : null,
          ),
        );
      },
    );
  }
}
