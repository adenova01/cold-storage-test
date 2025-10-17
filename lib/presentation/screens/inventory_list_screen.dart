import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/inventory_item.dart';
import '../providers/inventory_provider.dart';
import '../providers/location_provider.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({Key? key}) : super(key: key);

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inventoryProvider = context.read<InventoryProvider>();
      _searchController.text = inventoryProvider.searchQuery;

      context.read<LocationProvider>().fetchLocations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              _showClearConfirmation();
            },
            tooltip: 'Clear all items',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<InventoryProvider>().refreshItem();
        },
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by SKU or Location...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<InventoryProvider>().clearSearch();
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  context.read<InventoryProvider>().updateSearchQuery(value);
                },
              ),
            ),
      
            // Inventory List
            Expanded(
              child: Consumer2<InventoryProvider, LocationProvider>(
                builder: (context, inventoryProvider, locationProvider, child) {
                  final items = inventoryProvider.items;
      
                  if (inventoryProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
      
                  if (inventoryProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            inventoryProvider.error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
      
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            inventoryProvider.searchQuery.isNotEmpty
                                ? 'No items found for "${inventoryProvider.searchQuery}"'
                                : 'No inventory items yet.\nAdd items through the Inbound screen.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
      
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final location =
                          locationProvider.getLocationById(item.locationId);
      
                      return _buildInventoryCard(item, location);
                    },
                  );
                },
              ),
            ),
      
            // Summary Footer
            Consumer<InventoryProvider>(
              builder: (context, provider, child) {
                if (provider.allItems.isEmpty) return const SizedBox.shrink();
      
                final totalItems = provider.allItems.length;
                final displayedItems = provider.items.length;
                final nearExpiryCount = provider.nearExpiryItems.length;
      
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Showing: $displayedItems / $totalItems',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (nearExpiryCount > 0)
                            Text(
                              '$nearExpiryCount items near expiry',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                            ),
                        ],
                      ),
                      if (provider.searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            provider.clearSearch();
                          },
                          child: const Text('Clear Filter'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item, location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.sku,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Batch: ${item.batch}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                // Near Expiry Badge
                if (item.isNearExpiry)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.daysUntilExpiry} days',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Details Row
            Row(
              children: [
                // Quantity
                Expanded(
                  child: _buildDetailColumn(
                    'Quantity',
                    '${item.quantity} units',
                    Icons.inventory_2,
                  ),
                ),
                // Expiry
                Expanded(
                  child: _buildDetailColumn(
                    'Expiry',
                    DateFormat('dd/MM/yyyy').format(item.expiry),
                    Icons.calendar_today,
                  ),
                ),
                // Location
                Expanded(
                  child: _buildDetailColumn(
                    'Location',
                    location?.label.split('/')[0] ?? item.locationId,
                    Icons.location_on,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Footer
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Added: ${DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Items'),
          content: const Text(
            'Are you sure you want to clear all inventory items? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<InventoryProvider>().clearAllItems();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All items cleared'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear All',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
