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
  DermatologoModel({
    this.id,
    this.nombre,
    this.apellido,
    this.codigo,
    this.nacimiento,
    this.tipo = "dermatologo",
    this.correo,
    this.password,
    this.password2,
    this.imagenProfile,
    this.imagenDni
  });

  String id;
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

  factory DermatologoModel.fromJson(Map<String, dynamic> json) =>
      DermatologoModel(
        id: json["id"],
        nombre: json["nombre"],
        apellido: json["apellido"],
        codigo: json["codigo"],
        nacimiento: json["nacimiento"],
        tipo: json["tipo"],
        correo: json["correo"],
        password: json["password"],
        password2: json["password2"],
        imagenProfile: json["imagenProfile"],
         imagenDni: json["imagenDni"]
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "apellido": apellido,
        "codigo": codigo,
        "nacimiento": nacimiento,
        "tipo": tipo,
        "correo": correo,
        // "password": password,
        "imagenProfile": imagenProfile,
        "imagenDni": imagenDni
      };
}
