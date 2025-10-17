import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/temperature_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/temperature_card.dart';
import 'inbound_screen.dart';
import 'inventory_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemperatureProvider>().startPolling();
    });
  }

  @override
  void dispose() {
    context.read<TemperatureProvider>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TemperatureProvider>().refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TemperatureProvider>().refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Temperature Monitoring Section
              _buildTemperatureSection(),

              const SizedBox(height: 20),

              // Quick Actions Section
              _buildQuickActionsSection(),

              const SizedBox(height: 20),

              // Inventory Summary Section
              _buildInventorySummarySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureSection() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.thermostat,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Temperature Monitoring',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<TemperatureProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.temperatures.isEmpty) {
                    return const SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (provider.error != null) {
                    return SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  provider.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (provider.temperatures.isEmpty) {
                    return const SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text('No temperature data available'),
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: provider.temperatures
                        .map((temp) => TemperatureCard(temperature: temp))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.dashboard,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InboundScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_box),
                        label: const Text('Add Inbound'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InventoryListScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.inventory),
                        label: const Text('View Inventory'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventorySummarySection() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Inventory Summary',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<InventoryProvider>(
                builder: (context, provider, child) {
                  final totalItems = provider.allItems.length;
                  final nearExpiryCount = provider.nearExpiryItems.length;

                  return Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Items',
                          totalItems.toString(),
                          Icons.inventory_2,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Near Expiry',
                          nearExpiryCount.toString(),
                          Icons.warning,
                          nearExpiryCount > 0 ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return SizedBox(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
