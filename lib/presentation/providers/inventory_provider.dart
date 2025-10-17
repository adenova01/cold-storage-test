import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:test_aplication/data/models/location.dart';
import 'package:test_aplication/presentation/providers/location_provider.dart';
import '../../data/models/inventory_item.dart';
import '../../data/services/mock_api_service.dart';

class InventoryProvider with ChangeNotifier {
  final MockApiService _apiService = MockApiService();
  final LocationProvider locationProvider;

  InventoryProvider({required this.locationProvider});

  final List<InventoryItem> _items = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<InventoryItem> get items => _getFilteredItems();
  List<InventoryItem> get allItems => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // add new inventory item
  Future<bool> addItem(InventoryItem item) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.submitInbound({
        'sku': item.sku,
        'batch': item.batch,
        'expiry': item.expiry.toIso8601String(),
        'quantity': item.quantity,
        'location_id': item.locationId,
      });

      if (response['success'] == true) {
        _items.add(item);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to add item');
      }
    } catch (e) {
      _error = 'Failed to add item: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // update search query
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  // clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // get filtered items based on search query
  List<InventoryItem> _getFilteredItems() {
    if (_searchQuery.isEmpty) return _items;

    final keyword = _searchQuery.toLowerCase();

    return _items.where((item) {
      final location = locationProvider.locations.firstWhere(
          (loc) => loc.id == item.locationId,
          orElse: () =>
              Location(id: '', label: '', capacity: 0, currentLoad: 0));
      return item.sku.toLowerCase().contains(keyword) ||
          location.label.toLowerCase().contains(keyword);
    }).toList();
  }

  // get items expiry (within 30 days)
  List<InventoryItem> get nearExpiryItems {
    return _items.where((item) => item.isNearExpiry).toList();
  }

  // get items count by location
  Map<String, int> get itemCountByLocation {
    final Map<String, int> counts = {};
    for (final item in _items) {
      counts[item.locationId] = (counts[item.locationId] ?? 0) + item.quantity;
    }
    return counts;
  }

  // clear all items (for testing)
  void clearAllItems() {
    _items.clear();
    notifyListeners();
  }

  Future<void> refreshItem() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _getFilteredItems();
  }
}
