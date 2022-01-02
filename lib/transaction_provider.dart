import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';

class TransactionProvider with ChangeNotifier {
  TransactionProvider(this._worksheet);
  // variables to keep track of transactions
  final Worksheet? _worksheet;
  int _numberOfTransactions = 0;
  final List<List<dynamic>> _currentTransactions = [];
  bool _loading = true;
  double totalIncome = 0;
  double totalExpense = 0;

  bool get isLoading => _loading;

  int get currentTransactionsLength => _currentTransactions.length;

  String getTransactionValue(int index, int valueNum) =>
      _currentTransactions[index][valueNum];

  double get getTotalIncome => totalIncome;

  double get getTotalExpense => totalExpense;

  //  initialize the spreadsheet
  Future init() async {
    if (_worksheet == null) {
      print('worksheet is null!');
      return;
    }
    countRows();
  }

  // count the number of transactions
  Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: _numberOfTransactions + 1)) !=
        '') {
      _numberOfTransactions++;
    }

    //  now we know how many transactions to load, now load them
    loadTransactions();
  }

  // load existing transactions from the sheet
  Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < _numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);
      if (_currentTransactions.length < _numberOfTransactions) {
        _currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    _calculateIncome();
    _calculateExpense();
    _loading = false;

    notifyListeners();
  }

  // insert a new transaction
  Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    _numberOfTransactions++;
    _currentTransactions.add([
      name,
      amount,
      _isIncome ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome ? 'income' : 'expense',
    ]);
    _calculateIncome();
    _calculateExpense();

    notifyListeners();
  }

  //calculate total income
  void _calculateIncome() {
    totalIncome = 0;
    for (int i = 0; i < _currentTransactions.length; i++) {
      if (_currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(_currentTransactions[i][1]);
      }
    }
    notifyListeners();
  }

  //calculate total expense
  void _calculateExpense() {
    totalExpense = 0;
    for (int i = 0; i < _currentTransactions.length; i++) {
      if (_currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(_currentTransactions[i][1]);
      }
    }
    notifyListeners();
  }
}
