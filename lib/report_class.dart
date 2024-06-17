import 'dart:io';
import 'package:latlong2/latlong.dart';

class Report {
  String id;
  LatLng location;
  String type;
  String description;
  String? imagePath;
  File? image;

  Report({
    required this.id,
    required this.location,
    required this.type,
    required this.description,
    this.imagePath,
    this.image,
  });
}

List<Report> reports = [];
