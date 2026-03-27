import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../../core/theme/app_colors.dart';

class CreateContestScreen extends StatefulWidget {
  const CreateContestScreen({super.key});

  @override
  State<CreateContestScreen> createState() => _CreateContestScreenState();
}

class _CreateContestScreenState extends State<CreateContestScreen> {
  final List<String> _rules = [
    'Minimum of 5 deals closed to qualify for the grand prize.',
    'All entries must be logged in CRM by 5 PM Friday.',
  ];
  final _ruleController = TextEditingController();

  void _addRule() {
    if (_ruleController.text.trim().isNotEmpty) {
      setState(() {
        _rules.add(_ruleController.text.trim());
        _ruleController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.montserrat(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          'Create Contest',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: () {
              /* Submit Logic */
              Navigator.pop(context);
            },
            icon: const Icon(Icons.rocket_launch, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            label: Text(
              'Launch Contest',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Section 1: Details
            _buildSectionCard(
              cardColor,
              'Contest Details',
              Icons.description_outlined,
              [
                _buildInputLabel('Contest Title'),
                _buildTextField('e.g., Q3 Sales Sprint'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Start Date'),
                          _buildTextField(
                            'mm/dd/yyyy',
                            icon: Icons.calendar_today_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('End Date'),
                          _buildTextField(
                            'mm/dd/yyyy',
                            icon: Icons.calendar_today_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section 2: Reward
            _buildSectionCard(
              cardColor,
              'Reward Configuration',
              Icons.emoji_events_outlined,
              [
                Row(
                  children: [
                    DottedBorder(
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[50],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, color: Colors.grey[400]),
                            Text(
                              'Icon',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Reward Name'),
                          _buildTextField('e.g. Weekend Trip to Goa'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: primaryBlue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Top 3 performers will receive this reward.',
                          style: GoogleFonts.montserrat(
                            color: primaryBlue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section 3: Rules
            _buildSectionCard(
              cardColor,
              'Contest Rules',
              Icons.gavel_outlined,
              [
                ..._rules.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            '${entry.key + 1}',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildInputLabel('Add New Rule'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ruleController,
                        style: GoogleFonts.montserrat(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Type a new rule here...',
                          hintStyle: GoogleFonts.montserrat(
                            color: Colors.grey[400],
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.add, color: primaryBlue),
                        onPressed: _addRule,
                      ),
                    ),
                  ],
                ),
              ],
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_rules.length} added',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    Color cardColor,
    String title,
    IconData icon,
    List<Widget> children, {
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[900], size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    ),
  );

  Widget _buildTextField(String hint, {IconData? icon}) {
    return TextField(
      style: GoogleFonts.montserrat(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
        suffixIcon: icon != null
            ? Icon(icon, color: Colors.grey[400], size: 20)
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
