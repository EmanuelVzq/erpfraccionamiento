class Residente {
  final int idResidente;
  final String nombre;
  final String primerApellido;
  final String? segundoApellido;
  final String correo;
  final String telefono;
  final int numeroResidencia;

  Residente({
    required this.idResidente,
    required this.nombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.correo,
    required this.telefono,
    required this.numeroResidencia,
  });

  factory Residente.fromJson(Map<String, dynamic> json) {
    return Residente(
      idResidente: json['id_residente'],
      nombre: json['nombre'],
      primerApellido: json['primer_apellido'],
      segundoApellido: json['segundo_apellido'],
      correo: json['correo'],
      telefono: json['telefono'],
      numeroResidencia: json['numero_residencia'],
    );
  }
}

