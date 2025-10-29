import 'package:flutter/material.dart';
import 'package:fraccionamiento/colors.dart';
import 'package:fraccionamiento/inicio_screen.dart';
import 'package:fraccionamiento/login_screen.dart';
import 'package:fraccionamiento/pagos_screen.dart';
import 'package:fraccionamiento/registro_screen.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Residentes App',
      theme: ThemeData(
        primaryColor: AppColors.celesteNegro,
        scaffoldBackgroundColor: AppColors.celesteClaro,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amarillo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/registro': (_) => const RegistroScreen(),
        '/inicio': (_) => const InicioScreen(),
        '/pagos': (_) => const PagosScreen(),
      },
    );
  }
}
