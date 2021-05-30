import 'package:flutter/material.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/widgets/tab_home.dart';
import 'package:suncare/src/widgets/tab_pacientes.dart';
import 'package:suncare/src/widgets/tab_statistic.dart';
import 'package:suncare/src/widgets/tab_setting.dart';

class HomeDermatologoPage extends StatefulWidget {
  @override
  _HomeDermatologoPageState createState() => _HomeDermatologoPageState();
}

class _HomeDermatologoPageState extends State<HomeDermatologoPage> {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final tabs = [Tab_Pacientes(), Tab_Setting()];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(143, 148, 251, 6),
        title: Text('Pacientes'),
      ),
      drawer: _crearMenuUsuario(context),
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.redAccent,
          items: [
            BottomNavigationBarItem(
                label: 'Pacientes', icon: Icon(Icons.people)),
            // BottomNavigationBarItem(
            //     label: 'Datos', icon: Icon(Icons.analytics)),
            BottomNavigationBarItem(
                label: 'Configuración', icon: Icon(Icons.settings))
          ],
          onTap: _onItemTapped,
        ),
      ),
      body: tabs[_currentIndex],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Drawer _crearMenuUsuario(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 25,
                    child: Image(image: AssetImage('assets/img/clock.png')),
                  ),
                  Text('Nombre Completo')
                ],
              ),
            ),
            decoration: BoxDecoration(color: Color.fromRGBO(143, 148, 251, 6)),
          ),
          ListTile(
            leading: Icon(Icons.perm_identity,
                color: Color.fromRGBO(143, 148, 251, 6)),
            title: Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'perfil_dermatologo');
            },
          ),
          ListTile(
            leading: Icon(Icons.perm_identity,
                color: Color.fromRGBO(143, 148, 251, 6)),
            title: Text('Solicitudes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'solicitudes');
            },
          ),
          Divider(),
          ListTile(
            leading:
                Icon(Icons.logout, color: Color.fromRGBO(143, 148, 251, 6)),
            title: Text('Cerrar sesión'),
            onTap: () {
              _showMesssageDialog(context, '¿Desea cerrar sesión?');
              // Navigator.pushNamed(context, 'solicitudes');
            },
          ),
        ],
      ),
    );
  }

  void _mostrarDialogo(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            title: Text('Nivel de  SPF'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                    title: Text('SPF 15'),
                    value: true,
                    onChanged: (value) {
                      print('ss ${value}');
                    }),
                CheckboxListTile(
                    title: Text('SPF 30'),
                    value: true,
                    onChanged: (value) {
                      print('ss ${value}');
                    }),
                CheckboxListTile(
                    title: Text('SPF 50'),
                    value: true,
                    onChanged: (value) {
                      print('ss ${value}');
                    }),
                CheckboxListTile(
                    title: Text('SPF 70'),
                    value: true,
                    onChanged: (value) {
                      print('ss ${value}');
                    }),
                CheckboxListTile(
                    title: Text('SPF 100'),
                    value: true,
                    onChanged: (value) {
                      print('ss ${value}');
                    }),
              ],
            ),
            actions: [
              FlatButton(
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop()),
              FlatButton(child: Text('Aceptar'), onPressed: () {})
            ],
          );
        });
  }

  void _showMesssageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              child: Text(
                message,
                textAlign: TextAlign.center
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                child: Text('Cancelar', style: TextStyle(color: Color.fromRGBO(143, 148, 251, 6))),
                onPressed: () => {
                  Navigator.of(context).pop(),
                  //Navigator.pushReplacementNamed(context, 'home_dermatologo')
                  }),
                FlatButton(
                child: Text('Aceptar', style: TextStyle(color: Color.fromRGBO(143, 148, 251, 6))),
                onPressed: () {
                  //Navigator.of(ctx).pop();                
                  _preferencia.cerrarSesion();
                  Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
                  // Navigator.popAndPushNamed(context, 'login');
                  //Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
                },
              ),
              ])
          ],
        ),
      ),
    );
  }

}
