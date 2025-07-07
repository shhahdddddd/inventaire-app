import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class PurchaseController extends GetxController {
  var purchases = [].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  final box = GetStorage();
  
  // Form controllers
  final typePieceController = TextEditingController();
  final numPieceController = TextEditingController();
  final dateController = TextEditingController();
  final fournisseurNomController = TextEditingController();
  RxInt selectedStationId = 0.obs;
  
  String get token => box.read('token') ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.achatsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          purchases.value = responseData['data'];
        } else {
          purchases.value = responseData;
        }
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else if (response.statusCode == 422) {
        error.value = 'Erreur de validation: ${response.body}';
      } else {
        error.value = 'Erreur ${response.statusCode}: Échec du chargement des achats';
      }
    } catch (e) {
      error.value = 'Erreur: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPurchase(Map<String, dynamic> purchaseData) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.achatsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(purchaseData),
      );
      
      if (response.statusCode == 201) {
        Get.snackbar('Succès', 'Achat créé !', snackPosition: SnackPosition.BOTTOM);
        fetchPurchases();
        Get.back(); // Close dialog
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else if (response.statusCode == 422) {
        error.value = 'Erreur de validation: ${response.body}';
      } else {
        error.value = 'Erreur ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      error.value = 'Erreur: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePurchase(int purchaseId, Map<String, dynamic> purchaseData) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.achatsUrl}/$purchaseId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(purchaseData),
      );
      
      if (response.statusCode == 200) {
        Get.snackbar('Succès', 'Achat mis à jour !', snackPosition: SnackPosition.BOTTOM);
        fetchPurchases();
        Get.back(); // Close dialog
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else if (response.statusCode == 422) {
        error.value = 'Erreur de validation: ${response.body}';
      } else {
        error.value = 'Erreur ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      error.value = 'Erreur: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePurchase(int purchaseId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.achatsUrl}/$purchaseId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar('Succès', 'Achat supprimé !', snackPosition: SnackPosition.BOTTOM);
        fetchPurchases();
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else if (response.statusCode == 422) {
        error.value = 'Erreur de validation: ${response.body}';
      } else {
        error.value = 'Erreur ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      error.value = 'Erreur: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    typePieceController.clear();
    numPieceController.clear();
    dateController.clear();
    fournisseurNomController.clear();
    selectedStationId.value = 0;
  }

  @override
  void onClose() {
    typePieceController.dispose();
    numPieceController.dispose();
    dateController.dispose();
    fournisseurNomController.dispose();
    super.onClose();
  }
} 