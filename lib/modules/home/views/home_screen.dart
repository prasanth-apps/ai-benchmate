import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import 'widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryColor = Color(0xFF673AB7);
  static const Color backgroundColor = Color(0xFFF8F7FC);

  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final String studentName = currentUser?.displayName ?? 'Student';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'AI BenchMate',
          style: TextStyle(
            color: Color(0xFF251442),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.account_circle_outlined,
              color: primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $studentName 👋',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF251442),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your personal companion for a smarter student life.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Everything you need for student life.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Learn smarter. Stay organized. Be prepared.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Explore Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF251442),
                ),
              ),

              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
                children: [
                  FeatureCard(
                    title: 'AI Mate',
                    subtitle: 'Learn, solve, summarise and revise with AI',
                    icon: Icons.psychology_rounded,
                    onTap: () => Get.toNamed(AppRoutes.homework),
                  ),

                  FeatureCard(
                    title: 'Assignments',
                    subtitle: 'Manage your assignments',
                    icon: Icons.assignment_rounded,
                    onTap: () {},
                  ),
                  FeatureCard(
                    title: 'Expense & Fees Tracker',
                    subtitle: 'Manage your student finances',
                    icon: Icons.account_balance_wallet_rounded,
                    onTap: () {},
                  ),
                  FeatureCard(
                    title: 'Document Vault',
                    subtitle: 'Store and access your important documents',
                    icon: Icons.folder_special_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
