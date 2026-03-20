import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    String path = join(await getDatabasesPath(), 'gallery.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
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
        createdBy INTEGER
      )
    ''');
  }

  // Hàm thêm user
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  // Hàm lấy user theo username và password
  Future<Map<String, dynamic>?> getUser(
    String username,
    String password,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // Hàm kiểm tra username đã tồn tại chưa
  Future<bool> isUsernameExists(String username) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  // Hàm thêm artwork
  Future<int> insertArtwork(Map<String, dynamic> artwork) async {
    Database db = await database;
    return await db.insert('artworks', artwork);
  }

  // Hàm lấy tất cả artwork của một user
  Future<List<Map<String, dynamic>>> getArtworks(int userId) async {
    Database db = await database;
    return await db.query(
      'artworks',
      where: 'createdBy = ?',
      whereArgs: [userId],
      orderBy: 'title ASC',
    );
  }

  // Hàm xóa artwork
  Future<int> deleteArtwork(int id) async {
    Database db = await database;
    return await db.delete('artworks', where: 'id = ?', whereArgs: [id]);
  }
}
