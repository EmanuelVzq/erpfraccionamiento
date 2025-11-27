// inicio_screen.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:fraccionamiento/avisos_historial_screen.dart';
import 'package:fraccionamiento/avisos_screen.dart';
import 'package:fraccionamiento/colors.dart';
import 'package:fraccionamiento/residentes_screen.dart';
import 'package:fraccionamiento/area_comun_screen.dart';

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
  static const String baseUrl = "https://apifraccionamiento.onrender.com";

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
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
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
      if (!mounted) return;
      setState(() {
        unread = (res.data is Map) ? (res.data["unread"] ?? 0) : 0;
      });
    } catch (e) {
      // ignore: avoid_print
      print("❌ Error cargando unread: $e");
    }
  }

  void _cerrarSesion() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _irAAreasComunes() async {
    // ✅ AreaComunScreen SOLO recibe idPersona e idUsuario (NO dio, NO roles)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AreaComunScreen(
          idPersona: widget.idPersona,
          idUsuario: widget.idUsuario,
        ),
      ),
    );
  }

  Future<void> _irAAvisos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AvisosScreen(
          roles: widget.roles,
          idPersona: widget.idPersona,
          idUsuario: widget.idUsuario,
        ),
      ),
    );
    cargarUnread();
  }

  void _goPagos() {
    Navigator.pushNamed(
      context,
      '/pagos',
      arguments: {
        "idPersona": widget.idPersona,
        "idUsuario": widget.idUsuario,
      },
    );
  }

  void _goMesaDirectiva() {
    Navigator.pushNamed(context, '/mesa_directiva');
  }

  void _goResidentes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResidentesScreen()),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);

    if (isAdmin) {
      // Admin: [Inicio, Residentes, Mesa, Pagos, Áreas, Avisos]
      switch (index) {
        case 1:
          _goResidentes();
          break;
        case 2:
          _goMesaDirectiva();
          break;
        case 3:
          _goPagos();
          break;
        case 4:
          _irAAreasComunes();
          break;
        case 5:
          _irAAvisos();
          break;
      }
      return;
    }

    if (isMesa) {
      // Mesa: [Inicio, Residentes, Áreas, Avisos]
      switch (index) {
        case 1:
          _goResidentes();
          break;
        case 2:
          _irAAreasComunes();
          break;
        case 3:
          _irAAvisos();
          break;
      }
      return;
    }

    // Residente: [Inicio, Pagos, Áreas]
    switch (index) {
      case 1:
        _goPagos();
        break;
      case 2:
        _irAAreasComunes();
        break;
    }
  }

  List<BottomNavigationBarItem> _buildItems() {
    if (isAdmin) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Residentes'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Mesa Dir.'),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Pagos'),
        BottomNavigationBarItem(icon: Icon(Icons.event_available), label: 'Áreas'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Avisos'),
      ];
    } else if (isMesa) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Residentes'),
        BottomNavigationBarItem(icon: Icon(Icons.event_available), label: 'Áreas'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Avisos'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Pagos'),
        BottomNavigationBarItem(icon: Icon(Icons.event_available), label: 'Áreas'),
      ];
    }
  }

  Drawer? _buildDrawer() {
    // ✅ Drawer solo para Residente y Mesa
    if (isAdmin) return null;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const ListTile(
              title: Text(
                "Menú",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text("Reservar Áreas Comunes"),
              onTap: () async {
                Navigator.pop(context);
                await _irAAreasComunes();
              },
            ),
            if (isResidente)
              ListTile(
                leading: const Icon(Icons.payments),
                title: const Text("Pagos"),
                onTap: () {
                  Navigator.pop(context);
                  _goPagos();
                },
              ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Avisos"),
              onTap: () async {
                Navigator.pop(context);
                await _irAAvisos();
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: _cerrarSesion,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celesteClaro,
      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: AppColors.celesteNegro,
        title: const Text('Inicio', style: TextStyle(color: Colors.white),),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white,),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AvisosHistorialScreen(idPersona: widget.idPersona),
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
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  _boton(context, Icons.directions_car, 'Registrar Visitas', onTap: () {}),
                  _boton(context, Icons.event_available, 'Reservar Áreas', onTap: _irAAreasComunes),
                  _boton(context, Icons.campaign, 'Ver Avisos', onTap: _irAAvisos),
                  _boton(context, Icons.payments, 'Consultar Pagos', onTap: _goPagos),
                ],
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.celesteNegro,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
