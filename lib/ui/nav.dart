import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tfg/ui/map_screen.dart';
import 'package:proyecto_tfg/ui/list_gasoil.dart';
import 'package:proyecto_tfg/ui/login_screen.dart';
import 'package:proyecto_tfg/ui/user_screen.dart';
import 'package:proyecto_tfg/utils/Authentication.dart';

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptionsLogged = <Widget>[
    MapPage(),
    //Text('Holi'),
    ListGasoil(),
    ProfileScreen(),
  ];
  List<Widget> _widgetOptionsUnlogged = <Widget>[
    MapPage(),
    //Text('Holi'),
    ListGasoil(),
    LoginScreen(),
  ];

  void _onItemTap(int index) {
      setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Builder(
      builder: (context) {
        if (authService.status == AuthStatus.Authenticated) {
          return Scaffold(
              body: Center(
                child: _widgetOptionsLogged.elementAt(_selectedIndex),
              ),
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Color(0xFF17202A),
                selectedItemColor: Color(0xFF566573),
                unselectedItemColor: Colors.white54,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.map_sharp,
                      color: Colors.white54,
                    ),
                    title: Text(
                      'Mapa',
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.list_alt_rounded,
                      color: Colors.white54,
                    ),
                    title: Text(
                      'Gasolineras',
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person,
                      color: Colors.white54,
                    ),
                    title: Text(
                      'Perfil',
                    ),
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTap,
                selectedFontSize: 13.0,
                unselectedFontSize: 13.0,
              ));
        } else {
          return Scaffold(
              body: Center(
                child: _widgetOptionsUnlogged.elementAt(_selectedIndex),
              ),
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Color(0xFF17202A),
                selectedItemColor: Color(0xFF566573),
                unselectedItemColor: Colors.white54,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.map_sharp,
                      color: Colors.white54,
                    ),
                    title: Text(
                      'Mapa',
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.list_alt_rounded,
                      color: Colors.white54,
                    ),
                    title: Text(
                      'Gasolineras',
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person,
                      color: Colors.white54,
                    ),
                    title: Text(
                      'Perfil',
                    ),
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTap,
                selectedFontSize: 13.0,
                unselectedFontSize: 13.0,
              ));
        }
      },
    );
  }
}
