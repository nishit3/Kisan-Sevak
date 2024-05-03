import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'field.dart';
import 'home.dart';
import 'notification.dart';

class StorageScreen extends StatefulWidget
{
  const StorageScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StorageScreenState();
  }

}

class _StorageScreenState extends State<StorageScreen>
{
  var _isLoading = true;

  var CO2;
  var Temperature;
  var Humidity;
  var fmUID;
  late ImageProvider camImage;

  void _loadData() async
  {
    setState(() {
      _isLoading = true;
    });
    final storageModulesResponse = await http.get(Uri.parse('https://ywqiiurra7.execute-api.ap-south-1.amazonaws.com/prod/get-storage-modules'),);
    final storageModulesResponseBody = await jsonDecode(storageModulesResponse.body);
    final storageModulesList = await storageModulesResponseBody['modules'];
    for (final module in storageModulesList)
    {
      CO2 = module["CO2"];
      Temperature = module["Temperature"];
      Humidity = module["Humidity"];
      fmUID = module["fmUID"];
    }
    final response = await http.post(Uri.parse("https://ywqiiurra7.execute-api.ap-south-1.amazonaws.com/prod/get-storage-img?fmUID=fm1"));
    final responseBodyBytes = response.bodyBytes;
    camImage = Image.memory(Uint8List.fromList(responseBodyBytes)).image;
    setState(() {
      _isLoading = false;
    });
  }


  @override
  void initState() {
    _loadData();
    Timer.periodic(const Duration(seconds: 10), (timer) {_loadData();});
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Storage"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationScreen(),));
            },
            icon: const Icon(Icons.notification_important),
          )
        ],
      ),



      body: _isLoading?
      const Center(child: CircularProgressIndicator(),)
          :
      SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("CO2 PPM:  $CO2", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
            const SizedBox(height: 15,),
            Text("Temperature °C:  $Temperature", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
            const SizedBox(height: 15,),
            Text("Humidity %RH:  $Humidity", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
            Container(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
              width: 600,
              height: 325,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                image: DecorationImage(image: camImage),
              ),
            ),
            const Text("Live Storage CAM Feed", style: TextStyle(fontWeight: FontWeight.bold, fontSize:20,)),
          ],
        ),
      ),

      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.textIn,
        initialActiveIndex: 0,
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
