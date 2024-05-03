import 'dart:async';
import 'dart:convert';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kisan_sevak/screens/notification.dart';
import 'package:kisan_sevak/screens/plant_disease.dart';
import 'package:kisan_sevak/screens/storage.dart';
import 'field.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget
{
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }}


class _HomeScreenState extends State<HomeScreen>
{
  var _isLoading = true;
  final Set<Marker> _markersList = {};
  static CameraPosition _initialPosition = const CameraPosition(
      target: LatLng(23.5, 72.0),
      zoom: 14,
  );

  Completer<GoogleMapController> mapController = Completer();

  void _loadData() async
  {
    setState(() {
      _isLoading = true;
    });

    final fieldModulesResponse = await http.get(Uri.parse('https://ENDPOINT/prod/get-field-modules'),);
    final fieldModulesResponseBody = await jsonDecode(fieldModulesResponse.body);
    final fieldModulesList = await fieldModulesResponseBody['modules'];
    for (final module in fieldModulesList)
    {
      _markersList.add(
        Marker(
            markerId: MarkerId(module["fmUID"]),
            position: LatLng(module["lat"], module["lng"]),
            visible: true,
            draggable: false,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: " Field Module"),
        )
      );
    }

    final storageModulesResponse = await http.get(Uri.parse('https://ENDPOINT/prod/get-storage-modules'),);
    final storageModulesResponseBody = await jsonDecode(storageModulesResponse.body);
    final storageModulesList = await storageModulesResponseBody['modules'];
    for (final module in storageModulesList)
    {
      _markersList.add(
          Marker(
            markerId: MarkerId("s"+(module["fmUID"])),
            position: LatLng(module["lat"], module["lng"]),
            visible: true,
            draggable: false,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: " Storage Module"),
          )
      );
    }
    _initialPosition = CameraPosition(
      target: LatLng(fieldModulesList[0]["lat"], fieldModulesList[0]["lng"]),
      zoom: 16,
    );
    setState(() {
      _isLoading = false;
    });

  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PlantDiseaseScreen(),));
                  },
                icon: const Icon(Icons.camera_alt)
            ),
          IconButton(
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationScreen(),));
                },
                icon: const Icon(Icons.notification_important),
            ),
        ],
      ),



      body: _isLoading?
      const Center(child: CircularProgressIndicator(),)
          :
      GoogleMap(
        initialCameraPosition: _initialPosition,
        mapToolbarEnabled: false,
        markers: _markersList,
        onMapCreated: (controller) {
          mapController.complete(controller);
        },
      ),


      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.textIn,
        initialActiveIndex: 1,
        items: const [
          TabItem(icon: Icons.store, title: "Storage"),
          TabItem(icon: Icons.location_on_sharp, title: "Location"),
          TabItem(icon: Icons.accessibility_sharp, title: "Field"),
        ],
        onTap: (localIndex) {
          if(localIndex == 0)
            {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const StorageScreen(),));
            }
          else if(localIndex == 1)
            {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen(),));
            }
          else if (localIndex == 2)
            {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const FieldScreen(),));
            }

        },
      ),
    );
  }
  
}
