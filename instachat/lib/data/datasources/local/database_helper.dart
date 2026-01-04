import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ============================================
// lib/data/datasources/local/database_helper.dart
// 🗄️ SQLITE DATABASE HELPER FOR COMPLEX DATA
// ============================================

class DatabaseHelper {
  static const DatabaseHelper _instance = DatabaseHelper._internal();
  const DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  static const String _databaseName = 'social_app.db';
  static const int _databaseVersion = 1;

  // ===========================================================================
  // DATABASE TABLES
  // ===========================================================================

  // Drafts table for saving post drafts
  static const String draftsTable = 'drafts';
  static const String colDraftId = 'id';
  static const String colDraftContent = 'content';
  static const String colDraftMedia = 'media';
  static const String colDraftType = 'type';
  static const String colDraftTimestamp = 'timestamp';

  // Bookmarks table for saved posts
  static const String bookmarksTable = 'bookmarks';
  static const String colBookmarkId = 'id';
  static const String colBookmarkPostId = 'post_id';
  static const String colBookmarkUserId = 'user_id';
  static const String colBookmarkTimestamp = 'timestamp';

  // Search history table
  static const String searchHistoryTable = 'search_history';
  static const String colSearchId = 'id';
  static const String colSearchQuery = 'query';
  static const String colSearchType = 'type';
  static const String colSearchTimestamp = 'timestamp';

  // Chat messages table for offline storage
  static const String messagesTable = 'messages';
  static const String colMessageId = 'id';
  static const String colMessageConversationId = 'conversation_id';
  static const String colMessageSenderId = 'sender_id';
  static const String colMessageContent = 'content';
  static const String colMessageType = 'type';
  static const String colMessageMediaUrl = 'media_url';
  static const String colMessageTimestamp = 'timestamp';
  static const String colMessageStatus = 'status';

  // ===========================================================================
  // DATABASE INITIALIZATION
  // ===========================================================================

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create drafts table
    await db.execute('''
      CREATE TABLE $draftsTable (
        $colDraftId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colDraftContent TEXT,
        $colDraftMedia TEXT,
        $colDraftType TEXT,
        $colDraftTimestamp INTEGER
      )
    ''');

    // Create bookmarks table
    await db.execute('''
      CREATE TABLE $bookmarksTable (
        $colBookmarkId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colBookmarkPostId TEXT NOT NULL,
        $colBookmarkUserId TEXT NOT NULL,
        $colBookmarkTimestamp INTEGER,
        UNIQUE($colBookmarkPostId, $colBookmarkUserId)
      )
    ''');

    // Create search history table
    await db.execute('''
      CREATE TABLE $searchHistoryTable (
        $colSearchId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colSearchQuery TEXT NOT NULL,
        $colSearchType TEXT,
        $colSearchTimestamp INTEGER,
        UNIQUE($colSearchQuery, $colSearchType)
      )
    ''');

    // Create messages table
    await db.execute('''
      CREATE TABLE $messagesTable (
        $colMessageId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colMessageConversationId TEXT NOT NULL,
        $colMessageSenderId TEXT NOT NULL,
        $colMessageContent TEXT,
        $colMessageType TEXT,
        $colMessageMediaUrl TEXT,
        $colMessageTimestamp INTEGER,
        $colMessageStatus TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Add migration logic as needed
    }
  }

  // ===========================================================================
  // DRAFTS OPERATIONS
  // ===========================================================================

  /// Save a post draft
  Future<int> saveDraft({
    String? content,
    String? media,
    String? type,
  }) async {
    final db = await database;
    return await db.insert(draftsTable, {
      colDraftContent: content,
      colDraftMedia: media,
      colDraftType: type,
      colDraftTimestamp: DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Get all drafts
  Future<List<Map<String, dynamic>>> getDrafts() async {
    final db = await database;
    return await db.query(
      draftsTable,
      orderBy: '$colDraftTimestamp DESC',
    );
  }

  /// Get draft by ID
  Future<Map<String, dynamic>?> getDraft(int id) async {
    final db = await database;
    final results = await db.query(
      draftsTable,
      where: '$colDraftId = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Update draft
  Future<int> updateDraft(int id, {
    String? content,
    String? media,
    String? type,
  }) async {
    final db = await database;
    return await db.update(
      draftsTable,
      {
        colDraftContent: content,
        colDraftMedia: media,
        colDraftType: type,
        colDraftTimestamp: DateTime.now().millisecondsSinceEpoch,
      },
      where: '$colDraftId = ?',
      whereArgs: [id],
    );
  }

  /// Delete draft
  Future<int> deleteDraft(int id) async {
    final db = await database;
    return await db.delete(
      draftsTable,
      where: '$colDraftId = ?',
      whereArgs: [id],
    );
  }

  /// Clear all drafts
  Future<int> clearAllDrafts() async {
    final db = await database;
    return await db.delete(draftsTable);
  }

  // ===========================================================================
  // BOOKMARKS OPERATIONS
  // ===========================================================================

  /// Add bookmark
  Future<int> addBookmark(String postId, String userId) async {
    final db = await database;
    return await db.insert(
      bookmarksTable,
      {
        colBookmarkPostId: postId,
        colBookmarkUserId: userId,
        colBookmarkTimestamp: DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Remove bookmark
  Future<int> removeBookmark(String postId, String userId) async {
    final db = await database;
    return await db.delete(
      bookmarksTable,
      where: '$colBookmarkPostId = ? AND $colBookmarkUserId = ?',
      whereArgs: [postId, userId],
    );
  }

  /// Check if post is bookmarked
  Future<bool> isBookmarked(String postId, String userId) async {
    final db = await database;
    final results = await db.query(
      bookmarksTable,
      where: '$colBookmarkPostId = ? AND $colBookmarkUserId = ?',
      whereArgs: [postId, userId],
    );
    return results.isNotEmpty;
  }

  /// Get all bookmarks for user
  Future<List<Map<String, dynamic>>> getBookmarks(String userId) async {
    final db = await database;
    return await db.query(
      bookmarksTable,
      where: '$colBookmarkUserId = ?',
      whereArgs: [userId],
      orderBy: '$colBookmarkTimestamp DESC',
    );
  }

  /// Get bookmark count for user
  Future<int> getBookmarkCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $bookmarksTable WHERE $colBookmarkUserId = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ===========================================================================
  // SEARCH HISTORY OPERATIONS
  // ===========================================================================

  /// Add search query to history
  Future<int> addSearchHistory(String query, {String? type}) async {
    final db = await database;
    return await db.insert(
      searchHistoryTable,
      {
        colSearchQuery: query,
        colSearchType: type,
        colSearchTimestamp: DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get search history
  Future<List<Map<String, dynamic>>> getSearchHistory({int limit = 20}) async {
    final db = await database;
    return await db.query(
      searchHistoryTable,
      orderBy: '$colSearchTimestamp DESC',
      limit: limit,
    );
  }

  /// Delete search history item
  Future<int> deleteSearchHistory(int id) async {
    final db = await database;
    return await db.delete(
      searchHistoryTable,
      where: '$colSearchId = ?',
      whereArgs: [id],
    );
  }

  /// Clear all search history
  Future<int> clearSearchHistory() async {
    final db = await database;
    return await db.delete(searchHistoryTable);
  }

  /// Get recent search queries
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    final db = await database;
    final results = await db.query(
      searchHistoryTable,
      columns: [colSearchQuery],
      orderBy: '$colSearchTimestamp DESC',
      limit: limit,
    );
    return results.map((row) => row[colSearchQuery] as String).toList();
  }

  // ===========================================================================
  // MESSAGES OPERATIONS (OFFLINE STORAGE)
  // ===========================================================================

  /// Save message locally
  Future<int> saveMessage({
    required String conversationId,
    required String senderId,
    String? content,
    required String type,
    String? mediaUrl,
    required int timestamp,
    String status = 'sent',
  }) async {
    final db = await database;
    return await db.insert(messagesTable, {
      colMessageConversationId: conversationId,
      colMessageSenderId: senderId,
      colMessageContent: content,
      colMessageType: type,
      colMessageMediaUrl: mediaUrl,
      colMessageTimestamp: timestamp,
      colMessageStatus: status,
    });
  }

  /// Get messages for conversation
  Future<List<Map<String, dynamic>>> getMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    return await db.query(
      messagesTable,
      where: '$colMessageConversationId = ?',
      whereArgs: [conversationId],
      orderBy: '$colMessageTimestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Update message status
  Future<int> updateMessageStatus(int messageId, String status) async {
    final db = await database;
    return await db.update(
      messagesTable,
      {colMessageStatus: status},
      where: '$colMessageId = ?',
      whereArgs: [messageId],
    );
  }

  /// Delete message
  Future<int> deleteMessage(int messageId) async {
    final db = await database;
    return await db.delete(
      messagesTable,
      where: '$colMessageId = ?',
      whereArgs: [messageId],
    );
  }

  /// Get unsent messages
  Future<List<Map<String, dynamic>>> getUnsentMessages() async {
    final db = await database;
    return await db.query(
      messagesTable,
      where: '$colMessageStatus = ?',
      whereArgs: ['sending'],
      orderBy: '$colMessageTimestamp ASC',
    );
  }

  /// Clear messages for conversation
  Future<int> clearConversationMessages(String conversationId) async {
    final db = await database;
    return await db.delete(
      messagesTable,
      where: '$colMessageConversationId = ?',
      whereArgs: [conversationId],
    );
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;

    final draftsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $draftsTable'),
    ) ?? 0;

    final bookmarksCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $bookmarksTable'),
    ) ?? 0;

    final searchHistoryCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $searchHistoryTable'),
    ) ?? 0;

    final messagesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $messagesTable'),
    ) ?? 0;

    return {
      'drafts': draftsCount,
      'bookmarks': bookmarksCount,
      'search_history': searchHistoryCount,
      'messages': messagesCount,
    };
  }

  /// Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(draftsTable);
    await db.delete(bookmarksTable);
    await db.delete(searchHistoryTable);
    await db.delete(messagesTable);
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete database (for testing or reset)
  Future<void> deleteDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
