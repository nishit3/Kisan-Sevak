import 'dart:async';
import 'dart:convert';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:kisan_sevak/screens/field_cam_feed.dart';
import 'package:kisan_sevak/screens/storage.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'notification.dart';

class FieldScreen extends StatefulWidget
{
  const FieldScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FieldScreenState();
  }

}

class _FieldScreenState extends State<FieldScreen>
{
  var _isLoading = true;

  var BestFertilizer;
  var Nitrogen;
  var Phosphorous;
  var Potassium;
  var lng;
  var Moisture;
  var fmUID;
  var RecommendedCrop;
  var rain;
  var pH;
  var Temperature;
  var lat;
  var Humidity;
  var selectedCropType;
  var selectedSoilType;

  void _loadData() async
  {
    setState(() {
      _isLoading = true;
    });
    final fieldModulesResponse = await http.get(Uri.parse('https://ENDPOINT/get-field-modules'),);
    final fieldModulesResponseBody = await jsonDecode(fieldModulesResponse.body);
    final fieldModulesList = await fieldModulesResponseBody['modules'];
    for (final module in fieldModulesList)
    {
       BestFertilizer = module["BestFertilizer"];
       Nitrogen = module["Nitrogen"];
       Phosphorous = module["Phosphorous"];
       Potassium = module["Potassium"];
       lng = module["lng"];
       Moisture = module["Moisture"];
       fmUID = module["fmUID"];
       RecommendedCrop = module["RecommendedCrop"];
       rain = module["rain"];
       pH = module["pH"];
       selectedSoilType = module["SoilType"];
       Temperature = module["Temperature"];
       lat = module["lat"];
       Humidity = module["Humidity"];
       selectedCropType = module["CropType"];
    }
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

  Future<void> makePostRequest(String CropType, String SoilType) async {
    final Map<String, String> postData = {
      "SoilType": SoilType,
      "CropType": CropType,
    };
      await http.post(
      Uri.parse('https://ENDPOINT/update-soil-crop-type?fmUID=fm1'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(postData)
      );
      _loadData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Field"),
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
        const Center(child: CircularProgressIndicator())
      :
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Recommended Fertilizer:  $BestFertilizer", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
              const SizedBox(height: 15,),
              Text("Recommended Crop:  $RecommendedCrop", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
              const SizedBox(height: 15,),
              Text("Predicted Rain (mm):  $rain", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
              const SizedBox(height: 15,),
              Text("Moisture % :  $Moisture", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
              const SizedBox(height: 15,),
              Text("Nitrogen:  $Nitrogen", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
              const SizedBox(height: 15,),
              Text("Phosphorous:  $Phosphorous", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
              const SizedBox(height: 15,),
              Text("Potassium:  $Potassium", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
              const SizedBox(height: 15,),
              Text("pH:  $pH", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
              const SizedBox(height: 15,),
              Text("Temperature °C :  $Temperature", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
              const SizedBox(height: 15,),
              Text("Humidity %RH :  $Humidity", style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16,)),
              const SizedBox(height: 15,),
              DropdownButton<String>(
                value: selectedSoilType,
                items: [ 'ST_Black', 'ST_Clayey', 'ST_Loamy', 'ST_Red', 'ST_Sandy',]
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.replaceAll('ST_', '')),
                  ),
                ).toList(),
                onChanged: (value) {
                  makePostRequest(selectedCropType, value!);
                },
              ),
              const SizedBox(height: 15,),
              DropdownButton<String>(
                value: selectedCropType,
                items: ['CT_Barley', 'CT_Cotton', 'CT_Ground Nuts', 'CT_Maize', 'CT_Millets',
                  'CT_Oil seeds', 'CT_Paddy', 'CT_Pulses', 'CT_Sugarcane', 'CT_Tobacco', 'CT_Wheat']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.replaceAll("CT_", "")),
                  ),
                ).toList(),
                onChanged: (value){
                  makePostRequest(value!, selectedSoilType);
                },
              ),
              const SizedBox(height: 25,),
              OutlinedButton(
                  onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FieldCamFeed(),));},
                  child: const Text("Live Cam", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),




      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.textIn,
        initialActiveIndex: 2,
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
