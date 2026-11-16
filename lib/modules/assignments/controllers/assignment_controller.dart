
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/assignment_model.dart';
import '../services/assignment_storage_service.dart';

class AssignmentController extends GetxController {
  final AssignmentStorageService _storageService =
      AssignmentStorageService();

  final List<AssignmentModel> assignments = [];

  bool isLoading = false;

  String selectedFilter = 'All';

  final Uuid _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    loadAssignments();
  }

  Future<void> loadAssignments() async {
    try {
      isLoading = true;
      update();

      final result = await _storageService.getAssignments();

      assignments.assignAll(result);
    } catch (e) {
      debugPrint('ASSIGNMENT LOAD ERROR: $e');
      Get.snackbar('Error', 'Could not load assignments.');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> addAssignment({
    required String title,
    required String description,
    required String subject,
    required DateTime dueDate,
    required String priority,
  }) async {
    try {
      final assignment = AssignmentModel(
        id: _uuid.v4(),
        title: title.trim(),
        description: description.trim(),
        subject: subject.trim(),
        dueDate: dueDate,
        priority: priority,
        createdAt: DateTime.now(),
      );

      await _storageService.addAssignment(assignment);

      assignments.insert(0, assignment);
      update();

      Get.back();

      Get.snackbar(
        'Success',
        'Assignment added successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('ASSIGNMENT ADD ERROR: $e');
      Get.snackbar('Error', 'Could not add assignment.');
    }
  }

  Future<void> toggleCompletion(AssignmentModel assignment) async {
    try {
      final updatedAssignment = assignment.copyWith(
        isCompleted: !assignment.isCompleted,
      );

      await _storageService.updateAssignment(updatedAssignment);

      final index = assignments.indexWhere(
        (item) => item.id == assignment.id,
      );

      if (index != -1) {
        assignments[index] = updatedAssignment;
      }

      update();
    } catch (e) {
      debugPrint('ASSIGNMENT UPDATE ERROR: $e');
      Get.snackbar('Error', 'Could not update assignment.');
    }
  }

  Future<void> deleteAssignment(String id) async {
    try {
      await _storageService.deleteAssignment(id);

      assignments.removeWhere((item) => item.id == id);

      update();

      Get.snackbar(
        'Deleted',
        'Assignment deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('ASSIGNMENT DELETE ERROR: $e');
      Get.snackbar('Error', 'Could not delete assignment.');
    }
  }

  void changeFilter(String filter) {
    selectedFilter = filter;
    update();
  }

  List<AssignmentModel> get filteredAssignments {
    switch (selectedFilter) {
      case 'Pending':
        return assignments
            .where((item) => !item.isCompleted)
            .toList();

      case 'Completed':
        return assignments
            .where((item) => item.isCompleted)
            .toList();

      default:
        return assignments.toList();
    }
  }

  int get pendingCount =>
      assignments.where((item) => !item.isCompleted).length;

  int get completedCount =>
      assignments.where((item) => item.isCompleted).length;
}
