import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:healthify/controller/counter_controller.dart';
import 'package:healthify/routing/routes.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final CounterController controller = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hello Home Page', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Obx(() => Text('GetX Count: ${controller.count.value}', style: const TextStyle(fontSize: 18))),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: controller.increment,
              child: const Text('Increment Count'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.details),
              child: const Text('Go to Details Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
