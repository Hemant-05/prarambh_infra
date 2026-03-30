import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/deal_model.dart';
import '../../data/repositories/admin_deal_repository.dart';

class AdminDealProvider extends ChangeNotifier {
  final AdminDealRepository repository;
  AdminDealProvider({required this.repository});

  bool _isSaving = false;
  bool _isLoading = false;
  List<DealModel> _deals = [];

  bool get isSaving => _isSaving;
  bool get isLoading => _isLoading;
  List<DealModel> get deals => _deals;

  Future<void> fetchAllDeals() async {
    _isLoading = true; notifyListeners();
    try {
      _deals = await repository.getAllDeals();
    } catch (e) {
      debugPrint('Fetch Deals Error: $e');
      _deals = [];
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> initiateDeal({
    required String clientName, required String clientNumber,
    required String advisorCode, required String tokenAmount,
    required String paymentMode,
    File? aadhaarPhotoFront, File? aadhaarPhotoBack,
    File? panPhotoFront, File? panPhotoBack,
    List<String>? docTitles, List<File>? docFiles,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.createDeal(
          clientName: clientName, clientNumber: clientNumber, advisorCode: advisorCode,
          stage: 'booking', dealStatus: 'not verified', paymentAmount: tokenAmount,
          paymentMode: paymentMode,
          clientAdharFront: aadhaarPhotoFront, clientAdharBack: aadhaarPhotoBack,
          clientPanFront: panPhotoFront, clientPanBack: panPhotoBack,
          docTitles: docTitles, docFiles: docFiles
      );
      if (success) await fetchAllDeals();
      return success;
    } catch (e) {
      debugPrint('Create Deal Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> addDealNote(String dealId, String title, String time) async {
    _isSaving = true; notifyListeners();
    try {
      return await repository.addDealNote(dealId, {'title': title, 'time': time});
    } catch (e) {
      debugPrint('Add Note Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> savePaymentPlan(String dealId, String installmentsJson, String totalAmount, String status) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.updateDealInstallments(dealId, installmentsJson, totalAmount, status);
      if (success) await fetchAllDeals();
      return success;
    } catch (e) {
      debugPrint('Save Plan Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}