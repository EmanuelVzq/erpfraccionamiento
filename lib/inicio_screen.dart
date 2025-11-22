// inicio_screen.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fraccionamiento/avisos_historial_screen.dart';
import 'package:fraccionamiento/avisos_screen.dart';
import 'package:fraccionamiento/colors.dart';
import 'package:fraccionamiento/residentes_screen.dart';

class InicioScreen extends StatefulWidget {
  final List<String> roles;
  final int idPersona;
  final int idUsuario;
  final String tipoUsuario;

  const InicioScreen({
    super.key,
    required this.roles,
    required this.idPersona,
    required this.idUsuario,
    required this.tipoUsuario,
  });

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  static const String BASE_URL = "http://192.168.1.85:3002";

  int _currentIndex = 0;
  int unread = 0;

  late final Dio dio;
  Timer? _timer;

  bool get isAdmin => widget.roles.contains('admin');
  bool get isMesa => widget.roles.contains('mesa_directiva');
  bool get isResidente => widget.roles.contains('residente');

  @override
  void initState() {
    super.initState();
    dio = Dio(BaseOptions(baseUrl: BASE_URL));
    cargarUnread();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => cargarUnread());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> cargarUnread() async {
    try {
      final res = await dio.get("/avisos/unread/${widget.idPersona}");
      setState(() => unread = res.data["unread"] ?? 0);
    } catch (e) {
      print("❌ Error cargando unread: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);

    if (isAdmin) {
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResidentesScreen()),
        );
      } else if (index == 2) {
        Navigator.pushNamed(context, '/mesa_directiva');
      } else if (index == 3) {
        Navigator.pushNamed(context, '/pagos');
      } else if (index == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AvisosScreen(
              roles: widget.roles,
              idPersona: widget.idPersona,
              idUsuario: widget.idUsuario,
            ),
          ),
        ).then((_) => cargarUnread());
      }
    } else if (isMesa) {
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResidentesScreen()),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AvisosScreen(
              roles: widget.roles,
              idPersona: widget.idPersona,
              idUsuario: widget.idUsuario,
            ),
          ),
        ).then((_) => cargarUnread());
      }
    } else if (isResidente) {
      if (index == 1) Navigator.pushNamed(context, '/pagos');
    }
  }

  List<BottomNavigationBarItem> _buildItems() {
    if (isAdmin) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Residentes'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Mesa Dir.'),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Pagos'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Avisos',
        ),
      ];
    } else if (isMesa) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Residentes'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Avisos',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Pagos'),
      ];
    }
  }

  void _cerrarSesion() {
    // Si luego guardas token en SharedPreferences,
    // aquí también lo borras.
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celesteClaro,
      appBar: AppBar(
        backgroundColor: AppColors.celesteVivo,
        title: const Text('Inicio'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AvisosHistorialScreen(idPersona: widget.idPersona),
                    ),
                  );
                  cargarUnread();
                },
              ),
              if (unread > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o casa...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  _boton(context, Icons.directions_car, 'Registrar Visitas'),
                  _boton(context, Icons.event, 'Reservar Áreas'),
                  _boton(
                    context,
                    Icons.campaign,
                    'Ver Avisos',
                    ruta: '/avisos',
                  ),
                  _boton(
                    context,
                    Icons.payments,
                    'Consultar Pagos',
                    ruta: '/pagos',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ✅ BOTÓN CERRAR SESIÓN
            ElevatedButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Cerrar sesión",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.celesteNegro,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.celesteNegro,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: _buildItems(),
      ),
    );
  }

  Widget _boton(
    BuildContext context,
    IconData icono,
    String texto, {
    String? ruta,
  }) {
    return GestureDetector(
      onTap: ruta != null ? () => Navigator.pushNamed(context, ruta) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 40, color: AppColors.celesteVivo),
            const SizedBox(height: 10),
            Text(texto, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
