import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controllers/login_controller.dart';
import '../controllers/user_invite_controller.dart';
import '../config/api_config.dart';

void log(String message) {
  if (kDebugMode) {
    print(message);
  }
}

class UserManagementController extends GetxController {
  var users = [].obs;
  var roles = [].obs;
  var stations = [].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  var selectedRole = ''.obs;

  final box = GetStorage();

  String get token => box.read('token') ?? '';

  bool isRetrying = false;

  @override
  void onInit() {
    super.onInit();
    log('DEBUG: UserManagementController initialized. Token: ${token.isNotEmpty ? "${token.substring(0,5)}..." : "empty"}');
    fetchRoles();
    fetchStations();
    fetchUsers();
  }

  Future<void> fetchRoles() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.rolesUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        roles.value = json.decode(response.body);
        if (roles.isNotEmpty) selectedRole.value = roles[0]['nom'];
      }
    } catch (e) {
      // ignore
    }
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
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> fetchUsers() async {
    log('DEBUG: fetchUsers token: ${token.isNotEmpty ? "${token.substring(0,5)}..." : "empty"}');
    log('DEBUG: Authorization header: Bearer ${token.isNotEmpty ? "${token.substring(0,5)}..." : "empty"}');
    
    if (isRetrying) return;
    
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.usersUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      log('DEBUG: fetchUsers status: ${response.statusCode}');
      log('DEBUG: fetchUsers body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          users.value = responseData['data'];
        } else {
          users.value = responseData;
        }
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else if (response.statusCode == 422) {
        error.value = 'Erreur de validation: ${response.body}';
      } else if (response.statusCode == 500) {
        error.value = 'Erreur serveur (500) - Veuillez vérifier les logs du backend';
        log('ERREUR SERVEUR: ${response.body}');
      } else {
        error.value = 'Erreur ${response.statusCode} lors du chargement des utilisateurs';
      }
    } catch (e) {
      if (e is TimeoutException) {
        error.value = 'La requête a expiré';
      } else if (e is http.ClientException) {
        error.value = 'Erreur de connexion au serveur';
      } else {
        error.value = 'Erreur inattendue: $e';
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> addUser() async {
    isLoading.value = true;
    error.value = '';
    try {
      final roleObj = roles.firstWhereOrNull((r) => r['nom'] == selectedRole.value);
      final response = await http.post(
        Uri.parse(ApiConfig.usersUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': usernameController.text,
          'mot_de_passe': passwordController.text,
          'role_id': roleObj != null ? roleObj['id'] : null,
        }),
      );
      if (response.statusCode == 201) {
        Get.snackbar('Succès', 'Utilisateur ajouté !', snackPosition: SnackPosition.BOTTOM);
        usernameController.clear();
        passwordController.clear();
        fetchUsers();
      } else if (response.statusCode == 401) {
        if (!isRetrying) {
          isRetrying = true;
          final loginController = Get.isRegistered<LoginController>() ? Get.find<LoginController>() : Get.put(LoginController());
          final refreshed = await loginController.refreshToken();
          if (refreshed) {
            await addUser();
          } else {
            error.value = 'Non autorisé. Veuillez vous reconnecter.';
            Get.snackbar('Erreur', error.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
          }
          isRetrying = false;
        } else {
          error.value = 'Échec de l\'actualisation du token. Veuillez vous reconnecter.';
          Get.snackbar('Erreur', error.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        final data = json.decode(response.body);
        error.value = data['message'] ?? data['error'] ?? 'Erreur lors de l\'ajout';
        Get.snackbar('Erreur', error.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      error.value = 'Erreur de connexion: $e';
      Get.snackbar('Erreur', error.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> changeUserRole(int userId, int newRoleId) async {
    if (token.isEmpty) {
      Get.snackbar('Erreur', 'Token d\'authentification manquant', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.usersUrl}/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'role_id': newRoleId}),
      ).timeout(const Duration(seconds: 10));

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        fetchUsers();
        Get.snackbar('Succès', 'Rôle mis à jour', snackPosition: SnackPosition.BOTTOM);
      } else if (response.statusCode == 401) {
        if (!isRetrying) {
          isRetrying = true;
          final loginController = Get.isRegistered<LoginController>() ? Get.find<LoginController>() : Get.put(LoginController());
          final refreshed = await loginController.refreshToken();
          if (refreshed) {
            await changeUserRole(userId, newRoleId);
          } else {
            error.value = 'Non autorisé. Veuillez vous reconnecter.';
            log('DEBUG: 401 Unauthorized response body: ${response.body}');
          }
          isRetrying = false;
        } else {
          error.value = 'Échec de l\'actualisation du token. Veuillez vous reconnecter.';
        }
      } else {
        Get.snackbar('Erreur', 'Erreur lors du changement de rôle. Code: ${response.statusCode}', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } on SocketException catch (e) {
      Get.snackbar('Erreur', 'Erreur de réseau: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } on TimeoutException catch (e) {
      Get.snackbar('Erreur', 'La requête a expiré: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur inattendue: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  // Optimized helper methods for better performance
  Future<void> _refreshUsersList() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.usersUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Handle paginated response
        if (responseData['data'] != null) {
          users.value = responseData['data'];
        } else {
          // Fallback for non-paginated response
          users.value = responseData;
        }
      }
    } catch (e) {
      // Silent fail - user will see the update on next manual refresh
    }
  }

  Future<void> _updateUserLocally(int userId, int newRoleId) async {
    try {
      // Find the role name for the new role ID
      final newRole = roles.firstWhereOrNull((r) => r['id'] == newRoleId);
      if (newRole != null) {
        // Update the user in the local list
        final userIndex = users.indexWhere((u) => u['id'] == userId);
        if (userIndex != -1) {
          users[userIndex]['role'] = newRole;
          users.refresh(); // Trigger UI update
        }
      }
    } catch (e) {
      // Fallback to full refresh if local update fails
      await _refreshUsersList();
    }
  }
}

class UserManagementScreen extends StatelessWidget {
  UserManagementScreen({Key? key}) : super(key: key) {
    Get.put(UserManagementController());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        actions: [
          buildInviteUserButton(context),
        ],
      ),
      body: GetBuilder<UserManagementController>(
        builder: (controller) {
          return Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Ajouter un utilisateur',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller.usernameController,
                        decoration: InputDecoration(
                          labelText: 'Nom d\'utilisateur',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: controller.selectedRole.value.isNotEmpty ? controller.selectedRole.value : null,
                        items: controller.roles
                            .where((role) => [
                                  'admin',
                                  'caissier',
                                  "agent d'achat",
                                  'gestionnaire de stock',
                                ].contains(role['nom']))
                            .map<DropdownMenuItem<String>>((role) {
                          return DropdownMenuItem<String>(
                            value: role['nom'],
                            child: Text(role['nom']),
                          );
                        }).toList(),
                        onChanged: (val) => controller.selectedRole.value = val ?? '',
                        decoration: InputDecoration(
                          labelText: 'Rôle',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          prefixIcon: const Icon(Icons.security),
                        ),
                      ),
                      const SizedBox(height: 16),
                      controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
                          : ElevatedButton(
                              onPressed: controller.addUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('Ajouter'),
                            ),
                      if (controller.error.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            controller.error.value,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 32),
                      Text(
                        'Utilisateurs',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
                          : controller.users.isEmpty
                              ? const Text('Aucun utilisateur trouvé.')
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.users.length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final user = controller.users[index];
                                    return ListTile(
                                      leading: const Icon(Icons.person, color: Colors.deepOrange),
                                      title: Text(user['username'] ?? ''),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Rôle: ${user['role']?['nom'] ?? 'N/A'}'),
                                          Text('Magasin: ${user['store']?['nom'] ?? 'N/A'}'),
                                          Text('Station: ${user['station']?['nom'] ?? 'N/A'}'),
                                        ],
                                      ),
                                      trailing: DropdownButton<int>(
                                        value: user['role']?['id'],
                                        items: controller.roles.map<DropdownMenuItem<int>>((role) {
                                          return DropdownMenuItem<int>(
                                            value: role['id'],
                                            child: Text(role['nom']),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null && val != user['role']?['id']) {
                                            controller.changeUserRole(user['id'], val);
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildInviteUserButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.person_add),
      label: Text('Inviter un utilisateur'),
      onPressed: () {
        Get.dialog(InviteUserDialog());
      },
    );
  }
}

class InviteUserDialog extends StatelessWidget {
  final UserInviteController inviteController = Get.put(UserInviteController());
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Inviter un utilisateur'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: inviteController.usernameController,
              decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
            ),
            TextField(
              controller: inviteController.nomController,
              decoration: InputDecoration(labelText: 'Nom complet'),
            ),
            // Role dropdown
            Obx(() {
              final roles = Get.find<UserManagementController>().roles;
              return DropdownButtonFormField<int>(
                value: inviteController.selectedRoleId.value == 0 && roles.isNotEmpty ? roles[0]['id'] : inviteController.selectedRoleId.value,
                items: roles.map<DropdownMenuItem<int>>((role) {
                  return DropdownMenuItem<int>(
                    value: role['id'],
                    child: Text(role['nom']),
                  );
                }).toList(),
                onChanged: (val) => inviteController.selectedRoleId.value = val ?? 0,
                decoration: InputDecoration(labelText: 'Rôle'),
              );
            }),
            // Station dropdown (optional, if stations are loaded)
            Obx(() {
              final stations = Get.find<UserManagementController>().stations;
              return DropdownButtonFormField<int>(
                value: inviteController.selectedStationId.value == 0 && stations.isNotEmpty ? stations[0]['id'] : inviteController.selectedStationId.value,
                items: stations.map<DropdownMenuItem<int>>((station) {
                  return DropdownMenuItem<int>(
                    value: station['id'],
                    child: Text(station['nom']),
                  );
                }).toList(),
                onChanged: (val) => inviteController.selectedStationId.value = val ?? 0,
                decoration: InputDecoration(labelText: 'Station'),
              );
            }),
            Obx(() => inviteController.error.value.isNotEmpty
                ? Text(inviteController.error.value, style: TextStyle(color: Colors.red))
                : SizedBox()),
            Obx(() => inviteController.activationToken.value.isNotEmpty
                ? Column(
                    children: [
                      SelectableText('Token: ${inviteController.activationToken.value}'),
                      SelectableText('URL: ${inviteController.activationUrl.value}'),
                    ],
                  )
                : SizedBox()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Annuler'),
        ),
        Obx(() => ElevatedButton(
              onPressed: inviteController.isLoading.value ? null : inviteController.inviteUser,
              child: inviteController.isLoading.value ? CircularProgressIndicator() : Text('Inviter'),
            )),
      ],
    );
  }
}