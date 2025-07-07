import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:interventionasm/controllers/user_controller.dart';
import '../controllers/article_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      backgroundColor: Colors.white.withOpacity(0.85),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(() {
            final userController = Get.find<UserController>();
            final user = userController.user.value;
            print('Drawer user from controller: $user');
            print('DEBUG: Full user object: $user');
            print('DEBUG: Role data: ${user['role']}');
            print('DEBUG: Role name: ${user['role_name']}');
            // Enhanced: Show fallback and debug info if username is missing
            String username = user['username']?.toString() ?? '';
            if (username.isEmpty) {
              username = 'No username found';
              print('DEBUG: Username missing in user object: $user');
            }
            return Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(username),
                  accountEmail: null,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                // Show user role and store information
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Text(
                    'Rôle: ${user['role_name'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14, color: Colors.deepOrange, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                  child: Text(
                    'Magasin: ${user['store_name'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 18),
          // Home section
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () => Get.back(),
          ),
          const SizedBox(height: 24),
          // Role-based menu items
          Obx(() {
            final userController = Get.find<UserController>();
            final isAdmin = userController.isAdmin;
            final isGestionnaireStock = userController.isGestionnaireStock;
            final isCaissier = userController.isCaissier;
            final isAgentAchat = userController.isAgentAchat;
            
            // Debug logging
            print('DEBUG: User data in drawer: ${userController.user.value}');
            print('DEBUG: Role name: ${userController.roleName}');
            print('DEBUG: isAdmin: $isAdmin');
            print('DEBUG: isGestionnaireStock: $isGestionnaireStock');
            print('DEBUG: isAgentAchat: $isAgentAchat');
            print('DEBUG: isCaissier: $isCaissier');
            
            // TEMPORARY: Force admin access for testing
            final forceAdmin = true; // Set to false to disable
            final testIsAdmin = forceAdmin || isAdmin;
            final testIsGestionnaireStock = forceAdmin || isGestionnaireStock;
            final testIsAgentAchat = forceAdmin || isAgentAchat;
            final testIsCaissier = forceAdmin || isCaissier;
            
            print('DEBUG: Force admin: $forceAdmin');
            print('DEBUG: Test isAdmin: $testIsAdmin');
            print('DEBUG: Test isGestionnaireStock: $testIsGestionnaireStock');
            print('DEBUG: Test isAgentAchat: $testIsAgentAchat');
            print('DEBUG: Test isCaissier: $testIsCaissier');
            
            return Column(
              children: [
                // TEST: Always show this item
                ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.red),
                  title: const Text('TEST ITEM - Should Always Show'),
                  onTap: () => Get.snackbar('Test', 'This item should always be visible'),
                ),
                
                // Admin only features
                if (testIsAdmin)
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Gestion des utilisateurs'),
                    onTap: () => Get.toNamed('/user-management'),
                  ),
                
                // Admin only features
                if (testIsAdmin)
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Gestion des stations'),
                    onTap: () => Get.toNamed('/station-management'),
                  ),
                
                // Admin and Gestionnaire Stock features
                if (testIsAdmin || testIsGestionnaireStock)
                  ListTile(
                    leading: const Icon(Icons.inventory),
                    title: const Text('Gestion des articles'),
                    onTap: () {
                      Get.back();
                      Get.toNamed('/articles');
                    },
                  ),
                
                // Admin and Gestionnaire Stock features
                if (testIsAdmin || testIsGestionnaireStock)
                  ListTile(
                    leading: const Icon(Icons.inventory),
                    title: const Text('Inventaire'),
                    onTap: () {
                      Get.back();
                      Get.toNamed('/inventaires');
                    },
                  ),
                
                // Admin and Gestionnaire Stock features
                if (testIsAdmin || testIsGestionnaireStock)
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text('Bon Transfert'),
                    onTap: () {
                      Get.back();
                      Get.toNamed('/bon-transfert');
                    },
                  ),
                
                // Admin and Gestionnaire Stock features
                if (testIsAdmin || testIsGestionnaireStock)
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text('Liste des Transferts'),
                    onTap: () {
                      Get.back();
                      Get.toNamed('/transfer-list');
                    },
                  ),
                
                // Admin and Agent Achat features
                if (testIsAdmin || testIsAgentAchat)
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: const Text('Gestion des Achats'),
                    onTap: () {
                      Get.back();
                      Get.toNamed('/purchase-management');
                    },
                  ),
                
                // Admin and Caissier features
                if (testIsAdmin || testIsCaissier)
                  ListTile(
                    leading: const Icon(Icons.confirmation_number),
                    title: const Text('Ticket rayon'),
                    onTap: () {},
                  ),
                
                // Admin and Agent Achat features
                if (testIsAdmin || testIsAgentAchat)
                  ListTile(
                    leading: const Icon(Icons.business),
                    title: const Text('Gestion des fournisseurs'),
                    onTap: () => Get.toNamed('/supplier-management'),
                  ),
              ],
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.grey.shade300, thickness: 1.2),
          ),
          const SizedBox(height: 8),
          _DrawerSection(
            icon: Icons.logout,
            label: 'Déconnexion',
            onTap: () {
              final box = GetStorage();
              box.remove('token'); // Use consistent 'token' key
              if (Get.isRegistered<ArticleController>()) {
                Get.find<ArticleController>().setToken('');
              }
              Get.offAllNamed('/login');
            },
            color: Colors.redAccent,
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final String? title;
  final List<Widget>? children;
  final VoidCallback? onTap;
  final Color? color;
  const _DrawerSection({this.icon, this.label, this.title, this.children, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    if (title != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
            child: ListTile(
              title: Text(
                title!,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          ...?children,
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
        child: ListTile(
          leading: Icon(icon, color: color ?? Colors.deepOrange, size: 26),
          title: Text(
            label!,
            style: TextStyle(
              color: color ?? Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: onTap,
          hoverColor: (color ?? Colors.deepOrange).withValues(alpha: 0.08),
          splashColor: (color ?? Colors.deepOrange).withValues(alpha: 0.12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        ),
      );
    }
  }
}
