import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class UserInviteController extends GetxController {
  final usernameController = TextEditingController();
  final nomController = TextEditingController();
  RxInt selectedRoleId = 0.obs;
  RxInt selectedStationId = 0.obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var activationToken = ''.obs;
  var activationUrl = ''.obs;
  final box = GetStorage();

  String get token => box.read('token') ?? '';

  Future<void> inviteUser() async {
    isLoading.value = true;
    error.value = '';
    activationToken.value = '';
    activationUrl.value = '';
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.usersUrl}/invite'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': usernameController.text,
          'nom': nomController.text,
          'role_id': selectedRoleId.value,
          'station_id': selectedStationId.value,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        activationToken.value = data['activation_token'] ?? '';
        activationUrl.value = data['activation_url'] ?? '';
        Get.snackbar('Succès', 'Utilisateur invité !', snackPosition: SnackPosition.BOTTOM);
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

  @override
  void onClose() {
    usernameController.dispose();
    nomController.dispose();
    super.onClose();
  }
} 