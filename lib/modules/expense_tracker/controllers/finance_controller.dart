import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';
import '../models/fee_model.dart';
import '../services/finance_storage_service.dart';

class FinanceController extends GetxController {
  final FinanceStorageService _storageService = FinanceStorageService();

  final List<TransactionModel> transactions = [];
  final List<FeeModel> fees = [];

  double cashBalance = 0.0;
  double bankBalance = 0.0;

  bool isLoading = false;
  String selectedFilter = 'All';

  final Uuid _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    loadFinanceData();
  }

  // Load transactions, fees and balances.
  Future<void> loadFinanceData() async {
    try {
      isLoading = true;
      update();

      final transactionData = await _storageService.getTransactions();
      final feeData = await _storageService.getFees();

      cashBalance = _storageService.getCashBalance();
      bankBalance = _storageService.getBankBalance();

      transactions.assignAll(transactionData);
      fees.assignAll(feeData);
    } catch (e) {
      debugPrint('FINANCE LOAD ERROR: $e');
      Get.snackbar('Error', 'Could not load finance data.');
    } finally {
      isLoading = false;
      update();
    }
  }

  // Manually edit cash balance.
  Future<void> updateCashBalance(double amount) async {
    if (amount < 0) {
      Get.snackbar('Invalid Amount', 'Balance cannot be negative.');
      return;
    }

    try {
      await _storageService.updateCashBalance(amount);
      cashBalance = amount;
      update();
    } catch (e) {
      debugPrint('CASH BALANCE UPDATE ERROR: $e');
      Get.snackbar('Error', 'Could not update cash balance.');
    }
  }

  // Manually edit bank balance.
  Future<void> updateBankBalance(double amount) async {
    if (amount < 0) {
      Get.snackbar('Invalid Amount', 'Balance cannot be negative.');
      return;
    }

    try {
      await _storageService.updateBankBalance(amount);
      bankBalance = amount;
      update();
    } catch (e) {
      debugPrint('BANK BALANCE UPDATE ERROR: $e');
      Get.snackbar('Error', 'Could not update bank balance.');
    }
  }

  // Add income or expense.
  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
    required String description,
    required DateTime date,
    String paymentSource = 'Record Only',
    bool affectsBalance = false,
  }) async {
    try {
      if (amount <= 0) {
        Get.snackbar('Invalid Amount', 'Enter an amount greater than zero.');
        return;
      }

      if (affectsBalance &&
          paymentSource != 'Cash' &&
          paymentSource != 'Bank') {
        Get.snackbar(
          'Invalid Payment Source',
          'Choose Cash or Bank to update a balance.',
        );
        return;
      }

      if (affectsBalance &&
          type == 'Expense' &&
          paymentSource == 'Cash' &&
          amount > cashBalance) {
        Get.snackbar(
          'Insufficient Cash',
          'Your recorded cash balance is not enough.',
        );
        return;
      }

      if (affectsBalance &&
          type == 'Expense' &&
          paymentSource == 'Bank' &&
          amount > bankBalance) {
        Get.snackbar(
          'Insufficient Bank Balance',
          'Your recorded bank balance is not enough.',
        );
        return;
      }

      final transaction = TransactionModel(
        id: _uuid.v4(),
        title: title.trim(),
        amount: amount,
        category: category,
        type: type,
        description: description.trim(),
        date: date,
        createdAt: DateTime.now(),
        paymentSource: paymentSource,
        affectsBalance: affectsBalance,
      );

      await _storageService.addTransaction(transaction);

      // Update the selected balance only when requested.
      if (affectsBalance) {
        final adjustment = type == 'Income' ? amount : -amount;

        if (paymentSource == 'Cash') {
          cashBalance += adjustment;
          await _storageService.updateCashBalance(cashBalance);
        } else if (paymentSource == 'Bank') {
          bankBalance += adjustment;
          await _storageService.updateBankBalance(bankBalance);
        }
      }

      transactions.insert(0, transaction);
      update();

      Get.back();

      Get.snackbar(
        'Success',
        '$type recorded successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('TRANSACTION ADD ERROR: $e');
      Get.snackbar('Error', 'Could not save transaction.');
    }
  }

  // Reverse the effect of a transaction on its balance.
  Future<void> _reverseTransactionBalance(TransactionModel transaction) async {
    if (!transaction.affectsBalance) return;

    final adjustment = transaction.type == 'Income'
        ? -transaction.amount
        : transaction.amount;

    if (transaction.paymentSource == 'Cash') {
      cashBalance += adjustment;
      await _storageService.updateCashBalance(cashBalance);
    } else if (transaction.paymentSource == 'Bank') {
      bankBalance += adjustment;
      await _storageService.updateBankBalance(bankBalance);
    }
  }

  // Add a fee.
  Future<void> addFee({
    required String title,
    required String description,
    required double amount,
    required DateTime dueDate,
  }) async {
    try {
      if (amount <= 0) {
        Get.snackbar('Invalid Amount', 'Enter an amount greater than zero.');
        return;
      }

      final fee = FeeModel(
        id: _uuid.v4(),
        title: title.trim(),
        description: description.trim(),
        amount: amount,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );

      await _storageService.addFee(fee);

      fees.insert(0, fee);
      update();

      Get.back();

      Get.snackbar(
        'Success',
        'Fee record added successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('FEE ADD ERROR: $e');
      Get.snackbar('Error', 'Could not save fee.');
    }
  }

  // Change fee payment status.
  Future<void> toggleFeePayment(FeeModel fee) async {
    try {
      final updatedFee = fee.copyWith(isPaid: !fee.isPaid);

      await _storageService.updateFee(updatedFee);

      final index = fees.indexWhere((item) => item.id == fee.id);

      if (index != -1) {
        fees[index] = updatedFee;
      }

      update();
    } catch (e) {
      debugPrint('FEE UPDATE ERROR: $e');
      Get.snackbar('Error', 'Could not update fee status.');
    }
  }

  // Delete transaction and reverse its balance effect.
  Future<void> deleteTransaction(String id) async {
    try {
      final index = transactions.indexWhere((item) => item.id == id);

      if (index == -1) return;

      final transaction = transactions[index];

      await _reverseTransactionBalance(transaction);
      await _storageService.deleteTransaction(id);

      transactions.removeAt(index);

      update();

      Get.snackbar('Deleted', 'Transaction deleted successfully.');
    } catch (e) {
      debugPrint('TRANSACTION DELETE ERROR: $e');
      Get.snackbar('Error', 'Could not delete transaction.');
    }
  }

  // Delete fee.
  Future<void> deleteFee(String id) async {
    try {
      await _storageService.deleteFee(id);

      fees.removeWhere((item) => item.id == id);

      update();

      Get.snackbar('Deleted', 'Fee record deleted successfully.');
    } catch (e) {
      debugPrint('FEE DELETE ERROR: $e');
      Get.snackbar('Error', 'Could not delete fee.');
    }
  }

  // Change transaction filter.
  void changeFilter(String filter) {
    selectedFilter = filter;
    update();
  }

  // Filter transactions.
  List<TransactionModel> get filteredTransactions {
    if (selectedFilter == 'Income' || selectedFilter == 'Expense') {
      return transactions.where((item) => item.type == selectedFilter).toList();
    }

    return transactions;
  }

  // Financial calculations.
  double get totalIncome {
    return transactions
        .where((item) => item.type == 'Income')
        .fold(0.0, (total, item) => total + item.amount);
  }

  double get totalExpenses {
    return transactions
        .where((item) => item.type == 'Expense')
        .fold(0.0, (total, item) => total + item.amount);
  }

  double get totalAvailableBalance => cashBalance + bankBalance;

  // Fee calculations.
  double get totalFees {
    return fees.fold(0.0, (total, fee) => total + fee.amount);
  }

  double get paidFees {
    return fees
        .where((fee) => fee.isPaid)
        .fold(0.0, (total, fee) => total + fee.amount);
  }

  double get pendingFees {
    return fees
        .where((fee) => !fee.isPaid)
        .fold(0.0, (total, fee) => total + fee.amount);
  }

  int get pendingFeeCount => fees.where((fee) => !fee.isPaid).length;

  int get paidFeeCount => fees.where((fee) => fee.isPaid).length;
}
