import 'package:flutter/material.dart';
import 'transaction_provider.dart';
import 'google_sheets_api.dart';
import 'homepage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleSheetsApi().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider<TransactionProvider>(
          create: (context) => TransactionProvider(GoogleSheetsApi.worksheet),
          child: const HomePage()),
    );
  }
}
