import 'package:argos_app_v2/edit_report_screen.dart';
import 'package:argos_app_v2/map_prin_screen.dart';
import 'package:argos_app_v2/report_class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';

class ReportDetailsScreen extends StatelessWidget {
  final String reportId;

  ReportDetailsScreen({required this.reportId});

  Future<String?> _getImageUrl(String imagePath) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(imagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting image URL: $e');
      return null;
    }
  }

  Future<void> _deleteReportAndImage(String? imagePath) async {
    try {
      if (imagePath != null) {
        // Delete the image from Firebase Storage
        final ref = FirebaseStorage.instance.ref().child(imagePath);
        await ref.delete();
      }
      // Delete the report from Firestore
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportId)
          .delete();
    } catch (e) {
      print('Error deleting report and image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Reporte'),
        backgroundColor: const Color(0xFFFFD400), // Color Lúcuma
      ),
      body: Container(
        color: Colors.white, // Fondo blanco
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reports')
              .doc(reportId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Reporte no encontrado'));
            }

            final reportData = snapshot.data!.data() as Map<String, dynamic>;
            final report = Report(
              id: snapshot.data!.id,
              location: LatLng(reportData['latitude'], reportData['longitude']),
              type: reportData['type'],
              description: reportData['description'],
              imagePath: reportData['imagePath'],
            );

            return SingleChildScrollView( // Envolvemos el contenido en SingleChildScrollView
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (report.imagePath != null)
                    FutureBuilder<String?>(
                      future: _getImageUrl(report.imagePath!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text('No hay imagen disponible');
                        }
                        return Image.network(snapshot.data!);
                      },
                    )
                  else
                    Text('No hay imagen disponible'),
                  SizedBox(height: 16.0),
                  Text(
                    'Tipo: ${report.type}',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Descripción: ${report.description}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditReportScreen(report: report),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit, color: Colors.white),
                    label: Text('Editar Reporte', style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xFFFFD400)), // Color Lúcuma
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _deleteReportAndImage(report.imagePath);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapPrincipalScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.delete, color: Colors.white),
                    label: Text('Eliminar Reporte', style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xFFFFD400)), // Color Lúcuma
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
