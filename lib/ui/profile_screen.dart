import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fraccionamiento/controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.to;

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: Obx(() {
        final user = auth.user.value;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: user.photoUrl.isNotEmpty
                    ? NetworkImage(user.photoUrl)
                    : const AssetImage("assets/avatar_default.png")
                          as ImageProvider,
              ),
              const SizedBox(height: 20),
              Text(user.name, style: const TextStyle(fontSize: 22)),
              Text(user.email, style: const TextStyle(color: Colors.grey)),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () => auth.logout(),
                child: const Text("Cerrar sesión"),
              ),
            ],
          ),
        );
      }),
    );
  }
}
