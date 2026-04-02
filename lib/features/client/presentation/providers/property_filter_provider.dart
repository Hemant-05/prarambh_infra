import 'package:flutter/material.dart';
import '../../../admin/data/models/unit_model.dart';

class PropertyFilterProvider extends ChangeNotifier {
  // Filter States
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(100, 5000);
  String _selectedBHK = '2BHK';
  
  // Options
  final List<String> _categories = ['All', 'House', 'Villa', 'Apartment', 'Plot'];
  final List<String> _bhkOptions = ['1BHK', '2BHK', '3BHK', '4BHK+'];
  
  // Getters
  String get selectedCategory => _selectedCategory;
  RangeValues get priceRange => _priceRange;
  String get selectedBHK => _selectedBHK;
  List<String> get categories => _categories;
  List<String> get bhkOptions => _bhkOptions;

  // Setters
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void setBHK(String bhk) {
    _selectedBHK = bhk;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _priceRange = const RangeValues(100, 5000);
    _selectedBHK = '2BHK';
    notifyListeners();
  }

  // Filtering Logic for Units
  List<UnitModel> getFilteredUnits(List<UnitModel> allUnits) {
    return allUnits.where((unit) {
      // Filter by BHK configuration
      // Assuming unit.configuration contains strings like "2BHK", "3BHK" etc.
      // If it's just "2", "3", etc., we handle that.
      final unitConfig = unit.configuration.toUpperCase();
      final filterBHK = _selectedBHK.replaceAll('BHK', '').replaceAll('+', '');
      
      bool matchesBHK = true;
      if (_selectedBHK != 'All') {
        if (_selectedBHK.contains('+')) {
           final count = int.tryParse(filterBHK) ?? 0;
           final unitCount = int.tryParse(unitConfig.replaceAll('BHK', '')) ?? 0;
           matchesBHK = unitCount >= count;
        } else {
           matchesBHK = unitConfig.contains(filterBHK);
        }
      }
      
      // Filter by Price (multiplying by 1000 assuming base values are in thousands)
      final unitPrice = unit.calculatedPrice;
      final matchesPrice = unitPrice >= _priceRange.start * 1000 && unitPrice <= _priceRange.end * 1000;
      
      // Filter by Category
      bool matchesCategory = true;
      if (_selectedCategory != 'All') {
        matchesCategory = unit.propertyType.toLowerCase() == _selectedCategory.toLowerCase();
      }

      return matchesBHK && matchesPrice && matchesCategory;
    }).toList();
  }
}
