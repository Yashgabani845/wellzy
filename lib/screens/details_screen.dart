import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hello Details Page', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
