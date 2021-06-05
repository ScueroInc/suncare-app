import 'package:connectivity/connectivity.dart';
import 'package:rxdart/rxdart.dart';

class ConnectivityBloc {
  Connectivity connectivity = Connectivity();
  final _connectivityController = BehaviorSubject<bool>();
  final _showErrorController = BehaviorSubject<bool>();

  ConnectivityBloc() {
    initialize();
  }
  Stream<bool> get connectivityStream => _connectivityController.stream;
  Stream<bool> get showErrorStream => _showErrorController.stream;

  void initialize() async {
    print('internet initialize');
    ConnectivityResult result = await connectivity.checkConnectivity();
    _checkStatus(result);
    connectivity.onConnectivityChanged.listen((response) {
      _checkStatus(response);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;

    print('_checkStatus $result');
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        isOnline = true;
        break;
      default:
        isOnline = false;
        break;
    }
    print('_checkStatus $isOnline');
    print('--------internet--------');
    _connectivityController.sink.add(isOnline);
    print('--------internet--------');
    _showErrorController.sink.add(false);
  }

  void obtenerConectividad() {
    //_connectivityController.sink.add()
  }
  void setErrorStream(bool estado) {
    _showErrorController.sink.add(estado);
  }

  // Obtener el último valor ingresado a los streams
  bool get conectividad => _connectivityController.value;
  bool get showError => _showErrorController.value;

  dispose() {
    _connectivityController?.close();
    _showErrorController?.close();
  }
}
