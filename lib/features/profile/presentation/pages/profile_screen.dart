import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/auth_cubit.dart';
import '../../../../core/bloc/settings_cubit.dart';
import '../../../../core/bloc/student_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Logic: Ensure we have the latest data from the backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
    });
  }

  void _fetchProfile() {
    final lang = Localizations.localeOf(context).languageCode;
    context.read<StudentCubit>().loadProfile(lang: lang);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<StudentCubit, StudentState>(
      listener: (context, state) {
        if (state is StudentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        // Implementation: Map Cubit state to Profile UI fields
        String studentName = l10n.students;
        String studentId = '';
        String studentEmail = '';
        String studentMajor = '';
        String studentYear = '';
        String studentPhone = '';
        double gpa = 0.0;
        int completedHours = 0;
        int remainingHours = 0;
        int totalHours = 0;

        if (state is StudentLoaded) {
          final user = state.user;
          final langCode = Localizations.localeOf(context).languageCode;
          studentName = user.getLocalizedName(langCode);
          studentId = user.studentId ?? '';
          studentEmail = user.email;
          studentMajor = user.major ?? '';
          studentYear = user.year ?? '';
          studentPhone = user.phone ?? '';
          gpa = user.gpa ?? 0.0;
          completedHours = user.completedCreditHours ?? 0;
          remainingHours = user.remainingCreditHours ?? 0;
          // totalHours calculation removed as it was unused
        } else if (state is StudentLoading && state.previousUser != null) {
          final user = state.previousUser!;
          final langCode = Localizations.localeOf(context).languageCode;
          studentName = user.getLocalizedName(langCode);
          studentId = user.studentId ?? '';
          studentEmail = user.email;
          studentMajor = user.major ?? '';
          studentYear = user.year ?? '';
          studentPhone = user.phone ?? '';
          gpa = user.gpa ?? 0.0;
          completedHours = user.completedCreditHours ?? 0;
          remainingHours = user.remainingCreditHours ?? 0;
        } else if (state is StudentError && state.previousUser != null) {
          final user = state.previousUser!;
          final langCode = Localizations.localeOf(context).languageCode;
          studentName = user.getLocalizedName(langCode);
          studentId = user.studentId ?? '';
          studentEmail = user.email;
          studentMajor = user.major ?? '';
          studentYear = user.year ?? '';
          studentPhone = user.phone ?? '';
          gpa = user.gpa ?? 0.0;
          completedHours = user.completedCreditHours ?? 0;
          remainingHours = user.remainingCreditHours ?? 0;
        }

        final initials = studentName.isNotEmpty && studentName != l10n.students
            ? studentName.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
            : 'ST';

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              l10n.profile,
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
            ),
            iconTheme: IconThemeData(color: theme.primaryColor),
          ),
          body: RefreshIndicator(
            onRefresh: () async => _fetchProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Premium Header Design
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: theme.primaryColor,
                                child: Text(
                                  initials,
                                  style: GoogleFonts.cairo(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          studentName,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : theme.primaryColor,
                          ),
                        ),
                        if (studentId.isNotEmpty)
                          Text(
                            "${l10n.studentId}: $studentId",
                            style: GoogleFonts.cairo(
                              color: AppColors.textGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Academic Summary Grid (GPA, Completed, Remaining)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.academicSummary,
                          style: GoogleFonts.cairo(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                context,
                                gpa.toStringAsFixed(2),
                                l10n.gba,
                                Icons.star_rounded,
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                context,
                                completedHours.toString(),
                                l10n.completedCreditHours,
                                Icons.task_alt_rounded,
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                context,
                                remainingHours.toString(),
                                l10n.remainingCreditHours,
                                Icons.hourglass_top_rounded,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // User Info Details Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDetailItem(l10n.email, studentEmail, Icons.email_rounded, theme),
                          _buildDetailItem(l10n.phone, studentPhone, Icons.phone_rounded, theme),
                          _buildDetailItem(l10n.major, studentMajor, Icons.account_tree_rounded, theme),
                          _buildDetailItem(l10n.yourYear, studentYear, Icons.calendar_today_rounded, theme, isLast: true),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // App Settings Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dashboard, // Using as section header
                          style: GoogleFonts.cairo(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: isDark ? Border.all(color: Colors.grey[800]!) : null,
                          ),
                          child: Column(
                            children: [
                              _buildSettingsTile(
                                context: context,
                                icon: Icons.language_rounded,
                                title: l10n.language,
                                trailing: Text(
                                  AppLocalizations.of(context)!.localeName == 'ar' ? 'العربية' : 'English',
                                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                ),
                                onTap: () => context.read<SettingsCubit>().toggleLocale(),
                              ),
                              const Divider(height: 1, indent: 50),
                              BlocBuilder<SettingsCubit, SettingsState>(
                                builder: (context, settings) {
                                  return _buildSettingsTile(
                                    context: context,
                                    icon: settings.themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                    title: l10n.darkMode,
                                    onTap: () {},
                                    trailing: Switch(
                                      value: settings.themeMode == ThemeMode.dark,
                                      onChanged: (val) => context.read<SettingsCubit>().toggleTheme(val),
                                      activeThumbColor: theme.primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Action Buttons logic
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.edit_rounded, size: 20),
                                const SizedBox(width: 10),
                                Text(l10n.editProfile, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: () {
                              _showLogoutDialog(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout_rounded, size: 20),
                                const SizedBox(width: 10),
                                Text(l10n.logout, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
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

  Widget _buildDetailItem(String label, String value, IconData icon, ThemeData theme, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.primaryColor, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500)),
                Text(
                  value.isNotEmpty ? value : '---',
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String value, String label, IconData icon, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1)),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.primaryColor, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.normal)),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
              context.read<StudentCubit>().clearProfile();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
