import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../../../core/theme/app_colors.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({Key? key}) : super(key: key);

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  int _currentStep = 0; // 0: Basic Info, 1: Amenities & Stats
  String _propertyType = 'Residential';
  String _constructionStatus = 'Ready to Move';

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('Add Project', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [TextButton(onPressed: (){}, child: Text('Save Draft', style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.w600)))],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Basic Info', style: GoogleFonts.montserrat(color: primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Container(height: 2, color: primaryBlue)])),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Amenities & Stats', style: GoogleFonts.montserrat(color: _currentStep == 1 ? primaryBlue : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Container(height: 2, color: _currentStep == 1 ? primaryBlue : Colors.grey[300])])),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20), color: Colors.white,
          child: Row(
            children: [
              if (_currentStep == 1) ...[
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentStep = 0), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Back', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)))),
                const SizedBox(width: 16),
              ] else ...[
                Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.grey[700], fontWeight: FontWeight.bold)))),
                const SizedBox(width: 16),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep == 0) setState(() => _currentStep = 1);
                    else { /* Submit Logic */ Navigator.pop(context); }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: Text(_currentStep == 0 ? 'Next Step →' : 'Publish Project ✓', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _currentStep == 0 ? _buildBasicInfoStep(primaryBlue, cardColor) : _buildAmenitiesStep(primaryBlue, cardColor),
      ),
    );
  }

  // --- STEP 1: Basic Info ---
  Widget _buildBasicInfoStep(Color primaryBlue, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Project Images'),
        DottedBorder(
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 30), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
            child: Column(children: [Icon(Icons.add_photo_alternate, color: primaryBlue, size: 32), const SizedBox(height: 8), Text('Upload Cover Image', style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold)), Text('Max size 5MB', style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 10))]),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)), const SizedBox(width: 12),
          Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)),
        ]),
        const SizedBox(height: 24),

        _buildCard(cardColor, primaryBlue, 'Project Details', Icons.business, [
          _buildTextField('PROJECT NAME', 'e.g. Prarambh Heights'), const SizedBox(height: 16),
          _buildTextField('DEVELOPER NAME', 'e.g. ABC Developers'), const SizedBox(height: 16),
          _buildTextField('RERA NO.', 'e.g. PR/GJ/AHMEDABAD/...'),
        ]),
        const SizedBox(height: 24),

        _buildCard(cardColor, primaryBlue, 'Configuration & Status', Icons.tune, [
          Text('PROPERTY TYPE', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])), const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _buildToggleBtn('Residential', _propertyType == 'Residential', () => setState(() => _propertyType = 'Residential'), primaryBlue)), const SizedBox(width: 12),
            Expanded(child: _buildToggleBtn('Commercial', _propertyType == 'Commercial', () => setState(() => _propertyType = 'Commercial'), primaryBlue)),
          ]),
          const SizedBox(height: 16),
          Text('AVAILABLE UNIT TYPES', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])), const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: ['2 BHK', '3 BHK', '4 BHK', 'Penthouse'].map((e) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)), child: Text(e, style: GoogleFonts.montserrat(fontSize: 12)))).toList()),
          const SizedBox(height: 16),
          _buildTextField('CONSTRUCTION STATUS', 'Ready to Move', isDropdown: true),
        ]),
        const SizedBox(height: 24),

        _buildCard(cardColor, primaryBlue, 'Location', Icons.location_on, [
          _buildTextField('FULL ADDRESS', 'Street address, City, Pincode', maxLines: 3), const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.map, size: 16), label: const Text('Pin on Map'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
        ]),
      ],
    );
  }

  // --- STEP 2: Amenities & Stats ---
  Widget _buildAmenitiesStep(Color primaryBlue, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('PROJECT INFRASTRUCTURE'),
        Row(children: [
          Expanded(child: _buildTextField('Total Towers', '0', icon: Icons.domain)), const SizedBox(width: 16),
          Expanded(child: _buildTextField('Floors per Tower', '0', icon: Icons.layers)),
        ]),
        const SizedBox(height: 16),
        _buildTextField('Total Units', 'Total number of apartments/shops', icon: Icons.grid_view),
        Text('Example: A-101, B-102 etc. range setup later', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 30),

        _buildSectionTitle('PROJECT BROCHURE'),
        DottedBorder(
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20), color: Colors.white, child: Column(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle), child: Icon(Icons.picture_as_pdf, color: primaryBlue)), const SizedBox(height: 8), Text('Tap to upload Brochure', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12)), Text('PDF format only (Max 5MB)', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey))])),
        ),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.picture_as_pdf, color: Colors.red), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Brochure_v1.pdf', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12)), Text('2.4 MB • Uploaded', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey))])), const Icon(Icons.close, color: Colors.grey, size: 16)])),
        const SizedBox(height: 30),

        _buildSectionTitle('SURROUNDING AMENITIES'),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 2.5, mainAxisSpacing: 12, crossAxisSpacing: 12,
          children: [
            _buildAmenityCheckbox('Gymnasium', 'Fitness center', false, primaryBlue),
            _buildAmenityCheckbox('Swimming Pool', 'Common pool', true, primaryBlue),
            _buildAmenityCheckbox('Club House', 'Recreation', false, primaryBlue),
            _buildAmenityCheckbox('Park / Garden', 'Green area', false, primaryBlue),
            _buildAmenityCheckbox('Mall', 'Shopping', false, primaryBlue),
            _buildAmenityCheckbox('Hospital', 'Nearby', false, primaryBlue),
          ],
        ),
        const SizedBox(height: 16),
        Text('+ Add custom amenity', style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 40),
      ],
    );
  }

  // --- Form Helpers ---
  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])));

  Widget _buildCard(Color cardColor, Color primaryBlue, String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryBlue.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: primaryBlue, size: 20), const SizedBox(width: 8), Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87))]), const SizedBox(height: 20), ...children]),
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1, bool isDropdown = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[Text(label, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])), const SizedBox(height: 8)],
        TextField(
          maxLines: maxLines, style: GoogleFonts.montserrat(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.grey) : null,
            suffixIcon: isDropdown ? const Icon(Icons.keyboard_arrow_down, color: Colors.grey) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true, fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleBtn(String text, bool isSelected, VoidCallback onTap, Color primaryBlue) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.center, decoration: BoxDecoration(color: isSelected ? primaryBlue : Colors.white, border: Border.all(color: isSelected ? primaryBlue : Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Text(text, style: GoogleFonts.montserrat(color: isSelected ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.w600))),
    );
  }

  Widget _buildAmenityCheckbox(String title, String subtitle, bool isSelected, Color primaryBlue) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: isSelected ? primaryBlue : Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [Checkbox(value: isSelected, activeColor: primaryBlue, onChanged: (v){}), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 11)), Text(subtitle, style: GoogleFonts.montserrat(fontSize: 9, color: Colors.grey))]))]),
    );
  }
}