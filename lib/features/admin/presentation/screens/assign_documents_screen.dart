import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/advisor_application_model.dart';

class AssignDocumentsScreen extends StatefulWidget {
  final AdvisorApplicationModel advisor;
  const AssignDocumentsScreen({Key? key, required this.advisor}) : super(key: key);

  @override
  State<AssignDocumentsScreen> createState() => _AssignDocumentsScreenState();
}

class _AssignDocumentsScreenState extends State<AssignDocumentsScreen> {
  bool selectAll = true;
  List<bool> selectedDocs = [true, true, false, false];

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Assign Documents', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: cardColor,
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              // Finish assignment and go to dashboard
              Navigator.popUntil(context, ModalRoute.withName('/admin_dashboard'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            label: Text('Confirm and Send', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.send, color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Advisor Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryBlue.withOpacity(0.5))),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(radius: 30, backgroundColor: Colors.grey[300], backgroundImage: const AssetImage('assets/images/logos.png')),
                      Positioned(bottom: 0, right: 0, child: Container(decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.verified, color: Colors.green, size: 20))),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.advisor.name, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      Text('Advisor ID: ${widget.advisor.displayId}', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 4),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text('Verified', style: GoogleFonts.montserrat(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Select Documents Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryBlue.withOpacity(0.5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Documents', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      Text('4 documents available for assignment', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                  Switch(
                    value: selectAll,
                    activeColor: primaryBlue,
                    onChanged: (val) {
                      setState(() {
                        selectAll = val;
                        selectedDocs = [val, val, val, val];
                      });
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Documents List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.3))),
              child: Column(
                children: [
                  _buildDocRow('Welcome Letter', '250 KB', 0, primaryBlue, textColor),
                  const Divider(),
                  _buildDocRow('Application Form', '1.2 MB', 1, primaryBlue, textColor),
                  const Divider(),
                  _buildDocRow('Circulars', '500 KB', 2, primaryBlue, textColor),
                  const Divider(),
                  _buildDocRow('ID Card', '400 KB', 3, primaryBlue, textColor),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Advisor Code
            Text('ADVISOR CODE', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                filled: true, fillColor: cardColor,
                hintText: 'PRI00001',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDocRow(String title, String size, int index, Color primaryBlue, Color textColor) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.description, color: primaryBlue)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
              Text('PDF • $size', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload, size: 14, color: Colors.white),
          label: Text('Upload', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        ),
        Checkbox(
          value: selectedDocs[index],
          activeColor: primaryBlue,
          onChanged: (val) {
            setState(() => selectedDocs[index] = val!);
          },
        )
      ],
    );
  }
}