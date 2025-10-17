import 'package:flutter/foundation.dart';
import '../../data/models/location.dart';
import '../../data/services/mock_api_service.dart';

class LocationProvider with ChangeNotifier {
  final MockApiService _apiService = MockApiService();

  List<Location> _locations = [];
  bool _isLoading = false;
  String? _error;

  List<Location> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // get all location
  Future<void> fetchLocations() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final locations = await _apiService.getLocations();
      _locations = locations;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch locations: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // get location by id
  Location? getLocationById(String id) {
    try {
      return _locations.firstWhere((location) => location.id == id);
    } catch (e) {
      return null;
    }
  }

  // get locations with available space
  List<Location> get availableLocations {
    return _locations.where((location) => !location.isFull).toList();
  }
}
