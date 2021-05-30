import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';

class BluetoothBloc {
  final _bluetooth = FlutterBlue.instance.state;

  Stream<BluetoothState> get bluetoothStream => _bluetooth;

  dispose() {}
}
