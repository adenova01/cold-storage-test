import 'dart:math';
import '../models/temperature.dart';
import '../models/location.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  final Random _random = Random();

  // Mock data storage
  final List<Location> _locations = [
    Location(
      id: 'A1-01',
      label: 'Zone A / Rack 1 / Slot 01',
      capacity: 100,
      currentLoad: 72,
    ),
    Location(
      id: 'A1-02',
      label: 'Zone A / Rack 1 / Slot 02',
      capacity: 120,
      currentLoad: 120,
    ),
    Location(
      id: 'B2-05',
      label: 'Zone B / Rack 2 / Slot 05',
      capacity: 80,
      currentLoad: 30,
    ),
    Location(
      id: 'A2-03',
      label: 'Zone A / Rack 2 / Slot 03',
      capacity: 150,
      currentLoad: 45,
    ),
    Location(
      id: 'C1-01',
      label: 'Zone C / Rack 1 / Slot 01',
      capacity: 90,
      currentLoad: 15,
    ),
  ];

  // Simulate GET /temperatures
  Future<List<Temperature>> getTemperatures() async {
    // simulasi delay ketika fetch ke api
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    return [
      Temperature(
        roomId: 'COLD-01',
        temperature: _generateTemperature(-18.3),
        timestamp: now,
      ),
      Temperature(
        roomId: 'COLD-02',
        temperature: _generateTemperature(-15.8),
        timestamp: now.add(const Duration(seconds: 5)),
      ),
      Temperature(
        roomId: 'COLD-03',
        temperature: _generateTemperature(-19.5),
        timestamp: now.add(const Duration(seconds: 10)),
      ),
      Temperature(
        roomId: 'COLD-04',
        temperature: _generateTemperature(-12.3),
        timestamp: now.add(const Duration(seconds: 10)),
      ),
    ];
  }

  // simulasi GET /locations
  Future<List<Location>> getLocations() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_locations);
  }

  // simulasi POST /inbound
  Future<Map<String, dynamic>> submitInbound(Map<String, dynamic> data) async {
    // simulasi network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // update location current load
    final locationId = data['location_id'] as String;
    final quantity = data['quantity'] as int;

    final locationIndex = _locations.indexWhere((loc) => loc.id == locationId);
    if (locationIndex != -1) {
      final location = _locations[locationIndex];
      _locations[locationIndex] = Location(
        id: location.id,
        label: location.label,
        capacity: location.capacity,
        currentLoad: location.currentLoad + quantity,
      );
    }

    return {
      'success': true,
      'message': 'Inbound data submitted successfully',
      'id': _generateId(),
    };
  }

  // generate simulasi temperature random
  double _generateTemperature(double baseTemp) {
    final variation = (_random.nextDouble() - 0.5) * 4;
    return baseTemp + variation;
  }

  // generate id
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
