import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _database = FirebaseFirestore.instance;
  final _descriptionController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitReport(String type) async {
    if (_descriptionController.text.isNotEmpty && _image != null) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final report = {
        'type': type,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'description': _descriptionController.text,
        'imagePath': _image!.path,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
      _database.collection("reports").add(report).then((value) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportar Incidente'),
      ),
      body: Padding(
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
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Tomar Foto'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitReport('Robo'),
              child: Text('Reportar Robo'),
            ),
            ElevatedButton(
              onPressed: () => _submitReport('Accidente'),
              child: Text('Reportar Accidente'),
            ),
          ],
        ),
      ),
    );
  }
}
