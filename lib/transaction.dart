import 'package:flutter/material.dart';

class MyTransaction extends StatelessWidget {
  const MyTransaction({
    Key? key,
    required this.transactionName,
    required this.money,
    required this.expenseOrIncome,
  }) : super(key: key);
  final String transactionName;
  final String money;
  final String expenseOrIncome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(15),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey[500]),
                    child: const Center(
                      child: Icon(
                        Icons.attach_money_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    transactionName,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Text(
                (expenseOrIncome == 'expense' ? '-' : '+') + '\$' + money,
                style: TextStyle(
                  color:
                      expenseOrIncome == 'expense' ? Colors.red : Colors.green,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
