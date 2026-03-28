import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_project_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/project_model.dart'; // NEW: Import the model

class AddProjectScreen extends StatefulWidget {
  // NEW: Optional parameter. If null, it's "Add". If provided, it's "Edit".
  final ProjectModel? existingProject;

  const AddProjectScreen({super.key, this.existingProject});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  int _currentStep = 0;

  // State Variables
  String _projectType = 'Residential';
  String _constructionStatus = 'New Launch';
  String _projectStatus = 'Ongoing';
  bool _reraApproved = true;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _devCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _reraCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _mapLinkCtrl = TextEditingController();
  final _marketValueCtrl = TextEditingController();
  final _budgetRangeCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _buildAreaCtrl = TextEditingController();
  final _totalPlotsCtrl = TextEditingController();
  final _amenitiesCtrl = TextEditingController();
  final _specialtiesCtrl = TextEditingController();

  // Media Files (New uploads)
  final List<File> _selectedImages = [];
  File? _selectedVideo;
  File? _selectedBrochure;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // NEW: Pre-fill data if we are in "Edit" mode
    if (widget.existingProject != null) {
      final p = widget.existingProject!;
      _nameCtrl.text = p.projectName;
      _devCtrl.text = p.developerName;
      _descCtrl.text = p.description;
      _reraCtrl.text = p.reraNumber;
      _addressCtrl.text = p.fullAddress;
      _cityCtrl.text = p.city;
      _mapLinkCtrl.text = p.locationMapUrl;
      _marketValueCtrl.text = p.marketValue.toString();
      _budgetRangeCtrl.text = p.budgetRange;
      _rateCtrl.text = p.ratePerSqft.toString();
      _buildAreaCtrl.text = p.buildArea;
      _totalPlotsCtrl.text = p.totalPlots.toString();
      _amenitiesCtrl.text = p.amenities.join(', ');
      _specialtiesCtrl.text = p.specialties.join(', ');

      _reraApproved = p.reraNumber.isNotEmpty;

      // Safe assignment for dropdowns to prevent crashes if DB has legacy data
      final validTypes = ['Residential', 'Commercial', 'Mixed Use'];
      if (validTypes.contains(p.projectType)) _projectType = p.projectType;

      final validStatus = ['New Launch', 'Under Construction', 'Ready to Move'];
      if (validStatus.contains(p.constructionStatus))
        _constructionStatus = p.constructionStatus;

      final validProjStatus = ['Completed', 'Ongoing', 'Upcoming'];
      if (validProjStatus.contains(p.status)) _projectStatus = p.status;
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(
        () => _selectedImages.addAll(images.map((img) => File(img.path))),
      );
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) setState(() => _selectedVideo = File(video.path));
  }

  Future<void> _pickBrochure() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null)
      setState(() => _selectedBrochure = File(result.files.single.path!));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _devCtrl.dispose();
    _descCtrl.dispose();
    _reraCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _mapLinkCtrl.dispose();
    _marketValueCtrl.dispose();
    _budgetRangeCtrl.dispose();
    _rateCtrl.dispose();
    _buildAreaCtrl.dispose();
    _totalPlotsCtrl.dispose();
    _amenitiesCtrl.dispose();
    _specialtiesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingProject != null; // NEW: Flag for UI logic

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Update Project' : 'Add Project', // Dynamic Title
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Info',
                        style: GoogleFonts.montserrat(
                          color: primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(height: 2, color: primaryBlue),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media & Config',
                        style: GoogleFonts.montserrat(
                          color: _currentStep == 1 ? primaryBlue : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        color: _currentStep == 1
                            ? primaryBlue
                            : Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Consumer<AdminProjectProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  if (_currentStep == 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep = 0),
                        child: const Text('Back'),
                      ),
                    )
                  else
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  const SizedBox(width: 16),

                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: provider.isSaving
                          ? null
                          : () async {
                              if (_currentStep == 0) {
                                setState(() => _currentStep = 1);
                              } else {
                                if (_nameCtrl.text.isEmpty ||
                                    _devCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill required fields.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                bool success;
                                if (isEditing) {
                                  // UPDATE EXISTING PROJECT
                                  success = await provider.modifyProject(
                                    id: widget.existingProject!.id.toString(),
                                    projectName: _nameCtrl.text,
                                    developerName: _devCtrl.text,
                                    city: _cityCtrl.text,
                                    fullAddress: _addressCtrl.text,
                                    projectType: _projectType,
                                    constructionStatus: _constructionStatus,
                                    marketValue: _marketValueCtrl.text,
                                    totalPlots: _totalPlotsCtrl.text,
                                    buildArea: _buildAreaCtrl.text,
                                    reraNumber: _reraCtrl.text,
                                    location: _mapLinkCtrl.text,
                                    ratePerSqft: _rateCtrl.text,
                                    budgetRange: _budgetRangeCtrl.text,
                                    description: _descCtrl.text,
                                    amenities: _amenitiesCtrl.text,
                                    specialties: _specialtiesCtrl.text,
                                    status: _projectStatus,
                                    projectImages: _selectedImages.isNotEmpty
                                        ? _selectedImages
                                        : null,
                                    videoFile: _selectedVideo,
                                    brochureFile: _selectedBrochure,
                                  );
                                } else {
                                  // CREATE NEW PROJECT
                                  success = await provider.createProject(
                                    projectName: _nameCtrl.text,
                                    developerName: _devCtrl.text,
                                    city: _cityCtrl.text,
                                    fullAddress: _addressCtrl.text,
                                    projectType: _projectType,
                                    constructionStatus: _constructionStatus,
                                    marketValue: _marketValueCtrl.text,
                                    totalPlots: _totalPlotsCtrl.text,
                                    buildArea: _buildAreaCtrl.text,
                                    reraNumber: _reraCtrl.text,
                                    location: _mapLinkCtrl.text,
                                    ratePerSqft: _rateCtrl.text,
                                    budgetRange: _budgetRangeCtrl.text,
                                    description: _descCtrl.text,
                                    amenities: _amenitiesCtrl.text,
                                    specialties: _specialtiesCtrl.text,
                                    projectImages: _selectedImages,
                                    videoFile: _selectedVideo,
                                    brochureFile: _selectedBrochure,
                                  );
                                }

                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEditing
                                            ? 'Project Updated Successfully!'
                                            : 'Project Created Successfully!',
                                      ),
                                    ),
                                  );
                                  Navigator.pop(
                                    context,
                                  ); // Pop back to list or details
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to save project. Check your connection.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: provider.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentStep == 0
                                  ? 'Next Step →'
                                  : (isEditing
                                        ? 'Save Changes ✓'
                                        : 'Publish Project ✓'),
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _currentStep == 0
            ? _buildStep1(primaryBlue, cardColor)
            : _buildStep2(primaryBlue, cardColor, isEditing),
      ),
    );
  }

  // --- STEP 1: Basic Info & Location ---
  Widget _buildStep1(Color primaryBlue, Color cardColor) {
    return Column(
      children: [
        _buildCard(cardColor, primaryBlue, 'Basic Details', Icons.business, [
          _buildTextField('Project Name', _nameCtrl),
          const SizedBox(height: 16),
          _buildTextField('Developer Name', _devCtrl),
          const SizedBox(height: 16),
          _buildTextField('Description', _descCtrl, maxLines: 3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  'Project Type',
                  _projectType,
                  ['Residential', 'Commercial', 'Mixed Use'],
                  (val) {
                    if (val != null) setState(() => _projectType = val);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  'Construction Status',
                  _constructionStatus,
                  ['New Launch', 'Under Construction', 'Ready to Move'],
                  (val) {
                    if (val != null) setState(() => _constructionStatus = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  'Project Status',
                  _projectStatus,
                  ['Completed', 'Ongoing', 'Upcoming'],
                  (val) {
                    if (val != null) setState(() => _projectStatus = val);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RERA Approved',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Switch(
                    value: _reraApproved,
                    activeThumbColor: primaryBlue,
                    onChanged: (v) => setState(() => _reraApproved = v),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_reraApproved) _buildTextField('RERA No.', _reraCtrl),
        ]),
        const SizedBox(height: 24),
        _buildCard(cardColor, primaryBlue, 'Location', Icons.location_on, [
          _buildTextField('Full Address', _addressCtrl, maxLines: 2),
          const SizedBox(height: 16),
          _buildTextField('City', _cityCtrl),
          const SizedBox(height: 16),
          _buildTextField('Google Maps Link', _mapLinkCtrl),
        ]),
      ],
    );
  }

  // --- STEP 2: Media, Config & Pricing ---
  Widget _buildStep2(Color primaryBlue, Color cardColor, bool isEditing) {
    return Column(
      children: [
        _buildCard(
          cardColor,
          primaryBlue,
          'Configuration & Pricing',
          Icons.tune,
          [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Total Units/Plots',
                    _totalPlotsCtrl,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField('Built-up Area', _buildAreaCtrl),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Market Value',
                    _marketValueCtrl,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    'Rate per Sqft',
                    _rateCtrl,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Budget Range (e.g. 50L - 1Cr)', _budgetRangeCtrl),
            const SizedBox(height: 16),
            _buildTextField('Amenities (Comma separated)', _amenitiesCtrl),
            const SizedBox(height: 16),
            _buildTextField('Specialties (Comma separated)', _specialtiesCtrl),
          ],
        ),
        const SizedBox(height: 24),

        _buildCard(cardColor, primaryBlue, 'Media Uploads', Icons.cloud_upload, [
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Note: Uploading new media will add to or replace existing files depending on backend logic.',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          GestureDetector(
            onTap: _pickImages,
            child: DottedBorder(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.blue[50],
                child: Column(
                  children: [
                    Icon(Icons.image, color: primaryBlue),
                    Text(
                      'Select Gallery Images',
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_selectedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                children: _selectedImages
                    .map(
                      (img) => Stack(
                        children: [
                          Image.file(
                            img,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedImages.remove(img)),
                              child: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 20),

          ListTile(
            onTap: _pickVideo,
            tileColor: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            leading: Icon(
              Icons.videocam,
              color: _selectedVideo != null ? Colors.green : Colors.grey,
            ),
            title: Text(
              _selectedVideo != null
                  ? 'New Video Selected'
                  : (isEditing && widget.existingProject!.videoUrl.isNotEmpty
                        ? 'Replace Existing Video'
                        : 'Select Preview Video'),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: _selectedVideo != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () => setState(() => _selectedVideo = null),
                  )
                : null,
          ),
          const SizedBox(height: 12),

          ListTile(
            onTap: _pickBrochure,
            tileColor: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            leading: Icon(
              Icons.picture_as_pdf,
              color: _selectedBrochure != null ? Colors.redAccent : Colors.grey,
            ),
            title: Text(
              _selectedBrochure != null
                  ? 'New Brochure Selected'
                  : (isEditing && widget.existingProject!.brochureUrl.isNotEmpty
                        ? 'Replace Existing Brochure'
                        : 'Select Brochure PDF'),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: _selectedBrochure != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () => setState(() => _selectedBrochure = null),
                  )
                : null,
          ),
        ]),
      ],
    );
  }

  // --- UI Helpers ---
  Widget _buildCard(
    Color cardColor,
    Color primaryBlue,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.montserrat(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.black87,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
