import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/finance_controller.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';
import 'fees_screen.dart';

class ExpenseTrackerScreen extends StatelessWidget {
  const ExpenseTrackerScreen({super.key});

  static const Color primaryColor = Color(0xFF673AB7);
  static const Color backgroundColor = Color(0xFFF8F7FC);
  static const Color headingColor = Color(0xFF251442);
  static const Color borderColor = Color(0xFFEAE5F3);

  String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    Get.put(FinanceController());

    return GetBuilder<FinanceController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text(
              'Expense & Fees Tracker',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  Get.to(() => const FeesScreen());
                },
                icon: const Icon(Icons.school_outlined),
                tooltip: 'Manage Fees',
              ),
            ],
          ),

          body: controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                )
              : RefreshIndicator(
                  onRefresh: controller.loadFinanceData,
                  color: primaryColor,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                    children: [
                      _buildBalanceCard(controller),

                      const SizedBox(height: 20),

                      _buildSummaryCards(controller),

                      const SizedBox(height: 28),

                      _buildSectionHeader(
                        'Recent Transactions',
                        'Track your income and spending',
                      ),

                      const SizedBox(height: 14),

                      _buildFilters(controller),

                      const SizedBox(height: 14),

                      if (controller.filteredTransactions.isEmpty)
                        _buildEmptyState()
                      else
                        ...controller.filteredTransactions
                            .take(20)
                            .map(
                              (transaction) => _buildTransactionCard(
                                context,
                                controller,
                                transaction,
                              ),
                            ),
                    ],
                  ),
                ),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Get.to(() => const AddTransactionScreen());
            },
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Transaction',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // AVAILABLE BALANCE CARD
  // --------------------------------------------------

  Widget _buildBalanceCard(FinanceController controller) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7445C5), Color(0xFF51269D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL AVAILABLE BALANCE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            formatAmount(controller.totalAvailableBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 22),

          Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _balanceDetail(
                  title: 'Cash Balance',
                  amount: controller.cashBalance,
                  icon: Icons.payments_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _balanceDetail(
                  title: 'Bank Balance',
                  amount: controller.bankBalance,
                  icon: Icons.account_balance_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditBalanceDialog(controller),
              icon: const Icon(Icons.edit_outlined, size: 17),
              label: const Text(
                'Edit Available Balance',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white60, size: 14),
              SizedBox(width: 6),
              Text(
                'Manage your cash and bank balances separately',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceDetail({
    required String title,
    required double amount,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          formatAmount(amount),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // EDIT BALANCE DIALOG
  // --------------------------------------------------

  Future<void> _showEditBalanceDialog(FinanceController controller) async {
    final result = await Get.dialog<bool>(
      _EditBalanceDialog(controller: controller),
      barrierDismissible: false,
    );

    if (result == true) {
      Get.snackbar(
        'Balance Updated',
        'Your cash and bank balances have been saved.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: headingColor,
        margin: const EdgeInsets.all(14),
      );
    }
  }

  // --------------------------------------------------
  // INCOME AND EXPENSE SUMMARY
  // --------------------------------------------------

  Widget _buildSummaryCards(FinanceController controller) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: 'Total Income',
            amount: controller.totalIncome,
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF269B58),
            background: const Color(0xFFEAF7EF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            title: 'Total Expenses',
            amount: controller.totalExpenses,
            icon: Icons.trending_down_rounded,
            color: const Color(0xFFE34D4D),
            background: const Color(0xFFFFEEEE),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            formatAmount(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SECTION HEADER
  // --------------------------------------------------

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: headingColor,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // TRANSACTION FILTERS
  // --------------------------------------------------

  Widget _buildFilters(FinanceController controller) {
    const filters = ['All', 'Income', 'Expense'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = controller.selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) => controller.changeFilter(filter),
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : headingColor,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: selected ? primaryColor : borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --------------------------------------------------
  // TRANSACTION CARD
  // --------------------------------------------------

  Widget _buildTransactionCard(
    BuildContext context,
    FinanceController controller,
    TransactionModel transaction,
  ) {
    final isIncome = transaction.type == 'Income';
    final color = isIncome ? const Color(0xFF269B58) : const Color(0xFFE34D4D);

    final date =
        '${transaction.date.day.toString().padLeft(2, '0')}/'
        '${transaction.date.month.toString().padLeft(2, '0')}/'
        '${transaction.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        leading: CircleAvatar(
          radius: 21,
          backgroundColor: color.withValues(alpha: 0.10),
          child: Icon(
            isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: color,
          ),
        ),
        title: Text(
          transaction.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: headingColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${transaction.category} • $date',
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${formatAmount(transaction.amount)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _confirmDelete(context, controller, transaction);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 19),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFB8A9D5)),
          SizedBox(height: 14),
          Text(
            'No transactions yet',
            style: TextStyle(
              color: headingColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Add your first income or expense to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DELETE CONFIRMATION
  // --------------------------------------------------

  void _confirmDelete(
    BuildContext context,
    FinanceController controller,
    TransactionModel transaction,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Transaction?'),
        content: Text(
          'Are you sure you want to delete "${transaction.title}"?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteTransaction(transaction.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ==================================================
// SEPARATE STATEFUL BALANCE DIALOG
// ==================================================

class _EditBalanceDialog extends StatefulWidget {
  final FinanceController controller;

  const _EditBalanceDialog({required this.controller});

  @override
  State<_EditBalanceDialog> createState() => _EditBalanceDialogState();
}

class _EditBalanceDialogState extends State<_EditBalanceDialog> {
  static const Color purple = Color(0xFF673AB7);
  static const Color heading = Color(0xFF251442);

  final formKey = GlobalKey<FormState>();

  late final TextEditingController cashController;
  late final TextEditingController bankController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    cashController = TextEditingController(
      text: widget.controller.cashBalance.toStringAsFixed(2),
    );

    bankController = TextEditingController(
      text: widget.controller.bankBalance.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    cashController.dispose();
    bankController.dispose();
    super.dispose();
  }

  String? validateBalance(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');

    if (amount == null || amount < 0) {
      return 'Enter a valid balance';
    }

    return null;
  }

  Future<void> saveBalance() async {
    if (!formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      isSaving = true;
    });

    try {
      final cash = double.parse(cashController.text.trim());
      final bank = double.parse(bankController.text.trim());

      await widget.controller.updateCashBalance(cash);
      await widget.controller.updateBankBalance(bank);

      if (!mounted) return;

      Get.back(result: true);
    } catch (e) {
      debugPrint('BALANCE SAVE ERROR: $e');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      Get.snackbar('Error', 'Could not save balances.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog heading.
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EAFE),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: purple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Balances',
                            style: TextStyle(
                              color: heading,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Update your available money',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: isSaving
                          ? null
                          : () => Get.back(result: false),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Cash balance field.
                const Text(
                  'CASH BALANCE',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 9),

                TextFormField(
                  controller: cashController,
                  enabled: !isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter cash balance',
                    prefixIcon: const Icon(
                      Icons.payments_outlined,
                      color: purple,
                    ),
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: const Color(0xFFF9F7FD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: Color(0xFFEAE5F3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: Color(0xFFEAE5F3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: purple, width: 1.5),
                    ),
                  ),
                  validator: validateBalance,
                ),

                const SizedBox(height: 19),

                // Bank balance field.
                const Text(
                  'BANK BALANCE',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 9),

                TextFormField(
                  controller: bankController,
                  enabled: !isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter bank balance',
                    prefixIcon: const Icon(
                      Icons.account_balance_outlined,
                      color: purple,
                    ),
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: const Color(0xFFF9F7FD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: Color(0xFFEAE5F3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: Color(0xFFEAE5F3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: purple, width: 1.5),
                    ),
                  ),
                  validator: validateBalance,
                ),

                const SizedBox(height: 20),

                // Information.
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F1FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: purple, size: 18),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Your total available balance will be calculated automatically from cash and bank balances.',
                          style: TextStyle(
                            color: heading,
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Save button.
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveBalance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            height: 21,
                            width: 21,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
