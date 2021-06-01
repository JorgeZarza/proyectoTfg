import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tfg/utils/Authentication.dart';


class ListUserGasoil extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ListUserGasoilState();
  }
}

class _ListUserGasoilState extends State<ListUserGasoil> {
  @override
  void initState() {
    super.initState();
  }

  Future llamadaFutura(){
    
  }

  Future getProjectDetails(AuthService authService) async {
    List<String> projetcList = [];
        await FirebaseFirestore.instance.collection('listaFavoritos').doc(authService.user.id).get().then((value) => {
          value.data().forEach((key, value) {
            print(value.toString());
            projetcList.add(value);
          })
        });
    return projetcList;
  }

  Widget projectWidget(AuthService authService) {
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
            String g = projectSnap.data[index];
            return Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    width: double.infinity,
                    child: RaisedButton(
                      color: Color(0xFFD5D8DC),
                      elevation: 5.0,
                      onPressed: () {
                      },
                      padding: EdgeInsets.all(20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Text(
                        '${g})',
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
      future: getProjectDetails(authService),
      
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Gasolineras'),
        backgroundColor: Color(0xFF17202A),
      ),
      backgroundColor: Color(0xFF17202A),
      body: projectWidget(authService),
    );
  }
}


 
