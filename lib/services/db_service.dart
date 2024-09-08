import 'dart:typed_data';

import 'package:contractor_book/models/contractor.dart';
import 'package:contractor_book/models/site_images.dart';
import 'package:contractor_book/models/site_note.dart';
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
      'CREATE TABLE site(id INTEGER PRIMARY KEY, name TEXT, date DATETIME, location TEXT, active INTEGER, ownerName TEXT)',
    );
    await db.execute(
      'CREATE TABLE owner(id INTEGER PRIMARY KEY, name TEXT, number INTEGER, address TEXT)',
    );
    await db.execute(
      'CREATE TABLE site_images(id INTEGER PRIMARY KEY, siteId INTEGER, image BLOB, FOREIGN KEY (siteId) REFERENCES site(id) ON DELETE SET NULL)',
    );
    await db.execute(
      'CREATE TABLE site_notes(id INTEGER PRIMARY KEY, siteId INTEGER, content TEXT, FOREIGN KEY (siteId) REFERENCES site(id) ON DELETE SET NULL)',
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

  Future<void> addNoteForSite(int siteId, String content) async {
    Note note = Note(
        id: 0, siteId: siteId, content: content, dateAdded: DateTime.now());
    final db = await _databaseService.database;

    await db.insert('site_notes', note.toMapWithoutId(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Contractor> getCurrentUser() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> contractors = await db.query('contractor');
    if (contractors.isNotEmpty) {
      print("Contractor $contractors[0]");
      return Contractor.fromMap(contractors[0]);
    } else {
      return Contractor(
          contractorId: 0,
          name: "",
          city: "",
          address: "",
          phone: "",
          title: "");
    }
  }

  Future<List<Sites>> getSites() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> sites = await db.query('site');
    return List.generate(sites.length, (index) => Sites.fromMap(sites[index]));
  }

  Future<List<SiteImage>> getImages(siteId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> siteImages = await db.query(
      'site_images',
      where: 'siteId = ?',
      whereArgs: [siteId],
    );
    return List.generate(
        siteImages.length, (index) => SiteImage.fromMap(siteImages[index]));
  }

  Future<List<Uint8List>> getSiteImages(int siteId) async {
    final db =
        await database; // Assuming you have a method to get the database instance
    final List<Map<String, dynamic>> maps = await db.query(
      'site_images',
      columns: ['image'],
      where: 'siteId = ?',
      whereArgs: [siteId],
    );

    return maps.map((map) => map['image'] as Uint8List).toList();
  }

  Future<List<Sites>> getSitesWithState(state) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> sites = await db.query('site',
        where: 'active = ?', whereArgs: [state != Null ? state : 0]);
    return List.generate(sites.length, (index) => Sites.fromMap(sites[index]));
  }

  Future<List<Note>> getNotesForSite(state) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> notes = await db.query("site_notes",
        where: 'siteId = ?', whereArgs: [state != Null ? state : 0]);
    return List.generate(notes.length, (index) => Note.fromMap(notes[index]));
  }

  Future<void> updateSiteStatus(int siteId, int newStatus) async {
    final db = await database; // Get the database instance

    // Perform the update query
    await db.update(
      'site', // The table name
      {'active': newStatus}, // The field to update with the new value
      where: 'id = ?', // Where condition to target the specific site
      whereArgs: [siteId], // Site ID to update
    );
  }
}
