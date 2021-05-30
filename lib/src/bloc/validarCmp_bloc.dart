import 'package:rxdart/rxdart.dart';
import 'package:suncare/src/bloc/validators.dart';

class ValidarCmpBloc with Validators {
  final _cmpController = BehaviorSubject<String>();

  Stream<String> get cmpStream => _cmpController.transform(validarCmpRegistrado);

  Function(String) get changeCmp => _cmpController.sink.add;

  String get cmp => _cmpController.value;

  dispose() {
    _cmpController?.close();
  }
}
