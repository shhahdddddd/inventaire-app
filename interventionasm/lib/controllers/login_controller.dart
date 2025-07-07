import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controllers/article_controller.dart';
import '../controllers/user_controller.dart';
import 'package:get_storage/get_storage.dart';
import '../config/api_config.dart';

class LoginController extends GetxController with GetTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController fadeController;
  late AnimationController scaleController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  var isLoading = false.obs;
  var error = ''.obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeInOut,
    ));
    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeInOut,
    ));
    fadeController.forward();
  }

  @override
  void onClose() {
    fadeController.dispose();
    scaleController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (isClosed) return;
    scaleController.forward().then((_) {
      scaleController.reverse();
    });
    final username = usernameController.text;
    final password = passwordController.text;
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );
      if (isClosed) return;
      print('API Status: ${response.statusCode}');
      print('API Response: ${response.body}');
      if (isClosed) return;
      if (response.statusCode == 200) {
        if (isClosed) return;
        final data = json.decode(response.body);
        print('Decoded Data: $data');
        final token = data['access_token'] as String? ?? '';

        box.write('token', token);
        print('DEBUG: Stored token: ${token.isNotEmpty ? token.substring(0,5) + "..." : "empty"}');
        
        // Set token in ArticleController
        if (Get.isRegistered<ArticleController>()) {
          Get.find<ArticleController>().setToken(token);
        }
        
        // Fetch user data
        try {
          print('DEBUG: User info request token: ${token.isNotEmpty ? token.substring(0,5) + "..." : "empty"}');
          final userResponse = await http.get(
            Uri.parse(ApiConfig.userUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          );
          
          if (userResponse.statusCode == 200) {
            final userData = json.decode(userResponse.body);
            print('DEBUG: Raw user data from API: $userData');
            final userInfo = {
              'username': userData['username'],
              'role_id': userData['role']?['id'] ?? 0,
              'role_name': userData['role']?['nom'] ?? '',
              'store_id': userData['store_id'],
              'store_name': userData['store']?['nom'] ?? '',
              'station_id': userData['station_id'],
              'station_name': userData['station']?['nom'] ?? '',
            };
            print('DEBUG: Processed user info: $userInfo');
            box.write('user', userInfo);
            // Update the UserController
            if (Get.isRegistered<UserController>()) {
              Get.find<UserController>().updateUser(userInfo);
            }
          } else {
            print('User data fetch failed: ${userResponse.statusCode}');
          }
        } catch (e) {
          print('Error fetching user data: $e');
        }
        Get.snackbar('Login', 'Connexion réussie', snackPosition: SnackPosition.BOTTOM);
        await Future.delayed(const Duration(milliseconds: 200));
        Get.offAllNamed('/home');
      } else {
        if (isClosed) return;
        if (response.statusCode == 401) {
          error.value = 'Invalid username or password';
        } else if (response.statusCode == 403) {
          error.value = 'Accès refusé. Permissions insuffisantes.';
        } else if (response.statusCode == 422) {
          error.value = 'Erreur de validation: ${response.body}';
        } else {
          error.value = 'Server error: ${response.statusCode}';
        }
        Get.snackbar('Erreur', error.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      if (isClosed) return;
      error.value = 'Erreur de connexion: $e';
      Get.snackbar('Erreur', error.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<bool> refreshToken() async {
    final refreshToken = box.read('refresh_token') ?? '';
    if (refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.refreshUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access_token'] as String? ?? '';
        final newRefreshToken = data['refresh_token'] as String? ?? '';

        box.write('token', newAccessToken);
        box.write('refresh_token', newRefreshToken);

        // Update token in other controllers
        if (Get.isRegistered<ArticleController>()) {
          Get.find<ArticleController>().setToken(newAccessToken);
        }
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return false;
  }
} 