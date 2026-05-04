import '../db.dart';
import '../Models/feedback_model.dart';

class FeedbackRepository {
  final _db = DB.instance;

  // ✅ Add a feedback
  Future<int> addFeedback(Feedback feedback) async {
    final db = await _db.database;
    return await db.insert('feedback', feedback.toMap()..remove('id'));
  }

  // ✅ Get all feedback for a specific doctor (with JOIN to get user info)
  Future<List<Map<String, dynamic>>> getFeedbackForDoctor(int doctorId) async {
    final db = await _db.database;
    return await db.rawQuery('''
      SELECT 
        feedback.id,
        feedback.message,
        feedback.rating,
        users.username,
        users.email AS user_email,
        doctors.name AS doctor_name
      FROM feedback
      INNER JOIN users ON feedback.user_id = users.id
      INNER JOIN doctors ON feedback.doctor_id = doctors.id
      WHERE feedback.doctor_id = ?
      ORDER BY feedback.id DESC
    ''', [doctorId]);
  }

  // ✅ Get all feedback by a specific user
  Future<List<Feedback>> getFeedbackByUser(int userId) async {
    final db = await _db.database;
    final result = await db.query(
      'feedback',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((e) => Feedback.fromMap(e)).toList();
  }

  // ✅ Get average rating for a doctor
  Future<double> getAverageRating(int doctorId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT AVG(rating) as avg_rating FROM feedback WHERE doctor_id = ?',
      [doctorId],
    );
    if (result.isEmpty || result.first['avg_rating'] == null) return 0.0;
    return (result.first['avg_rating'] as num).toDouble();
  }

  // ✅ Delete a feedback
  Future<int> deleteFeedback(int id) async {
    final db = await _db.database;
    return await db.delete('feedback', where: 'id = ?', whereArgs: [id]);
  }
}
