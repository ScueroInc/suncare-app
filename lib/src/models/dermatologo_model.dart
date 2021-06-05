// To parse this JSON data, do
//
//     final dermatologoModel = dermatologoModelFromJson(jsonString);
// {
//        "id":0,
//        "nombre":"text",
//        "apellido":"text",
//        "codigo":"text",
//        "nacimiento": "text",
//        "tipo": "text",
//        "correo":"text",
//        "password":"text",
//        "imagenProfile":"text"
// }

import 'dart:convert';

DermatologoModel dermatologoModelFromJson(String str) =>
    DermatologoModel.fromJson(json.decode(str));

String dermatologoModelToJson(DermatologoModel data) =>
    json.encode(data.toJson());

class DermatologoModel {
  DermatologoModel(
      {this.id,
      this.first = false,
      this.nombre,
      this.apellido,
      this.codigo,
      this.nacimiento,
      this.tipo = "dermatologo",
      this.correo,
      this.password,
      this.password2,
      this.imagenProfile,
      this.imagenDni,
      this.order});

  String id;
  bool first;
  String nombre;
  String apellido;
  String codigo;
  String nacimiento;
  String tipo;
  String correo;
  String password;
  String password2;
  String imagenProfile;
  String imagenDni;
  int order=DateTime.now().millisecondsSinceEpoch;

  factory DermatologoModel.fromJson(Map<String, dynamic> json) =>
      DermatologoModel(
          id: json["id"],
          first: json["first"],
          nombre: json["nombre"],
          apellido: json["apellido"],
          codigo: json["codigo"],
          nacimiento: json["nacimiento"],
          tipo: json["tipo"],
          correo: json["correo"],
          password: json["password"],
          password2: json["password2"],
          imagenProfile: json["imagenProfile"],
          imagenDni: json["imagenDni"],
          order: json["order"]);


  Map<String, dynamic> toJson() => {
        "id": id,
        "first": first,
        "nombre": nombre,
        "apellido": apellido,
        "codigo": codigo,
        "nacimiento": nacimiento,
        "tipo": tipo,
        "correo": correo,
        // "password": password,
        "imagenProfile": imagenProfile,
        "imagenDni": imagenDni,
         "order":order,
      };
}
