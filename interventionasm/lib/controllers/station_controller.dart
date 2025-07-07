import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class StationController extends GetxController {
  var stations = [].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  final box = GetStorage();
  
  // Form controllers
  final nomController = TextEditingController();
  final descriptionController = TextEditingController();
  
  String get token => box.read('token') ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchStations();
  }

  Future<void> fetchStations() async {
    isLoading.value = true;
    error.value = '';
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
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else if (response.statusCode == 422) {
        error.value = 'Erreur de validation: ${response.body}';
      } else {
        error.value = 'Erreur ${response.statusCode}: Échec du chargement des stations';
      }
    } catch (e) {
      error.value = 'Erreur: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createStation() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.stationsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'nom': nomController.text,
          'description': descriptionController.text,
        }),
      );
      
      if (response.statusCode == 201) {
        Get.snackbar('Succès', 'Station créée !', snackPosition: SnackPosition.BOTTOM);
        clearForm();
        fetchStations();
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

  Future<void> updateStation(int stationId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.stationsUrl}/$stationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'nom': nomController.text,
          'description': descriptionController.text,
        }),
      );
      
      if (response.statusCode == 200) {
        Get.snackbar('Succès', 'Station mise à jour !', snackPosition: SnackPosition.BOTTOM);
        clearForm();
        fetchStations();
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

  Future<void> deleteStation(int stationId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.stationsUrl}/$stationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar('Succès', 'Station supprimée !', snackPosition: SnackPosition.BOTTOM);
        fetchStations();
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

  void loadStationForEdit(Map<String, dynamic> station) {
    nomController.text = station['nom'] ?? '';
    descriptionController.text = station['description'] ?? '';
  }

  void clearForm() {
    nomController.clear();
    descriptionController.clear();
  }

  @override
  void onClose() {
    nomController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
} 