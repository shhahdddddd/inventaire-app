import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  final box = GetStorage();
  Rx<Map<String, dynamic>> user = Rx<Map<String, dynamic>>({});
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    user.value = box.read('user') ?? {};
    print('DEBUG: UserController onInit - user data: ${user.value}');
    // Always use 'token' as the key for JWT
    super.onInit();
  }

  void updateUser(Map<String, dynamic> newUser) {
    user.value = newUser;
    print('UserController updated: $newUser');
    print('DEBUG: Role name from update: ${newUser['role_name']}');
    print('DEBUG: isAdmin check: ${newUser['role_name']?.toLowerCase() == 'admin'}');
    box.write('user', newUser);
    update();
  }

  // Add store and role information getters
  String get storeName => user.value['store_name'] ?? '';
  String get roleName => user.value['role_name'] ?? '';
  bool get isAdmin => roleName.toLowerCase() == 'admin';
  bool get isGestionnaireStock => roleName.toLowerCase() == 'gestionnaire de stock';
  bool get isCaissier => roleName.toLowerCase() == 'caissier';
  bool get isAgentAchat => roleName.toLowerCase() == 'agent d\'achat';

  @override
  void onClose() {
    // Do NOT dispose controllers here
    super.onClose();
  }
}
