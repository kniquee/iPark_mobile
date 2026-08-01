import 'package:flutter/material.dart';

class RoadWidget extends StatelessWidget {
  final String label;
  final double? height;
  final double topMargin;

  const RoadWidget({
    super.key,
    required this.label,
    this.height,
    this.topMargin = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topMargin),
      child: Column(
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Container(
            width: 30,
            height: height ?? 690,
            decoration: BoxDecoration(
              color: const Color(0xFF334155), // Slate gray road color
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF475569), width: 1),
            ),
            child: CustomPaint(painter: _WhiteDashedLinePainter()),
          ),
        ],
      ),
    );
  }
}

class _WhiteDashedLinePainter extends CustomPainter {
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x88FFFFFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashHeight = 8;
    double dashSpace = 8;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }
}
