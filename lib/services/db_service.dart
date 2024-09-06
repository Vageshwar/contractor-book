import 'package:contractor_book/models/contractor.dart';
import 'package:contractor_book/models/site_images.dart';
import 'package:contractor_book/models/sites.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Singleton pattern
  static const String dbName = 'contractor_book';
  static final DatabaseService _databaseService = DatabaseService._internal();

  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the DB first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    final path = join(databasePath, dbName);

    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  // When the database is first created, create a table to store breeds
  // and a table to store dogs.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE contractor(id INTEGER PRIMARY KEY, name TEXT, title TEXT, phone INTEGER, address TEXT, city TEXT)',
    );
    await db.execute(
      'CREATE TABLE site(id INTEGER PRIMARY KEY, name TEXT, date DATETIME, location TEXT, active INTEGER, ownerId INTEGER, FOREIGN KEY (ownerId) REFERENCES owners(id) ON DELETE SET NULL)',
    );
    await db.execute(
      'CREATE TABLE owner(id INTEGER PRIMARY KEY, name TEXT, number INTEGER, address TEXT)',
    );
    await db.execute(
      'CREATE TABLE site_images(id INTEGER PRIMARY KEY, siteId INTEGER, image BLOB, FOREIGN KEY (siteId) REFERENCES site(id) ON DELETE SET NULL)',
    );
  }

  Future<void> insertContractor(Contractor contractor) async {
    final db = await _databaseService.database;

    await db.insert('contractor', contractor.toMapWithoutId(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertSite(Sites site) async {
    final db = await _databaseService.database;

    await db.insert('site', site.toMapWithoutId(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertImage(SiteImage image) async {
    final db = await _databaseService.database;

    await db.insert('site_images', image.toMapWithoutId(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
