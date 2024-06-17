import 'package:argos_app_v2/edit_report_screen.dart';
import 'package:argos_app_v2/report_class.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:argos_app_v2/buttom.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:geocoding/geocoding.dart';
import 'report_details_screen.dart';

const double safetyRadius = 50;
const int yellowLimit = 4;
const int orangeLimit = 7;

double calculateDistance(LatLng point1, LatLng point2) {
  return Geolocator.distanceBetween( //CALCULA LA DISTANCIA ENTRE 2 PUNTOS, ENTRE 2 CIUDADES
    point1.latitude, //metodo
    point1.longitude, //LATLNG CLASE QUE REPRESENTA UNA COORDENADA GEOGRAFICA
    point2.latitude,
    point2.longitude,
  );
}

class MapPrincipalScreen extends StatefulWidget {
  const MapPrincipalScreen({super.key});

  @override
  State<MapPrincipalScreen> createState() => _MapPrincipalScreenState(); //se crea una instancia del estado asociado a ese widget
}

class _MapPrincipalScreenState extends State<MapPrincipalScreen> {
  LatLng? myPosition; //guarda la posicion actual del usuario
  LatLng? searchPosition; //guarda la posicion de busqueda
  TextEditingController searchController = TextEditingController(); //controlador para el campo de texto de busqueda
  final MapController mapController = MapController(); //controlador del mapa
  bool isInDangerZone = false; //Indica si el usuario está en una zona de peligro.
  final _database = FirebaseFirestore.instance; //Instancia de Firestore para acceder a la base de datos.
  List<Report> reports = []; //Lista de reportes obtenidos de la base de datos.

  Future<Position> determinePosition() async { // es si o no, una de dos
    bool serviceEnabled; //Verifica si los servicios de ubicación están habilitados.
    LocationPermission permission; //Verifica y solicita permisos de ubicación.

    serviceEnabled = await Geolocator.isLocationServiceEnabled(); //Obtiene la posición actual si los permisos son concedidos.
    if (!serviceEnabled) { //serviciohabilitado ! es false cambia el valor
      return Future.error('Location services are disabled.'); //estan desabilitados
    } //future valor que puede estar disponible en el futuro

    permission = await Geolocator.checkPermission(); //asigna el valor de la derecha a la variable de la izquierda y se comprueba el estado actual del permiso
    if (permission == LocationPermission.denied) { //compara dos valores - si el permiso de localización ha sido denegado
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) { //denegado permanentemente.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');// no se puede solictR PERMISOS
    }

    return await Geolocator.getCurrentPosition(); //se obtiene y devuelve la posición actual del dispositivo
  }

  void getCurrentLocation() async { //Llama a determinePosition para obtener la ubicación y actualizar myPosition.
    try {
      Position position = await determinePosition();
      setState(() {
        myPosition = LatLng(position.latitude, position.longitude);
        print(myPosition);
        _checkProximityToReport(myPosition!);
      });
    } catch (e) {
      print('Could not determine location: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri( //Un URI (Identificador Uniforme de Recursos) es una cadena de caracteres que identifica un recurso en internet.
      scheme: 'tel',
      path: phoneNumber, //url es el medio para localizar
    );//Verifica si hay una aplicación disponible en el dispositivo 
    if (await canLaunch(launchUri.toString())) { //Convierte la URI a una cadena y verifica si se puede lanzar.
      await launch(launchUri.toString());
    } else {
      throw 'Could not launch $phoneNumber'; //describe el error
    } //lanzar una excepcion
  }

  Future<void> _showHospitalOptions(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, //Permite que el diálogo se cierre si el usuario toca fuera de él.
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona una opción'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextButton(
                  child: const Text('Llamar al seguro EsSalud'),
                  onPressed: () {
                    Navigator.of(context).pop();//cierra la pantalla actual y regresa a la pantalla anterior.
                    _showConfirmationDialog(
                        context, '922424297', '¿Quieres realizar la llamada?');
                  },
                ),
                TextButton(
                  child: const Text('Llamar a un hospital privado'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showConfirmationDialog(
                        context, '922424297', '¿Quieres realizar la llamada?');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String phoneNumber, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sí'),
              onPressed: () {
                Navigator.of(context).pop();
                _makePhoneCall(phoneNumber);
              },
            ),
          ],
        );
      },
    );
  }

  void _activateAlarm() async {
    Vibration.vibrate(duration: 5000);//Hace vibrar el dispositivo.
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/alarm.mp3'));//Reproduce un archivo de sonido alarm.mp3.
  }

  void _checkProximityToReport(LatLng position) {
    if (reports.isEmpty) {//Comprueba si la lista de reportes está vacía.
      setState(() {//Actualiza el estado de la variable isInDangerZone a false si no hay reportes
        isInDangerZone = false;
      });
      debugPrint(isInDangerZone.toString());//Imprime el valor de isInDangerZone en la consola para fines de depuración.
      return;
    }

    bool inDanger = false;//se utilizará para determinar si el usuario está en una zona de peligro.
    for (Report report in reports) {//Itera sobre cada reporte en la lista de reports.
      double distance = calculateDistance(position, report.location);//Calcula la distancia entre la posición actual del usuario (position) y la ubicación del reporte (report.location).
      if (distance <= safetyRadius) {//Comprueba si la distancia calculada es menor o igual al safetyRadius (el radio de seguridad definido).
        inDanger = true;
        _activateAlarm();
        break;// Sale del bucle tan pronto como se encuentra un reporte dentro de la zona de peligro.
      }
    }

    setState(() {
      isInDangerZone = inDanger;//e reflejará si el usuario está en una zona de peligro.
    });

    debugPrint(isInDangerZone.toString());
  }

  void _searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          searchPosition = LatLng(location.latitude, location.longitude);
        });
        mapController.move(searchPosition!, 15);
      }
    } catch (e) {
      print('Could not find location: $e');
    }
  }

  void _showLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leyenda de colores'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                ListTile(
                  leading: Icon(Icons.circle, color: Colors.yellow),
                  title: Text('Pocos reportes (Seguridad: Alta)'),
                ),
                ListTile(
                  leading: Icon(Icons.circle, color: Colors.orange),
                  title: Text('Medio reportes (Seguridad: Media)'),
                ),
                ListTile(
                  leading: Icon(Icons.circle, color: Colors.red),
                  title: Text('Muchos reportes (Seguridad: Baja)'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color getCircleColor(int reportCount) {
    if (reportCount < yellowLimit) {
      return Colors.transparent;
    } else if (reportCount < orangeLimit) {
      return Colors.yellow.withOpacity(0.3);
    } else if (reportCount < 10) {
      return Colors.orange.withOpacity(0.3);
    } else {
      return Colors.red.withOpacity(0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Buscar lugares',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _searchLocation(searchController.text);
              },
            ),
          ),
          onSubmitted: (value) {
            _searchLocation(value);
          },
        ),
        backgroundColor: const Color(0xFFFFD400),
      ),
      body: StreamBuilder<QuerySnapshot>( //DETECTA CAMBIOS, APARECE, RENDERIZAR EL MAPA, ACTUALIZAR LAS UBICACIONES
        stream: _database.collection("reports").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); //CARGA TODOS LOS REPORTES
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          reports = snapshot.data!.docs.map((doc) { //LISTA VACIA , OBLIGATORIAMENTE LLENO 
            final report = doc.data() as Map<String, dynamic>; //DOC QUE SE ESTA LISTANDO, COMO UN MAPA DE TEXTO DINAMICO, OBJETO JSON

            return Report(
              id: doc.id,
              location: LatLng(report['latitude'], report['longitude']),
              type: report['type'],
              description: report['description'],
            );
          }).toList();

          List<Marker> markers = reports.map((report) { //MAPEAR LOS REPORTES - VARIABLE DIRECTA
            return Marker(
              point: report.location,
              width: 48,
              height: 48,
              builder: (context) {
                return IconButton(
                  icon: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    fill: 0.5,
                    size: 48,
                  ),
                  onPressed: () {
                    print('Report tapped: ${report.description}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReportDetailsScreen(reportId: report.id), //COMO PARA JALAR PORQUE YA TODO SE TIENE  UNA LISTA
                      ),
                    );
                  },
                );
              },
            );
          }).toList();

          if (searchPosition != null) {
            markers.add(
              Marker(
                point: searchPosition!,
                builder: (context) => const Icon(
                  Icons.location_pin,
                  color: Colors.red, //BUSCADOR
                  size: 40,
                ),
              ),
            );
          }

          CircleMarker dangerZoneCircle = CircleMarker(
            point: myPosition ?? LatLng(0, 0),
            color: getCircleColor(reports.length),
            borderStrokeWidth: 2,
            borderColor: getCircleColor(reports.length),
            radius: safetyRadius,
          );

          return myPosition == null //CARGAR MAPA
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: myPosition,
                    minZoom: 5,
                    maxZoom: 25,
                    zoom: 18,
                  ),
                  nonRotatedChildren: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.argos_app_v2',
                      tileSize: 256,
                      minNativeZoom: 0,
                      maxNativeZoom: 19,
                      maxZoom: 25,
                    ),
                    if (myPosition != null)
                      CircleLayer(circles: [dangerZoneCircle]),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: myPosition!,
                          color: getCircleColor(reports.length),
                          borderStrokeWidth: 2,
                          borderColor: getCircleColor(reports.length),
                          radius: safetyRadius,
                        ),
                      ],
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(location: myPosition)),
              );
            },
            backgroundColor: const Color(0xFFFFD400),
            child: const Icon(Icons.security),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              _showHospitalOptions(context);
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.local_hospital),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              _showConfirmationDialog(context, '922424297',
                  '¿Quieres llamar a la policía Chincha?');
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.local_police),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              _showLegend(context);
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}

class MapMarker extends StatefulWidget {
  const MapMarker({Key? key, required this.report}) : super(key: key);
  final Report report;
  @override
  _MapMarkerState createState() => _MapMarkerState();
}

class _MapMarkerState extends State<MapMarker> {
  final key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return InkWell(//detecta gestos como toques y proporciona un efecto visual al ser tocado.
      onTap: () {//se ejecuta una función que obtiene el estado actual del tooltip asociado al marcador y asegura que sea visible. T
        final dynamic tooltip = key.currentState;//Tooltip para mostrar información adicional cuando se toca el marcador.
        tooltip.ensureTooltipVisible();
        debugPrint('Marker tapped');
      },
      child: Tooltip(
        key: key,//muestra un mensaje emergente informativo cuando se mantiene presionado o se pasa el mouse sobre otro widget.
        message: "widget.x.name",
        textStyle: TextStyle(color: Colors.white),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Container(
          child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditReportScreen(report: widget.report)),
                );
              },
              icon: Icon(Icons.location_pin, color: Colors.red)),
        ),
      ),
    );
  }
}
