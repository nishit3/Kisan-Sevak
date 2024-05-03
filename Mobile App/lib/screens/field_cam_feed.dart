import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class FieldCamFeed extends StatefulWidget
{
  const FieldCamFeed({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FieldCamFeedState();
  }

}

class _FieldCamFeedState extends State<FieldCamFeed>
{
  var _isLoading = false;
  late ImageProvider camImage;

  void _loadImage() async
  {
    setState(() {
      _isLoading = true;
    });
    final response = await http.post(Uri.parse("https://ENDPOINT/prod/get-farm-img?fmUID=fm1"));
    final responseBodyBytes = response.bodyBytes;
    camImage = Image.memory(Uint8List.fromList(responseBodyBytes)).image;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _loadImage();
    Timer.periodic(const Duration(seconds: 10), (timer) {_loadImage();});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading? const Center(child: CircularProgressIndicator(),)
          :
      Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
              image: DecorationImage(image: camImage)
          ),
        ),
      ),
    );
  }

}
