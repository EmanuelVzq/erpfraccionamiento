import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:fraccionamiento/colors.dart';
import 'package:fraccionamiento/login_screen.dart';
import 'package:fraccionamiento/registro_screen.dart';
import 'package:fraccionamiento/avisos_screen.dart';
import 'package:fraccionamiento/pagos_screen.dart';
import 'package:fraccionamiento/area_comun_screen.dart';
import 'package:fraccionamiento/services/push_service.dart';
import 'package:fraccionamiento/session.dart';
import 'package:fraccionamiento/inicio_screen.dart';
import 'package:fraccionamiento/controllers/auth_controller.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushService.initGlobal();

  Stripe.publishableKey =
      "pk_test_51SWmkKFFf8vKAWyUeuIU57DSP0L1T57zoMJyEqcYGYIAen012W9p2OmtuxTn6nHMMm7NhBEXb5cesoIEFDbLTrqq00HpqwEdxW";
  await Stripe.instance.applySettings();

  // ⚙️ Registrar el AuthController para usarlo en toda la app
  Get.put(AuthController(), permanent: true);

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

      // 👇 YA NO usamos initialRoute '/login'
      home: const AuthWrapper(),

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
            builder: (_) =>
                PagosScreen(idPersona: idPersona, idUsuario: idUsuario),
          );
        }

        if (settings.name == '/area_comun') {
          final idPersona = args['idPersona'] as int? ?? 0;
          final idUsuario = args['idUsuario'] as int? ?? 0;

          return MaterialPageRoute(
            builder: (_) =>
                AreaComunScreen(idPersona: idPersona, idUsuario: idUsuario),
          );
        }

        return null;
      },
    );
  }
}

// Pequeño modelo interno para decidir a dónde ir
class _StartInfo {
  final bool loggedIn;
  final int idPersona;
  final int idUsuario;
  final List<String> roles;
  final String tipoUsuario;

  const _StartInfo({
    required this.loggedIn,
    required this.idPersona,
    required this.idUsuario,
    required this.roles,
    required this.tipoUsuario,
  });
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<_StartInfo> _load() async {
    // 1) Revisar si hay sesión de tu backend (SharedPreferences)
    final savedIdPersona = await Session.idPersona();
    final savedIdUsuario = await Session.idUsuario();

    if (savedIdPersona > 0 && savedIdUsuario > 0) {
      // aquí podrías guardar también roles en SharedPreferences,
      // por ahora asumimos 'residente'
      return _StartInfo(
        loggedIn: true,
        idPersona: savedIdPersona,
        idUsuario: savedIdUsuario,
        roles: const ['residente'],
        tipoUsuario: 'backend',
      );
    }

    // 2) Revisar si Firebase tiene un usuario (Google)
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      // sincroniza con tu AuthController para que tenga la foto / nombre
      AuthController.to.setFromFirebase(fbUser);

      return const _StartInfo(
        loggedIn: true,
        idPersona: 0,
        idUsuario: 0,
        roles: ['residente'],
        tipoUsuario: 'google',
      );
    }

    // 3) Nadie logueado → ir al login
    return const _StartInfo(
      loggedIn: false,
      idPersona: 0,
      idUsuario: 0,
      roles: [],
      tipoUsuario: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StartInfo>(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final info = snapshot.data!;

        if (!info.loggedIn) {
          return const LoginScreen();
        }

        return InicioScreen(
          roles: info.roles,
          idPersona: info.idPersona,
          idUsuario: info.idUsuario,
          tipoUsuario: info.tipoUsuario,
        );
      },
    );
  }
}
