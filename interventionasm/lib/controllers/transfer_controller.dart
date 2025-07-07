import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class TransferController extends GetxController {
  var transfers = [].obs;
  var stations = [].obs;
  var articles = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  final box = GetStorage();
  
  // Form controllers
  final dateController = TextEditingController();
  RxString selectedSourceStation = ''.obs;
  RxString selectedDestinationStation = ''.obs;
  RxInt selectedSourceStationId = 0.obs;
  RxInt selectedDestinationStationId = 0.obs;
  RxString selectedStatus = 'en_instance'.obs;
  
  String get token => box.read('token') ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchTransfers();
    fetchStations();
  }

  Future<void> fetchStations() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.stationsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          stations.value = responseData['data'];
        } else {
          stations.value = responseData;
        }
        if (stations.isNotEmpty) {
          selectedSourceStation.value = stations[0]['id'].toString();
          selectedDestinationStation.value = stations[0]['id'].toString();
        }
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else {
        error.value = 'Erreur ${response.statusCode}: Échec du chargement des stations';
      }
    } catch (e) {
      error.value = 'Erreur: $e';
    }
  }

  void setSourceStation(String? stationId) {
    if (stationId != null) {
      selectedSourceStation.value = stationId;
    }
  }

  void setDestinationStation(String? stationId) {
    if (stationId != null) {
      selectedDestinationStation.value = stationId;
    }
  }

  void setStatus(String? status) {
    if (status != null) {
      selectedStatus.value = status;
    }
  }

  void addArticle() {
    articles.add({
      'designation': 'Article ${articles.length + 1}',
      'barcode': '123456789',
      'qty': '1',
      'price': '10.00',
    });
  }

  void editArticle(int index) {
    if (index >= 0 && index < articles.length) {
      // TODO: Show edit dialog for article
      Get.snackbar('Info', 'Édition d\'article à implémenter');
    }
  }

  Future<void> submitTransfer() async {
    if (selectedSourceStation.value.isEmpty || selectedDestinationStation.value.isEmpty || articles.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs requis');
      return;
    }

    isLoading.value = true;
    error.value = '';
    
    final transferData = {
      'station_source_id': int.tryParse(selectedSourceStation.value) ?? 0,
      'station_destination_id': int.tryParse(selectedDestinationStation.value) ?? 0,
      'date_transfert': DateTime.now().toIso8601String(),
      'etat': selectedStatus.value,
      'transfert_items': articles.map((a) => {
        'article_id': 1, // TODO: Replace with actual article id
        'quantite': int.tryParse(a['qty'] ?? '1') ?? 1,
        'prix_ht': double.tryParse(a['price'] ?? '0') ?? 0,
        'code_barre': a['barcode'] ?? '',
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.transfertsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(transferData),
      );
      
      if (response.statusCode == 201) {
        Get.snackbar('Succès', 'Transfert créé avec succès');
        articles.clear();
        Get.back();
        fetchTransfers();
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

  Future<void> fetchTransfers() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.transfertsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          transfers.value = responseData['data'];
        } else {
          transfers.value = responseData;
        }
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else if (response.statusCode == 422) {
        error.value = 'Erreur de validation: ${response.body}';
      } else {
        error.value = 'Erreur ${response.statusCode}: Échec du chargement des transferts';
      }
    } catch (e) {
      error.value = 'Erreur: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTransfer(Map<String, dynamic> transferData) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.transfertsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(transferData),
      );
      
      if (response.statusCode == 201) {
        Get.snackbar('Succès', 'Transfert créé !', snackPosition: SnackPosition.BOTTOM);
        fetchTransfers();
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

  Future<void> updateTransfer(int transferId, Map<String, dynamic> transferData) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.transfertsUrl}/$transferId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(transferData),
      );
      
      if (response.statusCode == 200) {
        Get.snackbar('Succès', 'Transfert mis à jour !', snackPosition: SnackPosition.BOTTOM);
        fetchTransfers();
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

  Future<void> deleteTransfer(int transferId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.transfertsUrl}/$transferId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar('Succès', 'Transfert supprimé !', snackPosition: SnackPosition.BOTTOM);
        fetchTransfers();
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
    dateController.clear();
    selectedSourceStationId.value = 0;
    selectedDestinationStationId.value = 0;
    selectedStatus.value = 'en_instance';
    articles.clear();
  }

  @override
  void onClose() {
    dateController.dispose();
    super.onClose();
  }
} 