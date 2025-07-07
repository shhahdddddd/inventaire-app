import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/station_controller.dart';

class StationManagementScreen extends StatelessWidget {
  final StationController controller = Get.put(StationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Stations'),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showStationDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  controller.error.value,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchStations,
                  child: Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (controller.stations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucune station trouvée',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showStationDialog(context),
                  child: Text('Ajouter une station'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchStations,
          child: ListView.builder(
            itemCount: controller.stations.length,
            itemBuilder: (context, index) {
              final station = controller.stations[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepOrange,
                    child: Icon(Icons.location_on, color: Colors.white),
                  ),
                  title: Text(station['nom'] ?? ''),
                  subtitle: Text(station['description'] ?? ''),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Modifier'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showStationDialog(context, station: station);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, station);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showStationDialog(BuildContext context, {Map<String, dynamic>? station}) {
    if (station != null) {
      controller.loadStationForEdit(station);
    } else {
      controller.clearForm();
    }

    Get.dialog(
      AlertDialog(
        title: Text(station != null ? 'Modifier la station' : 'Nouvelle station'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.nomController,
                decoration: InputDecoration(
                  labelText: 'Nom de la station',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: controller.descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Obx(() => controller.error.value.isNotEmpty
                  ? Text(
                      controller.error.value,
                      style: TextStyle(color: Colors.red),
                    )
                  : SizedBox()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearForm();
              Get.back();
            },
            child: Text('Annuler'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (station != null) {
                          controller.updateStation(station['id']);
                        } else {
                          controller.createStation();
                        }
                      },
                child: controller.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(station != null ? 'Modifier' : 'Créer'),
              )),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> station) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer la station "${station['nom']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteStation(station['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }
} 