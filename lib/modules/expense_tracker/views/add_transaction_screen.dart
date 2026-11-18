import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/finance_controller.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final FinanceController controller = Get.find();

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedType = 'Expense';
  String selectedCategory = 'Food';
  String selectedPaymentSource = 'Record Only';

  bool affectsBalance = false;

  DateTime selectedDate = DateTime.now();

  final categories = [
    'Food',
    'Travel',
    'Education',
    'Shopping',
    'Entertainment',
    'Health',
    'Salary',
    'Scholarship',
    'Other',
  ];

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void saveTransaction() {
    if (!formKey.currentState!.validate()) return;

    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) return;

    controller.addTransaction(
      title: titleController.text,
      amount: amount,
      category: selectedCategory,
      type: selectedType,
      description: descriptionController.text,
      date: selectedDate,
      paymentSource: selectedPaymentSource,
      affectsBalance: affectsBalance,
    );
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF673AB7);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: const Text('Add Transaction'),
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
                'Transaction Details',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF251442),
                ),
              ),
              const SizedBox(height: 22),

              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Income', 'Expense'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedType = value;
                    selectedCategory = value == 'Income' ? 'Salary' : 'Food';
                  });
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Monthly allowance',
                  prefixIcon: Icon(Icons.edit_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
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

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Payment Source',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF251442),
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: selectedPaymentSource,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(),
                ),
                items: ['Cash', 'Bank', 'Record Only'].map((source) {
                  return DropdownMenuItem(value: source, child: Text(source));
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedPaymentSource = value;
                    affectsBalance = value != 'Record Only';
                  });
                },
              ),

              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAE5F3)),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Update Available Balance',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    selectedPaymentSource == 'Record Only'
                        ? 'This transaction will not affect your balances.'
                        : 'Automatically update your $selectedPaymentSource balance.',
                  ),
                  value: affectsBalance,
                  activeThumbColor: purple,
                  onChanged: selectedPaymentSource == 'Record Only'
                      ? null
                      : (value) {
                          setState(() => affectsBalance = value);
                        },
                ),
              ),

              const SizedBox(height: 18),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month, color: purple),
                title: const Text('Transaction Date'),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                trailing: TextButton(
                  onPressed: pickDate,
                  child: const Text('Change'),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
