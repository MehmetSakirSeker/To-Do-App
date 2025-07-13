import 'package:get/get.dart';
import '../model/task_response.dart';
import '../model/task_status.dart';
import '../model/task_update_request.dart';
import '../repository/task_repository.dart';
import '../service/database_service.dart';

class MainController extends GetxController {
  static MainController get to => Get.find();

  final taskRepository = TaskRepository(DatabaseService.instance);

  RxList<TaskResponse> allTasks = <TaskResponse>[].obs;
  RxList<TaskResponse> tasks = <TaskResponse>[].obs;

  Rxn<TaskStatus> currentFilter = Rxn<TaskStatus>();
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshTasks();
  }

  Future<void> refreshTasks() async {
    allTasks.value = await DatabaseService.instance.getAllTasks();
    _applyFilters();
  }

  void filterTasks(TaskStatus? status) {
    currentFilter.value = status;
    _applyFilters();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  bool isUrgent(TaskResponse task) {
    final now = DateTime.now();
    final diff = task.endDate.difference(now);
    return diff.inHours < 24 && !diff.isNegative;
  }

  void _applyFilters() {
    final filtered =
        allTasks.where((task) {
          final statusMatches =
              currentFilter.value == null || task.status == currentFilter.value;
          final searchMatches =
              task.title.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              task.description.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              );
          return statusMatches && searchMatches;
        }).toList();

    tasks.value = filtered;
  }

  Future<void> completeTask(String taskId) async {
    await taskRepository.completeTask(taskId, true);
    await refreshTasks();
  }

  Future<void> markTaskIncomplete(String taskId) async {
    await taskRepository.completeTask(taskId, false);
    await refreshTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await taskRepository.deleteTask(taskId);
    await refreshTasks();
  }

  Future<void> updateTask(String taskId, TaskUpdateRequest updatedTask) async {
    await taskRepository.updateTask(taskId, updatedTask);
    await refreshTasks();
  }
}
