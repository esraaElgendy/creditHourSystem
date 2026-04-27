import 'package:flutter/material.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock Data based on screenshot
    final scheduleData = [
      {
        "day": "Saturday",
        "lectures": [
          {
            "name": "Computer Progaming", // Typography in screenshot
            "type": "LECTURE",
            "time": "08:00 - 10:00",
            "instructor": "Dr.Khaled",
            "location": "Hall A - Floor 2",
            "color": const Color(0xff5D65D8) // Purple/Blue
          },
          {
            "name": "Data Structures",
            "type": "LAB",
            "time": "10:30 - 12:00",
            "instructor": "Eng.Mariem",
            "location": "Lab 4 - Floor 4",
            "color": const Color(0xff4D5596) // Darker Blue
          }
        ]
      },
      {
        "day": "Sunday",
        "lectures": [] // Empty
      },
      {
        "day": "Monday",
        "lectures": [
          {
            "name": "Math 1",
            "type": "LECTURE",
            "time": "08:00 - 10:00",
            "instructor": "Dr.Hesham",
            "location": "Hall B - Floor 3",
            "color": const Color(0xff5D65D8)
          }
        ]
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mySchedule, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black), // Using default back button color or theme
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today_outlined, color: theme.primaryColor),
            onPressed: () {},
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: scheduleData.length,
        itemBuilder: (context, index) {
          final dayData = scheduleData[index];
          final String day = dayData['day'] as String;
          final List lectures = dayData['lectures'] as List;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  day,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              if (lectures.isEmpty)
                _buildEmptyState(context, isDark)
              else
                ...lectures.map((lecture) => _buildLectureCard(context, lecture, isDark)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLectureCard(BuildContext context, Map<String, dynamic> lecture, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E1E2C) : const Color(0xffEBEBFF), // Light purple bg from screenshot
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  lecture['name'],
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff2A31FA), // Blue text
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: lecture['type'] == 'LECTURE' ? const Color(0xff6C72FF) : const Color(0xff4D5596),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lecture['type'],
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time_filled, lecture['time'], isDark),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person, lecture['instructor'], isDark),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, lecture['location'], isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xff2A31FA)), // Blue icons
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: isDark ? Colors.grey[300] : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E1E2C) : const Color(0xffEBEBFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today, size: 40, color: const Color(0xff9DA2FF)),
          const SizedBox(height: 10),
          Text(
            l10n.noLectures,
            style: GoogleFonts.cairo(color: const Color(0xff9DA2FF), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
