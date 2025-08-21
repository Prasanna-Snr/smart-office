import 'package:flutter/material.dart';
import '../../core/utils/temperature_utils.dart';
import '../../core/constants/app_constants.dart';
import '../common/info_card.dart';

class TemperatureWidget extends StatelessWidget {
  final double temperature;

  const TemperatureWidget({
    Key? key,
    required this.temperature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = TemperatureUtils.getTemperatureColor(temperature);
    final progress = TemperatureUtils.getTemperatureProgress(temperature);
    
    return InfoCard(
      icon: Icons.thermostat,
      title: 'Room Temperature',
      subtitle: 'Optimal range: ${AppConstants.optimalTempMin}-${AppConstants.optimalTempMax}°C',
      value: '${temperature.toStringAsFixed(1)}°C',
      iconColor: color,
      valueColor: color,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${temperature.toStringAsFixed(1)}°C',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppConstants.minTemperature.toInt()}°C',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${AppConstants.maxTemperature.toInt()}°C',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}