class Location {
  final String id;
  final String label;
  final int capacity;
  final int currentLoad;

  Location({
    required this.id,
    required this.label,
    required this.capacity,
    required this.currentLoad,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      label: json['label'],
      capacity: json['capacity'],
      currentLoad: json['current_load'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'capacity': capacity,
      'current_load': currentLoad,
    };
  }

  bool get isFull {
    return currentLoad >= capacity;
  }

  double get loadPercentage {
    return (currentLoad / capacity) * 100;
  }

  int get availableSpace {
    return capacity - currentLoad;
  }
}
