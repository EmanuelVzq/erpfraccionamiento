import 'package:flutter/material.dart';
import 'package:fraccionamiento/colors.dart';
import 'package:fraccionamiento/residentes_screen.dart';

class InicioScreen extends StatefulWidget {
  final List<String> roles; // ['admin'], ['mesa_directiva'], ['residente'], etc.

  const InicioScreen({super.key, required this.roles});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _currentIndex = 0;

  bool get isAdmin => widget.roles.contains('admin');
  bool get isMesa => widget.roles.contains('mesa_directiva');
  bool get isResidente => widget.roles.contains('residente');

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (isAdmin) {
      // admin: Inicio (0), Residentes (1), Mesa Directiva (2), Pagos (3), Avisos (4)
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
        Navigator.pushNamed(context, '/avisos');
      }
    } else if (isMesa) {
      // mesa_directiva: Inicio (0), Residentes (1), Avisos (2)
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResidentesScreen()),
        );
      } else if (index == 2) {
        Navigator.pushNamed(context, '/avisos');
      }
    } else if (isResidente) {
      // residente: Inicio (0), Pagos (1)
      if (index == 1) {
        Navigator.pushNamed(context, '/pagos');
      }
    }
  }

  List<BottomNavigationBarItem> _buildItems() {
    if (isAdmin) {
      // 5 pestañas
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Residentes'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Mesa Dir.'),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Pagos'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Avisos'),
      ];
    } else if (isMesa) {
      // 3 pestañas
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Residentes'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Avisos'),
      ];
    } else {
      // residente: 2 pestañas
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Pagos'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Para debug, puedes ver en consola qué roles trae el usuario
    print('📌 Roles en InicioScreen: ${widget.roles} (admin:$isAdmin mesa:$isMesa res:$isResidente)');

    return Scaffold(
      backgroundColor: AppColors.celesteClaro,
      appBar: AppBar(
        backgroundColor: AppColors.celesteVivo,
        title: const Text('Inicio'),
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
                  _boton(context, Icons.campaign, 'Ver Avisos', ruta: '/avisos'),
                  _boton(
                    context,
                    Icons.payments,
                    'Consultar Pagos',
                    ruta: '/pagos',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // importante para 5 ítems
        backgroundColor: AppColors.celesteNegro,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: _buildItems(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.amarillo,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
