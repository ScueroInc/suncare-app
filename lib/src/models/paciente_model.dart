// To parse this JSON data, do
//
//     final pacienteModel = pacienteModelFromJson(jsonString);
// {
//        "id":0,
//        "nombre":"text",
//        "apellido":"text",
//        "nacimiento": "text",
//        "tipo": "text",
//        "correo":"text",
//        "password":"text",
//        "imagenProfile":"text"
// }

import 'dart:convert';

PacienteModel pacienteModelFromJson(String str) =>
    PacienteModel.fromJson(json.decode(str));

String pacienteModelToJson(PacienteModel data) => json.encode(data.toJson());

class PacienteModel {
  PacienteModel(
      {this.id,
      this.nombre,
      this.apellido,
      this.nacimiento,
      this.tipo = "paciente",
      this.correo,
      this.password,
      this.password2,
      this.imagenProfile,
      this.tipoPiel,
      this.vinculacion = false,
      this.vinculacionFecha,
      this.vinculacionIdMedico});

  String id;
  String nombre;
  String apellido;
  String nacimiento;
  String tipo;
  String correo;
  String password;
  String password2;
  String imagenProfile;
  String tipoPiel;
  bool vinculacion;
  String vinculacionFecha;
  String vinculacionIdMedico;

  factory PacienteModel.fromJson(Map<String, dynamic> json) => PacienteModel(
        id: json["id"],
        nombre: json["nombre"],
        apellido: json["apellido"],
        nacimiento: json["nacimiento"],
        tipo: json["tipo"],
        correo: json["correo"],
        password: json["password"],
        password2: json["password2"],
        imagenProfile: json["imagenProfile"],
        tipoPiel: json["tipoPiel"],
        vinculacion: json["vinculacion"],
        vinculacionFecha: json["vinculacionFecha"],
        vinculacionIdMedico: json["vinculacionIdMedico"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "apellido": apellido,
        "nacimiento": nacimiento,
        "tipo": tipo,
        "correo": correo,
        // "password": password,
        // "password2": password2,
        "imagenProfile": imagenProfile,
        "tipoPiel": tipoPiel,
        "vinculacion": vinculacion,
        "vinculacionFecha": vinculacionFecha,
        "vinculacionIdMedico": vinculacionIdMedico,
      };

  int miEdad() {
    int edad;
    var fechaDeHoy = DateTime.now();
    int anioActual = fechaDeHoy.year;
    int nacimineto = int.parse(this.nacimiento.substring(0, 4));

    edad = anioActual - nacimineto;
    return edad;
  }
}
