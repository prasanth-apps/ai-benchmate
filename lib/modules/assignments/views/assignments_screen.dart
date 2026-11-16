import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/assignment_controller.dart';
import '../models/assignment_model.dart';
import 'add_assignment_screen.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  static const Color primaryColor = Color(0xFF673AB7);
  static const Color backgroundColor = Color(0xFFF8F7FC);
  static const Color headingColor = Color(0xFF251442);

  @override
  Widget build(BuildContext context) {
    Get.put(AssignmentController());

    return GetBuilder<AssignmentController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text(
              'Assignments',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              _buildSummary(controller),
              _buildFilters(controller),
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.filteredAssignments.isEmpty
                    ? _buildEmptyState(controller)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: controller.filteredAssignments.length,
                        itemBuilder: (context, index) {
                          return _buildAssignmentCard(
                            context,
                            controller,
                            controller.filteredAssignments[index],
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Get.to(() => const AddAssignmentScreen());
            },
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Assignment'),
          ),
        );
      },
    );
  }

  Widget _buildSummary(AssignmentController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              'Total',
              controller.assignments.length.toString(),
              Icons.assignment_outlined,
            ),
          ),
          Expanded(
            child: _summaryItem(
              'Pending',
              controller.pendingCount.toString(),
              Icons.pending_actions,
            ),
          ),
          Expanded(
            child: _summaryItem(
              'Completed',
              controller.completedCount.toString(),
              Icons.task_alt,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 25),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildFilters(AssignmentController controller) {
    const filters = ['All', 'Pending', 'Completed'];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = controller.selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => controller.changeFilter(filter),
            selectedColor: primaryColor,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : headingColor,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: isSelected ? primaryColor : const Color(0xFFEAE5F3),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AssignmentController controller) {
    final filter = controller.selectedFilter;

    final message = switch (filter) {
      'Pending' => 'No pending assignments.',
      'Completed' => 'No completed assignments yet.',
      _ => 'Start by adding your first assignment.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 65,
              color: Colors.deepPurple.shade100,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nothing here yet!',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    AssignmentController controller,
    AssignmentModel assignment,
  ) {
    final priorityColor = switch (assignment.priority) {
      'High' => Colors.red,
      'Medium' => Colors.orange,
      _ => Colors.green,
    };

    final dueDate =
        '${assignment.dueDate.day.toString().padLeft(2, '0')}/'
        '${assignment.dueDate.month.toString().padLeft(2, '0')}/'
        '${assignment.dueDate.year}';

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEAE5F3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: assignment.isCompleted
                          ? Colors.grey
                          : headingColor,
                      decoration: assignment.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(context, controller, assignment);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              assignment.subject,
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (assignment.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                assignment.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
                Text(
                  dueDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    assignment.priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Checkbox(
                  value: assignment.isCompleted,
                  activeColor: primaryColor,
                  onChanged: (_) {
                    controller.toggleCompletion(assignment);
                  },
                ),
                const Text('Done', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AssignmentController controller,
    AssignmentModel assignment,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Assignment?'),
        content: Text('Are you sure you want to delete "${assignment.title}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAssignment(assignment.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
