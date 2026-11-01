import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/models.dart';

/// Reminder muncul di H-3 sebelum kadaluarsa (jam 08:00 WIB).
/// Kalau sisa hari sudah <= 3 saat barang dimasukkan, notif muncul beberapa detik kemudian.
class NotificationService {
  static final _p = FlutterLocalNotificationsPlugin();
  static const reminderDaysBefore = 3;

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // ganti kalau mau multi zona waktu
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _p.initialize(init);
    await _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails('expiry', 'Pengingat Kadaluarsa',
        importance: Importance.high, priority: Priority.high),
    iOS: DarwinNotificationDetails(),
  );

  static int _id(FoodItem f) => f.id.hashCode & 0x7fffffff;

  static Future<void> scheduleExpiry(FoodItem f) async {
    if (f.daysLeft < 0) return;
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, f.expiry.year, f.expiry.month, f.expiry.day - reminderDaysBefore, 8);
    var days = reminderDaysBefore;
    if (when.isBefore(now)) {
      when = now.add(const Duration(seconds: 5));
      days = f.daysLeft;
    }
    final body = days == 0
        ? '${f.name} kadaluarsa HARI INI. Yuk segera dimasak!'
        : '${f.name} akan membusuk/kadaluarsa $days hari lagi. Yuk segera dimasak!';
    await _p.zonedSchedule(
      _id(f),
      'Peringatan Kadaluarsa ⚠️',
      body,
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancel(FoodItem f) => _p.cancel(_id(f));
}
