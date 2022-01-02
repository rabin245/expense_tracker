import 'package:expense_tracker/transaction.dart';
import 'package:flutter/material.dart';
import 'loading_circle.dart';
import 'plus_button.dart';
import 'top_card.dart';
import 'package:provider/provider.dart';
import 'transaction_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //collect user inputs
  final _textControllerAmount = TextEditingController();
  final _textControllerItem = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    context.read<TransactionProvider>().init();
  }

  //new transaction
  void _newTransaction() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Text('NEW TRANSACTION'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text('Expense'),
                        Switch(
                          value: _isIncome,
                          onChanged: (newValue) {
                            setState(() {
                              _isIncome = newValue;
                            });
                          },
                        ),
                        const Text('Income'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _textControllerAmount,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Amount',
                              ),
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Enter an amount';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'For what?',
                            ),
                            controller: _textControllerItem,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    _textControllerAmount.clear();
                    _textControllerItem.clear();
                    Navigator.of(context).pop();
                  },
                  color: Colors.grey[600],
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                MaterialButton(
                  color: Colors.grey[600],
                  child: const Text(
                    'Enter',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _enterTransaction();
                      _textControllerAmount.clear();
                      _textControllerItem.clear();
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  //enter the new transaction
  void _enterTransaction() {
    context.read<TransactionProvider>().insert(
          _textControllerItem.text,
          _textControllerAmount.text,
          _isIncome,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (_, transactionProvider, __) => Scaffold(
        backgroundColor: Colors.grey[300],
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              TopNeuCard(
                balance: (transactionProvider.getTotalIncome -
                        transactionProvider.getTotalExpense)
                    .toStringAsFixed(2),
                income: transactionProvider.getTotalIncome.toStringAsFixed(2),
                expense: transactionProvider.getTotalExpense.toStringAsFixed(2),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: transactionProvider.isLoading
                            ? const LoadingCircle()
                            : ListView.builder(
                                itemBuilder: (context, index) => MyTransaction(
                                  transactionName: transactionProvider
                                      .getTransactionValue(index, 0),
                                  money: transactionProvider
                                      .getTransactionValue(index, 1),
                                  expenseOrIncome: transactionProvider
                                      .getTransactionValue(index, 2),
                                ),
                                itemCount: transactionProvider
                                    .currentTransactionsLength,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PlusButton(
                function: _newTransaction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
