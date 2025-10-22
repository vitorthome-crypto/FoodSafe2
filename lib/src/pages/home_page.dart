import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/profile_repository.dart';
import '../widgets/custom_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodSafe'),
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text('Bem-vindo ao FoodSafe!'),
      ),
    );
  }
}