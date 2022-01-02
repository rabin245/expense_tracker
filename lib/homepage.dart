import 'dart:async';

import 'package:expense_tracker/google_sheets_api.dart';
import 'package:expense_tracker/transaction.dart';
import 'package:flutter/material.dart';

import 'loading_circle.dart';
import 'plus_button.dart';
import 'top_card.dart';

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
    GoogleSheetsApi.insert(
      _textControllerItem.text,
      _textControllerAmount.text,
      _isIncome,
    );
    setState(() {});
  }

  //wait for the data to be getched from google sheets
  bool timerHasStarted = false;
  void startLoading() {
    timerHasStarted = true;
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (GoogleSheetsApi.loading == false) {
          setState(() {
            timer.cancel();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // start loading until the data arrives
    if (GoogleSheetsApi.loading == true && timerHasStarted == false) {
      startLoading();
    }
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TopNeuCard(
              balance: (GoogleSheetsApi.calculateIncome() -
                      GoogleSheetsApi.calculateExpense())
                  .toString(),
              income: GoogleSheetsApi.calculateIncome().toString(),
              expense: GoogleSheetsApi.calculateExpense().toString(),
            ),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                        child: GoogleSheetsApi.loading
                            ? const LoadingCircle()
                            : ListView.builder(
                                itemBuilder: (context, index) => MyTransaction(
                                  transactionName: GoogleSheetsApi
                                      .currentTransactions[index][0],
                                  money: GoogleSheetsApi
                                      .currentTransactions[index][1],
                                  expenseOrIncome: GoogleSheetsApi
                                      .currentTransactions[index][2],
                                ),
                                itemCount:
                                    GoogleSheetsApi.currentTransactions.length,
                              ))
                  ],
                ),
              ),
            ),
            PlusButton(
              function: _newTransaction,
            ),
          ],
        ),
      ),
    );
  }
}
