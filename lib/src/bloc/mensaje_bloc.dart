import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:suncare/src/bloc/validators.dart';

class MensajesBloc with Validators {
  final _mensajeController = BehaviorSubject<String>();

  Stream<String> get mensajeStream => _mensajeController.transform(validarMensaje);

  Stream<bool> get formValidStream => CombineLatestStream.combine2(
      mensajeStream, mensajeStream, (a, b) => true);

  Function(String) get changeMensaje => _mensajeController.sink.add;

  String get mensaje => _mensajeController.value;

  dispose() {
    _mensajeController?.close();
  }
}
