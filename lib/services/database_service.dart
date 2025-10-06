import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/models/user_model.dart';
import '../core/models/study_group_model.dart';
import '../core/models/message_model.dart';
import '../core/models/post_model.dart';
import '../core/database/schema.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'study_connect.db';
  static const int _databaseVersion = 2; // Updated version

  static DatabaseService? _instance;
  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create all tables
    await db.execute('''
      CREATE TABLE users (
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

    await db.execute('''
      CREATE TABLE study_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        isPublic INTEGER DEFAULT 1,
        createdBy INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        memberCount INTEGER DEFAULT 0,
        FOREIGN KEY (createdBy) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE group_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        role TEXT DEFAULT 'member',
        joinedAt TEXT NOT NULL,
        FOREIGN KEY (groupId) REFERENCES study_groups (id),
        FOREIGN KEY (userId) REFERENCES users (id),
        UNIQUE(groupId, userId)
      )
    ''');

    // Phase 2 tables
    await db.execute(DatabaseSchema.createMessagesTable);
    await db.execute(DatabaseSchema.createPostsTable);
    await db.execute(DatabaseSchema.createCommentsTable);
    await db.execute(DatabaseSchema.createLikesTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add Phase 2 tables
      await db.execute(DatabaseSchema.createMessagesTable);
      await db.execute(DatabaseSchema.createPostsTable);
      await db.execute(DatabaseSchema.createCommentsTable);
      await db.execute(DatabaseSchema.createLikesTable);
    }
  }

  // Message operations
  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getMessages(int groupId, {int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.*, u.displayName as sender_name, u.avatarPath as sender_avatar
      FROM messages m
      LEFT JOIN users u ON m.sender_id = u.id
      WHERE m.group_id = ? AND m.is_deleted = 0
      ORDER BY m.timestamp DESC
      LIMIT ?
    ''', [groupId, limit]);

    return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
  }

  Future<void> deleteMessage(int messageId) async {
    final db = await database;
    await db.update('messages',
        {'is_deleted': 1},
        where: 'id = ?',
        whereArgs: [messageId]
    );
  }

  // Post operations
  Future<int> insertPost(Post post) async {
    final db = await database;
    return await db.insert('posts', post.toMap());
  }

  Future<List<Post>> getPosts({int? groupId, int limit = 20}) async {
    final db = await database;
    String query = '''
      SELECT p.*, u.displayName as author_name, u.avatarPath as author_avatar,
             sg.name as group_name
      FROM posts p
      LEFT JOIN users u ON p.author_id = u.id
      LEFT JOIN study_groups sg ON p.group_id = sg.id
    ''';

    List<dynamic> args = [];
    if (groupId != null) {
      query += ' WHERE p.group_id = ?';
      args.add(groupId);
    }

    query += ' ORDER BY p.created_at DESC LIMIT ?';
    args.add(limit);

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    return List.generate(maps.length, (i) => Post.fromMap(maps[i]));
  }

  Future<void> likePost(int postId, int userId) async {
    final db = await database;

    // Check if already liked
    final existing = await db.query('likes',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, userId],
    );

    if (existing.isEmpty) {
      // Add like
      await db.insert('likes', {
        'post_id': postId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update likes count
      await db.rawUpdate('''
        UPDATE posts SET likes_count = likes_count + 1 WHERE id = ?
      ''', [postId]);
    } else {
      // Remove like
      await db.delete('likes',
        where: 'post_id = ? AND user_id = ?',
        whereArgs: [postId, userId],
      );

      // Update likes count
      await db.rawUpdate('''
        UPDATE posts SET likes_count = likes_count - 1 WHERE id = ?
      ''', [postId]);
    }
  }

  Future<bool> isPostLiked(int postId, int userId) async {
    final db = await database;
    final result = await db.query('likes',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, userId],
    );
    return result.isNotEmpty;
  }

  // Search functionality
  Future<List<Post>> searchPosts(String query, {int limit = 20}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, u.displayName as author_name, u.avatarPath as author_avatar,
             sg.name as group_name
      FROM posts p
      LEFT JOIN users u ON p.author_id = u.id
      LEFT JOIN study_groups sg ON p.group_id = sg.id
      WHERE p.title LIKE ? OR p.content LIKE ?
      ORDER BY p.created_at DESC
      LIMIT ?
    ''', ['%$query%', '%$query%', limit]);

    return List.generate(maps.length, (i) => Post.fromMap(maps[i]));
  }
  // ADD THESE METHODS TO YOUR EXISTING DatabaseService CLASS:

// Study Groups table
  Future<void> _createStudyGroupsTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS study_groups(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      icon_path TEXT,
      created_at TEXT NOT NULL,
      member_count INTEGER DEFAULT 0,
      is_public INTEGER DEFAULT 1,
      admin_id TEXT
    )
  ''');

    // Insert default groups matching your wireframes
    await db.insert('study_groups', {
      'name': 'AI Study Group',
      'description': 'Artificial Intelligence and Machine Learning discussions',
      'category': 'AI',
      'created_at': DateTime.now().toIso8601String(),
      'member_count': 5,
      'is_public': 1,
    });

    await db.insert('study_groups', {
      'name': 'Mobile Dev Group',
      'description': 'Mobile app development with Flutter and React Native',
      'category': 'Mobile Dev',
      'created_at': DateTime.now().toIso8601String(),
      'member_count': 8,
      'is_public': 1,
    });

    await db.insert('study_groups', {
      'name': 'OS Study Group',
      'description': 'Operating Systems concepts and implementation',
      'category': 'OS',
      'created_at': DateTime.now().toIso8601String(),
      'member_count': 12,
      'is_public': 1,
    });
  }

// Study group operations
  Future<List<StudyGroup>> getStudyGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('study_groups');
    return List.generate(maps.length, (i) => StudyGroup.fromMap(maps[i]));
  }

  Future<List<StudyGroup>> getUserGroups(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT sg.* FROM study_groups sg
    INNER JOIN group_members gm ON sg.id = gm.group_id
    WHERE gm.user_id = ?
  ''', [userId]);
    return List.generate(maps.length, (i) => StudyGroup.fromMap(maps[i]));
  }

  Future<int> insertStudyGroup(StudyGroup group) async {
    final db = await database;
    return await db.insert('study_groups', group.toMap());
  }

  Future<void> joinGroup(int groupId, String userId) async {
    final db = await database;
    await db.insert('group_members', {
      'group_id': groupId,
      'user_id': userId,
      'joined_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> leaveGroup(int groupId, String userId) async {
    final db = await database;
    await db.delete('group_members',
        where: 'group_id = ? AND user_id = ?',
        whereArgs: [groupId, userId]);
  }

  Future<List<StudyGroup>> searchStudyGroups(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_groups',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => StudyGroup.fromMap(maps[i]));
  }

}
