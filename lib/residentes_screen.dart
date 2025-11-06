import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fraccionamiento/colors.dart';
import 'package:fraccionamiento/editar_residente_screen.dart';
import 'package:fraccionamiento/models/api_fracc_dao.dart';
import 'package:fraccionamiento/nuevo_residente_screen.dart';

class ResidentesScreen extends StatefulWidget {
  const ResidentesScreen({super.key});

  @override
  State<ResidentesScreen> createState() => _ResidentesScreenState();
}

class _ResidentesScreenState extends State<ResidentesScreen> {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3002'));
  List<Residente> residentes = [];
  bool cargando = true;
  String filtro = '';

  @override
  void initState() {
    super.initState();
    obtenerResidentes();
  }

  Future<void> obtenerResidentes() async {
    try {
      final response = await dio.get('/residentes');
      final List data = response.data;
      setState(() {
        residentes = data.map((e) => Residente.fromJson(e)).toList();
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener residentes: $e')),
      );
    }
  }

  Future<void> eliminarResidente(int id) async {
    try {
      await dio.delete('/residente/$id');
      await obtenerResidentes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Residente eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar residente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final residentesFiltrados = residentes
        .where(
          (r) =>
              r.nombre.toLowerCase().contains(filtro.toLowerCase()) ||
              r.numeroResidencia.toString().contains(filtro),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.celesteClaro,
      appBar: AppBar(
        backgroundColor: AppColors.celesteVivo,
        title: const Text('Residentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
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
                    onChanged: (valor) => setState(() => filtro = valor),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: residentesFiltrados.length,
                      itemBuilder: (context, index) {
                        final r = residentesFiltrados[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/avatar_default.png',
                              ),
                              radius: 25,
                            ),
                            title: Text(
                              '${r.nombre} ${r.primerApellido}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              'Casa ${r.numeroResidencia.toString()}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
                                  ),
                                  onPressed: () async {
                                    final actualizado = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditarResidenteScreen(residente: r),
                                      ),
                                    );

                                    if (actualizado == true) {
                                      obtenerResidentes();
                                    }
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    eliminarResidente(r.numeroResidencia);
                                    
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.amarillo,
        onPressed: () async {
          final agregado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NuevoResidenteScreen(),
            ),
          );

          if (agregado == true) {
            obtenerResidentes(); 
          }
        },
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.celesteNegro,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
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
    );
  }
}
