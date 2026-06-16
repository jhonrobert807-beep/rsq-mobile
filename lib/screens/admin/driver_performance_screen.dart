import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_performance_provider.dart';

class DriverPerformanceScreen extends StatefulWidget {
  const DriverPerformanceScreen({super.key});

  @override
  State<DriverPerformanceScreen> createState() => _DriverPerformanceScreenState();
}

class _DriverPerformanceScreenState extends State<DriverPerformanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredDrivers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DriverPerformanceProvider>().loadAllStats();
      }
    });
  }

  void _filterDrivers(String query) {
    final provider = context.read<DriverPerformanceProvider>();
    final allStats = provider.allStats;
    if (allStats == null) return;

    final drivers = allStats['drivers'] as List<dynamic>? ?? [];
    if (query.isEmpty) {
      _filteredDrivers = drivers;
    } else {
      _filteredDrivers = drivers
          .where((perf) =>
              (perf['driverName']?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (perf['driverId']?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Performance'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<DriverPerformanceProvider>(
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
                    onPressed: () => provider.loadAllStats(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final allStats = provider.allStats ?? {};
          final driversData = (allStats['drivers'] as List<dynamic>?) ?? [];
          final drivers = _filteredDrivers.isEmpty && _searchController.text.isEmpty
              ? driversData
              : _filteredDrivers;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterDrivers,
                  decoration: InputDecoration(
                    hintText: 'Search drivers...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              Expanded(
                child: drivers.isEmpty
                    ? const Center(child: Text('No drivers'))
                    : ListView.builder(
                        itemCount: drivers.length,
                        itemBuilder: (context, index) {
                          final perf = drivers[index];
                          final rating = (perf['averageRating'] ?? 0.0) as double;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  (perf['driverName'] ?? 'D')[0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(perf['driverName'] ?? 'Driver'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rides: ${perf['totalRides'] ?? 0} | Rating: ${rating.toStringAsFixed(1)} ⭐',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Earnings: PKR ${perf['totalEarnings'] ?? 0}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward),
                              onTap: () => _showDetails(perf),
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

  void _showDetails(dynamic perf) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(perf['driverName'] ?? 'Driver Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Driver ID', perf['driverId'] ?? 'N/A'),
              _detailRow('Total Rides', (perf['totalRides'] ?? 0).toString()),
              _detailRow('Average Rating', (perf['averageRating'] ?? 0).toString()),
              _detailRow('Total Earnings', 'PKR ${(perf['totalEarnings'] ?? 0).toString()}'),
              _detailRow('Completed Rides', (perf['completedRides'] ?? 0).toString()),
              _detailRow('Cancelled Rides', (perf['cancelledRides'] ?? 0).toString()),
              _detailRow('Avg Response Time', (perf['avgResponseTime'] ?? 0).toString()),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
