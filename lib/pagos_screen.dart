import 'package:flutter/material.dart';
import 'package:fraccionamiento/colors.dart';

class PagosScreen extends StatelessWidget {
  const PagosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.celesteNegro,
        title: const Text('Administración de Pagos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filtro('Pendientes', true),
                _filtro('Historial de Pagos', false),
              ],
            ),
            const SizedBox(height: 25),
            const Text('Gráfico de Ingresos Anuales',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Icon(Icons.pie_chart, color: AppColors.celesteNegro, size: 100),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _boton('Exportar PDF', AppColors.celesteNegro),
                _boton('Exportar Excel', AppColors.celesteVivo),
              ],
            ),
            const SizedBox(height: 20),
            _recibo('2024-005', '\$424.00', 'PENDIENTE'),
            _recibo('2024-004', '\$123.00', 'PAGADO'),
          ],
        ),
      ),
    );
  }

  Widget _filtro(String texto, bool activo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: activo ? AppColors.amarillo : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(texto, style: TextStyle(color: activo ? Colors.black : Colors.grey[700])),
    );
  }

  Widget _boton(String texto, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(texto, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _recibo(String id, String monto, String estado) {
    final bool pagado = estado == 'PAGADO';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recibo #$id', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Monto: $monto'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: pagado ? Colors.green : AppColors.amarillo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(estado, style: const TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {},
                child: Text(pagado ? 'Ver Comprobante' : 'Marcar como Pagado'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
