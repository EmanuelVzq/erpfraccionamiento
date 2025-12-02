import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialService {
  late TutorialCoachMark tutorial;

  List<TargetFocus> createTargets({
    required GlobalKey botonReservas,
    required GlobalKey botonAvisos,
    required GlobalKey botonPagos,
    required GlobalKey botonPerfil,
  }) {
    return [
      TargetFocus(
        identify: "btn1",
        keyTarget: botonReservas,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _texto(
              "Reservar Áreas",
              "Toca aquí para reservar áreas como el salón, asador o multicancha.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "btn2",
        keyTarget: botonAvisos,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _texto(
              "Avisos",
              "Aquí podrás ver los avisos importantes del fraccionamiento.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "btn3",
        keyTarget: botonPagos,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _texto(
              "Pagos",
              "Consulta tus pagos pendientes o revisa tu historial.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "btn4",
        keyTarget: botonPerfil,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _texto(
              "Tu Perfil",
              "Accede a tu información y cierra sesión desde tu foto.",
            ),
          ),
        ],
      ),
    ];
  }

  Widget _texto(String titulo, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(desc, style: const TextStyle(fontSize: 17, color: Colors.white)),
      ],
    );
  }

  Future<void> start({
    required BuildContext context,
    required List<TargetFocus> targets,
  }) async {
    tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "Saltar",
      paddingFocus: 10,
      opacityShadow: 0.9,
      onFinish: () => debugPrint("🎉 Tutorial finalizado"),
      onSkip: () {
        debugPrint("⏭️ Tutorial saltado");
        return true; // 👈 MUY IMPORTANTE
      },
    );

    await Future.delayed(const Duration(milliseconds: 300));

    tutorial.show(context: context);
  }
}
