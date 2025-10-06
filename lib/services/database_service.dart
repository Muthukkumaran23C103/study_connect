import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'studyconnect.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        username TEXT NOT NULL,
        profilePicUrl TEXT,
        registeredEmail TEXT,
        firstName TEXT,
        lastName TEXT,
        bio TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isActive INTEGER DEFAULT 1,
        isVerified INTEGER DEFAULT 0,
        interests TEXT,
        settings TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE study_groups(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        memberCount INTEGER DEFAULT 0,
        maxMembers INTEGER DEFAULT 50,
        createdBy TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        tags TEXT,
        imageUrl TEXT,
        meetingLink TEXT,
        nextMeetingDate TEXT,
        isActive INTEGER DEFAULT 1,
        isPublic INTEGER DEFAULT 1,
        isPremium INTEGER DEFAULT 0,
        rating REAL,
        ratingCount INTEGER DEFAULT 0,
        settings TEXT,
        admins TEXT,
        members TEXT,
        FOREIGN KEY (createdBy) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_groups(
        userId TEXT,
        groupId TEXT,
        role TEXT DEFAULT 'member',
        joinedAt TEXT NOT NULL,
        PRIMARY KEY (userId, groupId),
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (groupId) REFERENCES study_groups (id)
      )
    ''');
  }
}
