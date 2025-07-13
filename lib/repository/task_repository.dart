import '../model/task_create_request.dart';
import '../model/task_response.dart';
import '../model/task_status.dart';
import '../model/task_update_request.dart';
import '../service/database_service.dart';

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
