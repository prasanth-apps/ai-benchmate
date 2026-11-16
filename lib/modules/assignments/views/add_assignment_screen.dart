import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/assignment_controller.dart';

class AddAssignmentScreen extends StatefulWidget {
  const AddAssignmentScreen({super.key});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final AssignmentController controller = Get.find();

  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final subjectController = TextEditingController();

  DateTime? selectedDueDate;

  String selectedPriority = 'Medium';

  final Color primaryColor = const Color(0xFF673AB7);
  final Color headingColor = const Color(0xFF251442);

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  Future<void> pickDueDate() async {
    final today = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? today,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context)
              .copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDueDate = pickedDate;
      });
    }
  }

  void saveAssignment() {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDueDate == null) {
      Get.snackbar(
        'Due Date Required',
        'Please select an assignment due date.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    controller.addAssignment(
      title: titleController.text,
      description: descriptionController.text,
      subject: subjectController.text,
      dueDate: selectedDueDate!,
      priority: selectedPriority,
    );
  }

  InputDecoration fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEAE5F3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: const Text(
          'Add Assignment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assignment Details',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add your assignment information below.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Assignment title
              TextFormField(
                controller: titleController,
                decoration: fieldDecoration(
                  label: 'Assignment Title',
                  icon: Icons.assignment_outlined,
                  hint: 'Enter assignment title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter assignment title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Subject
              TextFormField(
                controller: subjectController,
                decoration: fieldDecoration(
                  label: 'Subject',
                  icon: Icons.menu_book_outlined,
                  hint: 'Enter subject name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Description
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: fieldDecoration(
                  label: 'Description',
                  icon: Icons.description_outlined,
                  hint: 'Enter assignment details',
                ),
              ),

              const SizedBox(height: 18),

              // Due date
              InkWell(
                onTap: pickDueDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEAE5F3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, color: primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedDueDate == null
                              ? 'Select Due Date'
                              : '${selectedDueDate!.day.toString().padLeft(2, '0')}/'
                                    '${selectedDueDate!.month.toString().padLeft(2, '0')}/'
                                    '${selectedDueDate!.year}',
                          style: TextStyle(
                            color: selectedDueDate == null
                                ? Colors.grey
                                : headingColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Priority
              Text(
                'Priority',
                style: TextStyle(
                  color: headingColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: selectedPriority,
                decoration: fieldDecoration(
                  label: 'Select Priority',
                  icon: Icons.flag_outlined,
                ),
                items: ['Low', 'Medium', 'High'].map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedPriority = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: saveAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Assignment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
