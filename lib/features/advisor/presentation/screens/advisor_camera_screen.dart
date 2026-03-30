import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/advisor_meeting_model.dart';
import 'advisor_attendance_preview_screen.dart';

class AdvisorCameraScreen extends StatefulWidget {
  final AdvisorMeetingModel meeting;
  const AdvisorCameraScreen({super.key, required this.meeting});

  @override
  State<AdvisorCameraScreen> createState() => _AdvisorCameraScreenState();
}

class _AdvisorCameraScreenState extends State<AdvisorCameraScreen> {
  CameraController? _controller;
  bool _isReady = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = "No cameras found on this device.");
        return;
      }

      // Default to front camera for selfies
      final frontCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);

      _controller = CameraController(frontCamera, ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isReady = true;
        _errorMessage = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isReady = false;
        _errorMessage = "Camera Error: Please restart the app or grant camera permissions.\n\n($e)";
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdvisorAttendancePreviewScreen(meeting: widget.meeting, imageFile: File(image.path))),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to take photo')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text('Check-in Photo Verification', style: GoogleFonts.montserrat(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Viewfinder Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The Camera Feed or Error State
                  if (_isReady && _controller != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: CameraPreview(_controller!),
                      ),
                    )
                  else if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
                      child: Center(
                        child: Text(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade800)),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(16)),
                      child: const Center(child: CircularProgressIndicator()),
                    ),

                  // Live View Badge
                  Positioned(
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, color: Colors.redAccent, size: 8),
                          const SizedBox(width: 6),
                          Text('LIVE VIEW', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  // Viewfinder Corners Overlay
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ViewfinderPainter(color: Colors.white.withOpacity(0.8), strokeWidth: 4, cornerLength: 40),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Please ensure your face or the site is\nclearly visible inside the frame.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: Colors.grey[600], fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 40),

          // Capture Button
          GestureDetector(
            onTap: _isReady ? _capturePhoto : null,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _isReady ? Colors.grey.shade300 : Colors.grey.shade200, width: 4),
              ),
              child: Center(
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: _isReady ? primaryBlue : Colors.grey.shade300, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;

  ViewfinderPainter({required this.color, required this.strokeWidth, required this.cornerLength});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;
    const double p = 20.0;

    canvas.drawLine(const Offset(p, p + 40), const Offset(p, p), paint);
    canvas.drawLine(const Offset(p, p), const Offset(p + 40, p), paint);
    canvas.drawLine(Offset(w - p - 40, p), Offset(w - p, p), paint);
    canvas.drawLine(Offset(w - p, p), Offset(w - p, p + 40), paint);
    canvas.drawLine(Offset(p, h - p - 40), Offset(p, h - p), paint);
    canvas.drawLine(Offset(p, h - p), Offset(p + 40, h - p), paint);
    canvas.drawLine(Offset(w - p - 40, h - p), Offset(w - p, h - p), paint);
    canvas.drawLine(Offset(w - p, h - p), Offset(w - p, h - p - 40), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}