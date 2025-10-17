import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/inventory_item.dart';
import '../../data/models/location.dart';
import '../../data/services/mock_api_service.dart';
import '../providers/inventory_provider.dart';
import '../providers/location_provider.dart';

class InboundScreen extends StatefulWidget {
  const InboundScreen({Key? key}) : super(key: key);

  @override
  State<InboundScreen> createState() => _InboundScreenState();
}

class _InboundScreenState extends State<InboundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _batchController = TextEditingController();
  final _quantityController = TextEditingController();
  final MockApiService _apiService = MockApiService();
  final Random _random = Random();

  DateTime? _selectedExpiry;
  String? _selectedLocationId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().fetchLocations();
    });
  }

  @override
  void dispose() {
    _skuController.dispose();
    _batchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbound - Add Item'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // field sku dan scan
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Information',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _skuController,
                              decoration: const InputDecoration(
                                labelText: 'SKU *',
                                border: OutlineInputBorder(),
                                hintText: 'Enter or scan SKU',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'SKU is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _simulateScan,
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Scan'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _batchController,
                        decoration: const InputDecoration(
                          labelText: 'Batch Number *',
                          border: OutlineInputBorder(),
                          hintText: 'Enter batch number',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Batch number is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Expiry and Quantity
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      // Expiry Date
                      InkWell(
                        onTap: _selectExpiryDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Expiry Date *',
                            border: const OutlineInputBorder(),
                            errorText: _selectedExpiry == null && _isSubmitting
                                ? 'Expiry date is required'
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedExpiry != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(_selectedExpiry!)
                                    : 'Select expiry date',
                                style: TextStyle(
                                  color: _selectedExpiry != null
                                      ? Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                      : Theme.of(context).hintColor,
                                ),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Quantity
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                          hintText: 'Enter quantity',
                          suffixText: 'units',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Quantity is required';
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Please enter a valid quantity';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Location Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Storage Location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Consumer<LocationProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (provider.error != null) {
                            return Text(
                              'Error loading locations: ${provider.error}',
                              style: const TextStyle(color: Colors.red),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            value: _selectedLocationId,
                            decoration: InputDecoration(
                              labelText: 'Location *',
                              border: const OutlineInputBorder(),
                              hintText: 'Select storage location',
                              errorText:
                                  _selectedLocationId == null && _isSubmitting
                                      ? 'Please select a location'
                                      : null,
                            ),
                            items: provider.locations.map((Location loc) {
                              return DropdownMenuItem<String>(
                                value: loc.id,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Location ' + loc.label),
                                    Text(
                                      '${loc.currentLoad}/${loc.capacity}',
                                      style: TextStyle(
                                        color: loc.isFull
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedLocationId = newValue;
                              });
                            },
                          );
                        },
                      ),
                      if (_selectedLocationId != null)
                        Consumer<LocationProvider>(
                          builder: (context, provider, child) {
                            final location =
                                provider.getLocationById(_selectedLocationId!);
                            if (location == null) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: location.loadPercentage / 100,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        location.isFull
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${location.currentLoad}/${location.capacity}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              Consumer2<LocationProvider, InventoryProvider>(
                builder: (context, locationProvider, inventoryProvider, child) {
                  final selectedLocation = _selectedLocationId != null
                      ? locationProvider.getLocationById(_selectedLocationId!)
                      : null;
                  final isLocationFull = selectedLocation?.isFull ?? false;

                  return ElevatedButton(
                    onPressed:
                        (_isSubmitting || isLocationFull) ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isLocationFull ? Colors.grey : null,
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Submitting...'),
                            ],
                          )
                        : Text(
                            isLocationFull
                                ? 'Location Full - Cannot Submit'
                                : 'Submit Inbound',
                            style: const TextStyle(fontSize: 16),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // dummy sku generate
  List<String> getDummySKU() {
    return [
      'SKU-MEAT-001',
      'SKU-FISH-002',
      'SKU-VEGGIE-003',
      'SKU-DAIRY-004',
      'SKU-FROZEN-005',
      'SKU-ICE-006',
      'SKU-BEVERAGE-007',
    ];
  }

  // get random sku
  String getRandomSKU() {
    final sku = getDummySKU();
    return sku[_random.nextInt(sku.length)];
  }

  // simulasi scan sku
  void _simulateScan() {
    final randomSKU = getRandomSKU();
    _skuController.text = randomSKU;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scanned: $randomSKU'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedExpiry = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });

    if (!_formKey.currentState!.validate() ||
        _selectedExpiry == null ||
        _selectedLocationId == null) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    try {
      final item = InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sku: _skuController.text,
        batch: _batchController.text,
        expiry: _selectedExpiry!,
        quantity: int.parse(_quantityController.text),
        locationId: _selectedLocationId!,
        createdAt: DateTime.now(),
      );

      final capacityAvailable = context
          .read<LocationProvider>()
          .getLocationById(_selectedLocationId!)!
          .availableSpace;
      if (item.quantity > capacityAvailable) {
        throw Exception(
            'Not enough space in selected location. Available: $capacityAvailable');
      }

      final success = await context.read<InventoryProvider>().addItem(item);

      if (success && mounted) {
        // Refresh locations to update capacity
        final locationProvider = context.read<LocationProvider>();
        await locationProvider.fetchLocations();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
