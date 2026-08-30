import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../providers/admin_attendance_provider.dart';
import 'package:prarambh_infra/core/utils/validators.dart';
import '../../data/models/meeting_model.dart';

class CreateMeetingScreen extends StatefulWidget {
  final MeetingModel? existingMeeting;
  const CreateMeetingScreen({super.key, this.existingMeeting});

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
  File? _selectedVideo;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.existingMeeting != null) {
      final m = widget.existingMeeting!;
      _titleCtrl.text = m.title;
      _locationCtrl.text = m.location;
      if (m.date.isNotEmpty) {
        _selectedDate = DateTime.tryParse(m.date);
      }
      if (m.time.isNotEmpty && m.time != '--:--') {
        final parts = m.time.split(':');
        if (parts.length >= 2) {
          _selectedStartTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
      if (m.endTime.isNotEmpty && m.endTime != '--:--') {
        final parts = m.endTime.split(':');
        if (parts.length >= 2) {
          _selectedEndTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    }
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'webm'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  String _formatTime12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedStartTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? _selectedStartTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedEndTime = picked);
  }

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

    // Basic time validation
    final startMins = _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
    final endMins = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;

    if (endMins <= startMins) {
      _showSnack('End time must be after start time', isError: true);
      return;
    }

    final data = {
      'title': _titleCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'meeting_date':
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
      'start_time': _formatApiTime(_selectedStartTime!),
      'end_time': _formatApiTime(_selectedEndTime!),
    };

    final provider = context.read<AdminAttendanceProvider>();
    
    if (widget.existingMeeting != null) {
      // UPDATE MEETING
      final success = await provider.updateMeeting(widget.existingMeeting!.id, data, image: _selectedImage);
      if (!mounted) return;
      if (success) {
        _showSnack('Meeting updated successfully!');
        if (_selectedVideo != null) {
          _showSnack('Starting video upload in background...');
          provider.uploadVideoInBackground(widget.existingMeeting!.id, _selectedVideo!);
        }
        Navigator.pop(context, true);
      } else {
        _showSnack('Failed to update meeting. Please try again.', isError: true);
      }
    } else {
      // CREATE MEETING
      final meetingId = await provider.addMeeting(data, image: _selectedImage);
      if (!mounted) return;
      if (meetingId != null) {
        _showSnack('Meeting created successfully!');
        if (_selectedVideo != null) {
          _showSnack('Starting video upload in background...');
          provider.uploadVideoInBackground(meetingId, _selectedVideo!);
        }
        Navigator.pop(context, true);
      } else {
        _showSnack('Failed to create meeting. Please try again.', isError: true);
      }
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
    final isEdit = widget.existingMeeting != null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: false),
        title: Text(
          isEdit ? 'Edit Meeting' : 'Create Meeting',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: isSaving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
            ),
            child: isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isEdit ? 'Update Meeting' : 'Create Meeting',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
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
              Text(
                isEdit ? 'Edit Meeting Details' : 'Meeting Details',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('MEETING NAME *'),
                    _textField(
                      controller: _titleCtrl,
                      hint: 'e.g., Weekly Site Inspection',
                      icon: Icons.edit_outlined,
                      validator: (v) =>
                          Validators.validateRequired(v, 'Meeting Name'),
                    ),
                    const SizedBox(height: 16),
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

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('START TIME *'),
                              _tapField(
                                value: _selectedStartTime == null
                                    ? 'Select Time'
                                    : _formatTime12Hour(_selectedStartTime!),
                                icon: Icons.access_time_outlined,
                                placeholder: _selectedStartTime == null,
                                isDark: isDark,
                                onTap: _pickStartTime,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('END TIME *'),
                              _tapField(
                                value: _selectedEndTime == null
                                    ? 'Select Time'
                                    : _formatTime12Hour(_selectedEndTime!),
                                icon: Icons.access_time_outlined,
                                placeholder: _selectedEndTime == null,
                                isDark: isDark,
                                onTap: _pickEndTime,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _label('LOCATION'),
                    _textField(
                      controller: _locationCtrl,
                      hint: 'e.g., Sector 45, Prarambh HQ',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    
                    _label('MEETING IMAGE (OPTIONAL)'),
                    if (isEdit && _selectedImage == null && widget.existingMeeting!.imageUrl.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(widget.existingMeeting!.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                    if (_selectedImage != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.image_outlined, color: primaryBlue, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedImage != null
                                    ? _selectedImage!.path.split('/').last.split('\\').last
                                    : (isEdit && widget.existingMeeting!.imageUrl.isNotEmpty
                                        ? 'Change Meeting Image'
                                        : 'Upload Meeting Image'),
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _label('ATTENDANCE VIDEO (OPTIONAL)'),
                    if (isEdit && _selectedVideo == null && widget.existingMeeting!.videoUrl.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _MeetingVideoPlayer(videoUrl: widget.existingMeeting!.videoUrl),
                        ),
                      ),
                    ],
                    GestureDetector(
                      onTap: _pickVideo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.video_file_outlined, color: _selectedVideo != null ? primaryBlue : Colors.grey[400], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedVideo != null
                                    ? _selectedVideo!.path.split('/').last.split('\\').last
                                    : (isEdit && widget.existingMeeting!.videoUrl.isNotEmpty
                                        ? 'Change uploaded video...'
                                        : 'Select a video file...'),
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  color: (_selectedVideo != null || (isEdit && widget.existingMeeting!.videoUrl.isNotEmpty))
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : Colors.grey[400],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedVideo != null)
                              GestureDetector(
                                onTap: () => setState(() => _selectedVideo = null),
                                child: const Icon(Icons.close, color: Colors.grey, size: 18),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryBlue.withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: primaryBlue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Meetings will automatically transition to "Completed" once the End Time has passed.',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
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

class _MeetingVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _MeetingVideoPlayer({required this.videoUrl});

  @override
  State<_MeetingVideoPlayer> createState() => _MeetingVideoPlayerState();
}

class _MeetingVideoPlayerState extends State<_MeetingVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white,
        ),
      );
    } catch (e) {
      debugPrint("Error initializing video player: $e");
      _hasError = true;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            'Failed to load video',
            style: GoogleFonts.montserrat(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized
        ? Chewie(controller: _chewieController!)
        : const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}