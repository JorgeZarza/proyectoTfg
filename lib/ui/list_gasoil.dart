import 'package:flutter/material.dart';
import 'package:proyecto_tfg/db/gasolineras_db.dart';
import 'package:proyecto_tfg/models/gasolinera.dart';
import 'package:proyecto_tfg/ui/gasoil_screen.dart';


class ListGasoil extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ListGasoilState();
  }
}

class _ListGasoilState extends State<ListGasoil> {
  @override
  void initState() {
    super.initState();
  }

  Future getProjectDetails() async {
    List<Gasolinera> projetcList =
        await GasolinerasDatabase.instance.readGasolineras();
    return projetcList;
  }

  Widget projectWidget() {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none &&
            projectSnap.hasData == null) {
          print('project snapshot data is: ${projectSnap.data}');
          return Container();
        }
        if (projectSnap.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(backgroundColor: Color(0xFF17202A));
        }
        return ListView.builder(
          itemCount: projectSnap.data.length,
          itemBuilder: (context, index) {
            Gasolinera g = projectSnap.data[index];
            return Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    width: double.infinity,
                    child: RaisedButton(
                      color: Color(0xFFD5D8DC),
                      elevation: 5.0,
                      onPressed: () {
                        Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => GasoilScreen(g)));
                      },
                      padding: EdgeInsets.all(20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Text(
                        '${g.rotulo}(${g.municipio})',
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ))
              ],
            );
          },
        );
      },
      future: getProjectDetails(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Gasolineras'),
        backgroundColor: Color(0xFF17202A),
      ),
      backgroundColor: Color(0xFF17202A),
      body: projectWidget(),
    );
  }
}
