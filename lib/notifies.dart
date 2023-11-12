// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';

class LocalNoticeService {
  static final LocalNoticeService _notificationService =
      LocalNoticeService._internal();

  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory LocalNoticeService() {
    return _notificationService;
  }
  LocalNoticeService._internal();

  Future<void> setup() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = IOSInitializationSettings(requestSoundPermission: true);

    const initSettings =
        InitializationSettings(android: androidSetting, iOS: iosSetting);

    await _localNotificationsPlugin.initialize(initSettings).then((_) {
      debugPrint('setupPlugin: setup success');
    }).catchError((Object error) {
      debugPrint('Error: $error');
    });
  }

  void addNotification(
    String title,
    String body, {
    String sound = '',
    String channel = '',
  }) async {
    final iosDetail = sound == ''
        ? null
        : IOSNotificationDetails(presentSound: true, sound: sound);

    final soundFile = sound.replaceAll('.mp3', '');
    final notificationSound =
        sound == '' ? null : RawResourceAndroidNotificationSound(soundFile);

    final androidDetail = AndroidNotificationDetails(
      channel, // channel Id
      channel, // channel Name
      priority: Priority.max,
      importance: Importance.max,
      audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      playSound: true,
      // groupKey: ,
      styleInformation:
          MediaStyleInformation(htmlFormatTitle: true, htmlFormatContent: true),
    );

    final noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
    );

    const id = 0;

    if (Platform.isIOS) {
      await _localNotificationsPlugin.show(
        id,
        title,
        body,
        noticeDetail,
      );
    } else {
      showSimpleNotification(
        Text(title),
        subtitle: Text(body),
        background: Colors.cyan.shade700,
        duration: Duration(seconds: 6),
      );
    }
  }

  void cancelAllNotification() {
    _localNotificationsPlugin.cancelAll();
  }
}
