import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/notification.dart';
import '../widgets/single_notification.dart';

class NotificationScreen extends StatefulWidget
{
  const NotificationScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NotificationScreenState();
  }

}

class _NotificationScreenState extends State<NotificationScreen>
{

  Widget screenContent = const Center(child: Text("No Notifications",style: TextStyle(fontSize: 21,color: Colors.black)),);
  bool isLoading = false;
  List<NotificationData> availableNotifications = [];
  void _onBackPress()
  {
    Navigator.of(context).pop();
  }

  void _loadNotifications() async
  {
    availableNotifications.clear();
    setState(() {
      isLoading=true;
    });
    final response = await http.get(Uri.parse('https://ywqiiurra7.execute-api.ap-south-1.amazonaws.com/prod/get-farm-alert-notifs'),);
    final responseBody = await jsonDecode(response.body);
    final notificationsMapList = await responseBody['alerts'];

    for(final notification in notificationsMapList)
    {
      availableNotifications.add(
          NotificationData(
              message: notification['Msg'],
              notificationType: notification['Type'],
              notifUID: notification['notifUID']
          )
      );
    }


    if(availableNotifications.isNotEmpty)
    {
      setState(() {
        screenContent = SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(9, 17, 17, 17),
          child: Column(
            children: [
              ...availableNotifications.map((e) => SingleNotification(notification: e))
            ],
          ),
        );
        isLoading=false;
      });
    }
    else if(availableNotifications.isEmpty)
    {
      setState(() {
        screenContent = const Center(child: Text("No Notifications",style: TextStyle(fontSize: 21,color: Colors.black)),);
        isLoading=false;
      });
    }
  }

  @override
  void initState() {
    _loadNotifications();
    Timer.periodic(const Duration(seconds: 10), (timer) { _loadNotifications();});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    if(isLoading)
    {
      screenContent = const Center(child: CircularProgressIndicator(),);
    }

    return Scaffold(
        appBar : AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back,color: Colors.white), onPressed: _onBackPress),
          backgroundColor: Colors.blueAccent.shade400,
          title: const Text("Alerts",style: TextStyle(color: Colors.white)),
        ),

        body: screenContent

    );
  }

}