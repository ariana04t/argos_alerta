import 'package:argos_app_v2/map_prin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:argos_app_v2/report_class.dart';

class EditReportScreen extends StatefulWidget {
  final Report report;

  EditReportScreen({required this.report});

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.report.description;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  final _database = FirebaseFirestore.instance;
  Future<void> _saveChanges() async {
    if (_descriptionController.text.isNotEmpty && _image != null) {
      try {
        FirebaseStorage st = _storage;

        st
            .refFromURL("gs://practihub-2428c.appspot.com/" + _image!.path)
            .putFile(
                _image!,
                SettableMetadata(
                  contentType: 'image/jpeg',
                ))
            .then((value) => {
                  debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>> image uploaded'),
                });
      } on FirebaseException catch (e) {
        debugPrint(e.toString());
      }
      final report = {
        'type': widget.report.type,
        'id': widget.report.id,
        'description': _descriptionController.text,
        'imagePath': _image!.path,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'latitude': widget.report.location.latitude,
        'longitude': widget.report.location.longitude,
      };
      _database.collection("reports").doc(widget.report.id).update(report).then(
        (value) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MapPrincipalScreen(),
            ),
          );
        },
      );
    } else if (_descriptionController.text.isNotEmpty && _image == null) {
      final report = {
        'type': widget.report.type,
        'id': widget.report.id,
        'description': _descriptionController.text,
        'imagePath': widget.report.image?.path,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'latitude': widget.report.location.latitude,
        'longitude': widget.report.location.longitude,
      };
      _database.collection("reports").doc(widget.report.id).update(report).then(
        (value) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MapPrincipalScreen(),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Reporte'),
        backgroundColor: const Color(0xFFFFD400), // Color Lúcuma
      ),
      body: SingleChildScrollView( // Envolvemos el contenido en SingleChildScrollView
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 10),
            _image == null
                ? Text('No hay imagen seleccionada.')
                : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.camera_alt, color: Colors.white),
              label: Text('Tomar Foto', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFFFD400)), // Color Lúcuma
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: Icon(Icons.save, color: Colors.white),
              label: Text('Guardar Cambios', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFFFD400)), // Color Lúcuma
              ),
            ),
          ],
        ),
      ),
    );
  }
}
