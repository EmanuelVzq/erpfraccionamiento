import 'package:flutter/material.dart';
import 'package:fraccionamiento/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home, color: AppColors.celesteNegro, size: 60),
              const SizedBox(height: 10),
              Text('Bienvenido',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.celesteNegro)),
              const SizedBox(height: 40),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: const TextStyle(color: AppColors.celesteVivo),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/inicio'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.celesteNegro,
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text('Iniciar Sesión', style: TextStyle(color: Colors.white),),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/registro'),
                      child: const Text('Registrarse')),
                  TextButton(onPressed: () {}, child: const Text('Recuperar Contraseña'))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
