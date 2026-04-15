import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_contest_provider.dart';
import 'package:prarambh_infra/core/utils/validators.dart';
import 'package:flutter/services.dart';

class CreateContestScreen extends StatefulWidget {
  const CreateContestScreen({super.key});

  @override
  State<CreateContestScreen> createState() => _CreateContestScreenState();
}

class _CreateContestScreenState extends State<CreateContestScreen> {
  final _formKey = GlobalKey<FormState>();
  // Form Controllers
  final _titleCtrl = TextEditingController();
  final _rewardNameCtrl = TextEditingController();
  final _ruleController = TextEditingController();

  // State Variables
  DateTime? _startDate;
  DateTime? _endDate;
  File? _rewardImage;
  final List<String> _rules = [
    'Minimum of 5 deals closed to qualify for the grand prize.',
    'All entries must be logged in CRM by 5 PM Friday.',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _rewardNameCtrl.dispose();
    _ruleController.dispose();
    super.dispose();
  }

  // --- Pickers ---
  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Auto-adjust end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _rewardImage = File(result.files.single.path!);
      });
    }
  }

  // --- Actions ---
  void _addRule() {
    if (_ruleController.text.trim().isNotEmpty) {
      setState(() {
        _rules.add(_ruleController.text.trim());
        _ruleController.clear();
      });
    }
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
    });
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _submitContest() async {
    // 1. Validation
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      return _showSnack('Start and End dates are required.');
    }
    if (_rewardImage == null) return _showSnack('Reward image is required.');

    // 2. Call Provider
    final provider = context.read<AdminContestProvider>();
    final success = await provider.createContest(
      title: _titleCtrl.text.trim(),
      startDate: _formatDate(_startDate!),
      endDate: _formatDate(_endDate!),
      rewardName: _rewardNameCtrl.text.trim(),
      rules: jsonEncode(
        _rules,
      ), // Encode rules array to JSON string for backend
      rewardImage: _rewardImage!,
    );

    if (!mounted) return;

    if (success) {
      _showSnack('Contest launched successfully!', isError: false);
      Navigator.pop(context);
    } else {
      _showSnack('Failed to launch contest. Try again.');
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        leading: backButton(isDark: isDark),
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
          child: Consumer<AdminContestProvider>(
            builder: (context, provider, child) {
              return ElevatedButton.icon(
                onPressed: provider.isSaving ? null : _submitContest,
                icon: provider.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.rocket_launch, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: Text(
                  provider.isSaving ? 'Launching...' : 'Launch Contest',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Section 1: Details
            _buildSectionCard(
              cardColor,
              'Contest Details',
              Icons.description_outlined,
              [
                _buildInputLabel('Contest Title'),
                _buildTextField(
                  'e.g., Q3 Sales Sprint',
                  controller: _titleCtrl,
                  validator: (v) => Validators.validateRequired(v, 'Contest Title'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Start Date'),
                          _buildTextField(
                            _startDate == null
                                ? 'Select Date'
                                : _formatDate(_startDate!),
                            icon: Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: () => _pickDate(true),
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
                            _endDate == null
                                ? 'Select Date'
                                : _formatDate(_endDate!),
                            icon: Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: () => _pickDate(false),
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
              'Reward',
              Icons.emoji_events_outlined,
              [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: DottedBorder(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _rewardImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _rewardImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Upload',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Reward Name'),
                          _buildTextField(
                            'e.g. Weekend Trip to Goa',
                            controller: _rewardNameCtrl,
                            validator: (v) => Validators.validateRequired(v, 'Reward Name'),
                          ),
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
                          'Ensure the reward image is clear and engaging.',
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
                        GestureDetector(
                          onTap: () => _removeRule(entry.key),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
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
                        onSubmitted: (_) => _addRule(),
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

  Widget _buildTextField(
    String hint, {
    IconData? icon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
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
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
