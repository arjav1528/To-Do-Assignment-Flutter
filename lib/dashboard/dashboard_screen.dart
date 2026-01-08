import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../auth/auth_service.dart';
import '../models/task_model.dart';
import '../utils/app_logger.dart';
import 'add_task_bottom_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    final taskService = Provider.of<TaskService>(context, listen: false);
    try {
      await taskService.fetchTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tasks: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddTaskSheet() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => const AddTaskBottomSheet(),
    );

    if (result == true && mounted) {
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              AppLogger.info('Sign out button pressed from dashboard');
              await authService.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: taskService.isLoading && taskService.tasks.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : taskService.tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt_outlined,
                          size: 80.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No tasks yet',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Tap the + button to add your first task',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: taskService.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskService.tasks[index];
                      return _TaskTile(task: task);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        child: Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}

class _TaskTile extends StatefulWidget {
  final Task task;

  const _TaskTile({required this.task});

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> {
  bool _isToggling = false;

  Future<void> _handleToggle() async {
    if (_isToggling) return;

    setState(() {
      _isToggling = true;
    });

    try {
      final taskService = Provider.of<TaskService>(context, listen: false);
      await taskService.toggleTaskStatus(widget.task);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: GestureDetector(
          onTap: _handleToggle,
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: _isToggling
                ? Padding(
                    padding: EdgeInsets.all(8.w),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        task.isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                  )
                : Icon(
                    task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: task.isCompleted ? Colors.green : Colors.orange,
                  ),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16.sp,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  task.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
