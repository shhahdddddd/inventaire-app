import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transfer_controller.dart';

class BonTransfertScreen extends StatelessWidget {
  const BonTransfertScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TransferController controller = Get.put(TransferController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFF5722)),
        title: Text(
          'Bon de Transfert',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            color: const Color(0xFFFF5722),
            onPressed: () => controller.submitTransfer(),
          ),
        ],
      ),
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
                    onPressed: controller.fetchStations,
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
                      Row(
                        children: [
                          Expanded(
                            child: _buildStationDropdown(
                              'Station Source',
                              controller.selectedSourceStation.value,
                              (value) => controller.setSourceStation(value),
                              controller.stations,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStationDropdown(
                              'Station destination',
                              controller.selectedDestinationStation.value,
                              (value) => controller.setDestinationStation(value),
                              controller.stations,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        'Etat',
                        ['En instance', 'Validée', 'Annulée'],
                        controller.selectedStatus.value,
                        (value) => controller.setStatus(value),
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
                            onPressed: controller.addArticle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        if (controller.articles.isEmpty) {
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
                          itemCount: controller.articles.length,
                          separatorBuilder: (_, __) => const Divider(height: 18, color: Colors.grey),
                          itemBuilder: (context, index) {
                            final article = controller.articles[index];
                            return ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              tileColor: Colors.deepOrange.withOpacity(0.07),
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepOrange.withOpacity(0.15),
                                child: const Icon(Icons.inventory_2, color: Colors.deepOrange),
                              ),
                              title: Text(article['designation'] ?? '', style: theme.textTheme.titleMedium),
                              subtitle: Text('Code à Barre: ${article['barcode'] ?? ''}', style: theme.textTheme.bodyMedium),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Qté: ${article['qty'] ?? ''}', style: theme.textTheme.bodySmall),
                                  Text('Prix: ${article['price'] ?? ''}', style: theme.textTheme.bodySmall),
                                ],
                              ),
                              onTap: () => controller.editArticle(index),
                            );
                          },
                        );
                      }),
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

  Widget _buildStationDropdown(String label, String? value, Function(String?) onChanged, List<dynamic> stations) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_on),
        border: const OutlineInputBorder(),
      ),
      items: stations
          .map((s) => DropdownMenuItem<String>(
                value: s['id'].toString(),
                child: Text(s['nom'] ?? ''),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.category),
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
} 