// To parse this JSON data, do
//
//     final mensajeModel = mensajeModelFromJson(jsonString);

import 'dart:convert';

List<MensajeModel> mensajeModelFromJson(String str) => List<MensajeModel>.from(
    json.decode(str).map((x) => MensajeModel.fromJson(x)));

String mensajeModelToJson(List<MensajeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MensajeModel {
  MensajeModel({
    this.id,
    this.idMedico,
    this.mensaje,
    this.fecha,
  });

  String id;
  String idMedico;
  String mensaje;
  String fecha;

  factory MensajeModel.fromJson(Map<String, dynamic> json) => MensajeModel(
        id: json["id"],
        idMedico: json["idMedico"],
        mensaje: json["mensaje"],
        fecha: json["fecha"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "idMedico": idMedico,
        "mensaje": mensaje,
        "fecha": fecha,
      };
}
