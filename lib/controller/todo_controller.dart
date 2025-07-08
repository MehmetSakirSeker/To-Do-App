import 'package:get/get.dart';
import '../model/task_status.dart';
import '../service/database_service.dart';
import '../model/task_model.dart';

class TodoController extends GetxController {
  static TodoController get to => Get.find();

  final taskRepository = TaskRepository(DatabaseService.instance);

  RxList<TaskResponse> tasks = <TaskResponse>[].obs;
  Rxn<TaskStatus> currentFilter = Rxn<TaskStatus>();

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final allTasks = await taskRepository.getAllTasks();
    tasks.value = allTasks;
  }

  Future<void> filterTasks(TaskStatus? status) async {
    currentFilter.value = status;
    if (status == null) {
      await loadTasks();
    } else {
      final filtered = await taskRepository.getTasksByStatus(status);
      tasks.value = filtered;
    }
  }
  Future<void> markTaskIncomplete(String taskId) async {
    await taskRepository.completeTask(taskId, false); // false yaparak tamamlanmadı yap
    await filterTasks(currentFilter.value);
  }



  Future<void> completeTask(String taskId) async {
    await taskRepository.completeTask(taskId, true);
    await filterTasks(currentFilter.value);
  }

  Future<void> deleteTask(String taskId) async {
    await taskRepository.deleteTask(taskId);
    await filterTasks(currentFilter.value);
  }

  Future<void> updateTask(String taskId, TaskUpdateRequest updatedTask) async {
    await taskRepository.updateTask(taskId, updatedTask);
    await filterTasks(currentFilter.value);
  }

  Future<void> refreshTasks() async {
    await filterTasks(currentFilter.value);
  }
}
