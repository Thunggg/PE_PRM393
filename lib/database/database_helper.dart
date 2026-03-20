import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/artwork.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'art_gallery.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng users
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        email TEXT,
        password TEXT,
        createdAt TEXT
      )
    ''');
    // Tạo bảng artworks
    await db.execute('''
      CREATE TABLE artworks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        artist TEXT,
        year INTEGER,
        category TEXT,
        description TEXT,
        createdBy INTEGER,
        FOREIGN KEY(createdBy) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // === User methods ===
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByUsername(String username) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<User?> login(String username, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // === Artwork methods ===
  Future<int> insertArtwork(Artwork artwork) async {
    Database db = await database;
    return await db.insert('artworks', artwork.toMap());
  }

  Future<List<Artwork>> getArtworksByUser(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'artworks',
      where: 'createdBy = ?',
      whereArgs: [userId],
      orderBy: 'title ASC',
    );
    return List.generate(maps.length, (i) => Artwork.fromMap(maps[i]));
  }

  Future<int> deleteArtwork(int id) async {
    Database db = await database;
    return await db.delete('artworks', where: 'id = ?', whereArgs: [id]);
  }

  Future<Artwork?> getArtworkById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'artworks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Artwork.fromMap(maps.first);
    return null;
  }
}
