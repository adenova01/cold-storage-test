// Test file for Cold Storage Management App
import 'package:flutter_test/flutter_test.dart';
import 'package:test_aplication/data/models/temperature.dart';
import 'package:test_aplication/data/models/inventory_item.dart';
import 'package:test_aplication/data/models/location.dart';

void main() {
  group('Data Models Test', () {
    test('Temperature model should detect out of range values', () {
      final normalTemp = Temperature(
        roomId: 'COLD-01',
        temperature: -18.0,
        timestamp: DateTime.now(),
      );

      final hotTemp = Temperature(
        roomId: 'COLD-02',
        temperature: -15.0,
        timestamp: DateTime.now(),
      );

      final coldTemp = Temperature(
        roomId: 'COLD-03',
        temperature: -22.0,
        timestamp: DateTime.now(),
      );

      expect(normalTemp.isOutOfRange, false);
      expect(hotTemp.isOutOfRange, true);
      expect(coldTemp.isOutOfRange, true);
    });

    test('Location model should detect full capacity', () {
      final availableLocation = Location(
        id: 'A1-01',
        label: 'Zone A / Rack 1 / Slot 01',
        capacity: 100,
        currentLoad: 50,
      );

      final fullLocation = Location(
        id: 'A1-02',
        label: 'Zone A / Rack 1 / Slot 02',
        capacity: 100,
        currentLoad: 100,
      );

      expect(availableLocation.isFull, false);
      expect(availableLocation.availableSpace, 50);

      expect(fullLocation.isFull, true);
      expect(fullLocation.availableSpace, 0);
    });

    test('Inventory item should detect near expiry', () {
      final nearExpiryItem = InventoryItem(
        id: '1',
        sku: 'SKU-001',
        batch: 'B001',
        expiry: DateTime.now().add(const Duration(days: 15)),
        quantity: 10,
        locationId: 'A1-01',
        createdAt: DateTime.now(),
      );

      final normalItem = InventoryItem(
        id: '2',
        sku: 'SKU-002',
        batch: 'B002',
        expiry: DateTime.now().add(const Duration(days: 60)),
        quantity: 20,
        locationId: 'A1-02',
        createdAt: DateTime.now(),
      );

      expect(nearExpiryItem.isNearExpiry, true);
      expect(normalItem.isNearExpiry, false);
    });
  });
}
