import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transfer_controller.dart';

class TransferListScreen extends StatelessWidget {
  const TransferListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TransferController controller = Get.put(TransferController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFF5722)),
        title: Text(
          'Liste des Transferts',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchTransfers,
            color: const Color(0xFFFF5722),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF5722),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Get.toNamed('/bon-transfert');
        },
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
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
                      onPressed: controller.fetchTransfers,
                    ),
                  ],
                ),
              );
            }

            if (controller.transfers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swap_horiz, color: Colors.deepOrange, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun transfert trouvé',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchTransfers,
              child: ListView.builder(
                itemCount: controller.transfers.length,
                itemBuilder: (context, index) {
                  final transfer = controller.transfers[index];
                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepOrange.withOpacity(0.15),
                        child: Icon(Icons.swap_horiz, color: Colors.deepOrange[400]),
                      ),
                      title: Text(
                        transfer['id'] != null ? 'Transfert_${transfer['id']}' : 'Transfert',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'De: ${transfer['stationSource']?['nom'] ?? 'N/A'}',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                          ),
                          Text(
                            'Vers: ${transfer['stationDestination']?['nom'] ?? 'N/A'}',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                          ),
                          Text(
                            'Date: ${transfer['date_transfert'] ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black38),
                          ),
                          Text(
                            'Statut: ${transfer['statut'] ?? 'En cours'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getStatusColor(transfer['statut']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.deepOrange),
                      onTap: () {
                        // TODO: Navigate to transfer details
                        Get.snackbar('Info', 'Détails de transfert à implémenter');
                      },
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'validé':
      case 'validée':
        return Colors.green;
      case 'annulé':
      case 'annulée':
        return Colors.red;
      case 'en cours':
      case 'en instance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
} 