import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await notificationsPlugin.initialize(initSettings);

  runApp(const RisaleVecizeApp());
}

class Vecize {
  final String metin;
  final String kaynak;
  final String eser;

  const Vecize({
    required this.metin,
    required this.kaynak,
    required this.eser,
  });
}

const List<Vecize> vecizeHavuzu = [
  Vecize(
    metin: 'Güzel gören güzel düşünür. Güzel düşünen hayatından lezzet alır.',
    kaynak: 'Mektubat, Hakikat Çekirdekleri',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Bâki hakikatler fâni şahsiyetler üzerine bina edilmez.',
    kaynak: 'Mektubat, Yirmi Dokuzuncu Mektup',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'İman hem nurdur, hem kuvvettir. Evet, hakiki imanı elde eden adam, kâinata meydan okuyabilir.',
    kaynak: 'Sözler, Yirmi Üçüncü Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Kadere iman eden, kederden emin olur.',
    kaynak: 'Sözler, Yirmi Altıncı Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Hayat bir sermayedir; sarf edilip gidiyor. Eğer meyvesi bulunmazsa zayi olur.',
    kaynak: 'Sözler, Yirmi Dördüncü Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'İhlâs, amelinizde rıza-yı İlâhîyi gaye edinmektir.',
    kaynak: 'Lem’alar, Yirmi Birinci Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'Musibet, cinayetin neticesi, mükâfatın mukaddimesidir.',
    kaynak: 'Sözler, İkinci Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Sabır, üç kısımdır: Biri masiyetten kendini çekmek, ikincisi musibetlere karşı sabır, üçüncüsü ibadet üzerinde sabırdır.',
    kaynak: 'Mesnevî-i Nuriye',
    eser: 'Mesnevî-i Nuriye',
  ),
  Vecize(
    metin: 'Her şeyde, hattâ en çirkin görünen şeylerde, hakiki bir hüsün ciheti vardır.',
    kaynak: 'Sözler, On Sekizinci Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Zaman ihtiyarlandıkça Kur’ân gençleşiyor, rumuzu tavazzuh ediyor.',
    kaynak: 'Mektubat, Yirmi Altıncı Mektup',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Hakkın hatırı âlidir, hiçbir hatıra feda edilmez.',
    kaynak: 'Mektubat, Yirmi İkinci Mektup',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'İnsan bu dünyaya yalnız güzel yaşamak için ve rahatla ve safa ile ömür geçirmek için gelmemiştir.',
    kaynak: 'Lem’alar, On Yedinci Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'Elhasıl: Dünya madem fânidir. Hem madem ömür kısadır. Hem madem en lüzumlu vazifeler çoktur. Öyleyse ehemmiyetli vazifeleri öne almak gerektir.',
    kaynak: 'Lem’alar, Yirmi Birinci Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'Dost istersen Allah yeter. Evet, o dost ise her şey dosttur.',
    kaynak: 'Sözler, Yirmi Üçüncü Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Büyük şeylere büyük fiyat verilir.',
    kaynak: 'Mektubat, Yirmi Dokuzuncu Mektup',
    eser: 'Mektubat',
  ),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14532D),
          surface: const Color(0xFFFDFBF7),
        ),
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
  int _seciliSekme = 0;
  String _seciliEser = 'Tümü';
  int _aktifIndex = 0;

  List<String> _saatListesi = ['08:30', '21:00'];
  bool _periyodikAktif = false;
  int _periyodikDakika = 60;

  final List<String> _eserler = [
    'Tümü',
    'Sözler',
    'Mektubat',
    'Lem’alar',
    'Mesnevî-i Nuriye',
  ];

  @override
  void initState() {
    super.initState();
    _izinleriIsteVeAyarlariYukle();
  }

  Future<void> _izinleriIsteVeAyarlariYukle() async {
    final androidImpl = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _saatListesi = prefs.getStringList('saatler') ?? ['08:30', '21:00'];
      _periyodikAktif = prefs.getBool('periyodik_aktif') ?? false;
      _periyodikDakika = prefs.getInt('periyodik_dakika') ?? 60;
    });
    await _bildirimleriPlanla();
  }

  Future<void> _ayarlariKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saatler', _saatListesi);
    await prefs.setBool('periyodik_aktif', _periyodikAktif);
    await prefs.setInt('periyodik_dakika', _periyodikDakika);
    await _bildirimleriPlanla();
  }

  Future<void> _bildirimleriPlanla() async {
    await notificationsPlugin.cancelAll();
    final rnd = Random();

    const androidDetay = AndroidNotificationDetails(
      'risale_vecize_kanal',
      'Risale-i Nur Vecize Hatırlatıcı',
      channelDescription: 'Ayarlanan saat ve dakikada vecize paylaşımı',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    const bildirimDetay = NotificationDetails(android: androidDetay);

    final simdi = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < _saatListesi.length; i++) {
      final parcalar = _saatListesi[i].split(':');
      final saat = int.parse(parcalar[0]);
      final dakika = int.parse(parcalar[1]);

      var hedef = tz.TZDateTime(
        tz.local,
        simdi.year,
        simdi.month,
        simdi.day,
        saat,
        dakika,
      );
      if (hedef.isBefore(simdi)) {
        hedef = hedef.add(const Duration(days: 1));
      }

      final v = vecizeHavuzu[rnd.nextInt(vecizeHavuzu.length)];
      await notificationsPlugin.zonedSchedule(
        100 + i,
        'Risale-i Nur • ${v.kaynak}',
        '“${v.metin}”',
        hedef,
        bildirimDetay,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    if (_periyodikAktif && _periyodikDakika >= 1) {
      for (int k = 1; k <= 24; k++) {
        final hedef = simdi.add(Duration(minutes: _periyodikDakika * k));
        final v = vecizeHavuzu[rnd.nextInt(vecizeHavuzu.length)];
        await notificationsPlugin.zonedSchedule(
          500 + k,
          'Risale-i Nur • ${v.kaynak}',
          '“${v.metin}”',
          hedef,
          bildirimDetay,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> _testBildirimiGonder() async {
    final v = _filtrelenmisVecizeler[_aktifIndex % _filtrelenmisVecizeler.length];
    const androidDetay = AndroidNotificationDetails(
      'risale_vecize_kanal',
      'Risale-i Nur Vecize Hatırlatıcı',
      channelDescription: 'Anlık test bildirimi',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    await notificationsPlugin.show(
      999,
      'Risale-i Nur • ${v.kaynak}',
      '“${v.metin}”',
      const NotificationDetails(android: androidDetay),
    );
  }

  List<Vecize> get _filtrelenmisVecizeler {
    if (_seciliEser == 'Tümü') return vecizeHavuzu;
    return vecizeHavuzu.where((v) => v.eser == _seciliEser).toList();
  }

  void _yeniVecize() {
    final liste = _filtrelenmisVecizeler;
    if (liste.length <= 1) return;
    final rnd = Random();
    int yeni;
    do {
      yeni = rnd.nextInt(liste.length);
    } while (yeni == _aktifIndex % liste.length);
    setState(() {
      _aktifIndex = yeni;
    });
  }

  Future<void> _saatEkle() async {
    final secilen = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Vecize Bildirim Saatini Seçin',
      cancelText: 'İptal',
      confirmText: 'Ekle',
    );
    if (secilen != null) {
      final formatli =
          '${secilen.hour.toString().padLeft(2, '0')}:${secilen.minute.toString().padLeft(2, '0')}';
      if (!_saatListesi.contains(formatli)) {
        setState(() {
          _saatListesi.add(formatli);
          _saatListesi.sort();
        });
        await _ayarlariKaydet();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$formatli saati için bildirim kuruldu.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final liste = _filtrelenmisVecizeler;
    final aktifVecize = liste[_aktifIndex % liste.length];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF14532D),
        foregroundColor: Colors.white,
        title: const Text(
          'Risale-i Nur Vecize',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Test Bildirimi Gönder',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: _testBildirimiGonder,
          ),
        ],
      ),
      body: _seciliSekme == 0
          ? _vecizelerEkrani(aktifVecize)
          : _zamanlayiciEkrani(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seciliSekme,
        onDestinationSelected: (index) => setState(() => _seciliSekme = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Vecizeler',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined),
            selectedIcon: Icon(Icons.access_time_filled),
            label: 'Saat & Dakika',
          ),
        ],
      ),
    );
  }

  Widget _vecizelerEkrani(Vecize vecize) {
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
              itemBuilder: (context, index) {
                final eser = _eserler[index];
                final secili = _seciliEser == eser;
                return ChoiceChip(
                  label: Text(eser),
                  selected: secili,
                  selectedColor: const Color(0xFF14532D),
                  labelStyle: TextStyle(
                    color: secili ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _seciliEser = eser;
                      _aktifIndex = 0;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD97706), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: 40,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          '“${vecize.metin}”',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 21,
                            height: 1.55,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1917),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vecize.kaynak,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF14532D),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF14532D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _yeniVecize,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yeni Vecize'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                ),
                tooltip: 'Kopyala',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: '“${vecize.metin}”\n— ${vecize.kaynak}'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vecize panoya kopyalandı.')),
                  );
                },
                icon: const Icon(Icons.copy),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  padding: const EdgeInsets.all(14),
                ),
                tooltip: 'Paylaş',
                onPressed: () {
                  Share.share('“${vecize.metin}”\n— ${vecize.kaynak}');
                },
                icon: const Icon(Icons.share),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _zamanlayiciEkrani() {
    final dakikaSecenekleri = [15, 30, 45, 60, 120, 180];

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
                    const Text(
                      'Belirli Saat & Dakika',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF14532D),
                      ),
                      onPressed: _saatEkle,
                      icon: const Icon(Icons.add_alarm, size: 18),
                      label: const Text('Saat Ekle'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seçtiğiniz saat ve dakikada her gün otomatik vecize bildirimi gelir.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 12),
                if (_saatListesi.isEmpty)
                  const Text('Henüz saat eklenmedi.')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _saatListesi.map((saat) {
                      return Chip(
                        label: Text(
                          saat,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () async {
                          setState(() {
                            _saatListesi.remove(saat);
                          });
                          await _ayarlariKaydet();
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Dakika Aralıklı Hatırlatıcı',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _periyodikAktif
                        ? 'Her $_periyodikDakika dakikada bir bildirim aktif'
                        : 'Kapalı',
                  ),
                  value: _periyodikAktif,
                  activeColor: const Color(0xFF14532D),
                  onChanged: (val) async {
                    setState(() => _periyodikAktif = val);
                    await _ayarlariKaydet();
                  },
                ),
                if (_periyodikAktif) ...[
                  const Divider(),
                  const Text('Kaç dakikada bir bildirim gelsin?'),
                  const SizedBox(heig
