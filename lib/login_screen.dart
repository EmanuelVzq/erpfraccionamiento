import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fraccionamiento/colors.dart';
import 'package:fraccionamiento/inicio_screen.dart';
import 'package:fraccionamiento/services/push_service.dart';
import 'package:fraccionamiento/session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String baseUrl = "https://apifraccionamiento.onrender.com";

  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  bool _cargando = false;
  String? _error;

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
      responseType: ResponseType.json,
      validateStatus: (s) => s != null && s >= 200 && s < 500,
    ),
  );

  int _asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  List<String> _asStringList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return const [];
  }

  String _serverMsg(Response res) {
    final d = res.data;
    if (d == null) return "";
    if (d is String) return d;
    if (d is Map && d["error"] != null) return d["error"].toString();
    return d.toString();
  }

  Future<void> _login() async {
    final correo = _correoController.text.trim();
    final contrasena = _contrasenaController.text;

    if (correo.isEmpty || contrasena.isEmpty) {
      setState(() => _error = "Ingresa correo y contraseña.");
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final res = await _dio.post(
        "/login",
        data: {"correo": correo, "contrasena": contrasena},
      );

      if (res.statusCode != 200) {
        final msg = _serverMsg(res);
        setState(() {
          _error = (res.statusCode == 401)
              ? "Credenciales incorrectas o usuario no encontrado."
              : "Error del servidor (HTTP ${res.statusCode}). ${msg.isNotEmpty ? msg : ""}".trim();
        });
        return;
      }

      if (res.data is! Map) {
        setState(() => _error = "Respuesta inválida del servidor (no es JSON objeto).");
        return;
      }

      final data = Map<String, dynamic>.from(res.data as Map);

      final roles = _asStringList(data["roles"]);
      final idPersona = _asInt(data["id_persona"]);
      final idUsuario = _asInt(data["id_usuario"]);

      // ✅ CLAVE: no dejes avanzar con 0
      if (idPersona <= 0 || idUsuario <= 0) {
        setState(() {
          _error =
              "Login OK pero IDs inválidos (id_persona=$idPersona, id_usuario=$idUsuario).\n"
              "Revisa tu endpoint /login para que regrese enteros correctos.";
        });
        return;
      }

      // ✅ Guardar sesión (para que Pagos/Mantenimiento jamás queden en 0)
      await Session.save(idPersona: idPersona, idUsuario: idUsuario);

      // init push sin romper login
      try {
        await PushService.init(idPersona: idPersona, baseUrl: baseUrl);
      } catch (e) {
        debugPrint("⚠️ PushService.init falló pero sigo login: $e");
      }

      final tipoUsuario = roles.contains("admin")
          ? "admin"
          : (roles.contains("mesa_directiva") ? "mesa_directiva" : "residente");

      if (!mounted) return;

      debugPrint("✅ Login OK -> idPersona=$idPersona, idUsuario=$idUsuario, roles=$roles");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InicioScreen(
            roles: roles,
            idPersona: idPersona,
            idUsuario: idUsuario,
            tipoUsuario: tipoUsuario,
          ),
        ),
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data?.toString();

      setState(() {
        _error = status == 401
            ? "Credenciales incorrectas o usuario no encontrado."
            : "Error de conexión/servidor. ${status != null ? "HTTP $status" : ""} ${body ?? ""}".trim();
      });
    } catch (e) {
      setState(() => _error = "Error inesperado: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
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
                "Bienvenido",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.celesteNegro,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Correo",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  labelStyle: const TextStyle(color: AppColors.celesteVivo),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
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
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Iniciar Sesión", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
