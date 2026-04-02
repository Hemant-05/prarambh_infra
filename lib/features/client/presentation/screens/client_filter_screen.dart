import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/property_filter_provider.dart';
import 'client_filtered_units_screen.dart';

class ClientFilterScreen extends StatelessWidget {
  const ClientFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PropertyFilterProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: textColor),
        title: Text(
          "Filter",
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Category Section
                  _sectionHeader(context, "Category"),
                  const SizedBox(height: 12),
                  _buildCategorySelection(context, provider, primaryBlue, isDark),
                  
                  const SizedBox(height: 32),
                  
                  // Price Range Section
                  _sectionHeader(context, "Price Range"),
                  const SizedBox(height: 12),
                  _buildPriceRangeSlider(provider, primaryBlue, isDark),
                  const SizedBox(height: 8),
                  _buildPriceLabels(context, provider.priceRange),
                  
                  const SizedBox(height: 32),
                  
                  // BHK / Configuration Section
                  _sectionHeader(context, "BHK Configuration"),
                  const SizedBox(height: 12),
                  _buildBHKSelection(context, provider, primaryBlue, isDark),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Bottom Buttons
          _buildBottomButtons(context, provider, primaryBlue, isDark),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildCategorySelection(BuildContext context, PropertyFilterProvider provider, Color activeColor, bool isDark) {
    final cardColor = Theme.of(context).cardColor;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: provider.categories.map((cat) {
          final isSelected = provider.selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => provider.setCategory(cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? activeColor : AppColors.getBorderColor(context)),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.montserrat(
                    color: isSelected ? Colors.white : secondaryTextColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRangeSlider(PropertyFilterProvider provider, Color activeColor, bool isDark) {
    return RangeSlider(
      values: provider.priceRange,
      min: 100,
      max: 5000,
      divisions: 49,
      activeColor: activeColor,
      inactiveColor: activeColor.withOpacity(0.1),
      onChanged: (RangeValues values) {
        provider.setPriceRange(values);
      },
    );
  }

  Widget _buildPriceLabels(BuildContext context, RangeValues range) {
    final primaryBlue = Theme.of(context).primaryColor;
    // Adjusting labels based on 100-5000 scale (Assuming units of 1,000 for realistic prices)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("₹${(range.start * 1000).toInt()}", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
        Text("₹${(range.end * 1000).toInt()}", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
      ],
    );
  }

  Widget _buildBHKSelection(BuildContext context, PropertyFilterProvider provider, Color activeColor, bool isDark) {
    final cardColor = Theme.of(context).cardColor;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Row(
      children: provider.bhkOptions.map((val) {
        final isSelected = provider.selectedBHK == val;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => provider.setBHK(val),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? activeColor : AppColors.getBorderColor(context)),
                ),
                child: Text(
                  val,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: isSelected ? Colors.white : secondaryTextColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomButtons(BuildContext context, PropertyFilterProvider provider, Color activeColor, bool isDark) {
    final bottomBarColor = Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bottomBarColor,
        border: Border(top: BorderSide(color: AppColors.getBorderColor(context))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => provider.resetFilters(),
              child: Text(
                "Reset",
                style: GoogleFonts.montserrat(color: activeColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientFilteredUnitsScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text("Apply Filter", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
