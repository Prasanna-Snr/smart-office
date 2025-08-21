import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GasDetector extends StatefulWidget {
  final bool gasDetected;
  final VoidCallback? onDismiss;

  const GasDetector({
    Key? key,
    required this.gasDetected,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<GasDetector> createState() => _GasDetectorState();
}

class _GasDetectorState extends State<GasDetector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.gasDetected ? 1.0 : 0.0, // start in correct state
    );
  }

  @override
  void didUpdateWidget(covariant GasDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gasDetected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect( // prevent any overpaint during the animation
      child: SizeTransition(
        sizeFactor: _controller,      // animates height factor 0→1
        axisAlignment: -1.0,          // grow from the top down
        child: Card(
          color: AppTheme.errorColor,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                // Let text wrap within the available width
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // don't demand extra height
                    children: [
                      const Text(
                        'GAS LEAK DETECTED!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Immediate action required',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onDismiss,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
