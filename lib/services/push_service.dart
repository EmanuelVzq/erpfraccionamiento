import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  static late String _baseUrl;
  static late int _idPersona;

  // ---------- HANDLER BACKGROUND ----------
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    // Si llega data-only y quieres mostrar también:
    if (message.notification != null) {
      await _showLocal(message);
    }
  }

  // ---------- INIT GLOBAL (main) ----------
  static Future<void> initGlobal() async {
    // 1) Inicializa local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _fln.initialize(initSettings);

    // 2) Crea canal Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'avisos',
      'Avisos',
      description: 'Notificaciones de avisos del fraccionamiento',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3) Permiso runtime Android 13+ + iOS
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    if (Platform.isAndroid) {
      await _fln
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // 4) Foreground: mostrar con notificación local
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        await _showLocal(message);
      }
    });

    // 5) Background/terminated handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // ---------- INIT POR USUARIO (login) ----------
  static Future<void> init({
    required int idPersona,
    required String baseUrl,
  }) async {
    _idPersona = idPersona;
    _baseUrl = baseUrl;

    final token = await _fcm.getToken();
    if (token != null) {
      await _registrarToken(token);
    }

    _fcm.onTokenRefresh.listen((newToken) async {
      await _registrarToken(newToken);
    });
  }

  static Future<void> _registrarToken(String token) async {
    final dio = Dio(BaseOptions(baseUrl: _baseUrl));
    await dio.post("/dispositivo", data: {
      "id_persona": _idPersona,
      "plataforma": "android",
      "push_token": token,
    });
  }

  static Future<void> _showLocal(RemoteMessage message) async {
    final n = message.notification!;
    const androidDetails = AndroidNotificationDetails(
      'avisos', // mismo channel_id
      'Avisos',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _fln.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      n.title,
      n.body,
      details,
    );
  }
}
