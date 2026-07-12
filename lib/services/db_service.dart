import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/flower.dart';
import '../models/walk.dart';

class DbService {
  static final DbService _instance = DbService._();
  factory DbService() => _instance;
  DbService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  Future<void> logMessage(String type, String content) async {
    final d = await db;
    await d.insert('message_log', {
      'type': type,
      'content': content,
      'shownAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getMessageLog() async {
    final d = await db;
    return d.query('message_log', orderBy: 'shownAt DESC');
  }

  /// Has a message already been logged today? (so we don't show 2x same day)
  Future<bool> hasLoggedToday(String type) async {
    final d = await db;
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final result = await d.query(
      'message_log',
      where: "type = ? AND date(shownAt) = ?",
      whereArgs: [type, todayStr],
    );
    return result.isNotEmpty;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'anet_garden.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE walks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            startedAt TEXT,
            endedAt TEXT,
            stepCount INTEGER,
            flowerCount INTEGER,
            distanceKm REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE flowers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL,
            longitude REAL,
            emoji TEXT,
            plantedAt TEXT,
            walkId INTEGER
          )
        ''');
        await db.execute('''
  CREATE TABLE message_log(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT,
    content TEXT,
    shownAt TEXT
  )
''');
      },
    );
  }

  // ── walks ──────────────────────────────────────────
  Future<int> insertWalk(Walk walk) async {
    final d = await db;
    return d.insert('walks', walk.toMap()..remove('id'));
  }

  Future<void> updateWalk(Walk walk) async {
    final d = await db;
    await d.update(
      'walks',
      walk.toMap(),
      where: 'id = ?',
      whereArgs: [walk.id],
    );
  }

  Future<List<Walk>> getWalks() async {
    final d = await db;
    final maps = await d.query('walks', orderBy: 'startedAt DESC');
    return maps.map(Walk.fromMap).toList();
  }

  // ── flowers ────────────────────────────────────────
  Future<int> insertFlower(Flower flower) async {
    final d = await db;
    return d.insert('flowers', flower.toMap()..remove('id'));
  }

  Future<List<Flower>> getFlowersForWalk(int walkId) async {
    final d = await db;
    final maps = await d.query(
      'flowers',
      where: 'walkId = ?',
      whereArgs: [walkId],
    );
    return maps.map(Flower.fromMap).toList();
  }

  Future<List<Flower>> getAllFlowers() async {
    final d = await db;
    final maps = await d.query('flowers', orderBy: 'plantedAt DESC');
    return maps.map(Flower.fromMap).toList();
  }

  /// Flowers planted today only
  Future<List<Flower>> getTodayFlowers() async {
    final d = await db;
    final today = _dayString(DateTime.now());
    final maps = await d.query(
      'flowers',
      where: "date(plantedAt) = ?",
      whereArgs: [today],
      orderBy: 'plantedAt DESC',
    );
    return maps.map(Flower.fromMap).toList();
  }

  /// How many flowers were planted yesterday
  Future<int> getYesterdayCount() async {
    final d = await db;
    final yesterday = _dayString(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final result = await d.rawQuery(
      "SELECT COUNT(*) as count FROM flowers WHERE date(plantedAt) = ?",
      [yesterday],
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Total flowers ever
  Future<int> getTotalFlowers() async {
    final d = await db;
    final result = await d.rawQuery('SELECT COUNT(*) as count FROM flowers');
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getTotalSteps() async {
    final d = await db;
    final result = await d.rawQuery(
      'SELECT SUM(stepCount) as total FROM walks',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  String _dayString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  Future<DateTime?> getLastShownDate(String type) async {
    final d = await db;
    final result = await d.query(
      'message_log',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'shownAt DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return DateTime.parse(result.first['shownAt'] as String);
  }

  Future<int> countShownBlessings() async {
    final d = await db;
    final result = await d.rawQuery(
      "SELECT COUNT(*) as count FROM message_log WHERE type = 'blessing'",
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Has the birthday message been shown for the given year already?
  Future<bool> hasShownBirthdayThisYear(int year) async {
    final d = await db;
    final key = 'birthday_$year';
    final result = await d.query(
      'message_log',
      where: 'type = ?',
      whereArgs: [key],
    );
    return result.isNotEmpty;
  }

  Future<void> markBirthdayShown(int year) async {
    await logMessage('birthday_$year', 'shown');
  }

  Future<bool> hasEverLogged(String type) async {
    final d = await db;
    final result = await d.query(
      'message_log',
      where: 'type = ?',
      whereArgs: [type],
    );
    return result.isNotEmpty;
  }
}
