import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'task_model.dart';
import 'task_status.dart';

class DatabaseService {
  static const _databaseName = 'todobase.db';
  static const _databaseVersion = 1;

  static const tableTasks = 'tasks';

  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  // CRUD Operations

  Future<List<TaskResponse>> listTasks() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableTasks);
    return List.generate(maps.length, (i) => TaskResponse.fromMap(maps[i]));
  }

  Future<List<TaskResponse>> listTasksByStatus(TaskStatus status) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      where: 'status = ?',
      whereArgs: [status.toString().split('.').last],
      orderBy: 'endDate ASC',
    );
    return List.generate(maps.length, (i) => TaskResponse.fromMap(maps[i]));
  }

  Future<TaskResponse> getTask(String taskId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      where: 'id = ?',
      whereArgs: [taskId],
    );
    if (maps.isNotEmpty) {
      return TaskResponse.fromMap(maps.first);
    } else {
      throw Exception('Task not found');
    }
  }

  Future<TaskResponse> createTask(TaskCreateRequest request) async {
    final db = await instance.database;

    // Determine initial status based on dates
    final now = DateTime.now();
    final status = now.isAfter(request.endDate)
        ? TaskStatus.OVERDUE
        : TaskStatus.UPCOMING;

    final id = await db.insert(
      tableTasks,
      {
        ...request.toMap(),
        'status': status.toString().split('.').last,
      },
    );


    return TaskResponse(
      id: id.toString(),
      title: request.title,
      description: request.description,
      startDate: request.startDate,
      endDate: request.endDate,
      status: status,
    );
  }


  Future<TaskResponse> updateTask(String taskId, TaskUpdateRequest request) async {
    final db = await instance.database;

    final currentTask = await getTask(taskId);

    final now = DateTime.now();
    final newStatus = now.isAfter(request.endDate)
        ? TaskStatus.OVERDUE
        : (currentTask.status == TaskStatus.COMPLETED
        ? TaskStatus.COMPLETED
        : TaskStatus.UPCOMING);

    await db.update(
      tableTasks,
      {
        'title': request.title,
        'description': request.description,
        'startDate': request.startDate.toIso8601String(),
        'endDate': request.endDate.toIso8601String(),
        'status': newStatus.toString().split('.').last,
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );

    return getTask(taskId);
  }

  Future<TaskResponse> completeTask(String taskId) async {
    final db = await instance.database;
    await db.update(
      tableTasks,
      {'status': TaskStatus.COMPLETED.toString().split('.').last},
      where: 'id = ?',
      whereArgs: [taskId],
    );
    return getTask(taskId);
  }

  Future<void> deleteTask(String taskId) async {
    final db = await instance.database;
    await db.delete(
      tableTasks,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}