import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/article_controller.dart';

class ArticleListScreen extends StatelessWidget {
  const ArticleListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ArticleController controller = Get.put(ArticleController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.toNamed('/add-article');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Famille',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => controller.setFamille(value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Marque',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => controller.setMarque(value),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error.value.isNotEmpty) {
                return Center(child: Text(controller.error.value));
              }
              if (controller.articles.isEmpty) {
                return const Center(child: Text('Aucun article trouvé.'));
              }
              return ListView.builder(
                itemCount: controller.articles.length,
                itemBuilder: (context, index) {
                  final article = controller.articles[index];
                  return ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(article['designation'] ?? ''),
                    subtitle: Text('Famille: ${article['famille'] ?? ''} | Marque: ${article['marque'] ?? ''}'),
                    onTap: () {
                      // Optionally, show article details
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
} 