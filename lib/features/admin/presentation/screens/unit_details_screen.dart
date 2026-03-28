import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_project_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/unit_model.dart';

class UnitDetailsScreen extends StatelessWidget {
  final UnitModel unit;
  const UnitDetailsScreen({super.key, required this.unit});

  void _showUpdateBottomSheet(BuildContext context, Color primaryBlue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UpdateUnitForm(unit: unit, primaryBlue: primaryBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor = unit.availabilityStatus.toUpperCase().contains('AVAILABLE')
        ? Colors.green
        : unit.availabilityStatus.toUpperCase().contains('BOOKED')
        ? Colors.orange
        : Colors.red;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20), color: isDark ? Colors.grey[900] : Colors.white,
          child: Consumer<AdminProjectProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: provider.isSaving ? null : () async {
                        bool confirm = await showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Delete Unit?'), content: const Text('This cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ) ?? false;

                        if (confirm) {
                          final success = await provider.removeUnit(unit.id.toString(), unit.projectId.toString());
                          if (success && context.mounted) Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: Text('Delete', style: GoogleFonts.montserrat(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: provider.isSaving ? null : () => _showUpdateBottomSheet(context, primaryBlue),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: Text('Update Unit', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220, pinned: true, backgroundColor: primaryBlue,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: Text('Unit Details', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.grey[300], child: const Icon(Icons.apartment, size: 80, color: Colors.grey)),
                  Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black12, Colors.transparent]))),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${unit.towerName} - ${unit.unitNumber}', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
                                Text(unit.propertyType, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text(unit.availabilityStatus.toUpperCase(), style: GoogleFonts.montserrat(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TOTAL PRICE', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                Text('₹${unit.calculatedPrice.toStringAsFixed(0)}', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue)),
                                Text('₹${unit.ratePerSqft} / sqft', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('SPECIFICATIONS', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    children: [
                      _buildSpecBox(Icons.square_foot, 'Super Area', '${unit.areaSqft} sqft', cardColor),
                      _buildSpecBox(Icons.bed, 'Configuration', unit.configuration, cardColor),
                      _buildSpecBox(Icons.explore, 'Facing', unit.facing, cardColor),
                      _buildSpecBox(Icons.layers, 'Floor', unit.floorNumber, cardColor),
                      _buildSpecBox(Icons.location_on, 'Location', unit.location.isNotEmpty ? unit.location : 'N/A', cardColor),
                      _buildSpecBox(Icons.category, 'Size', unit.size.isNotEmpty ? unit.size : 'N/A', cardColor),
                      _buildSpecBox(Icons.map, 'Plot No.', unit.plotNumber.isNotEmpty ? unit.plotNumber : 'N/A', cardColor),
                      _buildSpecBox(Icons.straighten, 'Dimensions', unit.plotDimensions.isNotEmpty ? unit.plotDimensions : 'N/A', cardColor),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBox(IconData icon, String title, String value, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.blue[800]), const SizedBox(width: 6),
              Text(title, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ======================================================================
// NEW: Bottom Sheet Form for Updating Unit
// ======================================================================
class _UpdateUnitForm extends StatefulWidget {
  final UnitModel unit;
  final Color primaryBlue;
  const _UpdateUnitForm({required this.unit, required this.primaryBlue});

  @override
  State<_UpdateUnitForm> createState() => _UpdateUnitFormState();
}

class _UpdateUnitFormState extends State<_UpdateUnitForm> {
  final _towerCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _plotNumCtrl = TextEditingController();
  final _plotDimCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();

  late String _config;
  late String _type;
  late String _saleCategory;
  late String _facing;
  late String _status;

  // Dynamic lists to prevent Dropdown crashes if DB has legacy values
  late List<String> configOptions;
  late List<String> typeOptions;
  late List<String> saleOptions;
  late List<String> facingOptions;
  late List<String> statusOptions;

  @override
  void initState() {
    super.initState();
    _towerCtrl.text = widget.unit.towerName;
    _floorCtrl.text = widget.unit.floorNumber;
    _unitCtrl.text = widget.unit.unitNumber;
    _locationCtrl.text = widget.unit.location;
    _plotNumCtrl.text = widget.unit.plotNumber;
    _plotDimCtrl.text = widget.unit.plotDimensions;
    _areaCtrl.text = widget.unit.areaSqft.toString();
    _rateCtrl.text = widget.unit.ratePerSqft.toString();
    _sizeCtrl.text = widget.unit.size;

    configOptions = ['1BHK', '2BHK', '3BHK', '4BHK', 'Villa'];
    if (!configOptions.contains(widget.unit.configuration) && widget.unit.configuration.isNotEmpty) configOptions.add(widget.unit.configuration);
    _config = widget.unit.configuration.isNotEmpty ? widget.unit.configuration : '3BHK';

    typeOptions = ['Apartment', 'Villa', 'Plot', 'Commercial'];
    if (!typeOptions.contains(widget.unit.propertyType) && widget.unit.propertyType.isNotEmpty) typeOptions.add(widget.unit.propertyType);
    _type = widget.unit.propertyType.isNotEmpty ? widget.unit.propertyType : 'Apartment';

    saleOptions = ['New Sale', 'Resale', 'Rent'];
    if (!saleOptions.contains(widget.unit.saleCategory) && widget.unit.saleCategory.isNotEmpty) saleOptions.add(widget.unit.saleCategory);
    _saleCategory = widget.unit.saleCategory.isNotEmpty ? widget.unit.saleCategory : 'New Sale';

    facingOptions = ['East', 'West', 'North', 'South'];
    if (!facingOptions.contains(widget.unit.facing) && widget.unit.facing.isNotEmpty) facingOptions.add(widget.unit.facing);
    _facing = widget.unit.facing.isNotEmpty ? widget.unit.facing : 'East';

    statusOptions = ['Available', 'Booked', 'Sold Out', 'Reselling'];
    if (!statusOptions.contains(widget.unit.availabilityStatus) && widget.unit.availabilityStatus.isNotEmpty) statusOptions.add(widget.unit.availabilityStatus);
    _status = widget.unit.availabilityStatus.isNotEmpty ? widget.unit.availabilityStatus : 'Available';
  }

  @override
  void dispose() {
    _towerCtrl.dispose(); _floorCtrl.dispose(); _unitCtrl.dispose();
    _areaCtrl.dispose(); _rateCtrl.dispose(); _locationCtrl.dispose();
    _plotNumCtrl.dispose(); _plotDimCtrl.dispose(); _sizeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20, left: 20, right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Update Unit Details', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown('Status', _status, statusOptions, (v) => setState(() => _status = v!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Unit Number', _unitCtrl)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Tower', _towerCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Floor', _floorCtrl)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown('Type', _type, typeOptions, (v) => setState(() => _type = v!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDropdown('Config', _config, configOptions, (v) => setState(() => _config = v!))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Plot Number', _plotNumCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Dimensions', _plotDimCtrl)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Area (SqFt)', _areaCtrl, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Rate/SqFt', _rateCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown('Category', _saleCategory, saleOptions, (v) => setState(() => _saleCategory = v!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDropdown('Facing', _facing, facingOptions, (v) => setState(() => _facing = v!))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Size (e.g. Large)', _sizeCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Location (Corner)', _locationCtrl)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Consumer<AdminProjectProvider>(
                    builder: (context, provider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isSaving ? null : () async {
                            final data = {
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
                              "rate_per_sqft": double.tryParse(_rateCtrl.text) ?? 0,
                              "size": _sizeCtrl.text,
                              "availability_status": _status,
                            };

                            final success = await provider.modifyUnit(widget.unit.id.toString(), data, widget.unit.projectId.toString());
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unit Details Updated!')));
                              Navigator.pop(context); // Close the bottom sheet
                              Navigator.pop(context); // Pop details screen to see the freshly updated Inventory list
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: widget.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: provider.isSaving ? const CircularProgressIndicator(color: Colors.white) : Text('Save Changes', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])), const SizedBox(height: 6),
        TextField(
          controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, style: GoogleFonts.montserrat(fontSize: 13),
          decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), filled: true, fillColor: Colors.grey.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300))),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])), const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value, isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey), style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black87),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}