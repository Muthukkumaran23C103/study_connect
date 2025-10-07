import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/models/user_model.dart';
import '../core/models/study_group_model.dart';
import '../core/models/message_model.dart';
import '../core/models/post_model.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  DatabaseService._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'study_connect.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        display_name TEXT NOT NULL,
        year TEXT,
        branch TEXT,
        college TEXT,
        avatar_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE study_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        created_by INTEGER NOT NULL,
        member_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE group_memberships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        group_id INTEGER NOT NULL,
        joined_at TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES study_groups (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        sender_id TEXT NOT NULL,
        sender_name TEXT NOT NULL,
        content TEXT NOT NULL,
        message_type TEXT DEFAULT 'text',
        attachment_url TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES study_groups (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        group_id INTEGER,
        likes_count INTEGER DEFAULT 0,
        comments_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES study_groups (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE post_likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts (id)
      )
    ''');

    // Insert default study groups
    await _insertDefaultGroups(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS study_groups (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          category TEXT NOT NULL,
          created_by INTEGER NOT NULL,
          member_count INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (created_by) REFERENCES users (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS group_memberships (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          group_id INTEGER NOT NULL,
          joined_at TEXT NOT NULL,
          FOREIGN KEY (group_id) REFERENCES study_groups (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          group_id INTEGER NOT NULL,
          sender_id TEXT NOT NULL,
          sender_name TEXT NOT NULL,
          content TEXT NOT NULL,
          message_type TEXT DEFAULT 'text',
          attachment_url TEXT,
          timestamp TEXT NOT NULL,
          FOREIGN KEY (group_id) REFERENCES study_groups (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS posts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          author_id TEXT NOT NULL,
          author_name TEXT NOT NULL,
          group_id INTEGER,
          likes_count INTEGER DEFAULT 0,
          comments_count INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (group_id) REFERENCES study_groups (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS post_likes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          post_id INTEGER NOT NULL,
          user_id TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (post_id) REFERENCES posts (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS comments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          post_id INTEGER NOT NULL,
          author_id TEXT NOT NULL,
          author_name TEXT NOT NULL,
          content TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (post_id) REFERENCES posts (id)
        )
      ''');

      await _insertDefaultGroups(db);
    }
  }

  Future<void> _insertDefaultGroups(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('study_groups', {
      'name': 'AI & Machine Learning',
      'description': 'Learn and discuss artificial intelligence, machine learning algorithms, neural networks, and AI applications.',
      'category': 'AI',
      'created_by': 1,
      'member_count': 0,
      'created_at': now,
    });

    await db.insert('study_groups', {
      'name': 'Mobile Development',
      'description': 'Flutter, React Native, Android, iOS development discussions and project collaborations.',
      'category': 'DEV',
      'created_by': 1,
      'member_count': 0,
      'created_at': now,
    });

    await db.insert('study_groups', {
      'name': 'Operating Systems',
      'description': 'Study operating system concepts, kernel programming, system calls, and OS architecture.',
      'category': 'OS',
      'created_by': 1,
      'member_count': 0,
      'created_at': now,
    });
  }

  // User operations
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Study Group operations
  Future<List<StudyGroup>> getStudyGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('study_groups');
    return List.generate(maps.length, (i) => StudyGroup.fromMap(maps[i]));
  }

  Future<List<StudyGroup>> getUserGroups(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT sg.* FROM study_groups sg
      INNER JOIN group_memberships gm ON sg.id = gm.group_id
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
    await db.insert('group_memberships', {
      'user_id': userId,
      'group_id': groupId,
      'joined_at': DateTime.now().toIso8601String(),
    });

    // Update member count
    await db.rawUpdate('''
      UPDATE study_groups 
      SET member_count = member_count + 1 
      WHERE id = ?
    ''', [groupId]);
  }

  Future<void> leaveGroup(int groupId, String userId) async {
    final db = await database;
    await db.delete(
      'group_memberships',
      where: 'group_id = ? AND user_id = ?',
      whereArgs: [groupId, userId],
    );

    // Update member count
    await db.rawUpdate('''
      UPDATE study_groups 
      SET member_count = CASE WHEN member_count > 0 THEN member_count - 1 ELSE 0 END 
      WHERE id = ?
    ''', [groupId]);
  }

  Future<bool> isUserInGroup(int groupId, String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'group_memberships',
      where: 'group_id = ? AND user_id = ?',
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
    return List.generate(maps.length, (i) => StudyGroup.fromMap(maps[i]));
  }

  // Message operations
  Future<List<Message>> getMessagesForGroup(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
  }

  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<Message?> getLastMessage(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Message.fromMap(maps.first);
  }

  // Post operations
  Future<List<Post>> getAllPosts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Post.fromMap(maps[i]));
  }

  Future<List<Post>> getGroupPosts(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Post.fromMap(maps[i]));
  }

  Future<int> insertPost(Post post) async {
    final db = await database;
    return await db.insert('posts', post.toMap());
  }

  Future<void> toggleLike(int postId, String userId) async {
    final db = await database;

    // Check if user already liked the post
    final List<Map<String, dynamic>> existingLike = await db.query(
      'post_likes',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, userId],
    );

    if (existingLike.isEmpty) {
      // Add like
      await db.insert('post_likes', {
        'post_id': postId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update likes count
      await db.rawUpdate('''
        UPDATE posts 
        SET likes_count = likes_count + 1 
        WHERE id = ?
      ''', [postId]);
    } else {
      // Remove like
      await db.delete(
        'post_likes',
        where: 'post_id = ? AND user_id = ?',
        whereArgs: [postId, userId],
      );

      // Update likes count
      await db.rawUpdate('''
        UPDATE posts 
        SET likes_count = CASE WHEN likes_count > 0 THEN likes_count - 1 ELSE 0 END 
        WHERE id = ?
      ''', [postId]);
    }
  }

  Future<bool> isPostLiked(int postId, String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'post_likes',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, userId],
    );
    return maps.isNotEmpty;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}