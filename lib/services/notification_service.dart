import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {},
    );
  }

  static Future<void> scheduleDailyCard() async {
    await _plugin.cancelAll();

    final location = await FlutterNativeTimezone.getLocalTimezone();
    final tzLocation = tz.getLocation(location);
    final now = tz.TZDateTime.now(tzLocation);

    var scheduledDate = tz.TZDateTime(
      tzLocation, now.year, now.month, now.day, 8, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      'PsicoTarot - Carta del Dia',
      'Tu carta del dia te espera. Abre la app para descubrirla.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_card_channel',
          'Carta del Dia',
          channelDescription: 'Notificacion diaria de la carta del tarot',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelScheduled() async {
    await _plugin.cancelAll();
  }
}
