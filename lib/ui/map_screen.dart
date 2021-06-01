import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:proyecto_tfg/db/gasolineras_db.dart';
import 'package:proyecto_tfg/models/gasolinera.dart';
import 'dart:async';
import 'dart:core';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final double CAMERA_ZOOM = 13;
  final double CAMERA_TILT = 30;
  final double CAMERA_BEARING = 30;
  final LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();

  // para mis rutas dibujadas en el mapa
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;

  String googleAPIKey = "AIzaSyAdBu7WLauUc2Nbv4ItxcPecIHVC7qOTeI";

  // para mis marcadores personalizados
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  // la ubicación inicial del usuario y la ubicación actual
  // a medida que se mueve
  LocationData currentLocation;
  // una referencia a la ubicación de destino
  LocationData destinationLocation;
  // envoltorio alrededor de la API de ubicación
  Location location;

  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;
  Gasolinera g;

  @override
  void initState() {
    super.initState();
    // crea una instancia de Location
    location = new Location();
    GasolinerasDatabase.instance;
    // suscribirse a los cambios en la ubicación del usuario
    // "escuchando" el evento onLocationChanged de la ubicación
    location.onLocationChanged.listen((LocationData cLoc) {
      // cLoc contiene el lat y el largo del
      // posición del usuario actual en tiempo real,
      // así que nos aferramos a eso
      currentLocation = cLoc;
      updatePinOnMap();
    });

    // establecer pines marcadores personalizados
    setSourceAndDestinationIcons(); // establece la ubicación inicial
    setInitialLocation();
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  void setInitialLocation() async {
    // establece la ubicación inicial tirando del usuario
    // ubicación actual de getLocation () de la ubicación
    currentLocation = await location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF17202A),
        title: Text('ZarzaOil'),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                // mi mapa ha terminado de ser creado;
                // estoy listo para mostrar los pines en el mapa
              }),
        ],
      ),
    );
  }

  void updatePinOnMap() async {
    // crea una nueva instancia de CameraPosition
    // cada vez que cambia la ubicación, entonces la cámara
    // sigue el pin mientras se mueve con una animación
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    showPinsOnMap();

    // haz esto dentro de setState () para que se notifique a Flutter
    // que se debe actualizar un widget

    if (this.mounted) {
      setState(() {
        // updated position
        var pinPosition =
            LatLng(currentLocation.latitude, currentLocation.longitude);
        GasolinerasDatabase.instance.deleteAll();
        // el truco es eliminar el marcador (por id)
        // y agregarlo nuevamente en la ubicación actualizada
        _markers.removeWhere((m) => m.markerId.toString() == 'sourcePin');
        _markers.add(Marker(
            markerId: MarkerId('sourcePin'),
            position: pinPosition, // posición actualizada
            icon: sourceIcon));
      });
    }
  }

  Future showPinsOnMap() {
    GeoFirePoint center = geo.point(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude);
    var collectionReference = _firestore.collection('localizaciones');
    double radius = 15;
    String precioGasoA,
        precioGasoB,
        precioGaso95,
        precioGaso98,
        rotulo,
        municipio,
        codigoPostal;
    String field = 'Posición';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field, strictMode: true);

    stream.listen((List<DocumentSnapshot> docList) {
      docList.forEach((DocumentSnapshot doc) {
        GeoPoint punto = doc.get('Posición.geopoint');
        String geohash = doc.get('Posición.geohash');

        var document = _firestore
            .collection('gasolineras')
            .where(FieldPath(['latitud/longitud']), isEqualTo: punto)
            .limit(1);
        document.get().then((value) {
          if (value.docs.length > 0) {
            GeoPoint geoGas = value.docs[0].data()['latitud/longitud'];
            precioGasoA = value.docs[0].data()['precioGasoleoA'];
            precioGasoB = value.docs[0].data()['precioGasoleoB'];
            precioGaso95 = value.docs[0].data()['precioGasolina95'];
            precioGaso98 = value.docs[0].data()['precioGasolina98'];
            codigoPostal = value.docs[0].data()['codigoPostal'];
            rotulo = value.docs[0].data()['rotulo'];
            municipio = value.docs[0].data()['municipio'];

            Gasolinera g = new Gasolinera(
                codigoPostal,
                rotulo,
                geoGas.latitude,
                geoGas.longitude,
                geohash,
                municipio,
                precioGasoA,
                precioGasoB,
                precioGaso95,
                precioGaso98);

           var pinPosition = LatLng(geoGas.latitude, geoGas.longitude);
                    _markers.add(Marker(
                        markerId: MarkerId('${g.id}${g.latitud}'),
                        position: pinPosition, // posición actualizada
                        icon: destinationIcon,
                        infoWindow: InfoWindow(
                            title: g.rotulo,
                            snippet:
                                'Sin Plomo 95: ${g.precioGasolina95} Gasoleo A: ${g.precioGasoleoA}')));

            GasolinerasDatabase.instance
                .hayGasolineraEnBd(g.geohash)
                .then((value) {
              if (!value) {
                    GasolinerasDatabase.instance.create(g);
              } else
                print('YA ESTA LA GASOLINERA ${g.rotulo}');
            });
          }
        });
      });
    });
  }

  void setPolylines(GeoPoint p) async {
    List<PointLatLng> result = (await polylinePoints.getRouteBetweenCoordinates(
        googleAPIKey,
        PointLatLng(destinationLocation.latitude, currentLocation.longitude),
        PointLatLng(p.latitude, p.longitude))) as List<PointLatLng>;

    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        _polylines.add(Polyline(
            width: 5, // fije el ancho de las polylineas
            polylineId: PolylineId("Destino ${p.latitude}${p.longitude}"),
            color: Color.fromARGB(255, 40, 122, 198),
            points: polylineCoordinates));
      });
    }
  }
}

Future<void> de0a4000() async {
  final respuesta = await http.get(Uri.parse(
      'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/'));

  if (respuesta.statusCode == 200) {
    final jsonData = jsonDecode(utf8.decode(respuesta.bodyBytes));
    String latitud;
    String codigoPostal;
    String municipio;
    String precioGasoleoA;
    String precioGasoleoB;
    String precioGasolina95;
    String precioGasolina98;
    String rotulo;
    String longitud;

    FirebaseFirestore _db = FirebaseFirestore.instance;
    final geo = Geoflutterfire();
    GeoFirePoint localizacion;

    for (var i = 500; i < 1000; i++) {
      print(jsonData["ListaEESSPrecio"][i]);

      codigoPostal = jsonData["ListaEESSPrecio"][i]["C.P."];
      municipio = jsonData["ListaEESSPrecio"][i]["Municipio"];
      precioGasoleoA = jsonData["ListaEESSPrecio"][i]["Precio Gasoleo A"];
      precioGasoleoB = jsonData["ListaEESSPrecio"][i]["Precio Gasoleo B"];
      precioGasolina95 =
          jsonData["ListaEESSPrecio"][i]["Precio Gasolina 95 E5"];
      precioGasolina98 =
          jsonData["ListaEESSPrecio"][i]["Precio Gasolina 98 E5"];
      rotulo = jsonData["ListaEESSPrecio"][i]["Rótulo"];
      latitud = jsonData["ListaEESSPrecio"][i]["Latitud"];
      longitud = jsonData["ListaEESSPrecio"][i]["Longitud (WGS84)"];

      latitud = latitud.replaceAll(',', '.');
      longitud = longitud.replaceAll(',', '.');

      _db.collection('gasolineras').add({
        'codigoPostal': codigoPostal,
        'latitud/longitud': geo.point(
            latitude: double.parse(latitud), longitude: double.parse(longitud)),
        'municipio': municipio,
        'precioGasoleoA': precioGasoleoA,
        'precioGasoleoB': precioGasoleoB,
        'precioGasolina95': precioGasolina95,
        'precioGasolina98': precioGasolina98,
        'rotulo': rotulo
      }).then((value) {
        print('letsgo');
      }).onError((error, stackTrace) => null);
    }
  } else {
    Fluttertoast.showToast(msg: "Fallo");
  }
  print(
      "YA ESTTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
}
/*   
    _firestore.collection('gasolineras').doc(value.docs[i].id).delete().whenComplete(() => print('done'));
        
        _firestore.collection('gasolineras').doc(value.docs[i].id).update({'latitud/longitud': FieldValue.delete()});

    _firestore.collection('gasolineras').doc(value.docs[i].id).get().then((value) => {
          point = value.data()['latitud/longitud']
        });
        _firestore.collection('gasolineras').doc(value.docs[i].id).update({'geoPoint': point});


    });
*/
