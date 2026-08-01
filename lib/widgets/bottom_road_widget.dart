import 'package:flutter/material.dart';

class BottomRoadWidget extends StatefulWidget {
  const BottomRoadWidget({super.key});

  @override
  State<BottomRoadWidget> createState() => _BottomRoadWidgetState();
}

class _BottomRoadWidgetState extends State<BottomRoadWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      height: 220,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF334155), // Sleek Dark Asphalt Slate
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF475569), // Subtle outer road shoulder
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Center Vertical Dashed Divider Line
          Center(
            child: CustomPaint(
              size: const Size(2, double.infinity),
              painter: _VerticalDashedPainter(),
            ),
          ),

          Row(
            children: [
              /// LEFT LANE - EXIT (Arrows Moving Downwards)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      const Text(
                        'EXIT',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFFF87171), // High-contrast Coral Red Text
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _controller.value * 24),
                              child: child,
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFFEF4444), // Bright Vivid Red Arrow
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// RIGHT LANE - ENTRANCE (Arrows Moving Upwards)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -_controller.value * 24),
                              child: child,
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                child: Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  color: Color(0xFF10B981), // Bright Emerald Green Arrow
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'ENTRANCE',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF34D399), // High-contrast Emerald Green Text
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerticalDashedPainter extends CustomPainter {
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFACC15) // Vibrant Road Line Yellow
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashHeight = 8;
    double dashSpace = 8;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }
}