import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'vecizeler.dart';

final notificationsPlugin = FlutterLocalNotificationsPlugin();

const _bildirimDetay = NotificationDetails(
  android: AndroidNotificationDetails(
    'risale_vecize_kanal',
    'Risale-i Nur Vecize',
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(''),
  ),
);

Future<void> bildirimBaslat() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  await notificationsPlugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  final android = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await android?.requestNotificationsPermission();
  await android?.createNotificationChannel(
    const AndroidNotificationChannel('risale_vecize_kanal', 'Risale-i Nur Vecize', importance: Importance.max),
  );
}

Future<bool> alarmIzniKontrol() async {
  final android = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  return await android?.canScheduleExactNotifications() ?? true;
}

Future<void> _zamanla({
  required int id,
  required String title,
  required String body,
  required tz.TZDateTime hedef,
  DateTimeComponents? tekrar,
}) async {
  try {
    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: hedef,
      notificationDetails: _bildirimDetay,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: tekrar,
    );
  } catch (_) {
    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: hedef,
      notificationDetails: _bildirimDetay,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: tekrar,
    );
  }
}

Future<String?> bildirimleriPlanla({
  required List<Vecize> havuz,
  required List<String> saatler,
  required bool periyodikAktif,
  required int periyodikDk,
}) async {
  await notificationsPlugin.cancelAll();
  if (havuz.isEmpty) return null;
  final rnd = Random();
  final simdi = tz.TZDateTime.now(tz.local);
  String? ilkSaat;

  for (int i = 0; i < saatler.length; i++) {
    final p = saatler[i].split(':');
    var hedef = tz.TZDateTime(tz.local, simdi.year, simdi.month, simdi.day, int.parse(p[0]), int.parse(p[1]));
    if (hedef.isBefore(simdi)) hedef = hedef.add(const Duration(days: 1));
    final v = havuz[rnd.nextInt(havuz.length)];
    await _zamanla(id: 100 + i, title: 'Risale-i Nur • ${v.kaynak}', body: '“${v.metin}”', hedef: hedef, tekrar: DateTimeComponents.time);
  }

  if (periyodikAktif && periyodikDk >= 1) {
    for (int k = 1; k <= 24; k++) {
      final hedef = simdi.add(Duration(minutes: periyodikDk * k));
      if (k == 1) ilkSaat = '${hedef.hour.toString().padLeft(2, '0')}:${hedef.minute.toString().padLeft(2, '0')}';
      final v = havuz[rnd.nextInt(havuz.length)];
      await _zamanla(id: 500 + k, title: 'Risale-i Nur • ${v.kaynak}', body: '“${v.metin}”', hedef: hedef);
    }
  }
  return ilkSaat;
}

Future<void> anlikTestBildirim(List<Vecize> havuz, int index) async {
  if (havuz.isEmpty) return;
  final v = havuz[index % havuz.length];
  await notificationsPlugin.show(id: 999, title: 'Risale-i Nur • ${v.kaynak}', body: '“${v.metin}”', notificationDetails: _bildirimDetay);
}

Future<void> zamanliTestBildirim(BuildContext context, List<Vecize> havuz, int index) async {
  if (havuz.isEmpty) return;
  final v = havuz[index % havuz.length];
  final hedef = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
  await _zamanla(id: 998, title: 'Risale-i Nur • ${v.kaynak}', body: '“${v.metin}”', hedef: hedef);
  if (context.mounted) {
    final saat = '${hedef.hour.toString().padLeft(2, '0')}:${hedef.minute.toString().padLeft(2, '0')}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(seconds: 4), content: Text('1 dk sonrası ($saat) için test kuruldu. Ekranı kapatıp bekleyin.')),
    );
  }
}

Widget alarmIzinUyarisi(bool izinVar) {
  if (izinVar) return const SizedBox.shrink();
  return Container(
    margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFD97706))),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
        const SizedBox(width: 10),
        const Expanded(child: Text('Zamanlı bildirimler için telefonun alarm iznini açın.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
          onPressed: () async {
            final android = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
            await android?.requestExactAlarmsPermission();
          },
          child: const Text('İzni Aç'),
        ),
      ],
    ),
  );
}
// --- BİLDİRİM DOSYASI BİTTİ ---
