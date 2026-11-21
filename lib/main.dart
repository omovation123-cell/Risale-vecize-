import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vecizeler.dart';
import 'ekranlar.dart';
import 'bildirim.dart';

final GlobalKey<AnaSayfaState> _anaSayfaKey = GlobalKey<AnaSayfaState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bildirimBaslat(
    onBildirimPaylas: (v) => _anaSayfaKey.currentState?.paylasSecenekleriGoster(v),
    onBildirimFavori: (m) => _anaSayfaKey.currentState?.favoriBildirimdenYenile(m),
  );
  runApp(const RisaleVecizeApp());
}

class RisaleVecizeApp extends StatefulWidget {
  const RisaleVecizeApp({super.key});
  @override
  State<RisaleVecizeApp> createState() => _RisaleVecizeAppState();
}

class _RisaleVecizeAppState extends State<RisaleVecizeApp> {
  int _temaIdx = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      final idx = p.getInt('tema_index') ?? 0;
      if (mounted && idx >= 0 && idx < temalar.length) setState(() => _temaIdx = idx);
    });
  }

  Future<void> _temaDegistir(int idx) async {
    setState(() => _temaIdx = idx);
    final p = await SharedPreferences.getInstance();
    await p.setInt('tema_index', idx);
  }

  @override
  Widget build(BuildContext context) {
    final tema = temalar[_temaIdx];
    return MaterialApp(
      title: 'Risale-i Nur Vecize',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'KitapSerif',
        brightness: tema.koyuMu ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: tema.ana, brightness: tema.koyuMu ? Brightness.dark : Brightness.light),
        scaffoldBackgroundColor: tema.zemin,
      ),
      home: AcilisEkrani(
        hedef: AnaSayfa(key: _anaSayfaKey, tema: tema, temaIdx: _temaIdx, onTemaSec: _temaDegistir),
      ),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  final UygulamaTemasi tema;
  final int temaIdx;
  final Future<void> Function(int) onTemaSec;
  const AnaSayfa({super.key, required this.tema, required this.temaIdx, required this.onTemaSec});

  @override
  State<AnaSayfa> createState() => AnaSayfaState();
}

class AnaSayfaState extends State<AnaSayfa> with WidgetsBindingObserver {
  int _sekme = 0, _index = 0, _periyodikDk = 60;
  double _yaziBoyutu = 20.0;
  String _seciliEser = 'Tümü', _aramaMetni = '', _seciliFont = 'KitapSerif';
  List<String> _saatler = ['08:30', '21:00'], _favoriler = [], _silinenler = [], _aktifKitaplar = [];
  List<Vecize> _ozelVecizeler = [], _turListesi = [];
  bool _periyodikAktif = false, _alarmIzniVar = true, _huSesi = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _baslat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _izinYenile();
  }

  Future<void> _izinYenile() async {
    final ok = await alarmIzniKontrol();
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (mounted) {
      setState(() {
        _alarmIzniVar = ok;
        _favoriler = prefs.getStringList('favoriler') ?? _favoriler;
      });
    }
    if (ok) await _planla();
  }

  Future<void> favoriBildirimdenYenile(String metin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (!mounted) return;
    setState(() => _favoriler = prefs.getStringList('favoriler') ?? _favoriler);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vecize bildirimden favorilere eklendi.')));
  }

  List<Vecize> get _tumVecizeler => [..._ozelVecizeler, ...varsayilanVecizeler.where((v) => !_silinenler.contains(v.metin))];

  List<Vecize> get _havuzVecizeler {
    if (_aktifKitaplar.isEmpty) return _tumVecizeler;
    final filtreli = _tumVecizeler.where((v) => _aktifKitaplar.contains(v.eser)).toList();
    return filtreli.isNotEmpty ? filtreli : _tumVecizeler;
  }

  void _turuYenile({bool karistir = true}) {
    _turListesi = adilKitapTuruHavuzu(_havuzVecizeler, karistir: karistir);
    _index = 0;
  }

  List<Vecize> get _liste {
    final q = _aramaMetni.trim().toLowerCase();
    final kaynak = (_seciliEser == 'Tümü' && q.isEmpty && _turListesi.isNotEmpty) ? _turListesi : _havuzVecizeler;
    return kaynak.where((v) {
      final eserOk = _seciliEser == 'Tümü' || v.eser == _seciliEser;
      final aramaOk = q.isEmpty || v.metin.toLowerCase().contains(q) || v.kaynak.toLowerCase().contains(q) || v.eser.toLowerCase().contains(q) || v.arapca.contains(q);
      return eserOk && aramaOk;
    }).toList();
  }

  Future<String?> _planla() => bildirimleriPlanla(
        havuz: _havuzVecizeler,
        saatler: _saatler,
        periyodikAktif: _periyodikAktif,
        periyodikDk: _periyodikDk,
        huSesi: _huSesi,
      );

  Future<void> _baslat() async {
    final ok = await alarmIzniKontrol();
    final prefs = await SharedPreferences.getInstance();
    final kayitli = prefs.getStringList('ozel_vecizeler') ?? [];
    setState(() {
      _alarmIzniVar = ok;
      _saatler = prefs.getStringList('saatler') ?? ['08:30', '21:00'];
      _favoriler = prefs.getStringList('favoriler') ?? [];
      _silinenler = prefs.getStringList('silinen_vecizeler') ?? [];
      _aktifKitaplar = prefs.getStringList('aktif_kitaplar') ?? [];
      _periyodikAktif = prefs.getBool('periyodik_aktif') ?? false;
      _periyodikDk = prefs.getInt('periyodik_dakika') ?? 60;
      _huSesi = prefs.getBool('hu_sesi') ?? true;
      _seciliFont = prefs.getString('secili_font') ?? 'KitapSerif';
      _yaziBoyutu = prefs.getDouble('yazi_boyutu') ?? 20.0;
      _ozelVecizeler = kayitli.map((e) => Vecize.fromMap(jsonDecode(e) as Map<String, dynamic>)).toList();
      _turuYenile(karistir: true);
    });
    await _planla();
  }

  Future<void> _ozelKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ozel_vecizeler', _ozelVecizeler.map((v) => jsonEncode(v.toMap())).toList());
    await prefs.setStringList('silinen_vecizeler', _silinenler);
    await prefs.setStringList('favoriler', _favoriler);
    setState(() => _turuYenile(karistir: false));
    await _planla();
  }

  Future<void> _ayarKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saatler', _saatler);
    await prefs.setBool('periyodik_aktif', _periyodikAktif);
    await prefs.setInt('periyodik_dakika', _periyodikDk);
    await prefs.setBool('hu_sesi', _huSesi);
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

  Future<void> _vecizeSil(Vecize v) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vecize Silinsin mi?'),
        content: const Text('Bu vecize listeden kaldırılacak.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil')),
        ],
      ),
    );
    if (onay != true) return;
    setState(() {
      _ozelVecizeler.removeWhere((e) => e.metin == v.metin);
      if (varsayilanVecizeler.any((e) => e.metin == v.metin) && !_silinenler.contains(v.metin)) _silinenler.add(v.metin);
      _favoriler.remove(v.metin);
    });
    await _ozelKaydet();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vecize silindi.')));
  }

  Future<void> _vecizeDuzenle(Vecize eski, Vecize yeni) async {
    setState(() {
      final idx = _ozelVecizeler.indexWhere((e) => e.metin == eski.metin);
      if (idx != -1) {
        _ozelVecizeler[idx] = yeni;
      } else {
        if (!_silinenler.contains(eski.metin)) _silinenler.add(eski.metin);
        _ozelVecizeler.insert(0, yeni);
      }
      final favIdx = _favoriler.indexOf(eski.metin);
      if (favIdx != -1) _favoriler[favIdx] = yeni.metin;
    });
    await _ozelKaydet();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vecize güncellendi.')));
  }
// --- PARÇA 1 SONU ---
  // --- PARÇA 2A BAŞLANGICI ---
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

  String _paylasimMetni(Vecize v) => v.arapca.isNotEmpty
      ? '${v.arapca}\n\n“${v.metin}”\n— ${v.kaynak}'
      : '“${v.metin}”\n— ${v.kaynak}';

  Future<void> _gorselOlarakPaylas(Vecize v) async {
    final t = widget.tema;
    final boundaryKey = GlobalKey();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: Opacity(
          opacity: 0.01,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: RepaintBoundary(
                key: boundaryKey,
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: t.kart, borderRadius: BorderRadius.circular(24), border: Border.all(color: t.vurgu, width: 2.2)),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: t.vurgu, width: 0.8)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: t.zemin, borderRadius: BorderRadius.circular(12), border: Border.all(color: t.vurgu, width: 0.8)),
                          child: Text(v.eser, style: TextStyle(color: t.koyuMu ? t.vurgu : t.ana, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: fontAilesiGetir(_seciliFont))),
                        ),
                        const SizedBox(height: 16),
                        if (v.arapca.isNotEmpty) ...[
                          Text(v.arapca, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: TextStyle(fontFamily: 'MushafFont', fontSize: _yaziBoyutu + 4, height: 1.75, color: t.yazi)),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          '“${v.metin}”',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: _yaziBoyutu, height: 1.6, fontWeight: FontWeight.w600, fontFamily: fontAilesiGetir(_seciliFont), color: t.yazi),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(color: t.zemin, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.vurgu, width: 0.9)),
                          child: Text(v.kaynak, textAlign: TextAlign.center, style: TextStyle(color: t.koyuMu ? t.vurgu : t.ana, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: fontAilesiGetir(_seciliFont))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 60));

    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/risale_vecize_${DateTime.now().millisecondsSinceEpoch}.png');
          await file.writeAsBytes(byteData.buffer.asUint8List());
          entry.remove();
          await Share.shareXFiles([XFile(file.path)], text: '— ${v.kaynak}');
          return;
        }
      }
    } catch (_) {}
    entry.remove();
    await Share.share(_paylasimMetni(v));
  }

  Future<void> paylasSecenekleriGoster(Vecize v) async {
    final t = widget.tema;
    await showModalBottomSheet(
      context: context,
      backgroundColor: t.zemin,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Paylaşım Şekli Seçin', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.koyuMu ? t.vurgu : t.ana)),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: t.ana, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () {
                Navigator.pop(ctx);
                _gorselOlarakPaylas(v);
              },
              icon: const Icon(Icons.image_outlined),
              label: const Text('Sayfa Görseli Olarak Paylaş (Resim)'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: t.vurgu)),
              onPressed: () {
                Navigator.pop(ctx);
                Share.share(_paylasimMetni(v));
              },
              icon: Icon(Icons.text_fields, color: t.koyuMu ? t.vurgu : t.ana),
              label: Text('Metin Olarak Paylaş (Yazı)', style: TextStyle(color: t.yazi, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
// --- PARÇA 2A SONU ---
  // --- PARÇA 2B BAŞLANGICI ---
  @override
  Widget build(BuildContext context) {
    final t = widget.tema;
    final aktifHavuz = _liste.isNotEmpty ? _liste : _havuzVecizeler;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: t.ana,
        foregroundColor: Colors.white,
        title: Text('Risale-i Nur (${_havuzVecizeler.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'HatBaslik')),
        actions: [
          PopupMenuButton<int>(
            tooltip: 'Tema Değiştir',
            icon: const Icon(Icons.palette_outlined),
            onSelected: widget.onTemaSec,
            itemBuilder: (_) => List.generate(
              temalar.length,
              (i) => PopupMenuItem(
                value: i,
                child: Row(
                  children: [
                    CircleAvatar(radius: 8, backgroundColor: temalar[i].ana),
                    const SizedBox(width: 10),
                    Text(temalar[i].ad, style: TextStyle(fontWeight: widget.temaIdx == i ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Vecize Ekle',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => vecizeEkleGoster(
              context: context,
              tumVecizeler: _tumVecizeler,
              tema: t,
              onEkle: (yeniler) async {
                setState(() => _ozelVecizeler.insertAll(0, yeniler));
                await _ozelKaydet();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${yeniler.length} yeni vecize eklendi.')));
              },
            ),
          ),
          IconButton(tooltip: 'Anlık Test', icon: const Icon(Icons.notifications_active_outlined), onPressed: () => anlikTestBildirim(aktifHavuz, _index, huSesi: _huSesi)),
        ],
      ),
      body: _sekme == 0
          ? _vecizeEkrani()
          : _sekme == 1
              ? FavorilerSayfasi(
                  tumVecizeler: _tumVecizeler,
                  favoriler: _favoriler,
                  tema: t,
                  aktifFont: fontAilesiGetir(_seciliFont),
                  onFavoriSil: _favoriDegistir,
                  onPaylasSecenekli: paylasSecenekleriGoster,
                )
              : _sekme == 2
                  ? Column(
                      children: [
                        alarmIzinUyarisi(_alarmIzniVar),
                        Expanded(
                          child: zamanSayfasi(
                            saatler: _saatler,
                            periyodikAktif: _periyodikAktif,
                            periyodikDk: _periyodikDk,
                            huSesi: _huSesi,
                            tema: t,
                            onSaatEkle: _saatEkle,
                            onSaatSil: (s) async { setState(() => _saatler.remove(s)); await _ayarKaydet(); },
                            onPeriyodikDegistir: (val) async {
                              setState(() => _periyodikAktif = val);
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('periyodik_aktif', _periyodikAktif);
                              final ilkSaat = await _planla();
                              if (mounted && val && ilkSaat != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kuruldu! İlk bildirim $ilkSaat saatinde gelecek.')));
                            },
                            onDakikaSec: (dk) async {
                              setState(() => _periyodikDk = dk);
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setInt('periyodik_dakika', _periyodikDk);
                              final ilkSaat = await _planla();
                              if (mounted && _periyodikAktif && ilkSaat != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Güncellendi! İlk bildirim $ilkSaat saatinde gelecek.')));
                            },
                            onHuSesiDegistir: (val) async {
                              setState(() => _huSesi = val);
                              await _ayarKaydet();
                            },
                            onTestBildirim: () => zamanliTestBildirim(context, aktifHavuz, _index, huSesi: _huSesi),
                          ),
                        ),
                      ],
                    )
                  : ayarlarSayfasi(
                      context: context,
                      tema: t,
                      seciliFont: _seciliFont,
                      yaziBoyutu: _yaziBoyutu,
                      aktifKitaplar: _aktifKitaplar,
                      ozelVecizeler: _ozelVecizeler,
                      favoriler: _favoriler,
                      onFontDegistir: (f) async {
                        setState(() => _seciliFont = f);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('secili_font', f);
                      },
                      onBoyutDegistir: (b) async {
                        setState(() => _yaziBoyutu = b);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('yazi_boyutu', b);
                      },
                      onKitaplarDegistir: (liste) async {
                        setState(() {
                          _aktifKitaplar = liste;
                          _seciliEser = 'Tümü';
                          _turuYenile(karistir: true);
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setStringList('aktif_kitaplar', liste);
                        await _planla();
                      },
                      onYedekYukle: (ozeller, favlar) async {
                        setState(() {
                          for (final v in ozeller) {
                            if (!_tumVecizeler.any((e) => e.metin == v.metin)) _ozelVecizeler.insert(0, v);
                          }
                          for (final f in favlar) {
                            if (!_favoriler.contains(f)) _favoriler.add(f);
                          }
                        });
                        await _ozelKaydet();
                      },
                    ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: t.kart,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
          const NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }
// --- PARÇA 2B SONU ---
  // --- PARÇA 2C BAŞLANGICI ---
  Widget _vecizeEkrani() {
    final t = widget.tema;
    final liste = _liste;
    final v = liste.isNotEmpty ? liste[_index % liste.length] : null;
    final aktifSira = liste.isNotEmpty ? (_index % liste.length) + 1 : 0;
    final favoriMi = v != null && _favoriler.contains(v.metin);
    final filtreKitaplar = ['Tümü', ...eserListesi.where((e) => e != 'Tümü' && (_aktifKitaplar.isEmpty || _aktifKitaplar.contains(e)))];

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() { _aramaMetni = val; _index = 0; }),
            style: TextStyle(color: t.yazi),
            decoration: InputDecoration(
              hintText: 'Vecize, âyet, hadis veya kaynak ara...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              filled: true,
              fillColor: t.kart,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filtreKitaplar.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final e = filtreKitaplar[i];
                final s = _seciliEser == e;
                return ChoiceChip(
                  label: Text(e),
                  selected: s,
                  selectedColor: t.ana,
                  backgroundColor: t.kart,
                  labelStyle: TextStyle(color: s ? Colors.white : t.yazi, fontWeight: FontWeight.w600),
                  onSelected: (_) => setState(() { _seciliEser = e; _index = 0; }),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: v == null
                ? Center(child: Text(_tumVecizeler.isEmpty ? 'Henüz vecize yok. Sağ üstteki + butonundan ekleyebilirsiniz.' : 'Aramanıza uygun kayıt bulunamadı.', textAlign: TextAlign.center, style: TextStyle(color: t.yazi)))
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: t.kart, borderRadius: BorderRadius.circular(24), border: Border.all(color: t.vurgu, width: 1.8)),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(19), border: Border.all(color: t.vurgu, width: 0.7)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('$aktifSira / ${liste.length}', style: TextStyle(color: t.koyuMu ? Colors.white60 : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(color: t.zemin, borderRadius: BorderRadius.circular(12), border: Border.all(color: t.vurgu, width: 0.7)),
                                  child: Text(v.eser, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: t.koyuMu ? t.vurgu : t.ana)),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Düzenle',
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                onPressed: () => vecizeDuzenleGoster(context: context, vecize: v, tema: t, onKaydet: (yeni) => _vecizeDuzenle(v, yeni)),
                                icon: Icon(Icons.edit_outlined, color: t.koyuMu ? t.vurgu : t.ana, size: 20),
                              ),
                              IconButton(
                                tooltip: 'Sil',
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                onPressed: () => _vecizeSil(v),
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              ),
                              IconButton(
                                tooltip: 'Favori',
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.only(left: 6),
                                onPressed: () => _favoriDegistir(v.metin),
                                icon: Icon(favoriMi ? Icons.favorite : Icons.favorite_border, color: favoriMi ? Colors.red : (t.koyuMu ? Colors.white60 : Colors.black54), size: 22),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (v.arapca.isNotEmpty) ...[
                                      Text(
                                        v.arapca,
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.rtl,
                                        style: TextStyle(fontFamily: 'MushafFont', fontSize: _yaziBoyutu + 4, height: 1.75, color: t.yazi),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 36),
                                        child: Divider(color: t.vurgu.withOpacity(0.5), thickness: 0.8),
                                      ),
                                    ],
                                    Text(
                                      '“${v.metin}”',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: _yaziBoyutu, height: 1.6, letterSpacing: 0.2, fontWeight: FontWeight.w600, fontFamily: fontAilesiGetir(_seciliFont), color: t.yazi),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(color: t.zemin, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.vurgu, width: 0.9)),
                            child: Text(v.kaynak, textAlign: TextAlign.center, style: TextStyle(color: t.koyuMu ? t.vurgu : t.ana, fontWeight: FontWeight.bold, fontFamily: fontAilesiGetir(_seciliFont))),
                          ),
                        ],
                      ),
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
                    style: FilledButton.styleFrom(backgroundColor: t.ana, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () {
                      if (liste.length <= 1) return;
                      setState(() {
                        if (_seciliEser == 'Tümü' && _aramaMetni.isEmpty && _index + 1 >= liste.length) {
                          _turuYenile(karistir: true);
                        } else {
                          _index = (_index + 1) % liste.length;
                        }
                      });
                    },
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: const Text('Sıradaki Vecize', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filledTonal(onPressed: () => setState(() => _index = (_index + 1) % liste.length), icon: const Icon(Icons.arrow_forward_ios, size: 18)),
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _paylasimMetni(v)));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kopyalandı.')));
                  },
                  icon: const Icon(Icons.copy),
                ),
                const SizedBox(width: 6),
                IconButton.filled(style: IconButton.styleFrom(backgroundColor: t.vurgu), onPressed: () => paylasSecenekleriGoster(v), icon: const Icon(Icons.share, color: Colors.white)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
// --- ANA DOSYA BİTTİ ---
