
import 'package:get_storage/get_storage.dart';

import '../models/assignment_model.dart';

class AssignmentStorageService {
  final GetStorage _storage = GetStorage();

  static const String _assignmentsKey = 'benchmate_assignments';

  // Save a new assignment.
  Future<void> addAssignment(AssignmentModel assignment) async {
    final assignments = await getAssignments();

    assignments.insert(0, assignment);

    await _storage.write(
      _assignmentsKey,
      assignments.map((assignment) => assignment.toMap()).toList(),
    );
  }

  // Retrieve all assignments.
  Future<List<AssignmentModel>> getAssignments() async {
    final data = _storage.read<List>(_assignmentsKey);

    if (data == null) return [];

    return data.map((item) {
      return AssignmentModel.fromMap(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  // Update an existing assignment.
  Future<void> updateAssignment(AssignmentModel updatedAssignment) async {
    final assignments = await getAssignments();

    final index = assignments.indexWhere(
      (assignment) => assignment.id == updatedAssignment.id,
    );

    if (index == -1) return;

    assignments[index] = updatedAssignment;

    await _storage.write(
      _assignmentsKey,
      assignments.map((assignment) => assignment.toMap()).toList(),
    );
  }

  // Delete an assignment.
  Future<void> deleteAssignment(String id) async {
    final assignments = await getAssignments();

    assignments.removeWhere((assignment) => assignment.id == id);

    await _storage.write(
      _assignmentsKey,
      assignments.map((assignment) => assignment.toMap()).toList(),
    );
  }
}
