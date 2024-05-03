import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class PlantDiseaseScreen extends StatefulWidget
{
  const PlantDiseaseScreen({super.key});

  @override
  State<PlantDiseaseScreen> createState() {
    return PlantDiseaseScreenState();
  }
}

class PlantDiseaseScreenState extends State<PlantDiseaseScreen>
{
  File? _selectedImage;
  bool _isProcessed = false;
  String _predictions = "";
  bool _isPredicting = false;
  final String _apiEndpoint = "https://ENDPOINT.ngrok-free.app/detectPlantDisease";

  Future _predictAndDisplay() async
  {
    setState(() {
      _predictions = "";
      _isPredicting = true;
      _isProcessed = false;
    });

    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, String> body = {'b64EncodedImgString': _toBase64String(_selectedImage!)};
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        _predictions = responseData["predictedDisease"];
        _predictions = _predictions.substring(_predictions.indexOf("___")+3);
        _predictions = _predictions.replaceAll("_", " ");
        _predictions = "Detected Disease:-  $_predictions";
      } else {
        _predictions = "Error Occurred";
      }
    } catch (e) {
      _predictions = "Error Occurred";
    }

    setState(() {
      _isProcessed = true;
      _isPredicting = false;
    });
  }

  void _onBackPress()
  {
    Navigator.of(context).pop();
  }

  Future _pickFromCamera() async
  {
    XFile? imgData = await ImagePicker().pickImage(source: ImageSource.camera);
    if (imgData == null) return;
    setState(() {
      _selectedImage = File(imgData.path);
    });
    await _predictAndDisplay();
  }

  Future _pickFromGallery() async
  {
    XFile? imgData = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imgData == null) return;
    setState(() {
      _selectedImage = File(imgData.path);
    });
    await _predictAndDisplay();
  }

  String _toBase64String(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64String = base64Encode(imageBytes);
    return base64String;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plant Disease Detector"),
        leading:  IconButton(icon: const Icon(Icons.arrow_back,color: Colors.white), onPressed: _onBackPress),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedImage != null) Container(
                margin: const EdgeInsets.all(10),
                height: 300,
                width: 380,
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
              else const Text("Please Select Image", style: TextStyle(color: Colors.black, fontSize: 20),),
              const SizedBox(height: 50,),
              if (_isProcessed && !_isPredicting) Text(_predictions)
              else if (_isPredicting && !_isProcessed) const Center(child: CircularProgressIndicator(),),
              const SizedBox(height: 40,),
              IconButton(
                onPressed: _pickFromCamera,
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blueAccent),
                  shape: MaterialStatePropertyAll(CircleBorder()),
                  padding: MaterialStatePropertyAll(EdgeInsets.all(24))
                ),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
              ),
              const SizedBox(height: 10,),
              IconButton(
                onPressed: _pickFromGallery,
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.blueAccent),
                    shape: MaterialStatePropertyAll(CircleBorder()),
                    padding: MaterialStatePropertyAll(EdgeInsets.all(24))
                ),
                icon: const Icon(Icons.photo_size_select_actual, color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
