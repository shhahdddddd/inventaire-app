import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class RegisterController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final storeController = TextEditingController();
  var isLoading = false.obs;
  var error = ''.obs;

  Future<void> register() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': usernameController.text,
          'password': passwordController.text,
          'store_name': storeController.text,
        }),
      );
      if (response.statusCode == 201) {
        Get.snackbar('Succès', 'Inscription réussie !', snackPosition: SnackPosition.BOTTOM);
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed('/login');
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
        Get.snackbar('Erreur', error.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
        Get.snackbar('Erreur', error.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      } else if (response.statusCode == 422) {
        error.value = 'Erreur de validation: ${response.body}';
        Get.snackbar('Erreur', error.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        final data = json.decode(response.body);
        error.value = data['message'] ?? data['error'] ?? 'Erreur lors de l\'inscription (Status: ${response.statusCode})';
        Get.snackbar('Erreur', error.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      error.value = 'Erreur de connexion: $e';
      Get.snackbar('Erreur', error.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  final RegisterController controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf8fafc), Color(0xFFe0e7ef), Color(0xFFf8fafc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                backgroundBlendMode: BlendMode.overlay,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.85 + (0.15 * value),
                        child: Opacity(
                          opacity: value,
                          child: Image.asset(
                            'assets/logo.png',
                            height: 100,
                            width: 100,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.business,
                                  size: 60,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18.0),
                  Text(
                    'Créer un compte admin',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Inscrivez votre magasin et devenez administrateur',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  TextField(
                    controller: controller.usernameController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      labelText: 'Nom d\'utilisateur',
                      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFe0e7ef)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFFF5722), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF6B7280)),
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      labelText: 'Mot de passe',
                      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFe0e7ef)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFFF5722), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF6B7280)),
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  TextField(
                    controller: controller.storeController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      labelText: 'Nom du magasin',
                      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFe0e7ef)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFFF5722), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.store, color: Color(0xFF6B7280)),
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  Obx(() => controller.isLoading.value
                      ? const CircularProgressIndicator(color: Color(0xFFFF5722))
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.register,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18.0),
                              backgroundColor: const Color(0xFFFF5722),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            child: const Text('S\'inscrire'),
                          ),
                        )),
                  const SizedBox(height: 18.0),
                  Obx(() => controller.error.value.isNotEmpty
                      ? Text(
                          controller.error.value,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        )
                      : const SizedBox()),
                  const SizedBox(height: 8.0),
                  TextButton(
                    onPressed: () => Get.offAllNamed('/login'),
                    child: const Text(
                      'Déjà inscrit ? Se connecter',
                      style: TextStyle(color: Color(0xFFFF5722)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 