import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class LeadDetailsScreen extends StatelessWidget {
  final String leadId;
  final String leadName;

  const LeadDetailsScreen({
    super.key,
    required this.leadId,
    required this.leadName,
  });

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lead Details',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: cardColor,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'EDIT LEAD',
                    style: GoogleFonts.montserrat(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add_comment,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    'ADD REMARK',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Stage Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on, color: primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CURRENT STAGE',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Site Visit Scheduled',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        Text(
                          'Scheduled for Oct 24, 2023 • 02:30 PM',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('CLIENT DETAILS'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: const AssetImage(
                          'assets/images/logos.png',
                        ),
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jonathan Miller',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Lead ID: #L-88291',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCol('MOBILE', '+1 (555) 012-3456'),
                      ),
                      Expanded(child: _buildInfoCol('AGE', '38 Years')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCol(
                          'ANNUAL INCOME',
                          '\$185,000 / annum',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('ADVISOR DETAILS'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: const AssetImage(
                          'assets/images/logos.png',
                        ),
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sarah Jenkins',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Senior Portfolio Consultant',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.phone, color: primaryBlue, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCol('ADVISOR ID', 'ADV-9082-CORP'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('PROPERTY DETAILS'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCol('PROJECT NAME', 'Azure Waterfront Residencies'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildInfoCol('UNIT', 'Tower B - 1404'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildInfoCol(
                            'CONFIGURATION',
                            '3 BHK + Study',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('ACTIVITY TIMELINE'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildTimelineItem(
                    Icons.phone,
                    primaryBlue,
                    'Today, 10:45 AM',
                    'CONNECTED',
                    'Follow-up Call',
                    'Discussed the payment plan for the corner unit. Client requested a detailed breakdown of taxes.',
                    true,
                  ),
                  _buildTimelineItem(
                    Icons.mail_outline,
                    Colors.grey[400]!,
                    'Yesterday, 04:15 PM',
                    'SENT',
                    'Brochure Dispatched',
                    'Digital brochure and virtual tour link sent via email.',
                    true,
                  ),
                  _buildTimelineItem(
                    Icons.person_add_alt_1,
                    Colors.grey[400]!,
                    'Oct 20, 2023',
                    '',
                    'Lead Created',
                    'Sourced from Facebook Campaign (Real Estate 2023).',
                    false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.blue[900],
      ),
    ),
  );

  Widget _buildInfoCol(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );

  Widget _buildTimelineItem(
    IconData icon,
    Color iconBgColor,
    String time,
    String status,
    String title,
    String desc,
    bool showLine,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        time,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (status.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: status == 'CONNECTED'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: status == 'CONNECTED'
                                  ? Colors.green
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
