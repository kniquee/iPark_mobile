import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _db =
      FirebaseDatabase.instance.ref('parkingSlots');

  Stream<Map<String, dynamic>> getParkingData() {
    return _db.onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) {
        return {};
      }

      return Map<String, dynamic>.from(data as Map);
    });
  }
}