import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';

class CreateInventaireScreen extends StatelessWidget {
  const CreateInventaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryController controller = Get.put(InventoryController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFF5722)),
        title: Text(
          'Créer un Inventaire',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFE0E7EF), Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    controller.error.value,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      controller.fetchStations();
                      controller.fetchArticles();
                    },
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Nouvel Inventaire',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        value: controller.selectedStation.value,
                        decoration: const InputDecoration(
                          labelText: 'Station',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        items: controller.stations
                            .map((s) => DropdownMenuItem<String>(
                                  value: s['id'].toString(),
                                  child: Text(s['nom'] ?? ''),
                                ))
                            .toList(),
                        onChanged: (v) => controller.setSelectedStation(v),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Articles',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
                            onPressed: controller.isLoadingArticles.value ? null : controller.showArticleSearch,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        if (controller.addedArticles.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Text(
                                'Aucun article ajouté',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.addedArticles.length,
                          separatorBuilder: (_, __) => const Divider(height: 18, color: Colors.grey),
                          itemBuilder: (context, index) {
                            final article = controller.addedArticles[index];
                            return ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              tileColor: Colors.deepOrange.withValues(alpha: 0.07),
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepOrange.withValues(alpha: 0.15),
                                child: const Icon(Icons.inventory_2, color: Colors.deepOrange),
                              ),
                              title: Text(article['designation'] ?? '', style: theme.textTheme.titleMedium),
                              subtitle: Text('Code à Barre: ${article['barcode'] ?? ''}', style: theme.textTheme.bodyMedium),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Qté: ${article['qte'] ?? ''}', style: theme.textTheme.bodySmall),
                                  Text('Prix: ${article['prix'] ?? ''}', style: theme.textTheme.bodySmall),
                                ],
                              ),
                              onTap: () => controller.editAddedArticle(index),
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.save_alt, color: Colors.white),
                          label: const Text(
                            'Enregistrer',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          onPressed: controller.isSubmitting.value ? null : controller.submitInventaire,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Article Search Dialog
class _ArticleSearchDialog extends StatefulWidget {
  final List<dynamic> articles;

  const _ArticleSearchDialog({required this.articles});

  @override
  _ArticleSearchDialogState createState() => _ArticleSearchDialogState();
}

class _ArticleSearchDialogState extends State<_ArticleSearchDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredArticles = widget.articles.where((article) {
      final designation = article['designation']?.toString().toLowerCase() ?? '';
      final barcode = article['barcode']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return designation.contains(query) || barcode.contains(query);
    }).toList();

    return Dialog(
      child: Container(
        width: double.maxFinite,
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher un article',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = filteredArticles[index];
                  return ListTile(
                    title: Text(article['designation'] ?? ''),
                    subtitle: Text('Code: ${article['barcode'] ?? ''}'),
                    onTap: () => Navigator.of(context).pop(article),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add Article Dialog
class _AddArticleDialog extends StatefulWidget {
  final Map<String, dynamic> article;

  const _AddArticleDialog({required this.article});

  @override
  _AddArticleDialogState createState() => _AddArticleDialogState();
}

class _AddArticleDialogState extends State<_AddArticleDialog> {
  final _qteController = TextEditingController(text: '1');
  final _prixController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prixController.text = widget.article['prix']?.toString() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ajouter ${widget.article['designation']}'),
            const SizedBox(height: 16),
            TextField(
              controller: _qteController,
              decoration: const InputDecoration(
                labelText: 'Quantité',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _prixController,
              decoration: const InputDecoration(
                labelText: 'Prix',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final result = {
                      ...widget.article,
                      'qte': int.tryParse(_qteController.text) ?? 1,
                      'prix': double.tryParse(_prixController.text) ?? 0,
                    };
                    Navigator.of(context).pop(result);
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 