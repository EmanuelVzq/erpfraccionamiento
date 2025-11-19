import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fraccionamiento/colors.dart';
import 'package:fraccionamiento/inicio_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _cargando = false;
  String? _error;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.100.161:3002', // ⚠️ en físico usa la IP de tu PC
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<void> _login() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final correo = _correoController.text.trim();
    final contrasena = _contrasenaController.text;

    try {
      final response = await _dio.post(
        '/login',
        data: {
          'correo': correo,
          'contrasena': contrasena,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // roles viene como List<dynamic>
        final List<dynamic> rolesDyn = data['roles'] as List<dynamic>;
        final roles = rolesDyn.map((e) => e.toString()).toList();

        // Determinar tipoUsuario para la navbar
        late String tipoUsuario;
        if (roles.contains('admin')) {
          tipoUsuario = 'admin';
        } else if (roles.contains('mesa_directiva')) {
          tipoUsuario = 'mesa_directiva';
        } else {
          // default si solo es residente u otro
          tipoUsuario = 'residente';
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InicioScreen(roles: roles),
          ),
        );
      } else {
        setState(() {
          _error = 'Credenciales incorrectas o usuario no encontrado';
        });
      }
    } on DioException catch (e) {
      setState(() {
        if (e.response?.statusCode == 401) {
          _error = 'Credenciales incorrectas o usuario no encontrado';
        } else {
          _error = 'Error de conexión con el servidor';
        }
      });
    } catch (_) {
      setState(() {
        _error = 'Error inesperado';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home, color: AppColors.celesteNegro, size: 60),
              const SizedBox(height: 10),
              Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.celesteNegro,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _correoController,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: const TextStyle(color: AppColors.celesteVivo),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _cargando ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.celesteNegro,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _cargando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Iniciar Sesión',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/registro'),
                    child: const Text('Registrarse'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Recuperar Contraseña'),
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
