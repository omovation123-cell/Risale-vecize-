import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'vecizeler.dart';

final FlutterLocalNotificationsPlugin _bildirim = FlutterLocalNotificationsPlugin();
bool _tzHazir = false;

void _zamanDilimiHazirla() {
  if (_tzHazir) return;
  tz.initializeTimeZones();
  try {
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  } catch (_) {}
  _tzHazir = true;
}

Future<void> bildirimBaslat({
  Function(String metin, String kaynak)? onFavori,
  Function(String metin, String kaynak, String eser)? onPaylas,
}) async {
  _zamanDilimiHazirla();
  const androidAyar = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ayarlar = InitializationSettings(android: androidAyar);

  await _bildirim.initialize(
    ayarlar,
    onDidReceiveNotificationResponse: (NotificationResponse res) {
      final payload = res.payload ?? '';
      if (payload.isEmpty) return;
      final parcalar = payload.split('|||');
      final metin = parcalar.isNotEmpty ? parcalar[0] : '';
      final kaynak = parcalar.length > 1 ? parcalar[1] : '';
      final eser = parcalar.length > 2 ? parcalar[2] : 'Risale-i Nur';

      if (res.actionId == 'fav_btn' && onFavori != null && metin.isNotEmpty) {
        onFavori(metin, kaynak);
      } else if (res.actionId == 'share_btn' && onPaylas != null && metin.isNotEmpty) {
        onPaylas(metin, kaynak, eser);
      }
    },
  );

  await izinleriIste();
}

Future<void> izinleriIste() async {
  if (!Platform.isAndroid) return;
  final android = _bildirim.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  if (android == null) return;
  await android.requestNotificationsPermission();
  final alarmOk = await android.canScheduleExactNotifications() ?? true;
  if (!alarmOk) {
    await android.requestExactAlarmsPermission();
  }
}

Future<bool> izinleriKontrolEt() async {
  if (!Platform.isAndroid) return true;
  final android = _bildirim.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  if (android == null) return true;
  final bildirimOk = await android.areNotificationsEnabled() ?? true;
  final alarmOk = await android.canScheduleExactNotifications() ?? true;
  return bildirimOk && alarmOk;
}

NotificationDetails _bildirimDetayi(Vecize v) {
  final icerik = v.arapca.isNotEmpty ? '${v.arapca}\n\n“${v.metin}”' : '“${v.metin}”';
  final androidDetay = AndroidNotificationDetails(
    'risale_vecize_kanali',
    'Risale-i Nur Vecizeleri',
    channelDescription: 'Günlük ve periyodik vecize bildirimleri',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    subText: v.eser,
    styleInformation: BigTextStyleInformation(
      icerik,
      contentTitle: v.kaynak,
      summaryText: v.eser,
    ),
    actions: const <AndroidNotificationAction>[
      AndroidNotificationAction('fav_btn', 'Favoriye Ekle', showsUserInterface: true),
      AndroidNotificationAction('share_btn', 'Paylaş', showsUserInterface: true),
    ],
  );
  return NotificationDetails(android: androidDetay);
}

Future<void> anlikTestBildirim(List<Vecize> vecizeler, int index, {bool huSesi = false}) async {
  if (vecizeler.isEmpty) return;
  await izinleriIste();
  final v = vecizeler[index % vecizeler.length];
  final icerik = v.arapca.isNotEmpty ? '${v.arapca}\n\n“${v.metin}”' : '“${v.metin}”';
  await _bildirim.show(
    99901,
    v.kaynak,
    icerik,
    _bildirimDetayi(v),
    payload: '${v.metin}|||${v.kaynak}|||${v.eser}',
  );
}

Future<void> zamanliTestBildirim(BuildContext context, List<Vecize> vecizeler, int index, {bool huSesi = false}) async {
  if (vecizeler.isEmpty) return;
  _zamanDilimiHazirla();
  await izinleriIste();
  final v = vecizeler[(index + 1) % vecizeler.length];
  final icerik = v.arapca.isNotEmpty ? '${v.arapca}\n\n“${v.metin}”' : '“${v.metin}”';
  final hedef = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

  try {
    await _bildirim.zonedSchedule(
      99902,
      v.kaynak,
      icerik,
      hedef,
      _bildirimDetayi(v),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: '${v.metin}|||${v.kaynak}|||${v.eser}',
    );
  } catch (_) {
    await _bildirim.zonedSchedule(
      99902,
      v.kaynak,
      icerik,
      hedef,
      _bildirimDetayi(v),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: '${v.metin}|||${v.kaynak}|||${v.eser}',
    );
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test kuruldu! Ekranı kilitleyin, 10 saniye içinde bildirim gelecek.')),
    );
  }
}

Future<String?> bildirimleriPlanla({
  required List<Vecize> vecizeler,
  required List<String> saatler,
  required bool periyodikAktif,
  required int periyodikDk,
  required int baslangicIndex,
  bool huSesi = false,
}) async {
  _zamanDilimiHazirla();
  await _bildirim.cancelAll();
  if (vecizeler.isEmpty) return null;

  final simdi = tz.TZDateTime.now(tz.local);
  tz.TZDateTime? enYakin;
  int idSayac = 100;
  int vIdx = baslangicIndex;

  for (final s in saatler) {
    final p = s.split(':');
    if (p.length != 2) continue;
    final saat = int.tryParse(p[0]) ?? 9;
    final dk = int.tryParse(p[1]) ?? 0;

    var hedef = tz.TZDateTime(tz.local, simdi.year, simdi.month, simdi.day, saat, dk);
    if (!hedef.isAfter(simdi)) {
      hedef = hedef.add(const Duration(days: 1));
    }

    final v = vecizeler[vIdx % vecizeler.length];
    vIdx++;
    final icerik = v.arapca.isNotEmpty ? '${v.arapca}\n\n“${v.metin}”' : '“${v.metin}”';

    try {
      await _bildirim.zonedSchedule(
        idSayac,
        v.kaynak,
        icerik,
        hedef,
        _bildirimDetayi(v),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '${v.metin}|||${v.kaynak}|||${v.eser}',
      );
    } catch (_) {
      await _bildirim.zonedSchedule(
        idSayac,
        v.kaynak,
        icerik,
        hedef,
        _bildirimDetayi(v),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '${v.metin}|||${v.kaynak}|||${v.eser}',
      );
    }

    idSayac++;
    if (enYakin == null || hedef.isBefore(enYakin)) {
      enYakin = hedef;
    }
  }

  if (periyodikAktif && periyodikDk > 0) {
    final adet = (1440 / periyodikDk).ceil().clamp(1, 48);
    for (int i = 1; i <= adet; i++) {
      final hedef = simdi.add(Duration(minutes: periyodikDk * i));
      final v = vecizeler[vIdx % vecizeler.length];
      vIdx++;
      final icerik = v.arapca.isNotEmpty ? '${v.arapca}\n\n“${v.metin}”' : '“${v.metin}”';

      try {
        await _bildirim.zonedSchedule(
          idSayac,
          v.kaynak,
          icerik,
          hedef,
          _bildirimDetayi(v),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: '${v.metin}|||${v.kaynak}|||${v.eser}',
        );
      } catch (_) {
        await _bildirim.zonedSchedule(
          idSayac,
          v.kaynak,
          icerik,
          hedef,
          _bildirimDetayi(v),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: '${v.metin}|||${v.kaynak}|||${v.eser}',
        );
      }

      idSayac++;
      if (enYakin == null || hedef.isBefore(enYakin)) {
        enYakin = hedef;
      }
    }
  }

  if (enYakin == null) return null;
  final h = enYakin.hour.toString().padLeft(2, '0');
  final m = enYakin.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
// --- BİLDİRİM DOSYASI BİTTİ ---
