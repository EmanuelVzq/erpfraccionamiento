import 'package:flutter/material.dart';
import 'package:fraccionamiento/colors.dart';
import 'package:fraccionamiento/residentes_screen.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _boton(context, Icons.campaign, 'Ver Avisos'),
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
        backgroundColor: AppColors.celesteNegro,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ResidentesScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Residentes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.amarillo,
        onPressed: () {},
        child: const Icon(Icons.add),
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
