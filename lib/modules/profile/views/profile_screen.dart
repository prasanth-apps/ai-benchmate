import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_benchmate/modules/profile/controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());

  static const Color primaryColor = Color(0xFF673AB7);
  static const Color backgroundColor = Color(0xFFF8F7FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF251442),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 48,
                backgroundColor: primaryColor.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.person_rounded,
                  size: 55,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                controller.studentName,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF251442),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                controller.email,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),

              const SizedBox(height: 35),

              _profileCard(
                icon: Icons.person_outline_rounded,
                title: 'Name',
                value: controller.studentName,
              ),

              const SizedBox(height: 14),

              _profileCard(
                icon: Icons.email_outlined,
                title: 'Email Address',
                value: controller.email,
              ),

              const SizedBox(height: 14),

              _profileCard(
                icon: Icons.verified_user_outlined,
                title: 'Account Status',
                value: 'Authenticated',
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: Get.back,
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              controller.logout();
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E1EF)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 25),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF251442),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
