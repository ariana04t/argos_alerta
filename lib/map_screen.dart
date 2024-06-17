import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'report_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ignore: unused_field
  GoogleMapController? _controller;
  final _database = FirebaseFirestore.instance;
  final Set<Marker> _markers = {};

  @override
  void initState() {//objeto que contiene los resultados de una consulta a una colección o subcolección en Firestore,
    super.initState();
    _database.collection("reports").get().then((QuerySnapshot querySnapshot) {//obtener todos los documentos dentro de la colección "reports" en Firebase Firestore.
      querySnapshot.docs.forEach((doc) {
        final report = doc.data() as Map<String, dynamic>;
        final marker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(report['latitude'], report['longitude']),
          infoWindow: InfoWindow(
            title: report['type'],
            snippet: report['description'],
          ),
        );
        setState(() {
          _markers.add(marker);
        });
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Reportes'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(-13.53195, -76.00983),
          zoom: 15,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportScreen()),
          );
        },
        child: Icon(Icons.report),
      ),
    );
  }
}
