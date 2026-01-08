import '../models/task_model.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';
import 'package:flutter/foundation.dart';

class TaskService extends ChangeNotifier {
  final _supabase = SupabaseService.client;
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  String? get _userId => SupabaseService.currentUser?.id;

  Future<void> fetchTasks() async {
    if (_userId == null) {
      AppLogger.warning('Cannot fetch tasks: User not authenticated');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      AppLogger.info('Fetching tasks for user: $_userId');
      
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      _tasks = (response as List)
          .map<Task>((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.success('Fetched ${_tasks.length} tasks');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching tasks', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Task> addTask({
    required String title,
    String status = 'pending',
  }) async {
    if (_userId == null) {
      AppLogger.error('Cannot add task: User not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      AppLogger.info('Adding new task: $title');

      final taskData = {
        'user_id': _userId!,
        'title': title,
        'status': status,
      };

      final response = await _supabase
          .from('tasks')
          .insert(taskData)
          .select()
          .single();

      final newTask = Task.fromJson(Map<String, dynamic>.from(response));
      
      _tasks.insert(0, newTask);
      AppLogger.success('Task added successfully: ${newTask.id}');
      
      notifyListeners();
      return newTask;
    } catch (e, stackTrace) {
      AppLogger.error('Error adding task: $title', e, stackTrace);
      rethrow;
    }
  }

  Future<void> refreshTasks() async {
    await fetchTasks();
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required String newStatus,
  }) async {
    if (_userId == null) {
      AppLogger.error('Cannot update task: User not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      AppLogger.info('Updating task status: $taskId to $newStatus');

      final updateData = {
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('tasks')
          .update(updateData)
          .eq('id', taskId)
          .eq('user_id', _userId!);

      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex] = _tasks[taskIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        AppLogger.success('Task status updated successfully: $taskId');
        notifyListeners();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error updating task status: $taskId', e, stackTrace);
      rethrow;
    }
  }

  Future<void> toggleTaskStatus(Task task) async {
    final newStatus = task.isCompleted ? 'pending' : 'completed';
    await updateTaskStatus(taskId: task.id, newStatus: newStatus);
  }

  Future<void> deleteTask(String taskId) async {
    if (_userId == null) {
      AppLogger.error('Cannot delete task: User not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      AppLogger.info('Deleting task: $taskId');

      await _supabase
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', _userId!);

      _tasks.removeWhere((task) => task.id == taskId);
      AppLogger.success('Task deleted successfully: $taskId');
      
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting task: $taskId', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateTask({
    required String taskId,
    String? title,
    String? status,
  }) async {
    if (_userId == null) {
      AppLogger.error('Cannot update task: User not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      AppLogger.info('Updating task: $taskId');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) {
        updateData['title'] = title;
      }
      if (status != null) {
        updateData['status'] = status;
      }

      final response = await _supabase
          .from('tasks')
          .update(updateData)
          .eq('id', taskId)
          .eq('user_id', _userId!)
          .select()
          .single();

      final updatedTask = Task.fromJson(Map<String, dynamic>.from(response));
      
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex] = updatedTask;
        AppLogger.success('Task updated successfully: $taskId');
        notifyListeners();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error updating task: $taskId', e, stackTrace);
      rethrow;
    }
  }
}
