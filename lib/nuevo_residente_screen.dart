import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fraccionamiento/colors.dart';

class NuevoResidenteScreen extends StatefulWidget {
  const NuevoResidenteScreen({super.key});

  @override
  State<NuevoResidenteScreen> createState() => _NuevoResidenteScreenState();
}

class _NuevoResidenteScreenState extends State<NuevoResidenteScreen> {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3002')); 
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController apellido1Ctrl = TextEditingController();
  final TextEditingController apellido2Ctrl = TextEditingController();
  final TextEditingController correoCtrl = TextEditingController();
  final TextEditingController telefonoCtrl = TextEditingController();
  final TextEditingController numeroCasaCtrl = TextEditingController();

  Future<void> insertarResidente() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await dio.post('/residente', data: {
        "nombre": nombreCtrl.text,
        "primer_apellido": apellido1Ctrl.text,
        "segundo_apellido": apellido2Ctrl.text,
        "correo": correoCtrl.text,
        "telefono": telefonoCtrl.text,
        "numero_residencia": int.parse(numeroCasaCtrl.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Residente agregado correctamente')),
      );
      Navigator.pop(context, true); // Vuelve a la lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar residente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celesteClaro,
      appBar: AppBar(
        backgroundColor: AppColors.celesteVivo,
        title: const Text('Nuevo Residente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              campoTexto('Nombre', nombreCtrl),
              campoTexto('Primer apellido', apellido1Ctrl),
              campoTexto('Segundo apellido', apellido2Ctrl),
              campoTexto('Correo electrónico', correoCtrl,
                  tipo: TextInputType.emailAddress),
              campoTexto('Teléfono', telefonoCtrl,
                  tipo: TextInputType.phone),
              campoTexto('Número de casa', numeroCasaCtrl,
                  tipo: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar residente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.celesteVivo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: (){
                  insertarResidente();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget campoTexto(String label, TextEditingController controller,
      {TextInputType tipo = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }
}
