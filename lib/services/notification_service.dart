import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Hora local a la que se programa el recordatorio diario.
  static const int horaRecordatorio = 8;

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    await _configurarZonaLocal();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {},
    );

    await requestPermissions();
  }

  /// `timezone` arranca en UTC. Sin fijar la zona local, el recordatorio de
  /// las 08:00 se programaba a las 04:00 en Venezuela (UTC-4).
  static Future<void> _configurarZonaLocal() async {
    try {
      // flutter_timezone 5.x devuelve String; 4.x devolvia un objeto con
      // .identifier. Soportamos ambos para no romper al cambiar versiones.
      final dynamic info = await FlutterTimezone.getLocalTimezone();
      final nombre = info is String ? info : info?.identifier as String?;
      tz.setLocalLocation(tz.getLocation(nombre!));
    } catch (e) {
      debugPrint('NotificationService: zona local no disponible ($e)');
      try {
        tz.setLocalLocation(tz.getLocation('America/Caracas'));
      } catch (_) {}
    }
  }

  /// Android 13+ exige POST_NOTIFICATIONS en runtime; sin el permiso la
  /// notificacion programada nunca se muestra.
  static Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? true;
  }

  static Future<void> scheduleDailyCard() async {
    await requestPermissions();
    await _plugin.cancelAll();

    final tzLocation = tz.local;
    final now = tz.TZDateTime.now(tzLocation);

    var scheduledDate = tz.TZDateTime(
      tzLocation, now.year, now.month, now.day, horaRecordatorio, 0);
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
