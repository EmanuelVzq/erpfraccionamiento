import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fraccionamiento/colors.dart';
import 'package:fraccionamiento/login_screen.dart';
import 'package:fraccionamiento/pagos_screen.dart';
import 'package:fraccionamiento/registro_screen.dart';
import 'package:fraccionamiento/avisos_screen.dart';
import 'package:fraccionamiento/services/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushService.initGlobal();

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
        '/pagos': (_) => const PagosScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/avisos') {
          final args = (settings.arguments as Map<String, dynamic>?) ?? {};
          final roles = (args['roles'] as List<dynamic>? ?? []).cast<String>();
          final idPersona = args['idPersona'] as int? ?? 0;
          final idUsuario = args['idUsuario'] as int? ?? 0;

          return MaterialPageRoute(
            builder: (_) => AvisosScreen(
              roles: roles,
              idPersona: idPersona,
              idUsuario: idUsuario,
            ),
          );
        }
        return null;
      },
    );
  }
}
