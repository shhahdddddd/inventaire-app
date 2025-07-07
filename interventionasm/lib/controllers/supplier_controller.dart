import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class SupplierController extends GetxController {
  var suppliers = [].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  final box = GetStorage();
  
  // Form controllers
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  
  String get token => box.read('token') ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.fournisseursUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          suppliers.value = responseData['data'];
        } else {
          suppliers.value = responseData;
        }
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else if (response.statusCode == 422) {
        error.value = 'Erreur de validation: ${response.body}';
      } else {
        error.value = 'Erreur ${response.statusCode}: Échec du chargement des fournisseurs';
      }
    } catch (e) {
      error.value = 'Erreur: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSupplier() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.fournisseursUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': nameController.text,
          'address': addressController.text,
          'phone': phoneController.text,
          'email': emailController.text,
        }),
      );
      
      if (response.statusCode == 201) {
        Get.snackbar('Succès', 'Fournisseur créé !', snackPosition: SnackPosition.BOTTOM);
        clearForm();
        fetchSuppliers();
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

  Future<void> updateSupplier(int supplierId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.fournisseursUrl}/$supplierId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': nameController.text,
          'address': addressController.text,
          'phone': phoneController.text,
          'email': emailController.text,
        }),
      );
      
      if (response.statusCode == 200) {
        Get.snackbar('Succès', 'Fournisseur mis à jour !', snackPosition: SnackPosition.BOTTOM);
        clearForm();
        fetchSuppliers();
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

  Future<void> deleteSupplier(int supplierId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.fournisseursUrl}/$supplierId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar('Succès', 'Fournisseur supprimé !', snackPosition: SnackPosition.BOTTOM);
        fetchSuppliers();
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

  void loadSupplierForEdit(Map<String, dynamic> supplier) {
    nameController.text = supplier['name'] ?? '';
    addressController.text = supplier['address'] ?? '';
    phoneController.text = supplier['phone'] ?? '';
    emailController.text = supplier['email'] ?? '';
  }

  void clearForm() {
    nameController.clear();
    addressController.clear();
    phoneController.clear();
    emailController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
} 