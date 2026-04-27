import 'package:flutter/material.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../l10n/app_localizations.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailsScreen({
    super.key,
    this.course = AppConstants.courseDetailsMath2, // Default mock for now
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  // Mock state for interactivity
  bool isRegistered = false; 

  @override
  void initState() {
    super.initState();
    isRegistered = widget.course['isRegistered'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final course = widget.course;
    
    // Derived values from mock
    final isFull = (course['enrolled'] ?? 0) >= (course['capacity'] ?? 0);
    final hasConflict = course['hasConflict'] ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    course['name'] ?? "Course Name",
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      course['code'] ?? "CODE",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
             ),
             const SizedBox(height: 10),
             Text(
                course['instructors'] ?? "",
                style: GoogleFonts.cairo(fontSize: 16),
             ),

             const SizedBox(height: 30),

             _buildInfoRow(Icons.access_time, l10n.creditHoursLabel(course['creditHours'] ?? 3), isDark),
             const SizedBox(height: 16),
             
             Text(
               course['time'] ?? "",
               style: GoogleFonts.cairo(fontSize: 16),
             ),
             const SizedBox(height: 10),
             Row(
               children: [
                 Text(l10n.prerequisites + " : ", style: GoogleFonts.cairo(fontSize: 16)),
                 Text(
                   course['prerequisite'] ?? "",
                   style: GoogleFonts.cairo(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                 ),
               ],
             ),

             const SizedBox(height: 30),
             
             Row(
                children: [
                  Icon(Icons.person_outline, size: 28, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    "${course['enrolled']}/${course['capacity']}",
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
             ),

             const SizedBox(height: 40),

             // Warnings
             if (isFull && !isRegistered)
                _buildWarning(l10n.courseFull),
             if (hasConflict && !isRegistered)
                _buildWarning(l10n.courseConflict),

             // Registration Status
             if (isRegistered)
               Padding(
                 padding: const EdgeInsets.only(bottom: 20),
                 child: Row(
                   children: [
                     const Icon(Icons.check_circle_outline, color: Colors.green),
                     const SizedBox(width: 8),
                     Text(l10n.registered, style: GoogleFonts.cairo(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                   ],
                 ),
               ),

             const Spacer(),

             // Action Button
             SizedBox(
               width: double.infinity,
               height: 55,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: isRegistered ? (isDark ? AppColors.inputFillDark : const Color(0xffDBDEFF)) : AppColors.primary,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   elevation: 0,
                 ),
                 onPressed: () {
                   setState(() {
                     isRegistered = !isRegistered;
                   });
                 },
                 child: Text(
                   isRegistered ? l10n.drop : l10n.register,
                   style: GoogleFonts.cairo(
                     fontSize: 20, 
                     fontWeight: FontWeight.bold,
                     color: isRegistered ? (isDark ? Colors.white : AppColors.primary) : Colors.white,
                   ),
                 ),
               ),
             ),
             const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 24, color: isDark ? Colors.grey[400] : Colors.grey[700]),
        const SizedBox(width: 10),
        Text(text, style: GoogleFonts.cairo(fontSize: 16)),
      ],
    );
  }

  Widget _buildWarning(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.red),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.cairo(color: Colors.red, fontSize: 16)),
        ],
      ),
    );
  }
}
