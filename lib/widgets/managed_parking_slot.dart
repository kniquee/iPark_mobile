import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'parking_slot.dart';

Map<String, dynamic> slotMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

DateTime? slotDate(Object? value) {
  if (value == null) return null;
  final number = value is num ? value : num.tryParse('$value');
  if (number != null) {
    if (number <= 0 || !number.isFinite) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      (number < 100000000000 ? number * 1000 : number).round(),
    );
  }
  return DateTime.tryParse('$value');
}

class ManagedParkingSlot extends StatelessWidget {
  final String slotId;
  final bool occupied;
  final bool hasSensor;
  final SlotPosition position;
  final Map<String, dynamic> management;

  const ManagedParkingSlot({
    super.key,
    required this.slotId,
    required this.occupied,
    required this.hasSensor,
    required this.management,
    this.position = SlotPosition.left,
  });

  @override
  Widget build(BuildContext context) {
    final unavailable =
        !hasSensor || slotMap(management[slotId])['enabled'] == false;
    return Semantics(
      button: true,
      label:
          'Parking slot $slotId${unavailable ? ', unavailable' : ''}. View details',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          backgroundColor: const Color(0xFF131D2A),
          showDragHandle: true,
          builder: (_) => _SlotDetails(slotId: slotId, hasSensor: hasSensor),
        ),
        child: ParkingSlot(
          slotId: slotId,
          occupied: occupied,
          hasSensor: hasSensor,
          position: position,
          unavailable: unavailable,
        ),
      ),
    );
  }
}

class _SlotDetails extends StatelessWidget {
  final String slotId;
  final bool hasSensor;
  const _SlotDetails({required this.slotId, required this.hasSensor});

  String _format(BuildContext context, DateTime? date) {
    if (date == null) return 'Not recorded';
    final local = date.toLocal();
    final labels = MaterialLocalizations.of(context);
    return '${labels.formatMediumDate(local)} · ${labels.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabase.instance;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: StreamBuilder<DatabaseEvent>(
          stream: db.ref('slotManagement/$slotId').onValue,
          builder: (context, managementSnapshot) => StreamBuilder<DatabaseEvent>(
            stream: db.ref('parkingSlots/$slotId').onValue,
            builder: (context, liveSnapshot) => StreamBuilder<DatabaseEvent>(
              stream: db.ref('history/$slotId').onValue,
              builder: (context, historySnapshot) => StreamBuilder<DatabaseEvent>(
                stream: db.ref('parkingHistory/$slotId').onValue,
                builder: (context, legacySnapshot) {
                  final snapshots = [
                    managementSnapshot,
                    liveSnapshot,
                    historySnapshot,
                    legacySnapshot,
                  ];
                  final management = slotMap(
                    managementSnapshot.data?.snapshot.value,
                  );
                  final live = slotMap(liveSnapshot.data?.snapshot.value);
                  final unavailable =
                      !hasSensor || management['enabled'] == false;
                  final occupied =
                      live['occupied'] == true || live['status'] == 'Occupied';
                  final records =
                      <Map<String, dynamic>>[
                            ...slotMap(
                              historySnapshot.data?.snapshot.value,
                            ).values.map(slotMap),
                            ...slotMap(
                              legacySnapshot.data?.snapshot.value,
                            ).values.map(slotMap),
                            live,
                          ]
                          .where((record) => slotDate(record['timeIn']) != null)
                          .toList()
                        ..sort((a, b) {
                          final comparison = slotDate(
                            b['timeIn'],
                          )!.compareTo(slotDate(a['timeIn'])!);
                          if (comparison != 0) return comparison;
                          return (slotDate(
                                    b['timeOut'],
                                  )?.millisecondsSinceEpoch ??
                                  0)
                              .compareTo(
                                slotDate(
                                      a['timeOut'],
                                    )?.millisecondsSinceEpoch ??
                                    0,
                              );
                        });
                  final record = occupied && slotDate(live['timeIn']) != null
                      ? live
                      : records.firstOrNull;
                  final status = unavailable
                      ? 'Unavailable'
                      : occupied
                      ? 'Occupied'
                      : 'Available';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Parking slot $slotId',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close details',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (managementSnapshot.connectionState ==
                              ConnectionState.waiting ||
                          liveSnapshot.connectionState ==
                              ConnectionState.waiting)
                        const Text(
                          'Loading slot details…',
                          style: TextStyle(color: Colors.white70),
                        )
                      else ...[
                        _detail('Current status', status),
                        if (management['enabled'] == false &&
                            slotId != 'M1') ...[
                          _detail(
                            'Reason',
                            '${management['reason'] ?? 'Not provided'}',
                          ),
                          if ('${management['details'] ?? ''}'
                              .trim()
                              .isNotEmpty)
                            _detail('Details', '${management['details']}'),
                        ],
                      ],
                      const Divider(color: Color(0xFF334155), height: 28),
                      const Text(
                        'Latest parking record',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (snapshots.any((snapshot) => snapshot.hasError))
                        const Text(
                          'Some details could not be loaded. Check your connection or database access.',
                          style: TextStyle(color: Color(0xFFF3D08C)),
                        )
                      else if (historySnapshot.connectionState ==
                              ConnectionState.waiting ||
                          legacySnapshot.connectionState ==
                              ConnectionState.waiting)
                        const Text(
                          'Loading parking record…',
                          style: TextStyle(color: Colors.white70),
                        )
                      else if (record == null)
                        const Text(
                          'No parking records yet.',
                          style: TextStyle(color: Colors.white70),
                        )
                      else ...[
                        _detail(
                          'Time In',
                          _format(context, slotDate(record['timeIn'])),
                        ),
                        _detail(
                          'Time Out',
                          occupied && record == live
                              ? 'Still parked'
                              : _format(context, slotDate(record['timeOut'])),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final labelWidget = Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB5C2D4),
            fontSize: 13,
            height: 1.5,
          ),
        );
        final valueWidget = Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.5,
            fontWeight: label == 'Current status'
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        );
        if (constraints.maxWidth < 320 ||
            MediaQuery.textScalerOf(context).scale(14) > 19) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [labelWidget, const SizedBox(height: 4), valueWidget],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: labelWidget),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: valueWidget),
          ],
        );
      },
    ),
  );
}
