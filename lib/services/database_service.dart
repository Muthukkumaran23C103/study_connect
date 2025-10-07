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
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  static DatabaseService get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'study_connect.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        displayName TEXT NOT NULL,
        password TEXT NOT NULL,
        college TEXT,
        year TEXT,
        department TEXT,
        avatarPath TEXT,
        createdAt TEXT,
        updatedAt TEXT
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
        createdAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY (createdBy) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE group_memberships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        groupId INTEGER NOT NULL,
        role TEXT DEFAULT 'member',
        joinedAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (groupId) REFERENCES study_groups (id),
        UNIQUE(userId, groupId)
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        senderId TEXT NOT NULL,
        senderName TEXT NOT NULL,
        groupId INTEGER NOT NULL,
        content TEXT NOT NULL,
        messageType TEXT DEFAULT 'text',
        attachmentUrl TEXT,
        senderAvatar TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (groupId) REFERENCES study_groups (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        authorId TEXT NOT NULL,
        groupId INTEGER,
        title TEXT NOT NULL,
        content TEXT,
        attachmentUrls TEXT,
        likesCount INTEGER DEFAULT 0,
        commentsCount INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (groupId) REFERENCES study_groups (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE post_likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        createdAt TEXT,
        FOREIGN KEY (postId) REFERENCES posts (id),
        UNIQUE(postId, userId)
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER NOT NULL,
        authorId TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (postId) REFERENCES posts (id)
      )
    ''');

    await _createDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS study_groups (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          category TEXT NOT NULL,
          isPublic INTEGER DEFAULT 1,
          createdBy INTEGER NOT NULL,
          createdAt TEXT,
          updatedAt TEXT,
          FOREIGN KEY (createdBy) REFERENCES users (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS group_memberships (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          groupId INTEGER NOT NULL,
          role TEXT DEFAULT 'member',
          joinedAt TEXT,
          FOREIGN KEY (userId) REFERENCES users (id),
          FOREIGN KEY (groupId) REFERENCES study_groups (id),
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
          messageType TEXT DEFAULT 'text',
          attachmentUrl TEXT,
          senderAvatar TEXT,
          timestamp TEXT NOT NULL,
          FOREIGN KEY (groupId) REFERENCES study_groups (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS posts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          authorId TEXT NOT NULL,
          groupId INTEGER,
          title TEXT NOT NULL,
          content TEXT,
          attachmentUrls TEXT,
          likesCount INTEGER DEFAULT 0,
          commentsCount INTEGER DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT,
          FOREIGN KEY (groupId) REFERENCES study_groups (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS post_likes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          postId INTEGER NOT NULL,
          userId TEXT NOT NULL,
          createdAt TEXT,
          FOREIGN KEY (postId) REFERENCES posts (id),
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
          FOREIGN KEY (postId) REFERENCES posts (id)
        )
      ''');

      await _createDefaultData(db);
    }
  }

  Future<void> _createDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('study_groups', {
      'name': 'AI Study Group',
      'description': 'Learn about Artificial Intelligence, Machine Learning, and Neural Networks',
      'category': 'AI',
      'isPublic': 1,
      'createdBy': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('study_groups', {
      'name': 'Mobile Development',
      'description': 'Flutter, React Native, iOS and Android development',
      'category': 'Mobile Development',
      'isPublic': 1,
      'createdBy': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('study_groups', {
      'name': 'Operating Systems',
      'description': 'Linux, Windows, macOS system administration and development',
      'category': 'Operating Systems',
      'isPublic': 1,
      'createdBy': 1,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  // User Operations
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

  // Study Group Operations
  Future<List<StudyGroup>> getStudyGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('study_groups');

    return List.generate(maps.length, (i) {
      return StudyGroup.fromMap(maps[i]);
    });
  }

  Future<List<StudyGroup>> getUserGroups(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT sg.* FROM study_groups sg
      INNER JOIN group_memberships gm ON sg.id = gm.groupId
      WHERE gm.userId = ?
    ''', [userId]);

    return List.generate(maps.length, (i) {
      return StudyGroup.fromMap(maps[i]);
    });
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
    final List<Map<String, dynamic>> maps = await db.query(
      'group_memberships',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, userId],
    );
    return maps.isNotEmpty;
  }

  Future<List<StudyGroup>> searchStudyGroups(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_groups',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return StudyGroup.fromMap(maps[i]);
    });
  }

  // Message Operations
  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getMessagesForGroup(int groupId, {int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Message.fromMap(maps[i]);
    }).reversed.toList();
  }

  Future<Message?> getLastMessage(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
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

  // Post Operations
  Future<int> insertPost(Post post) async {
    final db = await database;
    return await db.insert('posts', post.toMap());
  }

  Future<List<Post>> getAllPosts({int limit = 20}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Post.fromMap(maps[i]);
    });
  }

  Future<List<Post>> getGroupPosts(int groupId, {int limit = 20}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Post.fromMap(maps[i]);
    });
  }

  Future<void> togglePostLike(int postId, String userId) async {
    final db = await database;

    final List<Map<String, dynamic>> existingLike = await db.query(
      'post_likes',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );

    if (existingLike.isNotEmpty) {
      await db.delete(
        'post_likes',
        where: 'postId = ? AND userId = ?',
        whereArgs: [postId, userId],
      );

      await db.rawUpdate(
        'UPDATE posts SET likesCount = likesCount - 1 WHERE id = ?',
        [postId],
      );
    } else {
      await db.insert('post_likes', {
        'postId': postId,
        'userId': userId,
        'createdAt': DateTime.now().toIso8601String(),
      });

      await db.rawUpdate(
        'UPDATE posts SET likesCount = likesCount + 1 WHERE id = ?',
        [postId],
      );
    }
  }

  Future<bool> isPostLiked(int postId, String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
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