import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, String>> grades = [
      {
        "name": "Mechanics 1",
        "grade": "A-",
        "score": "3.7",
        "code": "4",
        "numeric": "91",
        "percentage": "91%",
        "semester": "1",
      },
      {
        "name": "CS Intro",
        "grade": "A",
        "score": "4",
        "code": "5",
        "numeric": "98",
        "percentage": "98%",
        "semester": "1",
      },
      {
        "name": "History",
        "grade": "B",
        "score": "3",
        "code": "6",
        "numeric": "82",
        "percentage": "82%",
        "semester": "1",
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTypography.spacingL,
                vertical: AppTypography.spacingXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppTypography.spacing3XL),
                  _buildPerformanceCard(isDark, grades),
                  const SizedBox(height: AppTypography.spacing3XL),
                  _buildSubjectGradesHeader(l10n),
                  const SizedBox(height: AppTypography.spacingL),
                  _buildGradesList(grades, isDark, l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(AppTypography.radiusM),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: AppTypography.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Grades',
                style: AppTypography.headingM.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: AppTypography.spacingXS),
              Text('Student Portal', style: AppTypography.bodyMSubtle()),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(AppTypography.radiusM),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(bool isDark, List<Map<String, String>> grades) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTypography.spacingXL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTypography.radius3XL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Academic\nPerformance',
                  style: AppTypography.headingM.copyWith(
                    color: AppColors.primaryDark,
                    height: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTypography.spacingM,
                  vertical: AppTypography.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppTypography.radiusXL),
                ),
                child: Text(
                  'ACTIVE',
                  style: AppTypography.badgeL.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTypography.spacingXXL),
          Row(
            children: [
              Expanded(
                child: _performanceStat(
                  label: 'GPA',
                  value: '3.7',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppTypography.spacingM),
              Expanded(
                child: _performanceStat(
                  label: 'Overall',
                  value: 'A',
                  subLabel: '(امتياز)',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppTypography.spacingM),
              Expanded(
                child: _performanceStat(
                  label: 'Points',
                  value: '11.1',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTypography.spacingXXL),
          _buildProgressBar(),
          const SizedBox(height: AppTypography.spacingM),
          Text('Level 1 - Semester 1', style: AppTypography.bodyMSubtle()),
          const SizedBox(height: AppTypography.spacingXS),
          Text(
            '${grades.length} subjects • Average ${grades.map((grade) => int.tryParse(grade['numeric'] ?? '0') ?? 0).fold<int>(0, (sum, value) => sum + value) ~/ grades.length}%',
            style: AppTypography.bodyMSubtle(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTypography.radiusM),
      child: Container(
        height: 12,
        color: AppColors.cardLight,
        child: Row(
          children: [
            Expanded(flex: 73, child: Container(color: AppColors.primary)),
            Expanded(flex: 27, child: Container(color: Colors.transparent)),
          ],
        ),
      ),
    );
  }

  Widget _performanceStat({
    required String label,
    required String value,
    String? subLabel,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTypography.spacingM,
        vertical: AppTypography.spacingM,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xffF6F7FF),
        borderRadius: BorderRadius.circular(AppTypography.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.captionMMuted()),
          const SizedBox(height: AppTypography.spacingXS),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.statisticL.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              if (subLabel != null) ...[
                const SizedBox(width: AppTypography.spacingXS),
                Text(subLabel, style: AppTypography.captionMMuted()),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectGradesHeader(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Subject Grades',
          style: AppTypography.headingS.copyWith(color: AppColors.primaryDark),
        ),
        Text(l10n.myGrades, style: AppTypography.subheadingMPrimary()),
      ],
    );
  }

  Widget _buildGradesList(
    List<Map<String, String>> grades,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      children: grades.map((grade) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTypography.spacingM),
          child: _buildGradeCard(grade, isDark, l10n),
        );
      }).toList(),
    );
  }

  Widget _buildGradeCard(
    Map<String, String> grade,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final gradeColor = _getGradeColor(grade['grade']!);
    return Container(
      padding: const EdgeInsets.all(AppTypography.spacingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTypography.radius2XL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              grade['grade']!,
              style: AppTypography.statisticL.copyWith(color: gradeColor),
            ),
          ),
          const SizedBox(width: AppTypography.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade['name']!,
                  style: AppTypography.subheadingL.copyWith(
                    color: isDark ? Colors.white : AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: AppTypography.spacingM),
                _gradeDetailRow('Course Code', grade['code'] ?? '--'),
                const SizedBox(height: AppTypography.spacingXS),
                _gradeDetailRow('Numeric Grade', grade['numeric'] ?? '–'),
                const SizedBox(height: AppTypography.spacingXS),
                _gradeDetailRow('${l10n.semester}', grade['semester'] ?? '1'),
              ],
            ),
          ),
          const SizedBox(width: AppTypography.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 72),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTypography.spacingM,
                  vertical: AppTypography.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTypography.radiusL),
                ),
                child: Text(
                  grade['percentage'] ?? '--',
                  textAlign: TextAlign.center,
                  style: AppTypography.buttonM.copyWith(color: gradeColor),
                ),
              ),
              const SizedBox(height: AppTypography.spacingM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTypography.spacingM,
                  vertical: AppTypography.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardLight,
                  borderRadius: BorderRadius.circular(AppTypography.radiusL),
                ),
                child: Text(
                  '${grade['score'] ?? ''} cr',
                  style: AppTypography.buttonS.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradeDetailRow(String label, String value) {
    return Text('$label • $value', style: AppTypography.bodySMuted());
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith("A")) return AppColors.gradeA;
    if (grade.startsWith("B")) return AppColors.gradeB;
    if (grade.startsWith("C")) return AppColors.gradeC;
    return AppColors.gradeF;
  }
}
