import 'package:cloud_firestore/cloud_firestore.dart';

class SleepLogEntry {
  final String id;
  final String userId;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int durationMinutes;
  final String quality; // poor, fair, good, excellent
  final String notes;
  final String date; // yyyy-MM-dd

  SleepLogEntry({
    required this.id,
    required this.userId,
    required this.bedTime,
    required this.wakeTime,
    required this.durationMinutes,
    required this.quality,
    this.notes = '',
    required this.date,
  });

  /// Computed duration in hours and minutes string (e.g. "7h 30m")
  String get durationFormatted {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return '${hours}h ${mins}m';
  }

  factory SleepLogEntry.fromMap(Map<String, dynamic> map, {String? docId}) {
    return SleepLogEntry(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      bedTime: (map['bedTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wakeTime: (map['wakeTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      quality: map['quality'] ?? 'fair',
      notes: map['notes'] ?? '',
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bedTime': bedTime,
      'wakeTime': wakeTime,
      'durationMinutes': durationMinutes,
      'quality': quality,
      'notes': notes,
      'date': date,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'bedTime': Timestamp.fromDate(bedTime),
      'wakeTime': Timestamp.fromDate(wakeTime),
      'durationMinutes': durationMinutes,
      'quality': quality,
      'notes': notes,
      'date': date,
    };
  }
}
