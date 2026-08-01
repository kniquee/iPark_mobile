import 'package:flutter/material.dart';

enum SlotPosition { left, right }

class ParkingSlot extends StatelessWidget {
  final String slotId;
  final bool occupied;
  final bool hasSensor;
  final SlotPosition position;

  const ParkingSlot({
    super.key,
    required this.slotId,
    required this.occupied,
    required this.hasSensor,
    this.position = SlotPosition.left,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;
    Color carColor;

    if (!hasSensor) {
      bg = const Color(0xFF1E2D3D);
      border = const Color(0xFF3B5268);
      textColor = const Color(0xFF94A3B8);
      carColor = const Color(0xFF475569);
    } else if (occupied) {
      bg = const Color(0xFFEF4444);
      border = const Color(0xFFFCA5A5);
      textColor = Colors.white;
      carColor = Colors.white;
    } else {
      bg = const Color(0xFF10B981);
      border = const Color(0xFF6EE7B7);
      textColor = Colors.white;
      carColor = Colors.white;
    }

    return Container(
      width: 72, // Restored original width
      height: 45, // Restored original height
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1.5),
        boxShadow: hasSensor
            ? [
                BoxShadow(
                  color:
                      (occupied
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981))
                          .withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            slotId,
            style: TextStyle(
              fontFamily: 'monospace',
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Icon(Icons.directions_car_rounded, color: carColor, size: 21),
        ],
      ),
    );
  }
}
