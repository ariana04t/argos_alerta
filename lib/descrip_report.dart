import 'dart:io';

import 'package:argos_app_v2/map_prin_screen.dart';
import 'package:argos_app_v2/report_class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ReportDetailPage extends StatefulWidget {
  final String reportType;
  final LatLng? location;

  const ReportDetailPage({Key? key, required this.reportType, this.location})
      : super(key: key);

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  File? _selectedImage;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  final _database = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reportType,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto', // Cambia a la fuente que prefieras
          ),
        ),
        backgroundColor: Color(0xFFFFD400), // Color lucuma
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Envolvemos el contenido en SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: '¿Qué está pasando?',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFFFF8E1), // Amarillo pastel
                filled: true,
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.photo),
              label: Text('Subir fotos'),
              onPressed: () {
                _showPhotoDialog(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFFFFD400),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Tomar foto'),
              onPressed: () {
                _takePhoto(); // Llama a la función para tomar una foto
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFFFFD400),
              ),
            ),
            SizedBox(height: 16),
            if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                height: 200,
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.report),
              label: Text('REPORTAR'),
              onPressed: () {
                if (widget.location != null) {
                  //reportes_argos_app
                  if (_selectedImage != null) {
                    try {
                      FirebaseStorage st = _storage.storage;

                      st
                          .refFromURL("gs://practihub-2428c.appspot.com/" +
                              _selectedImage!.path)
                          .putFile(
                              _selectedImage!,
                              SettableMetadata(
                                contentType: 'image/jpeg',
                              ))
                          .then((value) => {
                                debugPrint(
                                    '>>>>>>>>>>>>>>>>>>>>>>>>>>>>> image uploaded'),
                              });
                    } on FirebaseException catch (e) {
                      debugPrint(e.toString());
                    }
                  }
                  //adding to cloudFirestore
                  Report report = Report(
                    id: "",
                    location: widget.location!,
                    type: widget.reportType,
                    description: _descriptionController.text,
                    image: _selectedImage,
                  );
                  String id = DateTime.now().millisecondsSinceEpoch.toString();
                  _database.collection('reports').doc(id).set({
                    'type': report.type,
                    'id': id,
                    'description': report.description,
                    'imagePath': report.image?.path,
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                    'latitude': report.location.latitude,
                    'longitude': report.location.longitude,
                  }).then((value) {
                    reports.add(report);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPrincipalScreen(),
                      ),
                      (route) => false,
                    );
                  });
                } else {
                  print('Error: No se pudo obtener la ubicación del usuario');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFFFFD400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Subir fotos'),
          content: Text('¿Deseas agregar fotos?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar el diálogo
                await _pickImage(); // Llamar a la función para seleccionar imágenes
              },
              child: Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagen seleccionada: ${image.path}')),
        );
      }
    } catch (e) {
      print('Error al seleccionar la imagen: $e');
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto tomada: ${image.path}')),
        );
      }
    } catch (e) {
      print('Error al tomar la foto: $e');
    }
  }
}
