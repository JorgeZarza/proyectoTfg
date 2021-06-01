
import 'package:flutter/material.dart';
import 'dart:core';

import 'package:sqflite/sqflite.dart';

class GasolineraFields {
  static final List<String> values = [
    'rotulo',
    'codigoPostal',
    'municipio',
    'precioGasoleoA',
    'precioGasoleoB',
    'precioGasolina95',
    'precioGasolina98'
  ];
}

class Gasolinera with ChangeNotifier {
  int id = 0;
  static int idF = 0;
  String codigoPostal,
      rotulo,
      municipio,
      precioGasoleoA,
      precioGasoleoB,
      precioGasolina95,
      geohash,
      precioGasolina98;
  
  double latitud, longitud;

  Gasolinera(String codigoPostal,String rotulo,double latitud,double longitud,String geohash,String municipio,String precioGasoleoA,String precioGasoleoB,String precioGasolina95,String precioGasolina98) {
    this.id = idF;
    this.codigoPostal = codigoPostal;
    this.rotulo = rotulo;
    this.latitud = latitud;
    this.longitud = longitud;
    this.municipio = municipio;
    this.precioGasoleoA = precioGasoleoA;
    this.precioGasoleoB = precioGasoleoB;
    this.precioGasolina95 = precioGasolina95;
    this.precioGasolina98 = precioGasolina98;
    this.geohash = geohash;
    idF++;

  }
  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'codigoPostal': codigoPostal,
      'rotulo': rotulo,
      'latitud': latitud,
      'longitud': longitud,
      'geohash' : geohash,
      'municipio': municipio,
      'precioGasoleoA': precioGasoleoA,
      'precioGasoleoB': precioGasoleoB,
      'precioGasolina95': precioGasolina95,
      'precioGasolina98': precioGasolina98,
    };
  }

  @override
  String toString() {
    return ('${this.rotulo} \n\n Sin Plomo 95: ${this.precioGasolina95} \n\n Precio Gasoleo A: ${this.precioGasoleoA}');
  }

  static Gasolinera fromMap(Map<String, Object> map) {
    Gasolinera g = new Gasolinera(map['codigoPostal'] as String, map['rotulo'] as String, map['latitud'] as double, map['longitud'] as double,map['geohash'] as String, map['municipio'] as String, 
    map['precioGasoleoA'] as String, map['precioGasoleoB'] as String, map['precioGasolina95'] as String, map['precioGasolina98'] as String);
    return g;
  }
}
