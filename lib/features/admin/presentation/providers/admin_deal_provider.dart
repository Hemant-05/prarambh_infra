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
  DealModel? _currentDeal;

  bool get isSaving => _isSaving;
  bool get isLoading => _isLoading;
  List<DealModel> get deals => _deals;
  DealModel? get currentDeal => _currentDeal;

  Future<void> fetchAllDeals({String advisorCode = ''}) async {
    _isLoading = true; notifyListeners();
    try {
      _deals = await repository.getAllDeals(advisorCode: advisorCode);
    } catch (e) {
      debugPrint('Fetch Deals Error: $e');
      _deals = [];
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> initiateDeal({
    required String clientName, required String clientNumber,
    String? clientEmail,
    required String advisorCode, required String leadId, required String propertyId, required String unitId,
    String? tokenAmount, String? tokenPaymentMode, String? paymentAmount, String? tokenDate,
    File? aadhaarPhotoFront, File? aadhaarPhotoBack,
    File? panPhotoFront, File? panPhotoBack,
    List<String>? docTitles, List<File>? docFiles,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.createDeal(
          clientName: clientName, clientNumber: clientNumber, 
          clientEmail: clientEmail,
          advisorCode: advisorCode,
          stage: 'booking', dealStatus: 'not verified', tokenAmount: tokenAmount,
          tokenPaymentMode: tokenPaymentMode, paymentAmount: paymentAmount, tokenDate: tokenDate,
          leadId: leadId, propertyId: propertyId, unitId: unitId,
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
      final success = await repository.addDealNote(dealId, {'title': title, 'time': time});
      if (success) await fetchAllDeals();
      return success;
    } catch (e) {
      debugPrint('Add Note Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> savePaymentPlan({
    required String dealId, 
    required String installmentsJson, 
    required String totalAmount, 
    required String status,
    String? tokenAmount,
    String? tokenPaymentMode,
    String? tokenDate,
    String? paymentPlan,
    String? dealStatus,
    String? stage,
    List<String>? docTitles,
    List<File>? docFiles,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.updateDealInstallments(
        dealId: dealId, installmentsJson: installmentsJson, 
        totalAmount: totalAmount, status: status,
        tokenAmount: tokenAmount, tokenPaymentMode: tokenPaymentMode,
        tokenDate: tokenDate, paymentPlan: paymentPlan, dealStatus: dealStatus,
        stage: stage,
        docTitles: docTitles, docFiles: docFiles,
      );
      if (success) await fetchAllDeals();
      return success;
    } catch (e) {
      debugPrint('Save Plan Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<DealModel?> getSingleDeal(String id) async {
    _isLoading = true; notifyListeners();
    try {
      return await repository.getSingleDeal(id);
    } catch (e) {
      debugPrint('Get Single Deal Error: $e');
      return null;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<DealModel?> fetchDealByLeadId(String leadId) async {
    _isLoading = true; 
    _currentDeal = null;
    notifyListeners();
    try {
      _currentDeal = await repository.getDealByLeadId(leadId);
      return _currentDeal;
    } catch (e) {
      debugPrint('Fetch Deal By Lead Id Error: $e');
      return null;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
}