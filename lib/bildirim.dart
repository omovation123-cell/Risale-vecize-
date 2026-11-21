import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'vecizeler.dart';

final FlutterLocalNotificationsPlugin _bildirim = FlutterLocalNotificationsPlugin();
void Function(Vecize)? _onPaylasCallback;
void Function(String)? _onFavoriCallback;

List<Vecize> adilKitapTuruHavuzu(List<Vecize> havuz, {bool karistir = false}) {
  if (havuz.isEmpty) return [];
  final gruplar = <String, List<Vecize>>{};
  for (final v in havuz) {
    gruplar.putIfAbsent(v.eser, () => []).add(v);
  }
  final kitaplar = gruplar.keys.toList();
  if (karistir) {
    final rnd = Random();
    kitaplar.shuffle(rnd);
    for (final k in kitaplar) {
      gruplar[k]!.shuffle(rnd);
    }
  }
  int maxUzunluk = 0;
  for (final liste in gruplar.values) {
    if (liste.length > maxUzunluk) maxUzunluk = liste.length;
  }
  final sirali = <Vecize>[];
  for (int tur = 0; tur < maxUzunluk; tur++) {
    for (final k in kitaplar) {
      final liste = gruplar[k]!;
      if (tur < liste.length) sirali.add(liste[tur]);
    }
  }
  return sirali;
}

Future<void> _arkaPlandaFavoriKaydet(String metin) async {
  if (metin.isEmpty) return;
  final prefs = await SharedPreferences.getInstance();
  final favs = prefs.getStringList('favoriler') ?? [];
  if (!favs.contains(metin)) {
    favs.add(metin);
    await prefs.setStringList('favoriler', favs);
  }
}

@pragma('vm:entry-point')
Future<void> arkaPlanBildirimAksiyonu(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (response.actionId == 'favori_ekle' && response.payload != null) {
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      await _arkaPlandaFavoriKaydet((data['metin'] ?? '').toString());
    } catch (_) {}
  }
}

Future<void> _bildirimYanitiIsle(NotificationResponse response) async {
  if (response.payload == null || response.payload!.isEmpty) return;
  try {
    final data = jsonDecode(response.payload!) as Map<String, dynamic>;
    final v = Vecize.fromMap(data);
    if (response.actionId == 'favori_ekle') {
      await _arkaPlandaFavoriKaydet(v.metin);
      _onFavoriCallback?.call(v.metin);
    } else if (response.actionId == 'paylas') {
      _onPaylasCallback?.call(v);
    }
  } catch (_) {}
}

Future<void> bildirimBaslat({
  void Function(Vecize)? onBildirimPaylas,
  void Function(String)? onBildirimFavori,
}) async {
  _onPaylasCallback = onBildirimPaylas;
  _onFavoriCallback = onBildirimFavori;

  tz.initializeTimeZones();
  try {
    final String yerelSaatDilimi = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(yerelSaatDilimi));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  }

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  await _bildirim.initialize(
    const InitializationSettings(android: android),
    onDidReceiveNotificationResponse: _bildirimYanitiIsle,
    onDidReceiveBackgroundNotificationResponse: arkaPlanBildirimAksiyonu,
  );

  final detay = await _bildirim.getNotificationAppLaunchDetails();
  if (detay != null && detay.didNotificationLaunchApp && detay.notificationResponse != null) {
    Future.delayed(const Duration(milliseconds: 600), () {
      _bildirimYanitiIsle(detay.notificationResponse!);
    });
  }

  final androidPlugin = _bildirim.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.requestNotificationsPermission();
  await androidPlugin?.requestExactAlarmsPermission();
}

Future<bool> alarmIzniKontrol() async {
  if (!Platform.isAndroid) return true;
  final androidPlugin = _bildirim.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  return await androidPlugin?.canScheduleExactNotifications() ?? true;
}

Widget alarmIzinUyarisi(bool izinVar) {
  if (izinVar) return const SizedBox.shrink();
  return Container(
    margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.redAccent),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Alarmlar ve Hatırlatıcılar İzni Kapalı', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 4),
        const Text('Bildirimlerin zamanında gelmesi için izin vermelisiniz.', style: TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            final p = _bildirim.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
            await p?.requestExactAlarmsPermission();
            await p?.requestNotificationsPermission();
          },
          icon: const Icon(Icons.alarm_on),
          label: const Text('İzni Şimdi Aç'),
        ),
      ],
    ),
  );
}

NotificationDetails _bildirimDetay(Vecize v, {bool huSesi = true}) {
  final govde = v.arapca.isNotEmpty
      ? '${v.arapca}\n\n“${v.metin}”\n— ${v.kaynak}'
      : '“${v.metin}”\n— ${v.kaynak}';

  return NotificationDetails(
    android: AndroidNotificationDetails(
      huSesi ? 'risale_hu_kanal_v1' : 'risale_varsayilan_kanal_v1',
      huSesi ? 'Risale-i Nur (Hû Sesi)' : 'Risale-i Nur (Standart)',
      channelDescription: 'Günlük ve saatlik Risale-i Nur vecize bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: huSesi ? const RawResourceAndroidNotificationSound('hu_sesi') : null,
      styleInformation: BigTextStyleInformation(govde),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'favori_ekle',
          'Favoriye Ekle',
          showsUserInterface: false,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'paylas',
          'Paylaş',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    ),
  );
}

Future<void> anlikTestBildirim(List<Vecize> havuz, int index, {bool huSesi = true}) async {
  if (havuz.isEmpty) return;
  final v = havuz[index % havuz.length];
  await _bildirim.show(
    999,
    'Risale-i Nur • ${v.eser}',
    '“${v.metin}” — ${v.kaynak}',
    _bildirimDetay(v, huSesi: huSesi),
    payload: jsonEncode(v.toMap()),
  );
}

Future<void> zamanliTestBildirim(BuildContext context, List<Vecize> havuz, int index, {bool huSesi = true}) async {
  if (havuz.isEmpty) return;
  final v = havuz[index % havuz.length];
  final hedef = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
  await _bildirim.zonedSchedule(
    998,
    'Risale-i Nur • ${v.eser}',
    '“${v.metin}” — ${v.kaynak}',
    hedef,
    _bildirimDetay(v, huSesi: huSesi),
    payload: jsonEncode(v.toMap()),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('10 saniye sonraya kuruldu. Şimdi uygulamayı kapatıp bekleyin.')),
    );
  }
}

Future<String?> bildirimleriPlanla({
  required List<Vecize> havuz,
  required List<String> saatler,
  required bool periyodikAktif,
  required int periyodikDk,
  bool huSesi = true,
}) async {
  await _bildirim.cancelAll();
  if (havuz.isEmpty) return null;
  final turHavuzu = adilKitapTuruHavuzu(havuz, karistir: true);
  final simdi = tz.TZDateTime.now(tz.local);
  int id = 100;

  for (int sIdx = 0; sIdx < saatler.length; sIdx++) {
    final p = saatler[sIdx].split(':');
    final saat = int.parse(p[0]);
    final dk = int.parse(p[1]);
    var ilk = tz.TZDateTime(tz.local, simdi.year, simdi.month, simdi.day, saat, dk);
    if (!ilk.isAfter(simdi)) ilk = ilk.add(const Duration(days: 1));

    for (int gun = 0; gun < 7; gun++) {
      final v = turHavuzu[(sIdx * 7 + gun) % turHavuzu.length];
      await _bildirim.zonedSchedule(
        id++,
        'Risale-i Nur • ${v.eser}',
        '“${v.metin}” — ${v.kaynak}',
        ilk.add(Duration(days: gun)),
        _bildirimDetay(v, huSesi: huSesi),
        payload: jsonEncode(v.toMap()),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  String? ilkPeriyodik;
  if (periyodikAktif) {
    final adet = min(48, (1440 / periyodikDk).ceil());
    for (int i = 1; i <= adet; i++) {
      final hedef = simdi.add(Duration(minutes: periyodikDk * i));
      ilkPeriyodik ??= '${hedef.hour.toString().padLeft(2, '0')}:${hedef.minute.toString().padLeft(2, '0')}';
      final v = turHavuzu[(i + saatler.length * 7) % turHavuzu.length];
      await _bildirim.zonedSchedule(
        id++,
        'Risale-i Nur • ${v.eser}',
        '“${v.metin}” — ${v.kaynak}',
        hedef,
        _bildirimDetay(v, huSesi: huSesi),
        payload: jsonEncode(v.toMap()),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
  return ilkPeriyodik;
}
// --- BİLDİRİM DOSYASI BİTTİ ---
