import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../core/models/user_model.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  static DatabaseService get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'study_connect.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        displayName TEXT NOT NULL,
        college TEXT,
        year TEXT,
        department TEXT,
        avatarPath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Study Groups table
    await db.execute('''
      CREATE TABLE study_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        isPrivate INTEGER NOT NULL DEFAULT 0,
        createdBy TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (createdBy) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Group Memberships table
    await db.execute('''
      CREATE TABLE group_memberships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        groupId INTEGER NOT NULL,
        role TEXT NOT NULL DEFAULT 'member',
        joinedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (groupId) REFERENCES study_groups (id) ON DELETE CASCADE,
        UNIQUE(userId, groupId)
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        senderId TEXT NOT NULL,
        senderName TEXT NOT NULL,
        groupId INTEGER NOT NULL,
        content TEXT NOT NULL,
        messageType TEXT NOT NULL DEFAULT 'text',
        attachment TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (senderId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (groupId) REFERENCES study_groups (id) ON DELETE CASCADE
      )
    ''');

    // Posts table
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        authorId TEXT NOT NULL,
        groupId INTEGER,
        title TEXT,
        content TEXT NOT NULL,
        attachments TEXT,
        likes INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (authorId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (groupId) REFERENCES study_groups (id) ON DELETE CASCADE
      )
    ''');

    // Post Likes table
    await db.execute('''
      CREATE TABLE post_likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        likedAt TEXT NOT NULL,
        FOREIGN KEY (postId) REFERENCES posts (id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(postId, userId)
      )
    ''');

    // Comments table
    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER NOT NULL,
        authorId TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (postId) REFERENCES posts (id) ON DELETE CASCADE,
        FOREIGN KEY (authorId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Insert default study groups
    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for Phase 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS study_groups (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          category TEXT NOT NULL,
          isPrivate INTEGER NOT NULL DEFAULT 0,
          createdBy TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (createdBy) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS group_memberships (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          groupId INTEGER NOT NULL,
          role TEXT NOT NULL DEFAULT 'member',
          joinedAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (groupId) REFERENCES study_groups (id) ON DELETE CASCADE,
          UNIQUE(userId, groupId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          senderId TEXT NOT NULL,
          senderName TEXT NOT NULL,
          groupId INTEGER NOT NULL,
          content TEXT NOT NULL,
          messageType TEXT NOT NULL DEFAULT 'text',
          attachment TEXT,
          timestamp TEXT NOT NULL,
          FOREIGN KEY (senderId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (groupId) REFERENCES study_groups (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS posts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          authorId TEXT NOT NULL,
          groupId INTEGER,
          title TEXT,
          content TEXT NOT NULL,
          attachments TEXT,
          likes INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (authorId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (groupId) REFERENCES study_groups (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS post_likes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          postId INTEGER NOT NULL,
          userId TEXT NOT NULL,
          likedAt TEXT NOT NULL,
          FOREIGN KEY (postId) REFERENCES posts (id) ON DELETE CASCADE,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          UNIQUE(postId, userId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS comments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          postId INTEGER NOT NULL,
          authorId TEXT NOT NULL,
          content TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (postId) REFERENCES posts (id) ON DELETE CASCADE,
          FOREIGN KEY (authorId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      await _insertDefaultData(db);
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Insert default study groups
    await db.insert('study_groups', {
      'name': 'AI & Machine Learning',
      'description': 'Discuss artificial intelligence, machine learning algorithms, and data science topics',
      'category': 'AI',
      'isPrivate': 0,
      'createdBy': 'system',
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('study_groups', {
      'name': 'Mobile Development',
      'description': 'Flutter, React Native, iOS, Android development discussions',
      'category': 'Development',
      'isPrivate': 0,
      'createdBy': 'system',
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('study_groups', {
      'name': 'Operating Systems',
      'description': 'Learn about OS concepts, Linux, Windows, and system programming',
      'category': 'OS',
      'isPrivate': 0,
      'createdBy': 'system',
      'createdAt': now,
      'updatedAt': now,
    });
  }

  // User Methods
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
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

  Future<UserModel?> getUserById(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
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

  // Study Group Methods
  Future<List<Map<String, dynamic>>> getStudyGroups() async {
    final db = await database;
    return await db.query('study_groups', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getUserGroups(String userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT sg.* FROM study_groups sg
      INNER JOIN group_memberships gm ON sg.id = gm.groupId
      WHERE gm.userId = ?
      ORDER BY sg.name ASC
    ''', [userId]);
  }

  Future<int> insertStudyGroup(Map<String, dynamic> group) async {
    final db = await database;
    return await db.insert('study_groups', group);
  }

  Future<void> joinGroup(int groupId, String userId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.insert('group_memberships', {
      'userId': userId,
      'groupId': groupId,
      'role': 'member',
      'joinedAt': now,
    });
  }

  Future<void> leaveGroup(int groupId, String userId) async {
    final db = await database;
    await db.delete(
      'group_memberships',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, userId],
    );
  }

  Future<List<Map<String, dynamic>>> searchStudyGroups(String query) async {
    final db = await database;
    return await db.query(
      'study_groups',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
  }

  Future<bool> isUserInGroup(int groupId, String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'group_memberships',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, userId],
    );
    return result.isNotEmpty;
  }

  // Message Methods
  Future<void> insertMessage(Map<String, dynamic> message) async {
    final db = await database;
    await db.insert('messages', message);
  }

  Future<List<Map<String, dynamic>>> getMessagesForGroup(int groupId, {int limit = 50}) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  Future<Map<String, dynamic>?> getLastMessage(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Post Methods
  Future<int> insertPost(Map<String, dynamic> post) async {
    final db = await database;
    return await db.insert('posts', post);
  }

  Future<List<Map<String, dynamic>>> getAllPosts({int limit = 20}) async {
    final db = await database;
    return await db.query(
      'posts',
      orderBy: 'createdAt DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getGroupPosts(int groupId, {int limit = 20}) async {
    final db = await database;
    return await db.query(
      'posts',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'createdAt DESC',
      limit: limit,
    );
  }

  Future<void> toggleLike(int postId, String userId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // Check if user already liked the post
    final List<Map<String, dynamic>> existingLike = await db.query(
      'post_likes',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );

    if (existingLike.isNotEmpty) {
      // Remove like
      await db.delete(
        'post_likes',
        where: 'postId = ? AND userId = ?',
        whereArgs: [postId, userId],
      );

      // Decrease like count
      await db.rawUpdate(
        'UPDATE posts SET likes = likes - 1 WHERE id = ?',
        [postId],
      );
    } else {
      // Add like
      await db.insert('post_likes', {
        'postId': postId,
        'userId': userId,
        'likedAt': now,
      });

      // Increase like count
      await db.rawUpdate(
        'UPDATE posts SET likes = likes + 1 WHERE id = ?',
        [postId],
      );
    }
  }

  Future<bool> isPostLiked(int postId, String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'post_likes',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );
    return result.isNotEmpty;
  }

  // Comments Methods
  Future<int> insertComment(Map<String, dynamic> comment) async {
    final db = await database;
    return await db.insert('comments', comment);
  }

  Future<List<Map<String, dynamic>>> getCommentsForPost(int postId) async {
    final db = await database;
    return await db.query(
      'comments',
      where: 'postId = ?',
      whereArgs: [postId],
      orderBy: 'createdAt ASC',
    );
  }

  // Utility Methods
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('users');
    await db.delete('study_groups');
    await db.delete('group_memberships');
    await db.delete('messages');
    await db.delete('posts');
    await db.delete('post_likes');
    await db.delete('comments');
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}