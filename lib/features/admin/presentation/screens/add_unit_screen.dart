import 'dart:io';
import 'package:excel/excel.dart' show Excel;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_project_provider.dart';

class AddUnitScreen extends StatefulWidget {
  final int projectId;
  const AddUnitScreen({super.key, required this.projectId});

  @override
  State<AddUnitScreen> createState() => _AddUnitScreenState();
}

class _AddUnitScreenState extends State<AddUnitScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Controllers
  final _towerCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();

  // NEW Controllers to match JSON
  final _locationCtrl = TextEditingController();
  final _plotNumCtrl = TextEditingController();
  final _plotDimCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();

  // Dropdown States
  String _config = '3BHK';
  String _type = 'Apartment';
  String _saleCategory = 'New Sale';
  String _facing = 'East';
  String _status = 'Available';

  // Bulk Upload State
  File? _selectedExcelFile;
  final List<Map<String, dynamic>> _parsedBulkData = [];
  bool _isParsing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _towerCtrl.dispose();
    _floorCtrl.dispose();
    _unitCtrl.dispose();
    _areaCtrl.dispose();
    _rateCtrl.dispose();
    _locationCtrl.dispose();
    _plotNumCtrl.dispose();
    _plotDimCtrl.dispose();
    _sizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndParseExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result != null) {
      setState(() {
        _isParsing = true;
        _selectedExcelFile = File(result.files.single.path!);
        _parsedBulkData.clear();
      });

      try {
        var bytes = _selectedExcelFile!.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);
        String sheetName = excel.tables.keys.first;
        var table = excel.tables[sheetName]!;

        for (int i = 1; i < table.maxRows; i++) {
          var row = table.row(i);
          if (row.isEmpty || row[0]?.value == null) continue;

          _parsedBulkData.add({
            "project_id": widget.projectId,
            "tower_name": row[0]?.value?.toString() ?? "",
            "floor_number": row[1]?.value?.toString() ?? "",
            "unit_number": row[2]?.value?.toString() ?? "",
            "configuration": row[3]?.value?.toString() ?? "3BHK",
            "property_type": row[4]?.value?.toString() ?? "Apartment",
            "sale_category": row[5]?.value?.toString() ?? "New Sale",
            "facing": row[6]?.value?.toString() ?? "East",
            "Location": row[7]?.value?.toString() ?? "",
            "plot_number": row[8]?.value?.toString() ?? "",
            "plot_dimensions": row[9]?.value?.toString() ?? "",
            "area_sqft":
                double.tryParse(row[10]?.value?.toString() ?? '0') ?? 0,
            "rate_per_sqft":
                double.tryParse(row[11]?.value?.toString() ?? '0') ?? 0,
            "size": row[12]?.value?.toString() ?? "",
            "availability_status": row[13]?.value?.toString() ?? "Available",
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid Excel format.')));
      } finally {
        setState(() => _isParsing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Inventory',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryBlue,
          tabs: const [
            Tab(text: 'Single Unit'),
            Tab(text: 'Bulk Upload (Excel)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSingleUnitForm(primaryBlue, cardColor),
          _buildBulkUploadForm(primaryBlue, cardColor),
        ],
      ),
    );
  }

  Widget _buildSingleUnitForm(Color primaryBlue, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField('Tower Name', _towerCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Floor Number', _floorCtrl)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Unit Number (e.g. A-101)', _unitCtrl),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown('Configuration', _config, [
                    '1BHK',
                    '2BHK',
                    '3BHK',
                    '4BHK',
                    'Villa',
                  ], (v) => setState(() => _config = v!)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown('Property Type', _type, [
                    'Apartment',
                    'Villa',
                    'Plot',
                    'Commercial',
                  ], (v) => setState(() => _type = v!)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'Sale Category',
                    _saleCategory,
                    ['New Sale', 'Resale', 'Rent'],
                    (v) => setState(() => _saleCategory = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown('Facing', _facing, [
                    'East',
                    'West',
                    'North',
                    'South',
                  ], (v) => setState(() => _facing = v!)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Location (e.g. Corner Unit)', _locationCtrl),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Plot Number', _plotNumCtrl)),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('Plot Dimensions', _plotDimCtrl),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Area (SqFt)',
                    _areaCtrl,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    'Rate / SqFt',
                    _rateCtrl,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Size (e.g. Large)', _sizeCtrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown('Status', _status, [
                    'Available',
                    'Booked',
                    'Sold',
                  ], (v) => setState(() => _status = v!)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Consumer<AdminProjectProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isSaving
                        ? null
                        : () async {
                            final data = {
                              "project_id": widget.projectId,
                              "tower_name": _towerCtrl.text,
                              "floor_number": _floorCtrl.text,
                              "unit_number": _unitCtrl.text,
                              "configuration": _config,
                              "property_type": _type,
                              "sale_category": _saleCategory,
                              "facing": _facing,
                              "Location": _locationCtrl.text,
                              "plot_number": _plotNumCtrl.text,
                              "plot_dimensions": _plotDimCtrl.text,
                              "area_sqft": double.tryParse(_areaCtrl.text) ?? 0,
                              "rate_per_sqft":
                                  double.tryParse(_rateCtrl.text) ?? 0,
                              "size": _sizeCtrl.text,
                              "availability_status": _status,
                            };
                            final success = await provider.createUnit(
                              data,
                              widget.projectId.toString(),
                            );
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Unit Added!')),
                              );
                              Navigator.pop(context);
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Add Unit',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkUploadForm(Color primaryBlue, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Excel Template Guide',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Columns:\nTower | Floor | Unit | Config | Type | Sale | Facing | Location | Plot No | Dimensions | Area | Rate | Size | Status',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickAndParseExcel,
            child: DottedBorder(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.upload_file, size: 40, color: primaryBlue),
                    const SizedBox(height: 12),
                    Text(
                      _selectedExcelFile != null
                          ? _selectedExcelFile!.path.split('/').last
                          : 'Tap to Upload Excel File',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_isParsing) const Center(child: CircularProgressIndicator()),
          if (_parsedBulkData.isNotEmpty) ...[
            Text(
              'Preview (${_parsedBulkData.length} units ready)',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _parsedBulkData.length,
                separatorBuilder: (c, i) => const Divider(),
                itemBuilder: (c, i) {
                  final u = _parsedBulkData[i];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${u['tower_name']} - ${u['unit_number']}',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '₹${(u['area_sqft'] * u['rate_per_sqft']).toStringAsFixed(0)}',
                        style: GoogleFonts.montserrat(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Consumer<AdminProjectProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isSaving
                        ? null
                        : () async {
                            final success = await provider.createBulkUnits(
                              _parsedBulkData,
                              widget.projectId.toString(),
                            );
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${_parsedBulkData.length} Units Uploaded!',
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: provider.isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Upload All Units',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // --- UI Helpers ---
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
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
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
