import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:fraccionamiento/colors.dart';
import 'package:fraccionamiento/login_screen.dart';
import 'package:fraccionamiento/registro_screen.dart';
import 'package:fraccionamiento/avisos_screen.dart';
import 'package:fraccionamiento/pagos_screen.dart';
import 'package:fraccionamiento/area_comun_screen.dart';
import 'package:fraccionamiento/services/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushService.initGlobal();

  Stripe.publishableKey =
      "pk_test_51SWmkKFFf8vKAWyUeuIU57DSP0L1T57zoMJyEqcYGYIAen012W9p2OmtuxTn6nHMMm7NhBEXb5cesoIEFDbLTrqq00HpqwEdxW";
  await Stripe.instance.applySettings();

  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Residentes App',
      debugShowCheckedModeBanner: false,
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
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/registro': (_) => const RegistroScreen(),
      },
      onGenerateRoute: (settings) {
        final args = (settings.arguments as Map<String, dynamic>?) ?? {};

        if (settings.name == '/avisos') {
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

        if (settings.name == '/pagos') {
          final idPersona = args['idPersona'] as int? ?? 0;
          final idUsuario = args['idUsuario'] as int? ?? 0;

          return MaterialPageRoute(
            builder: (_) => PagosScreen(
              idPersona: idPersona,
              idUsuario: idUsuario,
            ),
          );
        }

        if (settings.name == '/area_comun') {
          final idPersona = args['idPersona'] as int? ?? 0;
          final idUsuario = args['idUsuario'] as int? ?? 0;

          return MaterialPageRoute(
            builder: (_) => AreaComunScreen(
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
