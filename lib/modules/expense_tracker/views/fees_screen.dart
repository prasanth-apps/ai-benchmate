import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/finance_controller.dart';
import '../models/fee_model.dart';
import 'add_fee_screen.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  static const Color purple = Color(0xFF673AB7);
  static const Color heading = Color(0xFF251442);

  String formatAmount(double amount) => '₹${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    Get.find<FinanceController>();

    return GetBuilder<FinanceController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F7FC),
          appBar: AppBar(
            title: const Text('Fees Tracker'),
            backgroundColor: purple,
            foregroundColor: Colors.white,
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildSummary(controller),
                    Expanded(
                      child: controller.fees.isEmpty
                          ? const Center(child: Text('No fee records yet.'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: controller.fees.length,
                              itemBuilder: (context, index) {
                                return _buildFeeCard(
                                  context,
                                  controller,
                                  controller.fees[index],
                                );
                              },
                            ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Get.to(() => const AddFeeScreen());
            },
            backgroundColor: purple,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Fee'),
          ),
        );
      },
    );
  }

  Widget _buildSummary(FinanceController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Fees', style: TextStyle(color: Colors.grey)),
              Text(
                formatAmount(controller.totalFees),
                style: const TextStyle(
                  color: heading,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _summaryItem('Paid', controller.paidFees, Colors.green),
              ),
              Expanded(
                child: _summaryItem(
                  'Pending',
                  controller.pendingFees,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        Text(
          formatAmount(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeCard(
    BuildContext context,
    FinanceController controller,
    FeeModel fee,
  ) {
    final statusColor = fee.isPaid ? Colors.green : Colors.orange;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFEAE5F3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    fee.title,
                    style: const TextStyle(
                      color: heading,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(context, controller, fee);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            if (fee.description.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  fee.description,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatAmount(fee.amount),
                    style: const TextStyle(
                      color: heading,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  fee.isPaid ? 'Paid' : 'Pending',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Due: ${fee.dueDate.day}/${fee.dueDate.month}/${fee.dueDate.year}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.toggleFeePayment(fee);
                  },
                  child: Text(fee.isPaid ? 'Mark Pending' : 'Mark Paid'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    FinanceController controller,
    FeeModel fee,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Fee?'),
        content: Text('Delete "${fee.title}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteFee(fee.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
