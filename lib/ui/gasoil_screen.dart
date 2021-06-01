import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tfg/models/gasolinera.dart';
import 'package:proyecto_tfg/utils/Authentication.dart';
import 'package:proyecto_tfg/utils/constant.dart';

class GasoilScreen extends StatelessWidget {
  Gasolinera gasolinera;
  GasoilScreen(this.gasolinera);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(g: gasolinera),
    );
  }

  Gasolinera getGasolinera() {
    return this.gasolinera;
  }
}

class MyHomePage extends StatefulWidget {
  Gasolinera g;
  MyHomePage({Key key, this.g}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
        appBar: buildAppBar(authService),
        body:
            GasoilView() // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  AppBar buildAppBar(AuthService authService) {
    return AppBar(
      backgroundColor: Colors.white70,
      elevation: 0,
      actions: <Widget>[
        IconButton(
          icon: SvgPicture.asset(
            "assets/heart.svg",
            // By default our  icon color is white
            color: kTextColor,
          ),
          onPressed: () {
            agregarAFavoritos(authService, widget.g);
          },
        ),
        SizedBox(width: kDefaultPaddin / 2)
      ],
    );
  }

  Widget GasoilView() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(30, 50, 30, 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${widget.g.rotulo}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(height: 24, width: 24)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
          child: Stack(
            children: <Widget>[
              CircleAvatar(
                radius: 70,
                child: ClipOval(
                  child: Image.asset(
                    'assets/REPYF.png',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF17202A), Color(0xFF17202A)])),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
                child: Container(
                  height: 60,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Municipio: ${widget.g.municipio}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(width: 1.0, color: Colors.white70)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 4),
                child: Container(
                  height: 60,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Precio Sin Plomo 95: ${widget.g.precioGasolina95}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(width: 1.0, color: Colors.white70)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 4),
                child: Container(
                  height: 60,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Precio Gasoleo A: ${widget.g.precioGasoleoA}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(width: 1.0, color: Colors.white70)),
                ),
              ),
            ],
          ),
        ))
      ],
    );
  }

  void agregarAFavoritos(AuthService authService, Gasolinera g) {
    switch (authService.status) {
      case AuthStatus.Unauthenticated:
        Fluttertoast.showToast(
            msg:
                'No has iniciado sesión, no puedes añadir esta gasolinera a favoritos');
        break;
      case AuthStatus.Authenticated:
        var lista = FirebaseFirestore.instance
            .collection('listaFavoritos')
            .doc(authService.user.id)
            .get()
            .then((value) => {
                  if (value.exists)
                    { 
                      FirebaseFirestore.instance
                          .collection('listaFavoritos')
                          .doc(authService.user.id)
                          .update({
                            'Gasolinera (${g.id})' as String: '${g.rotulo} ${g.municipio}' as String,
                      }),
                      Fluttertoast.showToast(
                          msg: 'Gasolinera añadida a tu lista de favoritos')
                    }
                  else
                    {
                      FirebaseFirestore.instance
                          .collection('listaFavoritos')
                          .doc(authService.user.id)
                          .set({
                        'Gasolinera(${g.id})':
                            '${g.rotulo} en ${g.municipio}'
                      }),
                      Fluttertoast.showToast(
                          msg: 'Gasolinera añadida a tu lista de favoritos')
                    }
                });
        break;
    }
  }
}
