import 'package:flutter/material.dart';

Icon notificationTypeIconProvider(String notificationType)
{
  if(notificationType.toUpperCase().trim() == "FA")
  {
    return const Icon(Icons.dangerous_outlined,size: 34,);
  }
  else if(notificationType.toUpperCase().trim() == "CO2")
  {
    return const Icon(Icons.warning_amber, size: 34);
  }
  else if(notificationType.toUpperCase().trim() == "FL")
  {
    return const Icon(Icons.fireplace_outlined, size: 34);
  }
  else
  {
    return const Icon(Icons.water_drop_outlined, size: 34);
  }
}

class NotificationData
{
  String notifUID;
  String message;
  String notificationType;
  Icon icon;
  NotificationData({required this.message, required this.notificationType, required this.notifUID}) : icon = notificationTypeIconProvider(notificationType);
}