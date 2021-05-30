// import 'package:rxdart/subjects.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/dermatologo_model.dart';
import 'package:suncare/src/providers/vinculacion_provider.dart';
import 'package:rxdart/rxdart.dart';

class VinculacionBloc {
  final VinculacionProvider provider = new VinculacionProvider();
  final _estadoController = BehaviorSubject<String>();
  final _dermatologoVinculadoController = BehaviorSubject<DermatologoModel>();
// final _passwordController = BehaviorSubject<String>();
  VinculacionBloc() {}

  Stream<String> get estadoStream => _estadoController.stream;
  Stream<DermatologoModel> get dermatologoVinculadoStream =>
      _dermatologoVinculadoController.stream;

  void estadoActual() async {
    Map<String, String> respuesta = await provider.estadoActual();
    _estadoController.sink.add(respuesta['estado']);
    if (respuesta['estado'] != "NULA") {
      DermatologoModel dermatologoModel =
          await provider.datosVinculacion(respuesta['idMedico']);

      _dermatologoVinculadoController.sink.add(dermatologoModel);
    }
  }

  Future<bool> cancelarVinculacion() async {
    DermatologoModel dermatologo = _dermatologoVinculadoController.value;
    final respuesta = await provider.cancelarVinculacion(dermatologo.id);
    return respuesta;
  }

  Future<bool> crearVinculacion(String id) async {
    return await provider.crearVinculacion(id);
    // return false;
  }

  dispose() {
    _estadoController?.close();
    _dermatologoVinculadoController?.close();
  }
}
