import 'package:argos_app_v2/map_prin_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MapPrincipalScreen(), // Reemplaza HomePage con tu página de inicio
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFD400), // Color lucuma
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140.0, // Ajusta el tamaño del logo según tus necesidades
              height: 140.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/logo.png'), // Asegúrate de tener el logo en esta ruta
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Bienvenido(a) a Argos Alerta',
              style: TextStyle(
                fontFamily: 'Pacifico', // Usa una fuente bonita y profesional
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tu contenido de la página de inicio aquí
    );
  }
}
