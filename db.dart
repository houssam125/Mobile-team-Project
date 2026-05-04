import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  static final DB instance = DB._();
  static Database? _database;

  DB._();

  // ─────────────────────────────────────────────
  // 🔹 Get Database Instance (Singleton)
  // ─────────────────────────────────────────────
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  // ─────────────────────────────────────────────
  // 🔹 Initialize the Database
  // ─────────────────────────────────────────────
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ─────────────────────────────────────────────
  // 🔹 Enable Foreign Keys Support
  // ─────────────────────────────────────────────
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ─────────────────────────────────────────────
  // 🔹 Create All Tables
  // ─────────────────────────────────────────────
  Future _onCreate(Database db, int version) async {

    // ══════════════════════════════════════════
    // 👤 TABLE: users
    // Matches: Models/user_model.dart → class User
    // Fields: id, username, email, password, role
    // ══════════════════════════════════════════
    await db.execute('''
      CREATE TABLE users (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT    NOT NULL,
        email    TEXT    NOT NULL UNIQUE,
        password TEXT    NOT NULL,
        role     TEXT    NOT NULL
      )
    ''');

    // ══════════════════════════════════════════
    // 🩺 TABLE: doctors
    // Matches: Models/doctor_model.dart → class Doctor
    // Fields: id, name, type, specialty, district_commune,
    //         phone, email, address, working_hours,
    //         appointment_book, gps, social_network,
    //         schedule, is_available, last_checked_at
    // ══════════════════════════════════════════
    await db.execute('''
      CREATE TABLE doctors (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        name             TEXT NOT NULL,
        type             TEXT,
        specialty        TEXT,
        district_commune TEXT,
        phone            TEXT,
        email            TEXT,
        address          TEXT,
        working_hours    TEXT,
        appointment_book TEXT,
        gps              TEXT,
        social_network   TEXT,
        schedule         TEXT,
        is_available     INTEGER NOT NULL DEFAULT 0,
        last_checked_at  TEXT
      )
    ''');

    // ══════════════════════════════════════════
    // ⭐ TABLE: feedback
    // Matches: Models/feedback_model.dart → class Feedback
    // Fields: id, user_id (FK), doctor_id (FK), message, rating
    // Relations: user_id → users.id | doctor_id → doctors.id
    // ══════════════════════════════════════════
    await db.execute('''
      CREATE TABLE feedback (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id   INTEGER NOT NULL,
        doctor_id INTEGER NOT NULL,
        message   TEXT,
        rating    INTEGER CHECK (rating >= 1 AND rating <= 5),

        FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE CASCADE,
        FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
      )
    ''');

    // ══════════════════════════════════════════
    // 🔹 Indexes for faster queries on feedback
    // ══════════════════════════════════════════
    await db.execute(
      'CREATE INDEX idx_feedback_user   ON feedback(user_id)'
    );
    await db.execute(
      'CREATE INDEX idx_feedback_doctor ON feedback(doctor_id)'
    );
  }

  // ─────────────────────────────────────────────
  // 🔹 Migrate Database on Version Upgrade
  // ─────────────────────────────────────────────
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 → v2 : add availability columns to doctors
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE doctors ADD COLUMN schedule TEXT'
      );
      await db.execute(
        'ALTER TABLE doctors ADD COLUMN is_available INTEGER NOT NULL DEFAULT 0'
      );
      await db.execute(
        'ALTER TABLE doctors ADD COLUMN last_checked_at TEXT'
      );
    }
  }

  // ─────────────────────────────────────────────
  // 🔹 Close Database Connection
  // ─────────────────────────────────────────────
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}