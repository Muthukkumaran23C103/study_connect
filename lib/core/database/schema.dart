class DatabaseSchema {
  static const String createMessagesTable = '''
    CREATE TABLE messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      group_id INTEGER NOT NULL,
      sender_id INTEGER NOT NULL,
      content TEXT NOT NULL,
      message_type TEXT DEFAULT 'text',
      attachment_url TEXT,
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
      is_deleted BOOLEAN DEFAULT 0,
      FOREIGN KEY (group_id) REFERENCES study_groups (id),
      FOREIGN KEY (sender_id) REFERENCES users (id)
    )
  ''';

  static const String createPostsTable = '''
    CREATE TABLE posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      group_id INTEGER NOT NULL,
      author_id INTEGER NOT NULL,
      title TEXT,
      content TEXT NOT NULL,
      post_type TEXT DEFAULT 'general',
      attachment_urls TEXT,
      likes_count INTEGER DEFAULT 0,
      comments_count INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (group_id) REFERENCES study_groups (id),
      FOREIGN KEY (author_id) REFERENCES users (id)
    )
  ''';

  static const String createCommentsTable = '''
    CREATE TABLE comments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      post_id INTEGER NOT NULL,
      author_id INTEGER NOT NULL,
      content TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (post_id) REFERENCES posts (id),
      FOREIGN KEY (author_id) REFERENCES users (id)
    )
  ''';

  static const String createLikesTable = '''
    CREATE TABLE likes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      post_id INTEGER NOT NULL,
      user_id INTEGER NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (post_id) REFERENCES posts (id),
      FOREIGN KEY (user_id) REFERENCES users (id),
      UNIQUE(post_id, user_id)
    )
  ''';
}
