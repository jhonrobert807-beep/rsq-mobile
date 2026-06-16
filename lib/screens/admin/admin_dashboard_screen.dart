import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminProvider>().loadStats();
        context.read<AdminProvider>().loadAdminActions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<AdminProvider>(
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
                    onPressed: () {
                      provider.loadStats();
                      provider.loadAdminActions();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = provider.stats ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard Stats',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatCard('Total Users', (stats['totalUsers'] ?? 0).toString()),
                _buildStatCard(
                    'Active Rides', (stats['activeRides'] ?? 0).toString()),
                _buildStatCard('Total Revenue', 'PKR ${(stats['revenue'] ?? 0).toString()}'),
                const SizedBox(height: 24),
                const Text(
                  'Recent Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                provider.adminActions.isEmpty
                    ? const Center(child: Text('No actions'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.adminActions.length,
                        itemBuilder: (context, index) {
                          final action = provider.adminActions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.note, color: Colors.blue),
                              title: Text(action['actionType'] ?? 'Action'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(action['description'] ?? '', maxLines: 2),
                                  Text(action['timestamp'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
