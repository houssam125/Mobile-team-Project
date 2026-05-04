import '../db.dart';
import '../Models/doctor_model.dart';

class DoctorRepository {
  final _db = DB.instance;

  // ✅ Add a new doctor
  Future<int> addDoctor(Doctor doctor) async {
    final db = await _db.database;
    return await db.insert('doctors', doctor.toMap()..remove('id'));
  }

  // ✅ Get all doctors
  Future<List<Doctor>> getAllDoctors() async {
    final db = await _db.database;
    final result = await db.query('doctors');
    return result.map((e) => Doctor.fromMap(e)).toList();
  }

  // ✅ Get doctor by ID
  Future<Doctor?> getDoctorById(int id) async {
    final db = await _db.database;
    final result = await db.query(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Doctor.fromMap(result.first);
  }

  // ✅ Search doctors by name or specialty
  Future<List<Doctor>> searchDoctors(String keyword) async {
    final db = await _db.database;
    final result = await db.query(
      'doctors',
      where: 'name LIKE ? OR specialty LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return result.map((e) => Doctor.fromMap(e)).toList();
  }

  // ✅ Filter doctors by specialty
  Future<List<Doctor>> getDoctorsBySpecialty(String specialty) async {
    final db = await _db.database;
    final result = await db.query(
      'doctors',
      where: 'specialty = ?',
      whereArgs: [specialty],
    );
    return result.map((e) => Doctor.fromMap(e)).toList();
  }

  // ✅ Filter doctors by district/commune
  Future<List<Doctor>> getDoctorsByDistrict(String district) async {
    final db = await _db.database;
    final result = await db.query(
      'doctors',
      where: 'district_commune = ?',
      whereArgs: [district],
    );
    return result.map((e) => Doctor.fromMap(e)).toList();
  }

  // ✅ Update doctor info
  Future<int> updateDoctor(Doctor doctor) async {
    final db = await _db.database;
    return await db.update(
      'doctors',
      doctor.toMap(),
      where: 'id = ?',
      whereArgs: [doctor.id],
    );
  }

  // ✅ Delete doctor
  Future<int> deleteDoctor(int id) async {
    final db = await _db.database;
    return await db.delete('doctors', where: 'id = ?', whereArgs: [id]);
  }

  // ✅ Update only the availability status (called by DoctorAvailabilityService)
  Future<int> updateAvailability(int doctorId, bool isAvailable) async {
    final db = await _db.database;
    return await db.update(
      'doctors',
      {
        'is_available': isAvailable ? 1 : 0,
        'last_checked_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [doctorId],
    );
  }

  // ✅ Get all doctors currently marked as available / working
  Future<List<Doctor>> getAvailableDoctors() async {
    final db = await _db.database;
    final result = await db.query(
      'doctors',
      where: 'is_available = ?',
      whereArgs: [1],
    );
    return result.map((e) => Doctor.fromMap(e)).toList();
  }
}
