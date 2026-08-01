import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import '../widgets/bottom_road_widget.dart';
import '../widgets/parking_slot.dart';
import '../widgets/road_widget.dart';

class ParkingScreen extends StatelessWidget {
  const ParkingScreen({super.key});

  static const List<String> sensorSlots = ['L1', 'M2', 'M4', 'M6', 'R3', 'R5'];

  bool isOccupied(Map<String, dynamic> data, String slotId) {
    return data[slotId]?['occupied'] == true;
  }

  int getAvailable(Map<String, dynamic> data) {
    int count = 0;
    for (var slot in sensorSlots) {
      if (!isOccupied(data, slot)) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1520),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFF0B1520),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Enlarged Logo (with light blue color tint)
            Image.asset(
              'assets/images/logo.png',
              height: 78, // Increased from 32 to 48 for better visibility
              fit: BoxFit.contain,

              // Transforms dark logo parts into glowing light blue
              color: const Color(0xFF38BDF8),
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(width: 1),
            const Text(
              'SMART PARKING',
              style: TextStyle(
                color: Color(0x66E2EAF4),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF1F3348), height: 1.0),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: firebaseService.getParkingData(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? {};
          final available = getAvailable(data);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // STATS CARD
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D2A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF22344A),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'AVAILABLE SPOTS',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Color(0xFF94A3B8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  Text(
                                    '$available',
                                    style: const TextStyle(
                                      fontSize: 54,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF34D399),
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LEGEND
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(color: Color(0xFF34D399)),
                    SizedBox(width: 8),
                    Text(
                      'Available',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFFE1E4E7),
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(width: 20),
                    _LegendDot(color: Color(0xFFF87171)),
                    SizedBox(width: 8),
                    Text(
                      'Occupied',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFFE1E4E7),
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // PARKING FLOOR CONTAINER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF182432), // Dark slate gray floor
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2B3C50),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// LEFT SIDE LAYOUT (Upper Section + Bottom Road Section)
                        SizedBox(
                          height: 740, // Matches total floor height
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// UPPER SECTION (LEFT, SHORT ROAD, MIDDLE WING)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// LEFT WING
                                  Column(
                                    children: [
                                      const _WingLabel(label: "LEFT"),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.only(
                                          top: 6,
                                          left: 6,
                                          bottom: 6,
                                          right: 2,
                                        ),
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12),
                                          ),
                                          border: Border(
                                            top: BorderSide(
                                              color: Color(0xFF2B3C50),
                                              width: 2.0,
                                            ),
                                            bottom: BorderSide(
                                              color: Color(0xFF2B3C50),
                                              width: 2.0,
                                            ),
                                            left: BorderSide(
                                              color: Color(0xFF2B3C50),
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        child: ParkingSlot(
                                          slotId: 'L1',
                                          occupied: isOccupied(data, 'L1'),
                                          hasSensor: true,
                                          position: SlotPosition.left,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 8),

                                  /// UPPER SHORT ROAD (Adjust height independently!)
                                  const RoadWidget(
                                    label: '',
                                    height:
                                        385, // ADJUST upper road height freely here
                                    topMargin: 40.0,
                                  ),

                                  const SizedBox(width: 8),

                                  /// MIDDLE WING (M1 to M7)
                                  Column(
                                    children: [
                                      const _WingLabel(label: "MIDDLE"),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.only(
                                          top: 6,
                                          left: 6,
                                          bottom: 6,
                                          right: 2,
                                        ),
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12),
                                          ),
                                          border: Border(
                                            top: BorderSide(
                                              color: Color(0xFF2B3C50),
                                              width: 2.0,
                                            ),
                                            bottom: BorderSide(
                                              color: Color(0xFF2B3C50),
                                              width: 2.0,
                                            ),
                                            left: BorderSide(
                                              color: Color(0xFF2B3C50),
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            const ParkingSlot(
                                              slotId: 'M1',
                                              occupied: false,
                                              hasSensor: false,
                                              position: SlotPosition.left,
                                            ),
                                            ParkingSlot(
                                              slotId: 'M2',
                                              occupied: isOccupied(data, 'M2'),
                                              hasSensor: true,
                                              position: SlotPosition.left,
                                            ),
                                            const ParkingSlot(
                                              slotId: 'M3',
                                              occupied: false,
                                              hasSensor: false,
                                              position: SlotPosition.left,
                                            ),
                                            ParkingSlot(
                                              slotId: 'M4',
                                              occupied: isOccupied(data, 'M4'),
                                              hasSensor: true,
                                              position: SlotPosition.left,
                                            ),
                                            const ParkingSlot(
                                              slotId: 'M5',
                                              occupied: false,
                                              hasSensor: false,
                                              position: SlotPosition.left,
                                            ),
                                            ParkingSlot(
                                              slotId: 'M6',
                                              occupied: isOccupied(data, 'M6'),
                                              hasSensor: true,
                                              position: SlotPosition.left,
                                            ),
                                            const ParkingSlot(
                                              slotId: 'M7',
                                              occupied: false,
                                              hasSensor: false,
                                              position: SlotPosition.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              /// ENTRANCE / EXIT BLOCK (Anchored to the bottom independently)
                              const BottomRoadWidget(),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// LONG MAIN ROAD (Adjust main right road height freely here)
                        const RoadWidget(
                          label: '',
                          height: 700, // Adjust long main road height here
                          topMargin: 40.0,
                        ),

                        const SizedBox(width: 8),

                        /// RIGHT WING (R1 to R13)
                        Column(
                          children: [
                            const _WingLabel(label: "RIGHT"),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.only(
                                top: 6,
                                right: 6,
                                bottom: 6,
                                left: 2,
                              ),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                border: Border(
                                  top: BorderSide(
                                    color: Color(0xFF2B3C50),
                                    width: 2.0,
                                  ),
                                  bottom: BorderSide(
                                    color: Color(0xFF2B3C50),
                                    width: 2.0,
                                  ),
                                  right: BorderSide(
                                    color: Color(0xFF2B3C50),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const ParkingSlot(
                                    slotId: 'R1',
                                    occupied: false,
                                    hasSensor: false,
                                    position: SlotPosition.right,
                                  ),
                                  const ParkingSlot(
                                    slotId: 'R2',
                                    occupied: false,
                                    hasSensor: false,
                                    position: SlotPosition.right,
                                  ),
                                  ParkingSlot(
                                    slotId: 'R3',
                                    occupied: isOccupied(data, 'R3'),
                                    hasSensor: true,
                                    position: SlotPosition.right,
                                  ),
                                  const ParkingSlot(
                                    slotId: 'R4',
                                    occupied: false,
                                    hasSensor: false,
                                    position: SlotPosition.right,
                                  ),
                                  ParkingSlot(
                                    slotId: 'R5',
                                    occupied: isOccupied(data, 'R5'),
                                    hasSensor: true,
                                    position: SlotPosition.right,
                                  ),
                                  const ParkingSlot(
                                    slotId: 'R6',
                                    occupied: false,
                                    hasSensor: false,
                                    position: SlotPosition.right,
                                  ),
                                  const ParkingSlot(
                                    slotId: 'R7',
                                    occupied: false,
                                    hasSensor: false,
                                    position: SlotPosition.right,
                                  ),
                                  const ParkingSlot(
                                    slotId: 'R8',
                                    occupied: false,
                                    hasSensor: false,
                                    position: SlotPosition.right,
                                  ),
                                  const ParkingSlot(
                                    slotId: 'R9',
                                    occupied: false,
                                    hasSensor: false,
                                    position: SlotPosition.right,
                                  ),
                                  const ParkingSlot(
                                    slotId: 'R10',
                                    occupied: false,
                                    hasSensor: false,
                                    position: SlotPosition.right,
                                  ),
                                  const ParkingSlot(
                                    slotId: 'R11',
                                    occupied: false,
                                    hasSensor: false,
                                    position: SlotPosition.right,
                                  ),
                                  const ParkingSlot(
                                    slotId: 'R12',
                                    occupied: false,
                                    hasSensor: false,
                                    position: SlotPosition.right,
                                  ),
                                  const ParkingSlot(
                                    slotId: 'R13',
                                    occupied: false,
                                    hasSensor: false,
                                    position: SlotPosition.right,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WingLabel extends StatelessWidget {
  final String label;
  const _WingLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2B),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF2B3C50)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'monospace',
          color: Color(0xFFB1BDC7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
