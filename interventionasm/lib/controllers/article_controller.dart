import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../config/api_config.dart';

class ArticleController extends GetxController {
  var articles = [].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  // Filters
  var selectedFamille = ''.obs;
  var selectedMarque = ''.obs;

  // Auth token
  var token = ''.obs;
  final box = GetStorage();

  void setToken(String newToken) {
    token.value = newToken;
    box.write('token', newToken); // Use consistent 'token' key
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    isLoading.value = true;
    error.value = '';
    try {
      String url = ApiConfig.articlesUrl;
      Map<String, String> queryParams = {};
      if (selectedFamille.value.isNotEmpty) queryParams['famille'] = selectedFamille.value;
      if (selectedMarque.value.isNotEmpty) queryParams['marque'] = selectedMarque.value;
      if (queryParams.isNotEmpty) {
        url = '$url?${Uri(queryParameters: queryParams).query}';
      }
      final headers = <String, String>{};
      if (token.value.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${token.value}';
      }
      final response = await http.get(Uri.parse(url), headers: headers);
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
      } else if (response.statusCode == 422) {
        error.value = 'Erreur de validation: ${response.body}';
      } else {
        error.value = 'Erreur ${response.statusCode}: Échec du chargement des articles';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setFamille(String famille) {
    selectedFamille.value = famille;
    fetchArticles();
  }

  void setMarque(String marque) {
    selectedMarque.value = marque;
    fetchArticles();
  }

  @override
  void onInit() {
    super.onInit();
    // Load token from storage if available
    final storedToken = box.read('token'); // Use consistent 'token' key
    if (storedToken != null && storedToken is String && storedToken.isNotEmpty) {
      token.value = storedToken;
    }
    fetchArticles();
  }
} 