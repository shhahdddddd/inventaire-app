import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';

class InventoryController extends GetxController {
  // Observable variables
  var inventaires = [].obs;
  var stations = [].obs;
  var articles = [].obs;
  var addedArticles = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isLoadingArticles = false.obs;
  var isSubmitting = false.obs;
  var error = ''.obs;
  
  // Form controllers
  final dateController = TextEditingController();
  final quantiteController = TextEditingController();
  final quantiteReelleController = TextEditingController();
  
  // Selected values
  var selectedStation = ''.obs;
  var selectedArticle = <String, dynamic>{}.obs;
  
  // Auth token
  final box = GetStorage();
  String get token => box.read('token') ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchStations();
    fetchArticles();
    fetchInventaires();
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

  Future<void> fetchArticles() async {
    isLoadingArticles.value = true;
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.articlesUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          articles.value = responseData['data'];
        } else {
          articles.value = responseData;
        }
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else {
        error.value = 'Erreur ${response.statusCode}: Échec du chargement des articles';
      }
    } catch (e) {
      error.value = 'Erreur: $e';
    } finally {
      isLoadingArticles.value = false;
    }
  }

  Future<void> fetchInventaires() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.inventairesUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          inventaires.value = responseData['data'];
        } else {
          inventaires.value = responseData;
        }
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else {
        error.value = 'Erreur ${response.statusCode}: Échec du chargement des inventaires';
      }
    } catch (e) {
      error.value = 'Erreur: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedStation(String? stationId) {
    selectedStation.value = stationId ?? '';
  }

  void showArticleSearch() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sélectionner un Article'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Rechercher un article',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  // Filter articles based on search
                  // This could be enhanced with a search API
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return ListTile(
                      title: Text(article['designation'] ?? ''),
                      subtitle: Text('Code: ${article['barcode'] ?? ''}'),
                      trailing: Text('Prix: ${article['prix'] ?? ''}'),
                      onTap: () {
                        selectedArticle.value = article;
                        Get.back();
                        showQuantityDialog();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void showQuantityDialog() {
    quantiteController.clear();
    quantiteReelleController.clear();
    
    Get.dialog(
      AlertDialog(
        title: Text('Quantités pour ${selectedArticle['designation'] ?? ''}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantiteController,
              decoration: const InputDecoration(
                labelText: 'Quantité Comptée',
                prefixIcon: Icon(Icons.calculate),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantiteReelleController,
              decoration: const InputDecoration(
                labelText: 'Quantité Réelle',
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: addArticleToInventory,
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void addArticleToInventory() {
    if (quantiteController.text.isEmpty || quantiteReelleController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir toutes les quantités');
      return;
    }

    final article = Map<String, dynamic>.from(selectedArticle);
    article['quantite_comptee'] = int.tryParse(quantiteController.text) ?? 0;
    article['quantite_reelle'] = int.tryParse(quantiteReelleController.text) ?? 0;
    
    addedArticles.add(article);
    Get.back();
    Get.snackbar('Succès', 'Article ajouté à l\'inventaire');
  }

  void editAddedArticle(int index) {
    final article = addedArticles[index];
    quantiteController.text = article['quantite_comptee'].toString();
    quantiteReelleController.text = article['quantite_reelle'].toString();
    selectedArticle.value = article;
    
    Get.dialog(
      AlertDialog(
        title: Text('Modifier ${article['designation'] ?? ''}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantiteController,
              decoration: const InputDecoration(
                labelText: 'Quantité Comptée',
                prefixIcon: Icon(Icons.calculate),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantiteReelleController,
              decoration: const InputDecoration(
                labelText: 'Quantité Réelle',
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              updateAddedArticle(index);
            },
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  void updateAddedArticle(int index) {
    if (quantiteController.text.isEmpty || quantiteReelleController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir toutes les quantités');
      return;
    }

    final article = Map<String, dynamic>.from(addedArticles[index]);
    article['quantite_comptee'] = int.tryParse(quantiteController.text) ?? 0;
    article['quantite_reelle'] = int.tryParse(quantiteReelleController.text) ?? 0;
    
    addedArticles[index] = article;
    Get.back();
    Get.snackbar('Succès', 'Article mis à jour');
  }

  void removeAddedArticle(int index) {
    addedArticles.removeAt(index);
    Get.snackbar('Succès', 'Article retiré de l\'inventaire');
  }

  Future<void> submitInventaire() async {
    if (selectedStation.value.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez sélectionner une station');
      return;
    }

    if (addedArticles.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez ajouter au moins un article');
      return;
    }

    isSubmitting.value = true;
    error.value = '';

    try {
      // Get current user ID from storage or API
      final userData = box.read('user');
      final userId = userData != null ? (userData['id'] ?? userData['user_id'] ?? 1) : 1; // Fallback to 1 for testing
      
      final inventaireItems = addedArticles.map((article) => {
        'article_id': article['id'],
        'quantite_relle': article['quantite_reelle'], // Match backend field name
        'qte_stock': article['quantite_comptee'], // Match backend field name
      }).toList();

      final response = await http.post(
        Uri.parse(ApiConfig.inventairesUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'date_ouverture': DateTime.now().toIso8601String().split('T')[0], // Match backend field name
          'station_id': int.parse(selectedStation.value),
          'user_id': userId, // Add missing required field
          'inventaire_items': inventaireItems,
        }),
      );

      if (response.statusCode == 201) {
        Get.snackbar('Succès', 'Inventaire créé avec succès !');
        clearForm();
        fetchInventaires();
        Get.offNamed('/inventaires');
      } else if (response.statusCode == 401) {
        error.value = 'Non autorisé. Veuillez vous reconnecter.';
      } else if (response.statusCode == 403) {
        error.value = 'Accès refusé. Permissions insuffisantes.';
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        error.value = 'Erreur de validation: ${errorData['message'] ?? response.body}';
      } else {
        error.value = 'Erreur ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      error.value = 'Erreur: $e';
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    selectedStation.value = '';
    addedArticles.clear();
    selectedArticle.value = {};
    quantiteController.clear();
    quantiteReelleController.clear();
  }

  @override
  void onClose() {
    dateController.dispose();
    quantiteController.dispose();
    quantiteReelleController.dispose();
    super.onClose();
  }
} 