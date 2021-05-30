// To parse this JSON data, do
//
//     final solicitudModel = solicitudModelFromJson(jsonString);

import 'dart:convert';

List<SolicitudModel> solicitudModelFromJson(String str) =>
    List<SolicitudModel>.from(
        json.decode(str).map((x) => SolicitudModel.fromJson(x)));

String solicitudModelToJson(List<SolicitudModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SolicitudModel {
  SolicitudModel({
    this.idUser,
    this.vinculacion,
    this.vinculacionIdMedico,
    this.vinculacionFecha,
    this.imagenProfile,
    this.nombre,
  });

  String idUser;
  bool vinculacion;
  String vinculacionIdMedico;
  String vinculacionFecha;
  String imagenProfile;
  String nombre;

  factory SolicitudModel.fromJson(Map<String, dynamic> json) => SolicitudModel(
        idUser: json["idUser"],
        imagenProfile: json["imagenProfile"],
        nombre: json["nombre"],
        vinculacion: json["vinculacion"],
        vinculacionIdMedico: json["vinculacionIdMedico"],
        vinculacionFecha: json["vinculacionFecha"],
      );

  Map<String, dynamic> toJson() => {
        "idUser": idUser,
        "vinculacion": vinculacion,
        "vinculacionIdMedico": vinculacionIdMedico,
        "vinculacionFecha": vinculacionFecha,
        "nombre": nombre,
        "imagenProfile": imagenProfile,
      };
}
