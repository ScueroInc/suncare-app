import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';

class PushNotificationsProvider {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription iosSubscription;

  final _mensajeStreamComtroller = StreamController<String>.broadcast();

  Stream<String> get mensajesStream => _mensajeStreamComtroller.stream;

  static Future<dynamic> onBackgroundMessage(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  initNotifications() async {
    await _firebaseMessaging.requestNotificationPermissions();
    final token = await _firebaseMessaging.getToken();

    print('======= FOM TOKEN========');
    print('token: $token');

    _firebaseMessaging.configure(
      onMessage: onMessage,
      onBackgroundMessage: onBackgroundMessage,
      onLaunch: onLaunch,
      onResume: onResume,
    );
  }

  Future<dynamic> onMessage(Map<String, dynamic> message) async {
    print('=======onMessage========');
    print('message: $message');

    final argumento = message['data']['alerta'];
    _mensajeStreamComtroller.sink.add(argumento);
  }

  Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    print('=======onLaunch========');
    // print('message: $message');

    final argumento = message['data']['alerta'];
    _mensajeStreamComtroller.sink.add(argumento);
  }

  Future<dynamic> onResume(Map<String, dynamic> message) async {
    print('=======onResume========');
    print('message: $message');

    final argumento = message['data']['alerta'];
    _mensajeStreamComtroller.sink.add(argumento);
  }

  saveDeviceToken(String id) async {
    String tokenDevice = await _firebaseMessaging.getToken();

    if (tokenDevice != null) {
      await _db.collection('usuarios').doc(id).update({
        'tokens': {
          'tokenDevice': tokenDevice,
          'plataforma': Platform.operatingSystem
        }
      });
      _preferencia.tokenNotification = tokenDevice;
    }
  }

  saveDeviceTokenIOS(String id) {
    iosSubscription =
        _firebaseMessaging.onIosSettingsRegistered.listen((event) {
      this.saveDeviceToken(id);
    });
    _firebaseMessaging
        .requestNotificationPermissions(IosNotificationSettings());
  }

  dispose() {
    _mensajeStreamComtroller?.close();
    iosSubscription?.cancel();
  }
}
