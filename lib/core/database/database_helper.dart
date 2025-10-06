import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'study_connect.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        displayName TEXT NOT NULL,
        college TEXT,
        year TEXT,
        branch TEXT,
        avatarPath TEXT,
        createdAt TEXT NOT NULL,
        lastActive TEXT
      )
    ''');

    // Study Groups table
    await db.execute('''
      CREATE TABLE study_groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        creatorId INTEGER NOT NULL,
        memberCount INTEGER DEFAULT 1,
        tags TEXT,
        isPublic INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (creatorId) REFERENCES users (id)
      )
    ''');

    // User Group Memberships table
    await db.execute('''
      CREATE TABLE user_group_memberships(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        groupId INTEGER NOT NULL,
        role TEXT DEFAULT 'member',
        joinedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (groupId) REFERENCES study_groups (id),
        UNIQUE(userId, groupId)
      )
    ''');
  }

  // User operations
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUser(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
