import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _kIdPersona = "id_persona";
  static const _kIdUsuario = "id_usuario";

  static Future<void> save({
    required int idPersona,
    required int idUsuario,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kIdPersona, idPersona);
    await sp.setInt(_kIdUsuario, idUsuario);
  }

  static Future<int> idPersona() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kIdPersona) ?? 0;
  }

  static Future<int> idUsuario() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kIdUsuario) ?? 0;
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kIdPersona);
    await sp.remove(_kIdUsuario);
  }
}
