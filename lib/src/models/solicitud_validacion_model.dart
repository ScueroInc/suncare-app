import 'dart:convert';

class SolicitudValidacionModel {
  
  String estadoSolicitud;
  String fechaSolicitud;
  String fechaProcesada;
  
  SolicitudValidacionModel({
    this.estadoSolicitud,
    this.fechaSolicitud,
    this.fechaProcesada
  });

  factory SolicitudValidacionModel.fromJson(Map<String, dynamic> json) =>
    SolicitudValidacionModel(
      estadoSolicitud: json["estadoSolicitud"],
      fechaSolicitud: json["fechaSolicitud"],
      fechaProcesada: json["fechaProcesada"]
    );

  Map<String, dynamic> toJson() => {
    "estadoSolicitud":estadoSolicitud,
    "fechaSolicitud":fechaSolicitud,
    "fechaProcesada":fechaProcesada
  };

}

SolicitudValidacionModel solicitudValidacionModelFromJson(String str) => 
  SolicitudValidacionModel.fromJson(json.decode(str));

String solicitudValidacionModelToJson(SolicitudValidacionModel data) =>
  json.encode(data.toJson());