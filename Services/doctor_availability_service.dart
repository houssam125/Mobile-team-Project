import 'dart:async';
import 'dart:convert';

import '../Repositories/doctor_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🕐 DoctorAvailabilityService
//
// Checks every hour whether each doctor is currently working based on their
// `schedule` field (JSON array stored in the doctors table).
//
// Schedule JSON format:
//   [
//     { "day": "Monday",    "from": "09:00", "to": "17:00" },
//     { "day": "Saturday",  "from": "08:00", "to": "14:00" }
//   ]
//
// Supported day names (case-insensitive):
//   Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
//
// Usage:
//   // Start the hourly check (e.g. in main() after runApp)
//   DoctorAvailabilityService.instance.start();
//
//   // Stop when no longer needed
//   DoctorAvailabilityService.instance.stop();
//
//   // Run a one-off check immediately (useful for testing / on app resume)
//   await DoctorAvailabilityService.instance.checkAll();
// ─────────────────────────────────────────────────────────────────────────────

class DoctorAvailabilityService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final DoctorAvailabilityService instance =
      DoctorAvailabilityService._();
  DoctorAvailabilityService._();

  // ── Dependencies ───────────────────────────────────────────────────────────
  final _repo = DoctorRepository();

  // ── State ──────────────────────────────────────────────────────────────────
  Timer? _timer;
  bool get isRunning => _timer != null && _timer!.isActive;

  // ─────────────────────────────────────────────
  // 🔹 Start Hourly Check
  // ─────────────────────────────────────────────
  /// Starts a periodic timer that fires once per hour.
  /// Calls [checkAll] immediately on start, then every hour afterward.
  void start() {
    if (isRunning) return; // already running — no duplicate timers

    // Run once right away so the UI reflects reality without waiting 1 hour
    checkAll();

    _timer = Timer.periodic(const Duration(hours: 1), (_) => checkAll());
  }

  // ─────────────────────────────────────────────
  // 🔹 Stop Hourly Check
  // ─────────────────────────────────────────────
  /// Cancels the periodic timer. Safe to call even when not running.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  // ─────────────────────────────────────────────
  // 🔹 Check All Doctors (one-off)
  // ─────────────────────────────────────────────
  /// Fetches all doctors, evaluates each one's schedule against [DateTime.now],
  /// and persists the updated [isAvailable] flag via the repository.
  Future<void> checkAll() async {
    final now = DateTime.now();
    final doctors = await _repo.getAllDoctors();

    for (final doctor in doctors) {
      if (doctor.id == null) continue;

      final available = _isAvailableNow(doctor.schedule, now);
      await _repo.updateAvailability(doctor.id!, available);
    }
  }

  // ─────────────────────────────────────────────
  // 🔹 Schedule Parser (private)
  // ─────────────────────────────────────────────
  /// Returns [true] if [scheduleJson] has an entry matching today's weekday
  /// and the current time falls inside the [from]–[to] window.
  ///
  /// Returns [false] when [scheduleJson] is null, empty, or malformed.
  bool _isAvailableNow(String? scheduleJson, DateTime now) {
    if (scheduleJson == null || scheduleJson.trim().isEmpty) return false;

    try {
      final List<dynamic> entries = jsonDecode(scheduleJson) as List<dynamic>;
      final todayName = _weekdayName(now.weekday); // e.g. "Monday"
      final nowMinutes = now.hour * 60 + now.minute;

      for (final entry in entries) {
        final map = entry as Map<String, dynamic>;
        final day = (map['day'] as String? ?? '').trim().toLowerCase();

        if (day != todayName.toLowerCase()) continue;

        final from = _parseTime(map['from'] as String?);
        final to   = _parseTime(map['to']   as String?);

        if (from == null || to == null) continue;

        // Handle overnight shifts (e.g. 22:00 – 06:00)
        final inWindow = to > from
            ? nowMinutes >= from && nowMinutes < to
            : nowMinutes >= from || nowMinutes < to;

        if (inWindow) return true;
      }
    } catch (_) {
      // Malformed JSON — treat as no schedule defined
      return false;
    }

    return false;
  }

  // ─────────────────────────────────────────────
  // 🔹 Helpers
  // ─────────────────────────────────────────────

  /// Converts [DateTime.weekday] (1 = Monday … 7 = Sunday) to a name string.
  String _weekdayName(int weekday) {
    const names = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return names[weekday] ?? '';
  }

  /// Parses a "HH:mm" string into total minutes since midnight.
  /// Returns [null] if the string is null or malformed.
  int? _parseTime(String? time) {
    if (time == null) return null;
    final parts = time.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }
}
