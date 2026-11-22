import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'vecizeler.dart';

final FlutterLocalNotificationsPlugin _bildirim = FlutterLocalNotificationsPlugin();
bool _tzHazir = false;
bool _motorHazir = false;
List<Vecize> _sonHavuz = [];
Function(Vecize v)? _paylasCallback;
Function(String metin)? _favoriCallback;

const AndroidNotificationChannel _vecizeKanali = AndroidNotificationChannel(
  'risale_vecize_alarm_v6',
  'Risale-i Nur Vecizeleri',
  description: 'Günlük ve periyodik vecize bildirimleri',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

void _zamanDilimiHazirla() {
  if (_tzHazir) return;
  try {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  } catch (_) {}
  _tzHazir = true;
}

Future<void> _motoruHazirla() async {
  _zamanDilimiHazirla();
  if (_motorHazir) return;

  const androidAyar = AndroidInitializationSettings('@drawable/ic_bildirim');
  const ayarlar = InitializationSettings(android: androidAyar);

  await _bildirim.initialize(
    ayarlar,
    onDidReceiveNotificationResponse: (NotificationResponse res) {
      final payload = res.payload ?? '';
      if (payload.isEmpty) return;

      if (res.actionId == 'fav_btn' && _favoriCallback != null) {
        _favoriCallback!(payload);
      } else if (res.actionId == 'share_btn' && _paylasCallback != null) {
        final eslesen = _sonHavuz.where((e) => e.metin == payload).toList();
        if (eslesen.isNotEmpty) {
          _paylasCallback!(eslesen.first);
        }
      }
    },
  );

  final android = _bildirim.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  if (android != null) {
    await android.createNotificationChannel(_vecizeKanali);
  }

  _motorHazir = true;
}

Future<void> bildirimBaslat({
  Function(Vecize v)? onBildirimPaylas,
  Function(String metin)? onBildirimFavori,
}) async {
  _paylasCallback = onBildirimPaylas;
  _favoriCallback = onBildirimFavori;
  try {
    await _motoruHazirla();
  } catch (_) {}
}

Future<bool> alarmIzniKontrol() async {
  if (!Platform.isAndroid) return true;
  try {
    await _motoruHazirla();
    final android = _bildirim.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;

    bool bildirimOk = true;
    try {
      bildirimOk = await android.areNotificationsEnabled() ?? true;
      if (!bildirimOk) {
        await android.requestNotificationsPermission();
        bildirimOk = await android.areNotificationsEnabled() ?? true;
      }
    } catch (_) {}

    try {
      final alarmOk = await android.canScheduleExactNotifications() ?? true;
      if (!alarmOk) {
        await android.requestExactAlarmsPermission();
      }
    } catch (_) {}

    return bildirimOk;
  } catch (_) {
    return true;
  }
}

Widget alarmIzinUyarisi(bool izinVar) {
  if (izinVar) return const SizedBox.shrink();
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.amber.shade100,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.amber.shade800, width: 1.2),
    ),
    child: Row(
      children: [
        Icon(Icons.notifications_off_outlined, color: Colors.amber.shade900),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Bildirim izni kapalı görünüyor. Vaktinde vecize gelmesi için izin verin.',
            style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w600, fontSize: 12.5),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.amber.shade900,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () => alarmIzniKontrol(),
          child: const Text('İzin Ver', style: TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );
}

List<Vecize> adilKitapTuruHavuzu(List<Vecize> kaynakListe, {bool karistir = true}) {
  if (kaynakListe.isEmpty) return [];
  final gruplar = <String, List<Vecize>>{};
  for (final v in kaynakListe) {
    gruplar.putIfAbsent(v.eser, () => []).add(v);
  }
  final kitaplar = gruplar.keys.toList();
  if (karistir) {
    kitaplar.shuffle();
    for (final k in kitaplar) {
      gruplar[k]!.shuffle();
    }
  }
  final sonuc = <Vecize>[];
  int tur = 0;
  bool eklendi = true;
  while (eklendi) {
    eklendi = false;
    for (final k in kitaplar) {
      final liste = gruplar[k]!;
      if (tur < liste.length) {
        sonuc.add(liste[tur]);
        eklendi = true;
      }
    }
    tur++;
  }
  return sonuc;
}

NotificationDetails _bildirimDetayi(Vecize v) {
  final icerik = v.arapca.isNotEmpty ? '${v.arapca}\n\n“${v.metin}”' : '“${v.metin}”';
  final androidDetay = AndroidNotificationDetails(
    _vecizeKanali.id,
    _vecizeKanali.name,
    channelDescription: _vecizeKanali.description,
    icon: '@drawable/ic_bildirim',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    enableVibration: true,
    visibility: NotificationVisibility.public,
    subText: v.eser,
    styleInformation: BigTextStyleInformation(
      icerik,
      contentTitle: v.kaynak,
      summaryText: v.eser,
    ),
  );
  return NotificationDetails(android: androidDetay);
}

Future<void> _miuiAlarmKur({
  required int id,
  required Vecize v,
  required tz.TZDateTime hedef,
  bool gunlukTekrar = false,
}) async {
  final icerik = v.arapca.isNotEmpty ? '${v.arapca}\n\n“${v.metin}”' : '“${v.metin}”';
  final detay = _bildirimDetayi(v);
  final tekrar = gunlukTekrar ? DateTimeComponents.time : null;

  try {
    await _bildirim.zonedSchedule(
      id,
      v.kaynak,
      icerik,
      hedef,
      detay,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: tekrar,
      payload: v.metin,
    );
  } catch (_) {
    try {
      await _bildirim.zonedSchedule(
        id,
        v.kaynak,
        icerik,
        hedef,
        detay,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: tekrar,
        payload: v.metin,
      );
    } catch (_) {
      await _bildirim.zonedSchedule(
        id,
        v.kaynak,
        icerik,
        hedef,
        detay,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: tekrar,
        payload: v.metin,
      );
    }
  }
}

Future<void> anlikTestBildirim(List<Vecize> vecizeler, int index, {bool huSesi = false}) async {
  if (vecizeler.isEmpty) return;
  try {
    await _motoruHazirla();
    if (_sonHavuz.isEmpty) _sonHavuz = List<Vecize>.from(vecizeler);
    final v = vecizeler[index % vecizeler.length];
    final icerik = v.arapca.isNotEmpty ? '${v.arapca}\n\n“${v.metin}”' : '“${v.metin}”';
    await _bildirim.show(
      99901,
      v.kaynak,
      icerik,
      _bildirimDetayi(v),
      payload: v.metin,
    );
  } catch (_) {}
}

Future<void> zamanliTestBildirim(BuildContext context, List<Vecize> vecizeler, int index, {bool huSesi = false}) async {
  if (vecizeler.isEmpty) return;
  try {
    await _motoruHazirla();
    if (_sonHavuz.isEmpty) _sonHavuz = List<Vecize>.from(vecizeler);
    final v = vecizeler[(index + 1) % vecizeler.length];
    final hedef = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    await _miuiAlarmKur(id: 99902, v: v, hedef: hedef);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test kuruldu! Ekranı kilitleyin, 10 saniye içinde bildirim gelecek.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bildirim hatası: $e')),
      );
    }
  }
}

Future<String?> bildirimleriPlanla({
  required List<Vecize> havuz,
  required List<String> saatler,
  required bool periyodikAktif,
  required int periyodikDk,
  int baslangicIndex = 0,
  bool huSesi = false,
}) async {
  await _motoruHazirla();
  _sonHavuz = List<Vecize>.from(havuz);
  await _bildirim.cancelAll();
  if (havuz.isEmpty) return null;

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

    final v = havuz[vIdx % havuz.length];
    vIdx++;

    await _miuiAlarmKur(id: idSayac, v: v, hedef: hedef, gunlukTekrar: true);

    idSayac++;
    if (enYakin == null || hedef.isBefore(enYakin)) {
      enYakin = hedef;
    }
  }

  if (periyodikAktif && periyodikDk > 0) {
    final adet = (1440 / periyodikDk).ceil().clamp(1, 48);
    for (int i = 1; i <= adet; i++) {
      final hedef = simdi.add(Duration(minutes: periyodikDk * i));
      final v = havuz[vIdx % havuz.length];
      vIdx++;

      await _miuiAlarmKur(id: idSayac, v: v, hedef: hedef);

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
