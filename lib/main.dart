import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await notificationsPlugin.initialize(initSettings);
  runApp(const RisaleVecizeApp());
}

class Vecize {
  final String metin, kaynak, eser;
  const Vecize(this.metin, this.kaynak, this.eser);
}

const vecizeHavuzu = [
  Vecize('Güzel gören güzel düşünür. Güzel düşünen hayatından lezzet alır.', 'Mektubat, Hakikat Çekirdekleri', 'Mektubat'),
  Vecize('Bâki hakikatler fâni şahsiyetler üzerine bina edilmez.', 'Mektubat, Yirmi Dokuzuncu Mektup', 'Mektubat'),
  Vecize('İman hem nurdur, hem kuvvettir. Evet, hakiki imanı elde eden adam, kâinata meydan okuyabilir.', 'Sözler, Yirmi Üçüncü Söz', 'Sözler'),
  Vecize('Kadere iman eden, kederden emin olur.', 'Sözler, Yirmi Altıncı Söz', 'Sözler'),
  Vecize('Hayat bir sermayedir; sarf edilip gidiyor. Eğer meyvesi bulunmazsa zayi olur.', 'Sözler, Yirmi Dördüncü Söz', 'Sözler'),
  Vecize('İhlâs, amelinizde rıza-yı İlâhîyi gaye edinmektir.', 'Lem’alar, Yirmi Birinci Lem’a', 'Lem’alar'),
  Vecize('Musibet, cinayetin neticesi, mükâfatın mukaddimesidir.', 'Sözler, İkinci Söz', 'Sözler'),
  Vecize('Sabır, üç kısımdır: Biri masiyetten kendini çekmek, ikincisi musibetlere karşı sabır, üçüncüsü ibadet üzerinde sabırdır.', 'Mesnevî-i Nuriye', 'Mesnevî-i Nuriye'),
  Vecize('Her şeyde, hattâ en çirkin görünen şeylerde, hakiki bir hüsün ciheti vardır.', 'Sözler, On Sekizinci Söz', 'Sözler'),
  Vecize('Zaman ihtiyarlandıkça Kur’ân gençleşiyor, rumuzu tavazzuh ediyor.', 'Mektubat, Yirmi Altıncı Mektup', 'Mektubat'),
  Vecize('Hakkın hatırı âlidir, hiçbir hatıra feda edilmez.', 'Mektubat, Yirmi İkinci Mektup', 'Mektubat'),
  Vecize('İnsan bu dünyaya yalnız güzel yaşamak için ve rahatla ve safa ile ömür geçirmek için gelmemiştir.', 'Lem’alar, On Yedinci Lem’a', 'Lem’alar'),
  Vecize('Elhasıl: Dünya madem fânidir. Hem madem ömür kısadır. Hem madem en lüzumlu vazifeler çoktur. Öyleyse ehemmiyetli vazifeleri öne almak gerektir.', 'Lem’alar, Yirmi Birinci Lem’a', 'Lem’alar'),
  Vecize('Dost istersen Allah yeter. Evet, o dost ise her şey dosttur.', 'Sözler, Yirmi Üçüncü Söz', 'Sözler'),
  Vecize('Büyük şeylere büyük fiyat verilir.', 'Mektubat, Yirmi Dokuzuncu Mektup', 'Mektubat'),
];

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
  String _seciliEser = 'Tümü';
  List<String> _saatler = ['08:30', '21:00'];
  bool _periyodikAktif = false;
  final _eserler = ['Tümü', 'Sözler', 'Mektubat', 'Lem’alar', 'Mesnevî-i Nuriye'];

  @override
  void initState() {
    super.initState();
    _baslat();
  }

  Future<void> _baslat() async {
    final android = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _saatler = prefs.getStringList('saatler') ?? ['08:30', '21:00'];
      _periyodikAktif = prefs.getBool('periyodik_aktif') ?? false;
      _periyodikDk = prefs.getInt('periyodik_dakika') ?? 60;
    });
    await _planla();
  }

  Future<void> _kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saatler', _saatler);
    await prefs.setBool('periyodik_aktif', _periyodikAktif);
    await prefs.setInt('periyodik_dakika', _periyodikDk);
    await _planla();
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

    for (int i = 0; i < _saatler.length; i++) {
      final p = _saatler[i].split(':');
      var hedef = tz.TZDateTime(tz.local, simdi.year, simdi.month, simdi.day, int.parse(p[0]), int.parse(p[1]));
      if (hedef.isBefore(simdi)) hedef = hedef.add(const Duration(days: 1));
      final v = vecizeHavuzu[rnd.nextInt(vecizeHavuzu.length)];
      await notificationsPlugin.zonedSchedule(
        100 + i, 'Risale-i Nur • ${v.kaynak}', '“${v.metin}”', hedef, _bildirimDetay,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    if (_periyodikAktif && _periyodikDk >= 1) {
      for (int k = 1; k <= 24; k++) {
        final hedef = simdi.add(Duration(minutes: _periyodikDk * k));
        final v = vecizeHavuzu[rnd.nextInt(vecizeHavuzu.length)];
        await notificationsPlugin.zonedSchedule(
          500 + k, 'Risale-i Nur • ${v.kaynak}', '“${v.metin}”', hedef, _bildirimDetay,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> _testBildirim() async {
    final v = _liste[_index % _liste.length];
    await notificationsPlugin.show(999, 'Risale-i Nur • ${v.kaynak}', '“${v.metin}”', _bildirimDetay);
  }

  List<Vecize> get _liste => _seciliEser == 'Tümü'
      ? vecizeHavuzu
      : vecizeHavuzu.where((v) => v.eser == _seciliEser).toList();

  void _yeniVecize() {
    if (_liste.length <= 1) return;
    final rnd = Random();
    int yeni;
    do {
      yeni = rnd.nextInt(_liste.length);
    } while (yeni == _index % _liste.length);
    setState(() => _index = yeni);
  }

  Future<void> _saatEkle() async {
    final secilen = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Bildirim Saatini Seçin',
      cancelText: 'İptal',
      confirmText: 'Ekle',
    );
    if (secilen != null) {
      final f = '${secilen.hour.toString().padLeft(2, '0')}:${secilen.minute.toString().padLeft(2, '0')}';
      if (!_saatler.contains(f)) {
        setState(() {
          _saatler.add(f);
          _saatler.sort();
        });
        await _kaydet();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$f saati kuruldu.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _liste[_index % _liste.length];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF14532D),
        foregroundColor: Colors.white,
        title: const Text('Risale-i Nur Vecize', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.notifications_active_outlined), onPressed: _testBildirim)],
      ),
      body: _sekme == 0 ? _vecizeEkrani(v) : _zamanEkrani(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _sekme,
        onDestinationSelected: (i) => setState(() => _sekme = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Vecizeler'),
          NavigationDestination(icon: Icon(Icons.access_time_outlined), selectedIcon: Icon(Icons.access_time_filled), label: 'Saat & Dakika'),
        ],
      ),
    );
  }

  Widget _vecizeEkrani(Vecize v) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _eserler.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final e = _eserler[i];
                final s = _seciliEser == e;
                return ChoiceChip(
                  label: Text(e),
                  selected: s,
                  selectedColor: const Color(0xFF14532D),
                  labelStyle: TextStyle(color: s ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                  onSelected: (_) => setState(() {
                    _seciliEser = e;
                    _index = 0;
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD97706), width: 1.2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.format_quote_rounded, size: 40, color: Color(0xFFD97706)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text('“${v.metin}”', textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, height: 1.5, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Chip(label: Text(v.kaynak, style: const TextStyle(color: Color(0xFF14532D), fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF14532D), padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: _yeniVecize,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yeni Vecize'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '“${v.metin}”\n— ${v.kaynak}'));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kopyalandı.')));
                },
                icon: const Icon(Icons.copy),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                onPressed: () => Share.share('“${v.metin}”\n— ${v.kaynak}'),
                icon: const Icon(Icons.share),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _zamanEkrani() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Belirli Saat & Dakika', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF14532D)),
                      onPressed: _saatEkle,
                      icon: const Icon(Icons.add_alarm, size: 18),
                      label: const Text('Saat Ekle'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _saatler.map((s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onDeleted: () async {
                      setState(() => _saatler.remove(s));
                      await _kaydet();
                    },
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dakika Aralıklı Hatırlatıcı', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  subtitle: Text(_periyodikAktif ? 'Her $_periyodikDk dakikada bir aktif' : 'Kapalı'),
                  value: _periyodikAktif,
                  activeColor: const Color(0xFF14532D),
                  onChanged: (val) async {
                    setState(() => _periyodikAktif = val);
                    await _kaydet();
                  },
                ),
                if (_periyodikAktif)
                  Wrap(
                    spacing: 8,
                    children: [15, 30, 45, 60, 120, 180].map((dk) => ChoiceChip(
                      label: Text('$dk dk'),
                      selected: _periyodikDk == dk,
                      selectedColor: const Color(0xFF14532D),
                      labelStyle: TextStyle(color: _periyodikDk == dk ? Colors.white : Colors.black87),
                      onSelected: (_) async {
                        setState(() => _periyodikDk = dk);
                        await _kaydet();
                      },
                    )).toList(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _testBildirim,
          icon: const Icon(Icons.notifications_active),
          label: const Text('Şimdi Test Bildirimi Gönder'),
        ),
      ],
    );
  }
}
// --- KODUN SONU ---

