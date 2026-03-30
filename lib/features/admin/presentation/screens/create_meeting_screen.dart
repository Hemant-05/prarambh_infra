import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../providers/admin_attendance_provider.dart';

class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedStartTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? _selectedStartTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedEndTime = picked);
  }

  // Helper to format TimeOfDay to the required API format (HH:mm:ss)
  String _formatApiTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      _showSnack('Please select a meeting date', isError: true);
      return;
    }
    if (_selectedStartTime == null) {
      _showSnack('Please select a start time', isError: true);
      return;
    }
    if (_selectedEndTime == null) {
      _showSnack('Please select an end time', isError: true);
      return;
    }

    // Format the payload exactly as the PHP backend expects
    final data = {
      'title': _titleCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'meeting_date': '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
      'start_time': _formatApiTime(_selectedStartTime!),
      'end_time': _formatApiTime(_selectedEndTime!)
    };

    final ok = await context.read<AdminAttendanceProvider>().addMeeting(data);
    if (!mounted) return;

    if (ok) {
      _showSnack('Meeting created successfully!');
      Navigator.pop(context, true); // return true → list refresh
    } else {
      _showSnack('Failed to create meeting. Please try again.', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.montserrat()),
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSaving = context.watch<AdminAttendanceProvider>().isSaving;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: false),
        title: Text('Create Meeting',
            style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: isSaving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            child: isSaving
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Create Meeting',
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Meeting Details',
                  style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 6),
              Text('Fill in the details below to schedule a meeting.',
                  style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[600], height: 1.4)),
              const SizedBox(height: 24),

              // Main card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meeting Title
                    _label('MEETING NAME *'),
                    _textField(
                      controller: _titleCtrl,
                      hint: 'e.g., Weekly Site Inspection',
                      icon: Icons.edit_outlined,
                      validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    // Date
                    _label('DATE *'),
                    _tapField(
                      value: _selectedDate == null
                          ? 'Select Date'
                          : '${_selectedDate!.day.toString().padLeft(2, '0')} / ${_selectedDate!.month.toString().padLeft(2, '0')} / ${_selectedDate!.year}',
                      icon: Icons.calendar_today_outlined,
                      placeholder: _selectedDate == null,
                      isDark: isDark,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),

                    // Time Row
                    Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _label('START TIME *'),
                          _tapField(
                            value: _selectedStartTime == null ? 'Select Time' : _selectedStartTime!.format(context),
                            icon: Icons.access_time_outlined,
                            placeholder: _selectedStartTime == null,
                            isDark: isDark,
                            onTap: _pickStartTime,
                          ),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _label('END TIME *'),
                          _tapField(
                            value: _selectedEndTime == null ? 'Select Time' : _selectedEndTime!.format(context),
                            icon: Icons.access_time_filled,
                            placeholder: _selectedEndTime == null,
                            isDark: isDark,
                            onTap: _pickEndTime,
                          ),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Location
                    _label('LOCATION'),
                    _textField(
                      controller: _locationCtrl,
                      hint: 'e.g., Sector 45, Prarambh HQ',
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryBlue.withOpacity(0.15)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline, color: primaryBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Once created, advisors can be marked present/absent from the Attendance Report screen.',
                      style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600], height: 1.5),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.montserrat(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 18),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.getPrimaryBlue(context))),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _tapField({
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required bool placeholder,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: Colors.grey[400], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: placeholder ? Colors.grey[400] : (isDark ? Colors.white : Colors.black87))),
          ),
        ]),
      ),
    );
  }
}