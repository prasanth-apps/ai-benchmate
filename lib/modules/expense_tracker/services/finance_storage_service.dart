import 'package:get_storage/get_storage.dart';

import '../models/transaction_model.dart';
import '../models/fee_model.dart';

class FinanceStorageService {
  final GetStorage _storage = GetStorage();

  static const String _transactionsKey = 'benchmate_transactions';
  static const String _feesKey = 'benchmate_fees';
  static const String _cashBalanceKey = 'benchmate_cash_balance';
  static const String _bankBalanceKey = 'benchmate_bank_balance';
  // ---------------- TRANSACTIONS ----------------

  Future<void> addTransaction(TransactionModel transaction) async {
    final transactions = await getTransactions();

    transactions.insert(0, transaction);

    await _storage.write(
      _transactionsKey,
      transactions.map((item) => item.toMap()).toList(),
    );
  }

  Future<List<TransactionModel>> getTransactions() async {
    final data = _storage.read<List>(_transactionsKey);

    if (data == null) return [];

    return data.map((item) {
      return TransactionModel.fromMap(Map<String, dynamic>.from(item as Map));
    }).toList();
  }

  Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();

    transactions.removeWhere((item) => item.id == id);

    await _storage.write(
      _transactionsKey,
      transactions.map((item) => item.toMap()).toList(),
    );
  }

  // ---------------- FEES ----------------

  Future<void> addFee(FeeModel fee) async {
    final fees = await getFees();

    fees.insert(0, fee);

    await _storage.write(_feesKey, fees.map((item) => item.toMap()).toList());
  }

  Future<List<FeeModel>> getFees() async {
    final data = _storage.read<List>(_feesKey);

    if (data == null) return [];

    return data.map((item) {
      return FeeModel.fromMap(Map<String, dynamic>.from(item as Map));
    }).toList();
  }

  Future<void> updateFee(FeeModel updatedFee) async {
    final fees = await getFees();

    final index = fees.indexWhere((item) => item.id == updatedFee.id);

    if (index == -1) return;

    fees[index] = updatedFee;

    await _storage.write(_feesKey, fees.map((item) => item.toMap()).toList());
  }

  Future<void> deleteFee(String id) async {
    final fees = await getFees();

    fees.removeWhere((item) => item.id == id);

    await _storage.write(_feesKey, fees.map((item) => item.toMap()).toList());
  }

  // Get cash balance
  double getCashBalance() {
    return (_storage.read<num>(_cashBalanceKey) ?? 0).toDouble();
  }

  // Get bank balance
  double getBankBalance() {
    return (_storage.read<num>(_bankBalanceKey) ?? 0).toDouble();
  }

  // Update cash balance
  Future<void> updateCashBalance(double amount) async {
    await _storage.write(_cashBalanceKey, amount);
  }

  // Update bank balance
  Future<void> updateBankBalance(double amount) async {
    await _storage.write(_bankBalanceKey, amount);
  }
}
