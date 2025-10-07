import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../core/models/user_model.dart';
import '../core/models/study_group_model.dart';
import '../core/models/message_model.dart';
import '../core/models/post_model.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._internal();

  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'study_connect.db');

      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createStudyGroupTables(db);
      await _createMessageTables(db);
      await _createPostTables(db);
      await _insertDefaultData(db);
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        displayName TEXT NOT NULL,
        college TEXT NOT NULL,
        department TEXT NOT NULL,
        year INTEGER NOT NULL,
        avatarPath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await _createStudyGroupTables(db);
    await _createMessageTables(db);
    await _createPostTables(db);
  }

  Future<void> _createStudyGroupTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS study_groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        isPublic INTEGER NOT NULL DEFAULT 1,
        createdBy TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS group_memberships(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        groupId INTEGER NOT NULL,
        role TEXT NOT NULL DEFAULT 'member',
        joinedAt TEXT NOT NULL,
        FOREIGN KEY (groupId) REFERENCES study_groups (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createMessageTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER NOT NULL,
        senderId TEXT NOT NULL,
        senderName TEXT NOT NULL,
        content TEXT NOT NULL,
        messageType TEXT NOT NULL DEFAULT 'text',
        attachmentUrl TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (groupId) REFERENCES study_groups (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createPostTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        authorId TEXT NOT NULL,
        authorName TEXT NOT NULL,
        groupId INTEGER,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        attachmentUrl TEXT,
        likesCount INTEGER NOT NULL DEFAULT 0,
        commentsCount INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (groupId) REFERENCES study_groups (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS post_likes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (postId) REFERENCES posts (id) ON DELETE CASCADE,
        UNIQUE(postId, userId)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS comments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (postId) REFERENCES posts (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _insertDefaultData(Database db) async {
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM study_groups');
    final groupCount = count.first['count'] as int;

    if (groupCount == 0) {
      await db.insert('study_groups', {
        'name': 'AI & Machine Learning',
        'description': 'Learn and discuss artificial intelligence, machine learning algorithms, neural networks, and deep learning concepts.',
        'category': 'AI',
        'isPublic': 1,
        'createdBy': 'system',
        'createdAt': DateTime.now().toIso8601String(),
      });

      await db.insert('study_groups', {
        'name': 'Mobile Development',
        'description': 'Flutter, React Native, Android, iOS development discussions and project collaborations.',
        'category': 'Mobile',
        'isPublic': 1,
        'createdBy': 'system',
        'createdAt': DateTime.now().toIso8601String(),
      });

      await db.insert('study_groups', {
        'name': 'Operating Systems',
        'description': 'Study operating system concepts, process management, memory management, and system programming.',
        'category': 'OS',
        'isPublic': 1,
        'createdBy': 'system',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }

  // User operations
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
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
    final maps = await db.query(
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

  // Study Group operations
  Future<List<StudyGroup>> getStudyGroups() async {
    final db = await database;
    final maps = await db.query('study_groups', orderBy: 'createdAt DESC');

    List<StudyGroup> groups = [];
    for (int i = 0; i < maps.length; i++) {
      groups.add(StudyGroup.fromMap(maps[i]));
    }
    return groups;
  }

  Future<List<StudyGroup>> getUserGroups(String userId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT sg.* FROM study_groups sg
      JOIN group_memberships gm ON sg.id = gm.groupId
      WHERE gm.userId = ?
      ORDER BY sg.createdAt DESC
    ''', [userId]);

    List<StudyGroup> groups = [];
    for (int i = 0; i < maps.length; i++) {
      groups.add(StudyGroup.fromMap(maps[i]));
    }
    return groups;
  }

  Future<int> insertStudyGroup(StudyGroup group) async {
    final db = await database;
    return await db.insert('study_groups', group.toMap());
  }

  Future<void> joinGroup(int groupId, String userId) async {
    final db = await database;
    await db.insert('group_memberships', {
      'userId': userId,
      'groupId': groupId,
      'role': 'member',
      'joinedAt': DateTime.now().toIso8601String(),
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

  Future<bool> isUserInGroup(int groupId, String userId) async {
    final db = await database;
    final maps = await db.query(
      'group_memberships',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, userId],
    );
    return maps.isNotEmpty;
  }

  Future<List<StudyGroup>> searchStudyGroups(String query) async {
    final db = await database;
    final maps = await db.query(
      'study_groups',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    List<StudyGroup> groups = [];
    for (int i = 0; i < maps.length; i++) {
      groups.add(StudyGroup.fromMap(maps[i]));
    }
    return groups;
  }

  // Message operations
  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getMessagesForGroup(int groupId, {int limit = 50}) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    List<Message> messages = [];
    for (int i = 0; i < maps.length; i++) {
      messages.add(Message.fromMap(maps[i]));
    }
    return messages.reversed.toList();
  }

  Future<Message?> getLastMessage(int groupId) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Message.fromMap(maps.first);
    }
    return null;
  }

  // Post operations
  Future<int> insertPost(Post post) async {
    final db = await database;
    return await db.insert('posts', post.toMap());
  }

  Future<List<Post>> getAllPosts({int limit = 20}) async {
    final db = await database;
    final maps = await db.query(
      'posts',
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    List<Post> posts = [];
    for (int i = 0; i < maps.length; i++) {
      posts.add(Post.fromMap(maps[i]));
    }
    return posts;
  }

  Future<List<Post>> getGroupPosts(int groupId, {int limit = 20}) async {
    final db = await database;
    final maps = await db.query(
      'posts',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    List<Post> posts = [];
    for (int i = 0; i < maps.length; i++) {
      posts.add(Post.fromMap(maps[i]));
    }
    return posts;
  }

  Future<void> toggleLike(int postId, String userId) async {
    final db = await database;

    final existingLike = await db.query(
      'post_likes',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );

    if (existingLike.isNotEmpty) {
      // Unlike
      await db.delete(
        'post_likes',
        where: 'postId = ? AND userId = ?',
        whereArgs: [postId, userId],
      );
      await db.execute(
        'UPDATE posts SET likesCount = likesCount - 1 WHERE id = ?',
        [postId],
      );
    } else {
      // Like
      await db.insert('post_likes', {
        'postId': postId,
        'userId': userId,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await db.execute(
        'UPDATE posts SET likesCount = likesCount + 1 WHERE id = ?',
        [postId],
      );
    }
  }

  Future<bool> isPostLiked(int postId, String userId) async {
    final db = await database;
    final maps = await db.query(
      'post_likes',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );
    return maps.isNotEmpty;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}