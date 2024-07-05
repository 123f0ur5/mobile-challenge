import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tractian_challenge/view/screens/company_view.dart';
import 'package:tractian_challenge/view_model/assets_tree_view_model.dart';
import 'package:tractian_challenge/view_model/company_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CompanyViewModel(), lazy: true),
        ChangeNotifierProvider(create: (context) => AssetsTreeViewModel(), lazy: true)
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Desafio Mobile',
        home: CompanyView(),
      ),
    );
  }
}
