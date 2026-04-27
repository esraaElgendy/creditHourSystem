import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/student_cubit.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _majorController;
  late TextEditingController _phoneController;
  late String _studentID;
  String? selectedYear;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _majorController = TextEditingController();
    _phoneController = TextEditingController();
    _studentID = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = context.watch<StudentCubit>().state;
      if (state is StudentLoaded) {
        final user = state.user;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _majorController.text = user.major ?? '';
        _phoneController.text = user.phone ?? '';
        _studentID = user.studentId ?? user.id;
        selectedYear = user.year;
        _initialized = true;
      } else if (state is StudentLoading && state.previousUser != null) {
        final user = state.previousUser!;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _majorController.text = user.major ?? '';
        _phoneController.text = user.phone ?? '';
        _studentID = user.studentId ?? user.id;
        selectedYear = user.year;
        _initialized = true;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _majorController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<StudentCubit, StudentState>(
      listener: (context, state) {
        if (state is StudentLoaded && _initialized) {
          // Success! Show snackbar and close screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully"), 
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else if (state is StudentError) {
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
        final isLoading = state is StudentLoading;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: BackButton(color: theme.primaryColor),
            title: Text(l10n.editProfile, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Avatar
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.primaryColor,
                          child: _getAvatarChild(state, context),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    _buildLabel(l10n.name, isDark),
                    _buildTextField(controller: _nameController, isDark: isDark),
                    
                    const SizedBox(height: 16),
                    _buildLabel(l10n.email, isDark),
                    _buildTextField(controller: _emailController, isDark: isDark, keyboardType: TextInputType.emailAddress),
                    
                    const SizedBox(height: 16),
                    _buildLabel(l10n.major, isDark),
                    _buildTextField(controller: _majorController, isDark: isDark),

                    const SizedBox(height: 16),
                    _buildLabel(l10n.yourYear, isDark),
                    _buildYearDropDown(isDark),

                    const SizedBox(height: 16),
                    _buildLabel(l10n.phone, isDark),
                    _buildTextField(controller: _phoneController, isDark: isDark, keyboardType: TextInputType.phone),

                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isLoading ? null : _saveProfile,
                        child: isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              l10n.save, 
                              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() {
    final lang = Localizations.localeOf(context).languageCode;
    
    // Validate
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty"), backgroundColor: AppColors.error),
      );
      return;
    }

    context.read<StudentCubit>().updateProfile(
      studentID: _studentID,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      major: _majorController.text.trim(),
      year: selectedYear ?? '',
      phone: _phoneController.text.trim(),
      lang: lang,
    );
  }

  Widget _buildLabel(String label, bool isDark) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4),
        child: Text(
          label,
          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required bool isDark, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildYearDropDown(bool isDark) {
    final years = ["First Year", "Second Year", "Third Year", "Fourth Year"];
    if (selectedYear != null && !years.contains(selectedYear)) {
      years.add(selectedYear!);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedYear,
          isExpanded: true,
          hint: const Text("Select Year"),
          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
          items: years
              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.cairo(color: isDark ? Colors.white : Colors.black))))
              .toList(),
          onChanged: (val) {
            if(val != null) setState(() => selectedYear = val);
          },
        ),
      ),
    );
  }

  Widget _getAvatarChild(StudentState state, BuildContext context) {
    UserModel? user;
    if (state is StudentLoaded) {
      user = state.user;
    } else if (state is StudentLoading) {
      user = state.previousUser;
    } else if (state is StudentError) {
      user = state.previousUser;
    }

    if (user != null) {
      return Text(
        user.getLocalizedName(Localizations.localeOf(context).languageCode)
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase(),
        style: GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }
    return const Icon(Icons.person, size: 50, color: Colors.white);
  }
}
