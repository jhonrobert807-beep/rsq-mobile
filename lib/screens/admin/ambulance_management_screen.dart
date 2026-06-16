import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ambulance_provider.dart';
import '../../models/ambulance_model.dart';

class AmbulanceManagementScreen extends StatefulWidget {
  const AmbulanceManagementScreen({super.key});

  @override
  State<AmbulanceManagementScreen> createState() => _AmbulanceManagementScreenState();
}

class _AmbulanceManagementScreenState extends State<AmbulanceManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AmbulanceModel> _filteredAmbulances = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AmbulanceProvider>().loadAmbulances();
      }
    });
  }

  void _filterAmbulances(String query) {
    final provider = context.read<AmbulanceProvider>();
    if (query.isEmpty) {
      _filteredAmbulances = provider.ambulances;
    } else {
      _filteredAmbulances = provider.ambulances
          .where((amb) =>
              (amb.registrationNumber?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              amb.type.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulance Management'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<AmbulanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 15),
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => provider.loadAmbulances(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final ambulances = _filteredAmbulances.isEmpty && _searchController.text.isEmpty
              ? provider.ambulances
              : _filteredAmbulances;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterAmbulances,
                  decoration: InputDecoration(
                    hintText: 'Search ambulances...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              Expanded(
                child: ambulances.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty ? 'No ambulances' : 'No results',
                        ),
                      )
                    : ListView.builder(
                        itemCount: ambulances.length,
                        itemBuilder: (context, index) {
                          final amb = ambulances[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.local_hospital, color: Colors.red),
                              title: Text(amb.registrationNumber ?? 'Ambulance'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Type: ${amb.type}'),
                                  Text('Status: ${amb.status}',
                                      style: const TextStyle(fontSize: 12, color: Colors.blue)),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('View'),
                                    onTap: () => _showDetails(amb),
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Edit'),
                                    onTap: () => _showEditDialog(amb, provider),
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Delete'),
                                    onTap: () => _showDeleteConfirm(amb, provider),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDetails(AmbulanceModel amb) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(amb.registrationNumber ?? 'Ambulance'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('ID', amb.id),
              _detailRow('Type', amb.type),
              _detailRow('Status', amb.status),
              _detailRow('Distance', amb.displayDistance),
              _detailRow('ETA', amb.displayEta),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final typeController = TextEditingController();
    final driverIdController = TextEditingController();
    final statusController = TextEditingController(text: 'AVAILABLE');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Ambulance'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: driverIdController,
                decoration: const InputDecoration(labelText: 'Driver ID'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type (e.g., WITH_DOCTOR)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!mounted) return;
              try {
                await context.read<AmbulanceProvider>().createAmbulance(
                      licensePlate: 'AUTO',
                      ambulanceType: typeController.text,
                      driverId: driverIdController.text,
                      status: statusController.text,
                    );
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ambulance created')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(AmbulanceModel amb, AmbulanceProvider provider) {
    final typeController = TextEditingController(text: amb.type);
    final statusController = TextEditingController(text: amb.status);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Ambulance'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!mounted) return;
              try {
                await provider.updateAmbulance(
                  amb.id,
                  ambulanceType: typeController.text,
                  status: statusController.text,
                );
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ambulance updated')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(AmbulanceModel amb, AmbulanceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ambulance'),
        content: Text('Delete ${amb.registrationNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!mounted) return;
              try {
                await provider.deleteAmbulance(amb.id);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ambulance deleted')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
