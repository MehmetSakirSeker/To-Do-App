import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../model/task_model.dart';
import '../model/task_status.dart';

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
class TaskRepository {
  final DatabaseService dbService;

  TaskRepository(this.dbService);

  Future<List<TaskResponse>> getAllTasks() async {
    final db = await dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableTasks,
    );
    return maps.map((map) => TaskResponse.fromMap(map)).toList();
  }

  Future<List<TaskResponse>> getTasksByStatus(TaskStatus status) async {
    final allTasks = await getAllTasks();
    return allTasks.where((task) => task.status == status).toList();
  }

  Future<TaskResponse> getTaskById(String taskId) async {
    final db = await dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableTasks,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [taskId],
      limit: 1,
    );

    if (maps.isEmpty) {
      throw Exception('Task with id $taskId not found');
    }
    return TaskResponse.fromMap(maps.first);
  }

  Future<TaskResponse> createTask(TaskCreateRequest request) async {
    final db = await dbService.database;
    final id = await db.insert(DatabaseConstants.tableTasks, {
      DatabaseConstants.columnTitle: request.title,
      DatabaseConstants.columnDescription: request.description,
      DatabaseConstants.columnStartDate: request.startDate.toIso8601String(),
      DatabaseConstants.columnEndDate: request.endDate.toIso8601String(),
      DatabaseConstants.columnIsCompleted: 0,
    });

    return TaskResponse(
      id: id.toString(),
      title: request.title,
      description: request.description,
      startDate: request.startDate,
      endDate: request.endDate,
      isCompleted: false,
    );
  }

  Future<TaskResponse> updateTask(
    String taskId,
    TaskUpdateRequest request,
  ) async {
    final db = await dbService.database;
    await db.update(
      DatabaseConstants.tableTasks,
      {
        DatabaseConstants.columnTitle: request.title,
        DatabaseConstants.columnDescription: request.description,
        DatabaseConstants.columnStartDate: request.startDate.toIso8601String(),
        DatabaseConstants.columnEndDate: request.endDate.toIso8601String(),
      },
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [taskId],
    );
    return getTaskById(taskId);
  }

  Future<TaskResponse> completeTask(String taskId, bool isCompleted) async {
    final db = await dbService.database;
    await db.update(
      DatabaseConstants.tableTasks,
      {DatabaseConstants.columnIsCompleted: isCompleted ? 1 : 0},
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [taskId],
    );
    return getTaskById(taskId);
  }

  Future<void> deleteTask(String taskId) async {
    final db = await dbService.database;
    await db.delete(
      DatabaseConstants.tableTasks,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [taskId],
    );
  }
}

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

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
