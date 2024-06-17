import 'package:argos_app_v2/descrip_report.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatelessWidget {
  final LatLng? location;

  const HomePage({super.key, this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar',
         style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto', // Cambia a la fuente que prefieras
          ),
        ),
        backgroundColor: Color(0xFFFFD400), // Color lucuma
        centerTitle: true,
      ),
      
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16.0),
        children: [
          ReportButton(
              icon: Icons.person_search,
              label: 'Desapariciones',
              onTap: () => navigateToReport(
                  context, 'Desapariciones', location)),
          ReportButton(
              icon: Icons.priority_high,
              label: 'Secuestro',
              onTap: () => navigateToReport(
                  context, 'Secuestro', location)),
          ReportButton(
              icon: Icons.person_off,
              label: 'Robo a persona',
              onTap: () =>
                  navigateToReport(context, 'Robo a persona', location)),
          ReportButton(
              icon: Icons.directions_car,
              label: 'Robo de vehículo',
              onTap: () =>
                  navigateToReport(context, 'Robo de vehículo', location)),
          ReportButton(
              icon: Icons.home,
              label: 'Robo a casa',
              onTap: () => navigateToReport(context, 'Robo a casa', location)),
          ReportButton(
              icon: Icons.visibility,
              label: 'Actividad sospechosa',
              onTap: () =>
                  navigateToReport(context, 'Actividad sospechosa', location)),
          ReportButton(
              icon: Icons.car_crash,
              label: 'Accidente',
              onTap: () => navigateToReport(context, 'Accidente', location)),
          ReportButton(
              icon: Icons.medication,
              label: 'Drogas',
              onTap: () => navigateToReport(context, 'Drogas', location)),
          ReportButton(
              icon: Icons.report_problem,
              label: 'Disturbios',
              onTap: () => navigateToReport(context, 'Disturbios', location)),
         
        ],
      ),
    );
  }

  void navigateToReport(
      BuildContext context, String reportType, LatLng? location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReportDetailPage(reportType: reportType, location: location),
      ),
    );
  }
}

class ReportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ReportButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});

@override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFFFD400), // Color lucuma
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto', // Cambia a la fuente que prefieras
              ),
            ),
          ],
        ),
      ),
    );
  }
}