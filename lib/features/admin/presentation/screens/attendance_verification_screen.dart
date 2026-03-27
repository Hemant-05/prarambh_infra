import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/attendance_review_screen.dart';
import '../../../../../core/theme/app_colors.dart';

class AttendanceVerificationScreen extends StatefulWidget {
  final String meetingName;
  final String meetingDate;

  const AttendanceVerificationScreen({
    super.key,
    required this.meetingName,
    required this.meetingDate,
  });

  @override
  State<AttendanceVerificationScreen> createState() =>
      _AttendanceVerificationScreenState();
}

class _AttendanceVerificationScreenState
    extends State<AttendanceVerificationScreen> {
  // Mocking the state locally for the UI demonstration
  List<Map<String, dynamic>> submissions = [
    {
      'id': '402',
      'name': 'Rahul Sharma',
      'in': '09:55 AM',
      'out': '11:05 AM',
      'late': false,
      'status': 'Pending',
    },
    {
      'id': '415',
      'name': 'Priya Desai',
      'in': '10:15 AM',
      'out': '11:10 AM',
      'late': true,
      'status': 'Pending',
    },
    {
      'id': '406',
      'name': 'Amit Verma',
      'in': '09:50 AM',
      'out': '11:00 AM',
      'late': false,
      'status': 'Approved',
    },
    {
      'id': '408',
      'name': 'Sneha Kapoor',
      'in': '09:58 AM',
      'out': '11:02 AM',
      'late': false,
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Attendance Verification',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              /* Verify All Logic */
            },
            child: Text(
              'Verify All',
              style: GoogleFonts.montserrat(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? Colors.grey[900] : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.meetingName,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.meetingDate} • 10:00 AM',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${submissions.length} Submissions',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment_turned_in_outlined,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          // List Section
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final sub = submissions[index];
                return _buildVerificationCard(
                  sub,
                  context,
                  primaryBlue,
                  isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(
    Map<String, dynamic> sub,
    BuildContext context,
    Color primaryBlue,
    bool isDark,
  ) {
    final cardColor = AppColors.getCardColor(context);
    final bool isApproved = sub['status'] == 'Approved';
    final textColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: () {
        // Navigate to the detailed review screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttendanceReviewScreen(
              advisorName: sub['name'],
              advisorId: sub['id'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Profile & Status
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: const AssetImage(
                        'assets/images/logos.png',
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isApproved ? Colors.green : Colors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sub['name'],
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isApproved ? Colors.grey : textColor,
                            ),
                          ),
                          isApproved
                              ? Text(
                                  'Approved',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'ID: ${sub['id']}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.login, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            sub['in'],
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isApproved ? Colors.grey : textColor,
                            ),
                          ),
                          if (sub['late'] == true) ...[
                            const SizedBox(width: 6),
                            Text(
                              'Late',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                          const SizedBox(width: 12),
                          Icon(Icons.logout, size: 12, color: Colors.red),
                          const SizedBox(width: 4),
                          Text(
                            sub['out'],
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isApproved ? Colors.grey : textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Photos & Actions (Conditional rendering based on approval status)
            if (!isApproved) ...[
              const SizedBox(height: 16),
              Text(
                'VERIFICATION PHOTOS',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPhotoThumbnail(true),
                  const SizedBox(width: 12),
                  _buildPhotoThumbnail(
                    sub['name'] != 'Sneha Kapoor',
                  ), // Simulating missing photo
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                      label: Text(
                        'Mark Absent',
                        style: GoogleFonts.montserrat(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 16,
                      ),
                      label: Text(
                        'Approve',
                        style: GoogleFonts.montserrat(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '2 Photos Verified',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mini thumbnails
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/logos.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-8, 0),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/logos.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Undo',
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(bool hasPhoto) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          style: hasPhoto ? BorderStyle.solid : BorderStyle.none,
        ),
        image: hasPhoto
            ? const DecorationImage(
                image: AssetImage('assets/images/logos.png'),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
    );
  }
}
