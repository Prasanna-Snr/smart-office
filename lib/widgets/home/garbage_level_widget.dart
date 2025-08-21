import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../core/utils/garbage_utils.dart';

class GarbageLevelWidget extends StatelessWidget {
  final double garbageLevel;

  const GarbageLevelWidget({
    Key? key,
    required this.garbageLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = GarbageUtils.getGarbageLevelColor(garbageLevel);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (icon + title, no warning/status chip)
            Row(
              children: [
                Icon(
                  GarbageUtils.getGarbageLevelIcon(garbageLevel),
                  size: 24,
                  color: color,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Dustbin Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Gauge with measuring scale 0,10,20,...,100
            SizedBox(
              height: 160,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 100,
                    showLabels: true,
                    showTicks: true,
                    interval: 10, // 0, 10, 20, ...
                    // No % in scale labels
                    axisLabelStyle: const GaugeTextStyle(
                      fontSize: 7, // smaller scale font
                      fontWeight: FontWeight.w500,
                    ),
                    majorTickStyle: const MajorTickStyle(
                      length: 7,
                      thickness: 2,
                    ),
                    minorTicksPerInterval: 4,
                    minorTickStyle: const MinorTickStyle(
                      length: 6,
                      thickness: 1,
                    ),

                    // Ranges
                    ranges: <GaugeRange>[
                      GaugeRange(startValue: 0, endValue: 80, color: Colors.green),
                      GaugeRange(startValue: 80, endValue: 95, color: Colors.orange),
                      GaugeRange(startValue: 95, endValue: 100, color: Colors.red),
                    ],

                    // Needle pointer
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: garbageLevel.clamp(0, 100),
                        needleColor: Colors.black,
                        needleStartWidth: 0,
                        needleEndWidth: 5,
                        needleLength: 0.85,
                        knobStyle: const KnobStyle(
                          color: Colors.black,
                          sizeUnit: GaugeSizeUnit.logicalPixel,
                          knobRadius: 10,
                          borderColor: Colors.white,
                          borderWidth: 2,
                        ),
                        tailStyle: const TailStyle(
                          color: Colors.black,
                          width: 5,
                          length: 0.12,
                        ),
                      ),
                    ],

                    // Center annotation (keeps % for clarity)
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          '${garbageLevel.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.75,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
