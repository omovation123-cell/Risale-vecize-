import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'vecizeler.dart';
import 'ekranlar.dart';

final notificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  await notificationsPlugin.initialize(
    settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
  );
  runApp(const RisaleVecizeApp());
}

class RisaleVecizeApp extends StatelessWidget {
  const RisaleVecizeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Risale-i Nur Vecize',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14532D)),
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
      ),
      home: const AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _sekme = 0, _index = 0, _periyodikDk = 60;
  String _seciliEser = 'Tümü', _aramaMetni = '';
  List<String> _saatler = ['08:30', '21:00'], _favoriler = [];
  List<Vecize> _ozelVecizeler = [];
  bool _periyodikAktif = false;

  @override
  void initState() {
    super.initState();
    _baslat();
  }

  List<Vecize> get _tumVecizeler => [..._ozelVecizeler, ...varsayilanVecizeler];

  List<Vecize> get _liste {
    final q = _aramaMetni.trim().toLowerCase();
    return _tumVecizeler.where((v) {
      final eserOk = _seciliEser == 'Tümü' || v.eser == _seciliEser;
      final aramaOk = q.isEmpty || v.metin.toLowerCase().contains(q) || v.kaynak.toLowerCase().contains(q) || v.eser.toLowerCase().contains(q);
      return eserOk && aramaOk;
    }).toList();
  }

  Future<void> _baslat() async {
    final android = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
    final prefs = await SharedPreferences.getInstance();
    final kayitli = prefs.getStringList('ozel_vecizeler') ?? [];
    setState(() {
      _saatler = prefs.getStringList('saatler') ?? ['08:30', '21:00'];
      _favoriler = prefs.getStringList('favoriler') ?? [];
      _periyodikAktif = prefs.getBool('periyodik_aktif') ?? false;
      _periyodikDk = prefs.getInt('periyodik_dakika') ?? 60;
      _ozelVecizeler = kayitli.map((e) => Vecize.fromMap(jsonDecode(e) as Map<String, dynamic>)).toList();
    });
    await _planla();
  }

  Future<void> _ozelKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ozel_vecizeler', _ozelVecizeler.map((v) => jsonEncode(v.toMap())).toList());
    await _planla();
  }

  Future<void> _ayarKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saatler', _saatler);
    await prefs.setBool('periyodik_aktif', _periyodikAktif);
    await prefs.setInt('periyodik_dakika', _periyodikDk);
    await _planla();
  }

  Future<void> _favoriDegistir(String metin) async {
    final prefs = await SharedPreferences.getInstance();
    final eklendi = !_favoriler.contains(metin);
    setState(() => eklendi ? _favoriler.add(metin) : _favoriler.remove(metin));
    await prefs.setStringList('favoriler', _favoriler);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: const Duration(seconds: 1), content: Text(eklendi ? 'Favorilere eklendi.' : 'Favorilerden çıkarıldı.')),
      );
    }
  }

  NotificationDetails get _bildirimDetay => const NotificationDetails(
        android: AndroidNotificationDetails(
          'risale_vecize_kanal',
          'Risale-i Nur Vecize',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      );

  Future<void> _planla() async {
    await notificationsPlugin.cancelAll();
    final rnd = Random();
    final simdi = tz.TZDateTime.now(tz.local);
    final havuz = _tumVecizeler;

    for (int i = 0; i < _saatler.length; i++) {
      final p = _saatler[i].split(':');
      var hedef = tz.TZDateTime(tz.local, simdi.year, simdi.month, simdi.day, int.parse(p[0]), int.parse(p[1]));
      if (hedef.isBefore(simdi)) hedef = hedef.add(const Duration(days: 1));
      final v = havuz[rnd.nextInt(havuz.length)];
      await notificationsPlugin.zonedSchedule(
        id: 100 + i,
        title: 'Risale-i Nur • ${v.kaynak}',
        body: '“${v.metin}”',
        scheduledDate: hedef,
        notificationDetails: _bildirimDetay,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    if (_periyodikAktif && _periyodikDk >= 1) {
      for (int k = 1; k <= 24; k++) {
        final hedef = simdi.add(Duration(minutes: _periyodikDk * k));
        final v = havuz[rnd.nextInt(havuz.length)];
        await notificationsPlugin.zonedSchedule(
          id: 500 + k,
          title: 'Risale-i Nur • ${v.kaynak}',
          body: '“${v.metin}”',
          scheduledDate: hedef,
          notificationDetails: _bildirimDetay,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  Future<void> _testBildirim() async {
    final havuz = _liste.isNotEmpty ? _liste : _tumVecizeler;
    final v = havuz[_index % havuz.length];
    await notificationsPlugin.show(
      id: 999,
      title: 'Risale-i Nur • ${v.kaynak}',
      body: '“${v.metin}”',
      notificationDetails: _bildirimDetay,
    );
  }

  Future<void> _saatEkle() async {
    final secilen = await showTimePicker(context: context, initialTime: TimeOfDay.now(), helpText: 'Bildirim Saatini Seçin', cancelText: 'İptal', confirmText: 'Ekle');
    if (secilen != null) {
      final f = '${secilen.hour.toString().padLeft(2, '0')}:${secilen.minute.toString().padLeft(2, '0')}';
      if (!_saatler.contains(f)) {
        setState(() { _saatler.add(f); _saatler.sort(); });
        await _ayarKaydet();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$f saati kuruldu.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF14532D),
        foregroundColor: Colors.white,
        title: Text('Risale-i Nur (${_tumVecizeler.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Vecize Ekle',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => vecizeEkleGoster(
              context: context,
              tumVecizeler: _tumVecizeler,
              onEkle: (yeniler) async {
                setState(() { _ozelVecizeler.insertAll(0, yeniler); _index = 0; });
                await _ozelKaydet();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${yeniler.length} yeni vecize arşive eklendi.')));
              },
            ),
          ),
          IconButton(tooltip: 'Test Bildirimi', icon: const Icon(Icons.notifications_active_outlined), onPressed: _testBildirim),
        ],
      ),
      body: _sekme == 0
          ? _vecizeEkrani()
          : _sekme == 1
              ? favorilerSayfasi(tumVecizeler: _tumVecizeler, favoriler: _favoriler, onFavoriSil: _favoriDegistir)
              : zamanSayfasi(
                  saatler: _saatler,
                  periyodikAktif: _periyodikAktif,
                  periyodikDk: _periyodikDk,
                  onSaatEkle: _saatEkle,
                  onSaatSil: (s) async { setState(() => _saatler.remove(s)); await _ayarKaydet(); },
                  onPeriyodikDegistir: (val) async { setState(() => _periyodikAktif = val); await _ayarKaydet(); },
                  onDakikaSec: (dk) async { setState(() => _periyodikDk = dk); await _ayarKaydet(); },
                  onTestBildirim: _testBildirim,
                ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _sekme,
        onDestinationSelected: (i) => setState(() => _sekme = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Vecizeler'),
          NavigationDestination(
            icon: Badge(isLabelVisible: _favoriler.isNotEmpty, label: Text('${_favoriler.length}'), child: const Icon(Icons.favorite_border)),
            selectedIcon: const Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          const NavigationDestination(icon: Icon(Icons.access_time_outlined), selectedIcon: Icon(Icons.access_time_filled), label: 'Saat & Dakika'),
        ],
      ),
    );
  }

  Widget _vecizeEkrani() {
    final liste = _liste;
    final v = liste.isNotEmpty ? liste[_index % liste.length] : null;
    final aktifSira = liste.isNotEmpty ? (_index % liste.length) + 1 : 0;
    final favoriMi = v != null && _favoriler.contains(v.metin);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() { _aramaMetni = val; _index = 0; }),
            decoration: InputDecoration(
              hintText: 'Vecize veya kaynak ara...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: eserListesi.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final e = eserListesi[i];
                final s = _seciliEser == e;
                return ChoiceChip(
                  label: Text(e),
                  selected: s,
                  selectedColor: const Color(0xFF14532D),
                  labelStyle: TextStyle(color: s ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                  onSelected: (_) => setState(() { _seciliEser = e; _index = 0; }),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: v == null
                ? const Center(child: Text('Aramanıza uygun vecize bulunamadı.'))
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFD97706), width: 1.2)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$aktifSira / ${liste.length}', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                            const Icon(Icons.format_quote_rounded, size: 32, color: Color(0xFFD97706)),
                            IconButton(
                              onPressed: () => _favoriDegistir(v.metin),
                              icon: Icon(favoriMi ? Icons.favorite : Icons.favorite_border, color: favoriMi ? Colors.red : Colors.black54, size: 28),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: Text('“${v.metin}”', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, height: 1.5, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Chip(label: Text(v.kaynak, style: const TextStyle(color: Color(0xFF14532D), fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
          ),
          if (v != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.filledTonal(onPressed: () => setState(() => _index = (_index - 1 + liste.length) % liste.length), icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
                const SizedBox(width: 6),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF14532D), padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () {
                      if (liste.length <= 1) return;
                      final rnd = Random();
                      int yeni;
                      do { yeni = rnd.nextInt(liste.length); } while (yeni == _index % liste.length);
                      setState(() => _index = yeni);
                    },
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Yeni Vecize'),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filledTonal(onPressed: () => setState(() => _index = (_index + 1) % liste.length), icon: const Icon(Icons.arrow_forward_ios, size: 18)),
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '“${v.metin}”\n— ${v.kaynak}'));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kopyalandı.')));
                  },
                  icon: const Icon(Icons.copy),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                  onPressed: () => Share.share('“${v.metin}”\n— ${v.kaynak}'),
                  icon: const Icon(Icons.share),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
// --- ANA DOSYA BİTTİ ---
