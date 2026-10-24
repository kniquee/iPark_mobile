import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import '../widgets/bottom_road_widget.dart';
import '../widgets/parking_slot.dart';
import '../widgets/managed_parking_slot.dart';
import '../widgets/road_widget.dart';

class ParkingScreen extends StatelessWidget {
  const ParkingScreen({super.key});

  static const List<String> sensorSlots = ['L1', 'M2', 'M4', 'M6', 'R3', 'R5'];

  bool isOccupied(Map<String, dynamic> data, String slotId) {
    return data[slotId]?['occupied'] == true;
  }

  int getAvailable(Map<String, dynamic> data, Map<String, dynamic> management) {
    int count = 0;
    for (var slot in sensorSlots) {
      if (!isOccupied(data, slot) &&
          slotMap(management[slot])['enabled'] != false) {
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
        toolbarHeight: 72,
        titleSpacing: 16,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Frame the artwork rather than the transparent margins of the asset.
            SizedBox(
              width: 52,
              height: 52,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  minWidth: 82,
                  maxWidth: 82,
                  minHeight: 82,
                  maxHeight: 82,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 82,
                    height: 82,
                    fit: BoxFit.contain,
                    color: const Color(0xFF38BDF8),
                    colorBlendMode: BlendMode.srcIn,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'SMART PARKING',
                maxLines: 2,
                style: TextStyle(
                  color: Color(0xFFB5C2D4),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF1F3348), height: 1.0),
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('slotManagement').onValue,
        builder: (context, managementSnapshot) {
          if (managementSnapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load slot availability. Check your connection or database access.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!managementSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final management = slotMap(managementSnapshot.data?.snapshot.value);
          return StreamBuilder<Map<String, dynamic>>(
            stream: firebaseService.getParkingData(),
            builder: (context, snapshot) {
              final data = snapshot.data ?? {};
              final available = getAvailable(data, management);

              return _ResponsiveParkingBody(
                child: Column(
                  children: [
                    // STATS CARD
                    _AvailableSummary(available: available),

                    const SizedBox(height: 16),

                    // LEGEND
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _SlotLegendItem(
                          label: 'Available',
                          color: Color(0xFF34D399),
                        ),
                        _SlotLegendItem(
                          label: 'Occupied',
                          color: Color(0xFFF87171),
                        ),
                        _SlotLegendItem(
                          label: 'Unavailable',
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // PARKING FLOOR CONTAINER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 16,
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// LEFT SIDE LAYOUT (Upper Section + Bottom Road Section)
                            SizedBox(
                              height: 740, // Matches total floor height
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// UPPER SECTION (LEFT, SHORT ROAD, MIDDLE WING)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            child: ManagedParkingSlot(
                                              slotId: 'L1',
                                              management: management,
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
                                                ManagedParkingSlot(
                                                  slotId: 'M1',
                                                  management: management,
                                                  occupied: false,
                                                  hasSensor: false,
                                                  position: SlotPosition.left,
                                                ),
                                                ManagedParkingSlot(
                                                  slotId: 'M2',
                                                  management: management,
                                                  occupied: isOccupied(
                                                    data,
                                                    'M2',
                                                  ),
                                                  hasSensor: true,
                                                  position: SlotPosition.left,
                                                ),
                                                ManagedParkingSlot(
                                                  slotId: 'M3',
                                                  management: management,
                                                  occupied: false,
                                                  hasSensor: false,
                                                  position: SlotPosition.left,
                                                ),
                                                ManagedParkingSlot(
                                                  slotId: 'M4',
                                                  management: management,
                                                  occupied: isOccupied(
                                                    data,
                                                    'M4',
                                                  ),
                                                  hasSensor: true,
                                                  position: SlotPosition.left,
                                                ),
                                                ManagedParkingSlot(
                                                  slotId: 'M5',
                                                  management: management,
                                                  occupied: false,
                                                  hasSensor: false,
                                                  position: SlotPosition.left,
                                                ),
                                                ManagedParkingSlot(
                                                  slotId: 'M6',
                                                  management: management,
                                                  occupied: isOccupied(
                                                    data,
                                                    'M6',
                                                  ),
                                                  hasSensor: true,
                                                  position: SlotPosition.left,
                                                ),
                                                ManagedParkingSlot(
                                                  slotId: 'M7',
                                                  management: management,
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
                                      ManagedParkingSlot(
                                        slotId: 'R1',
                                        management: management,
                                        occupied: false,
                                        hasSensor: false,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R2',
                                        management: management,
                                        occupied: false,
                                        hasSensor: false,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R3',
                                        management: management,
                                        occupied: isOccupied(data, 'R3'),
                                        hasSensor: true,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R4',
                                        management: management,
                                        occupied: false,
                                        hasSensor: false,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R5',
                                        management: management,
                                        occupied: isOccupied(data, 'R5'),
                                        hasSensor: true,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R6',
                                        management: management,
                                        occupied: false,
                                        hasSensor: false,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R7',
                                        management: management,
                                        occupied: false,
                                        hasSensor: false,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R8',
                                        management: management,
                                        occupied: false,
                                        hasSensor: false,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R9',
                                        management: management,
                                        occupied: false,
                                        hasSensor: false,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R10',
                                        management: management,
                                        occupied: false,
                                        hasSensor: false,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R11',
                                        management: management,
                                        occupied: false,
                                        hasSensor: false,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R12',
                                        management: management,
                                        occupied: false,
                                        hasSensor: false,
                                        position: SlotPosition.right,
                                      ),
                                      ManagedParkingSlot(
                                        slotId: 'R13',
                                        management: management,
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

class _SlotLegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _SlotLegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label == 'Unavailable')
          Text(
            '×',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          )
        else
          _LegendDot(color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFE1E4E7), fontSize: 13),
        ),
      ],
    );
  }
}

class _ResponsiveParkingBody extends StatelessWidget {
  final Widget child;
  const _ResponsiveParkingBody({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 360 ? 10 : 16,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailableSummary extends StatelessWidget {
  final int available;
  const _AvailableSummary({required this.available});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131D2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF22344A), width: 1.5),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'AVAILABLE SLOTS',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFFE1E4E7),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$available',
                style: const TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF34D399),
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
