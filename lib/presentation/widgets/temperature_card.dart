import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/temperature.dart';

class TemperatureCard extends StatelessWidget {
  final Temperature temperature;

  const TemperatureCard({
    Key? key,
    required this.temperature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isOutOfRange = temperature.isOutOfRange;
    final Color cardColor =
        isOutOfRange ? Colors.red.shade50 : Colors.green.shade50;
    final Color iconColor = isOutOfRange ? Colors.red : Colors.green;
    final Color textColor =
        isOutOfRange ? Colors.red.shade800 : Colors.green.shade800;

    return Card(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isOutOfRange ? Icons.warning : Icons.thermostat,
                color: iconColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    temperature.roomId,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: ${DateFormat('HH:mm:ss').format(temperature.timestamp)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  temperature.temperatureDisplay,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                ),
                if (isOutOfRange) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'OUT OF RANGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NORMAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
