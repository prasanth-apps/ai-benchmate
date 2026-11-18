
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/finance_controller.dart';

class AddFeeScreen extends StatefulWidget {
  const AddFeeScreen({super.key});

  @override
  State<AddFeeScreen> createState() => _AddFeeScreenState();
}

class _AddFeeScreenState extends State<AddFeeScreen> {
  final FinanceController controller = Get.find();

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? selectedDueDate;

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDueDate() async {
    final today = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? today,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 5),
    );

    if (picked != null) {
      setState(() {
        selectedDueDate = picked;
      });
    }
  }

  void saveFee() {
    if (!formKey.currentState!.validate()) return;

    if (selectedDueDate == null) {
      Get.snackbar(
        'Due Date Required',
        'Please select the fee due date.',
      );
      return;
    }

    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) return;

    controller.addFee(
      title: titleController.text,
      description: descriptionController.text,
      amount: amount,
      dueDate: selectedDueDate!,
    );
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF673AB7);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: const Text('Add Fee'),
        backgroundColor: purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fee Details',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF251442),
                ),
              ),

              const SizedBox(height: 22),

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Fee Title',
                  hintText: 'e.g. Semester Tuition Fee',
                  prefixIcon: Icon(Icons.school_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter fee title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');

                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add additional fee details',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              InkWell(
                onTap: pickDueDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEAE5F3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: purple,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedDueDate == null
                              ? 'Select Due Date'
                              : '${selectedDueDate!.day}/'
                                '${selectedDueDate!.month}/'
                                '${selectedDueDate!.year}',
                          style: TextStyle(
                            color: selectedDueDate == null
                                ? Colors.grey
                                : const Color(0xFF251442),
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: saveFee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Fee',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
