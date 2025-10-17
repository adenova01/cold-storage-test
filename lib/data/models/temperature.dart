class Temperature {
  final String roomId;
  final double temperature;
  final DateTime timestamp;

  Temperature({
    required this.roomId,
    required this.temperature,
    required this.timestamp,
  });

  factory Temperature.fromJson(Map<String, dynamic> json) {
    return Temperature(
      roomId: json['room_id'],
      temperature: json['temperature'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isOutOfRange {
    return temperature < -20.0 || temperature > -16.0;
  }

  String get temperatureDisplay {
    return '${temperature.toStringAsFixed(1)}°C';
  }
}
