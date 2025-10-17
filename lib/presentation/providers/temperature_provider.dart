import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/temperature.dart';
import '../../data/services/mock_api_service.dart';

class TemperatureProvider with ChangeNotifier {
  final MockApiService _apiService = MockApiService();
  Timer? _timer;

  List<Temperature> _temperatures = [];
  bool _isLoading = false;
  String? _error;

  List<Temperature> get temperatures => _temperatures;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Start polling temperature data every 7 seconds
  void startPolling() {
    _fetchTemperatures();
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      _fetchTemperatures();
    });
  }

  // Stop polling
  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  // Fetch temperature data
  Future<void> _fetchTemperatures() async {
    try {
      _setLoading(true);
      _setError(null);

      final temperatures = await _apiService.getTemperatures();
      _temperatures = temperatures;

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch temperatures: $e');
      _setLoading(false);
      notifyListeners();
    }
  }

  // Manual refresh
  Future<void> refresh() async {
    await _fetchTemperatures();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String? error) {
    _error = error;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
