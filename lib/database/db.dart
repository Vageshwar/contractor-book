import 'package:contractor_book/models/ContractorModel.dart';
import 'package:contractor_book/models/contractor_fields.dart';
import 'package:sqflite/sqflite.dart';

class ContractorDatabase {
  static final ContractorDatabase instance = ContractorDatabase._internal();

  static Database? _database;

  ContractorDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/contractor.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    return await db.execute('''
        CREATE TABLE ${ContractorFields.tableName} (
          ${ContractorFields.id} ${ContractorFields.idType},
          ${ContractorFields.phone} ${ContractorFields.intType},
          ${ContractorFields.title} ${ContractorFields.textType},
          ${ContractorFields.name} ${ContractorFields.textType},
          ${ContractorFields.city} ${ContractorFields.textType},
          ${ContractorFields.address} ${ContractorFields.textType},
        )
      ''');
  }

  Future<ContractorModel> create(ContractorModel contractor) async {
    final db = await instance.database;
    final id = await db.insert(ContractorFields.tableName, contractor.toJson());
    return contractor.copy(id: id);
  }
}
