import '../db.dart';
import '../Models/user_model.dart';

class UserRepository {
  final _db = DB.instance;

  // ✅ Register a new user
  Future<int> register(User user) async {
    final db = await _db.database;
    return await db.insert('users', user.toMap()..remove('id'));
  }

  // ✅ Login (check email + password)
  Future<User?> login(String email, String password) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // ✅ Get user by ID
  Future<User?> getUserById(int id) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // ✅ Get all users
  Future<List<User>> getAllUsers() async {
    final db = await _db.database;
    final result = await db.query('users');
    return result.map((e) => User.fromMap(e)).toList();
  }

  // ✅ Update user info
  Future<int> updateUser(User user) async {
    final db = await _db.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ✅ Delete user
  Future<int> deleteUser(int id) async {
    final db = await _db.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
