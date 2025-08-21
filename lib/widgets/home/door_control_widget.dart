import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/firebase_service.dart'; // ← adjust if your path differs

class DoorControlWidget extends StatelessWidget {
  const DoorControlWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        height: AppConstants.dashboardCardHeight,
      ),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: StreamBuilder<bool>(
            stream: FirebaseService.doorStatusStream(),
            builder: (context, snapshot) {
              final bool hasData = snapshot.hasData;
              final bool isOpen = snapshot.data ?? false;
              final Color statusColor =
              isOpen ? AppTheme.successColor : Colors.red;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: Icon + Title (like GarbageLevelWidget) ───────────
                  Row(
                    children: [
                      Icon(
                        isOpen
                            ? Icons.door_front_door
                            : Icons.door_front_door_outlined,
                        size: 24,
                        color: statusColor,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Door Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Middle: Styled OPEN/CLOSED badge ─────────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: statusColor.withOpacity(0.25), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status dot
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasData
                                ? (isOpen ? 'OPEN' : 'CLOSED')
                                : '…', // loading fallback
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Bottom: Buttons (no icons) ───────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: !hasData || isOpen
                              ? null
                              : () => FirebaseService.updateDoorStatus(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Open'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: !hasData || !isOpen
                              ? null
                              : () => FirebaseService.updateDoorStatus(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
