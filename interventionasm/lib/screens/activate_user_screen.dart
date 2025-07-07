import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class ActivateUserController extends GetxController {
  final usernameController = TextEditingController();
  final tokenController = TextEditingController();
  final passwordController = TextEditingController();
  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;

  Future<void> activateUser() async {
    isLoading.value = true;
    error.value = '';
    success.value = false;
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.activateUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'username': usernameController.text,
          'activation_token': tokenController.text,
          'password': passwordController.text,
        }),
      );
      if (response.statusCode == 200) {
        success.value = true;
        Get.snackbar('Succès', 'Activation réussie !', snackPosition: SnackPosition.BOTTOM);
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed('/login');
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
    tokenController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class ActivateUserScreen extends StatelessWidget {
  final ActivateUserController controller = Get.put(ActivateUserController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activer le compte')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: controller.usernameController,
              decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
            ),
            TextField(
              controller: controller.tokenController,
              decoration: InputDecoration(labelText: 'Token d\'activation'),
            ),
            TextField(
              controller: controller.passwordController,
              decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Obx(() => controller.error.value.isNotEmpty
                ? Text(controller.error.value, style: TextStyle(color: Colors.red))
                : SizedBox()),
            const SizedBox(height: 16),
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.activateUser,
                  child: controller.isLoading.value ? CircularProgressIndicator() : Text('Activer'),
                )),
          ],
        ),
      ),
    );
  }
} 