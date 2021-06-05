import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';

class ConnectivityProvider {
  ConnectivityProvider._internal();

  static final ConnectivityProvider _instance =
      ConnectivityProvider._internal();

  static ConnectivityProvider get instance => _instance;

  Connectivity connectivity = Connectivity();

  StreamController controller = StreamController.broadcast();
  StreamController<bool> showError = StreamController.broadcast();

  Stream get connectivityStream => controller.stream;
  Stream get showErrorStream => showError.stream;

  void initialize() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    _checkStatus(result);
    connectivity.onConnectivityChanged.listen((response) {
      _checkStatus(response);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    // try {

    //   final response = await InternetAddress.lookup('youtube.com');
    //   if(response.isNotEmpty && response[0].rawAddress.isNotEmpty) {
    //     isOnline = true;
    //   } else {
    //     isOnline = false;
    //   }

    // } on SocketException catch(_) {
    //   isOnline = false;
    // }

    // //controller.sink.add({result:isOnline});
    // controller.sink.add(isOnline);
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        isOnline = true;
        break;
      default:
        isOnline = false;
        break;
    }

    controller.sink.add(isOnline);
  }

  void setShowError(bool isConnected) {
    showError.sink.add(isConnected);
  }

  void dispose() {
    controller?.close();
    showError?.close();
  }
}
