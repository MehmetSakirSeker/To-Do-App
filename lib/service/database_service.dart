import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../model/task_response.dart';

// Database config
class DatabaseConstants {
  static const databaseName = 'todobase.db';
  static const databaseVersion = 3;
  static const tableTasks = 'tasks';

  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnStartDate = 'startDate';
  static const columnEndDate = 'endDate';
  static const columnIsCompleted = 'isCompleted';
}

// Handles all CRUD database operations and Business logic

// Handles database initialization and connection management
class DatabaseService {
  //Singelton for accesing db
  DatabaseService._privateConstructor();

  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableTasks} (
        ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.columnTitle} TEXT NOT NULL,
        ${DatabaseConstants.columnDescription} TEXT,
        ${DatabaseConstants.columnStartDate} TEXT NOT NULL,
        ${DatabaseConstants.columnEndDate} TEXT NOT NULL,
        ${DatabaseConstants.columnIsCompleted} INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
  Future<List<TaskResponse>> getAllTasks() async {
    final db = await database;
    final result = await db.query(DatabaseConstants.tableTasks);

    return result.map((map) => TaskResponse.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

}
