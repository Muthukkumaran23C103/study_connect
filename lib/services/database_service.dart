
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/models/user_model.dart';
import '../core/models/message_model.dart';
import '../core/models/post_model.dart';
import '../core/models/study_group_model.dart';

class DatabaseService {
static final DatabaseService _instance = DatabaseService._internal();
factory DatabaseService() => _instance;
static DatabaseService get instance => _instance;
DatabaseService._internal();

static Database? _database;
static const String _databaseName = 'studyconnect.db';
static const int _databaseVersion = 1;

Future<Database> get database async {
if (_database != null) return _database!;
_database = await _initDB();
return _database!;
}

Future<Database> _initDB() async {
String path = join(await getDatabasesPath(), _databaseName);
return await openDatabase(
path,
version: _databaseVersion,
onCreate: _createDB,
onUpgrade: _upgradeDB,
);
}

Future<void> _createDB(Database db, int version) async {
// Users table
await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        avatar_url TEXT,
        avatar_path TEXT,
        college TEXT,
        year TEXT,
        branch TEXT,
        joined_groups TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        last_active TEXT,
        is_verified INTEGER DEFAULT 0,
        password TEXT,
        password_hash TEXT
      )
      ''');

// Study groups table
await db.execute('''
      CREATE TABLE study_groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        created_by TEXT NOT NULL,
        tags TEXT,
        member_count INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
      ''');

// Posts table
await db.execute('''
      CREATE TABLE posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        group_id INTEGER,
        media_urls TEXT,
        likes_count INTEGER DEFAULT 0,
        comments_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (author_id) REFERENCES users (id),
        FOREIGN KEY (group_id) REFERENCES study_groups (id)
      )
      ''');

// Messages table
await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        sender_name TEXT NOT NULL,
        group_id INTEGER NOT NULL,
        message_type TEXT DEFAULT 'text',
        media_url TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (sender_id) REFERENCES users (id),
        FOREIGN KEY (group_id) REFERENCES study_groups (id)
      )
      ''');

// Group members table
await db.execute('''
      CREATE TABLE group_members(
        group_id INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        joined_at TEXT NOT NULL,
        role TEXT DEFAULT 'member',
        PRIMARY KEY (group_id, user_id),
        FOREIGN KEY (group_id) REFERENCES study_groups (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
      ''');

// Post likes table
await db.execute('''
      CREATE TABLE post_likes(
        post_id INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (post_id, user_id),
        FOREIGN KEY (post_id) REFERENCES posts (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
      ''');

// Post comments table
await db.execute('''
      CREATE TABLE post_comments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
      ''');

// Notes table
await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        group_id INTEGER NOT NULL,
        category TEXT DEFAULT 'general',
        file_url TEXT,
        downloads_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (author_id) REFERENCES users (id),
        FOREIGN KEY (group_id) REFERENCES study_groups (id)
      )
      ''');

// Quizzes table
await db.execute('''
      CREATE TABLE quizzes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        creator_id TEXT NOT NULL,
        creator_name TEXT NOT NULL,
        group_id INTEGER NOT NULL,
        questions_count INTEGER DEFAULT 0,
        time_limit INTEGER,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (creator_id) REFERENCES users (id),
        FOREIGN KEY (group_id) REFERENCES study_groups (id)
      )
      ''');
}

Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
// Handle database upgrades here
if (oldVersion < newVersion) {
// Drop all tables and recreate
await db.execute('DROP TABLE IF EXISTS post_comments');
await db.execute('DROP TABLE IF EXISTS post_likes');
await db.execute('DROP TABLE IF EXISTS group_members');
await db.execute('DROP TABLE IF EXISTS notes');
await db.execute('DROP TABLE IF EXISTS quizzes');
await db.execute('DROP TABLE IF EXISTS messages');
await db.execute('DROP TABLE IF EXISTS posts');
await db.execute('DROP TABLE IF EXISTS study_groups');
await db.execute('DROP TABLE IF EXISTS users');
await _createDB(db, newVersion);
}
}

// Reset database (useful for development)
Future<void> resetDatabase() async {
String path = join(await getDatabasesPath(), _databaseName);
await deleteDatabase(path);
_database = null;
await database; // This will recreate the database
}

// ============ USER OPERATIONS ============
Future<void> insertUser(UserModel user) async {
final db = await database;
await db.insert(
'users',
user.toMap(),
conflictAlgorithm: ConflictAlgorithm.replace,
);
}

Future<UserModel?> getUser(String userId) async {
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

Future<void> updateUser(UserModel user) async {
final db = await database;
await db.update(
'users',
user.toMap(),
where: 'id = ?',
whereArgs: [user.id],
);
}

Future<List<UserModel>> getAllUsers() async {
final db = await database;
final maps = await db.query('users', orderBy: 'created_at DESC');
return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
}

// ============ STUDY GROUP OPERATIONS ============
Future<int> insertStudyGroup(StudyGroupModel group) async {
final db = await database;
// Insert the group
final groupId = await db.insert('study_groups', group.toMap());
// Add creator as first member
await db.insert('group_members', {
'group_id': groupId,
'user_id': group.createdBy,
'joined_at': DateTime.now().toIso8601String(),
'role': 'admin',
});
return groupId;
}

Future<List<StudyGroupModel>> getStudyGroups() async {
final db = await database;
final maps = await db.query('study_groups', orderBy: 'created_at DESC');
return List.generate(maps.length, (i) => StudyGroupModel.fromMap(maps[i]));
}

Future<List<StudyGroupModel>> getUserGroups(String userId) async {
final db = await database;
final maps = await db.rawQuery('''
      SELECT sg.* FROM study_groups sg
      INNER JOIN group_members gm ON sg.id = gm.group_id
      WHERE gm.user_id = ?
      ORDER BY sg.created_at DESC
      ''', [userId]);
return List.generate(maps.length, (i) => StudyGroupModel.fromMap(maps[i]));
}

Future<StudyGroupModel?> getStudyGroup(int groupId) async {
final db = await database;
final maps = await db.query(
'study_groups',
where: 'id = ?',
whereArgs: [groupId],
);
if (maps.isNotEmpty) {
return StudyGroupModel.fromMap(maps.first);
}
return null;
}

Future<void> updateStudyGroup(StudyGroupModel group) async {
final db = await database;
await db.update(
'study_groups',
group.toMap(),
where: 'id = ?',
whereArgs: [group.id],
);
}

Future<void> joinGroup(int groupId, String userId) async {
final db = await database;
// Insert group membership
await db.insert('group_members', {
'group_id': groupId,
'user_id': userId,
'joined_at': DateTime.now().toIso8601String(),
'role': 'member',
}, conflictAlgorithm: ConflictAlgorithm.ignore);
// Update member count
await _updateGroupMemberCount(groupId);
}

Future<void> leaveGroup(int groupId, String userId) async {
final db = await database;
await db.delete(
'group_members',
where: 'group_id = ? AND user_id = ?',
whereArgs: [groupId, userId],
);
// Update member count
await _updateGroupMemberCount(groupId);
}

Future<bool> isUserInGroup(int groupId, String userId) async {
final db = await database;
final result = await db.query(
'group_members',
where: 'group_id = ? AND user_id = ?',
whereArgs: [groupId, userId],
);
return result.isNotEmpty;
}

Future<List<StudyGroupModel>> searchStudyGroups(String query) async {
final db = await database;
final maps = await db.query(
'study_groups',
where: 'name LIKE ? OR description LIKE ? OR tags LIKE ?',
whereArgs: ['%$query%', '%$query%', '%$query%'],
orderBy: 'created_at DESC',
);
return List.generate(maps.length, (i) => StudyGroupModel.fromMap(maps[i]));
}

Future<void> _updateGroupMemberCount(int groupId) async {
final db = await database;
await db.rawUpdate('''
      UPDATE study_groups 
      SET member_count = (
        SELECT COUNT(*) FROM group_members WHERE group_id = ?
      ) 
      WHERE id = ?
      ''', [groupId, groupId]);
}

// ============ POST OPERATIONS ============
Future<int> insertPost(PostModel post) async {
final db = await database;
return await db.insert('posts', post.toMap());
}

Future<List<PostModel>> getAllPosts() async {
final db = await database;
final maps = await db.query('posts', orderBy: 'created_at DESC');
return List.generate(maps.length, (i) => PostModel.fromMap(maps[i]));
}

Future<List<PostModel>> getGroupPosts(int groupId) async {
final db = await database;
final maps = await db.query(
'posts',
where: 'group_id = ?',
whereArgs: [groupId],
orderBy: 'created_at DESC',
);
return List.generate(maps.length, (i) => PostModel.fromMap(maps[i]));
}

Future<List<PostModel>> getUserPosts(String userId) async {
final db = await database;
final maps = await db.query(
'posts',
where: 'author_id = ?',
whereArgs: [userId],
orderBy: 'created_at DESC',
);
return List.generate(maps.length, (i) => PostModel.fromMap(maps[i]));
}

Future<void> updatePost(PostModel post) async {
final db = await database;
await db.update(
'posts',
post.toMap(),
where: 'id = ?',
whereArgs: [post.id],
);
}

Future<void> deletePost(int postId) async {
final db = await database;
// Delete post likes first
await db.delete('post_likes', where: 'post_id = ?', whereArgs: [postId]);
// Delete post comments
await db.delete('post_comments', where: 'post_id = ?', whereArgs: [postId]);
// Delete the post
await db.delete('posts', where: 'id = ?', whereArgs: [postId]);
}

// ============ POST LIKES OPERATIONS ============
Future<void> toggleLike(int postId, String userId) async {
final db = await database;
// Check if user already liked the post
final existingLike = await db.query(
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
} else {
// Remove like
await db.delete(
'post_likes',
where: 'post_id = ? AND user_id = ?',
whereArgs: [postId, userId],
);
}
// Update likes count
await _updatePostLikesCount(postId);
}

Future<bool> isPostLiked(int postId, String userId) async {
final db = await database;
final result = await db.query(
'post_likes',
where: 'post_id = ? AND user_id = ?',
whereArgs: [postId, userId],
);
return result.isNotEmpty;
}

Future<void> _updatePostLikesCount(int postId) async {
final db = await database;
await db.rawUpdate('''
      UPDATE posts 
      SET likes_count = (
        SELECT COUNT(*) FROM post_likes WHERE post_id = ?
      ) 
      WHERE id = ?
      ''', [postId, postId]);
}

// ============ MESSAGE OPERATIONS ============
Future<int> insertMessage(MessageModel message) async {
final db = await database;
return await db.insert('messages', message.toMap());
}

Future<List<MessageModel>> getGroupMessages(int groupId) async {
final db = await database;
final maps = await db.query(
'messages',
where: 'group_id = ?',
whereArgs: [groupId],
orderBy: 'created_at ASC',
);
return List.generate(maps.length, (i) => MessageModel.fromMap(maps[i]));
}

// Add this method that was missing
Future<List<MessageModel>> getMessagesForGroup(int groupId) async {
return await getGroupMessages(groupId);
}

Future<MessageModel?> getLastGroupMessage(int groupId) async {
final db = await database;
final maps = await db.query(
'messages',
where: 'group_id = ?',
whereArgs: [groupId],
orderBy: 'created_at DESC',
limit: 1,
);
if (maps.isNotEmpty) {
return MessageModel.fromMap(maps.first);
}
return null;
}

// Add this method that was missing
Future<MessageModel?> getLastMessage(int groupId) async {
return await getLastGroupMessage(groupId);
}

Future<void> deleteMessage(int messageId) async {
final db = await database;
await db.delete('messages', where: 'id = ?', whereArgs: [messageId]);
}

// ============ NOTES OPERATIONS ============
Future<int> insertNote(Map<String, dynamic> note) async {
final db = await database;
return await db.insert('notes', note);
}

Future<List<Map<String, dynamic>>> getGroupNotes(int groupId) async {
final db = await database;
return await db.query(
'notes',
where: 'group_id = ?',
whereArgs: [groupId],
orderBy: 'created_at DESC',
);
}

Future<List<Map<String, dynamic>>> getNotesByCategory(int groupId, String category) async {
final db = await database;
return await db.query(
'notes',
where: 'group_id = ? AND category = ?',
whereArgs: [groupId, category],
orderBy: 'created_at DESC',
);
}

// ============ QUIZ OPERATIONS ============
Future<int> insertQuiz(Map<String, dynamic> quiz) async {
final db = await database;
return await db.insert('quizzes', quiz);
}

Future<List<Map<String, dynamic>>> getGroupQuizzes(int groupId) async {
final db = await database;
return await db.query(
'quizzes',
where: 'group_id = ?',
whereArgs: [groupId],
orderBy: 'created_at DESC',
);
}

Future<List<Map<String, dynamic>>> getActiveQuizzes(int groupId) async {
final db = await database;
return await db.query(
'quizzes',
where: 'group_id = ? AND is_active = 1',
whereArgs: [groupId],
orderBy: 'created_at DESC',
);
}

// ============ UTILITY OPERATIONS ============
Future<void> clearAllData() async {
final db = await database;
await db.delete('post_comments');
await db.delete('post_likes');
await db.delete('group_members');
await db.delete('notes');
await db.delete('quizzes');
await db.delete('messages');
await db.delete('posts');
await db.delete('study_groups');
await db.delete('users');
}

Future<Map<String, int>> getDatabaseStats() async {
final db = await database;
final usersCount = Sqflite.firstIntValue(
await db.rawQuery('SELECT COUNT(*) FROM users'),
) ?? 0;
final groupsCount = Sqflite.firstIntValue(
await db.rawQuery('SELECT COUNT(*) FROM study_groups'),
) ?? 0;
final postsCount = Sqflite.firstIntValue(
await db.rawQuery('SELECT COUNT(*) FROM posts'),
) ?? 0;
final messagesCount = Sqflite.firstIntValue(
await db.rawQuery('SELECT COUNT(*) FROM messages'),
) ?? 0;

return {
'users': usersCount,
'groups': groupsCount,
'posts': postsCount,
'messages': messagesCount,
};
}

// Close database
Future<void> close() async {
final db = _database;
if (db != null) {
await db.close();
_database = null;
}
}
}
