import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bildirim.dart';
import 'giris_ekrani.dart';
import 'vecizeler.dart';
import 'yedek_ve_yukle.dart';

final GlobalKey<AnaSayfaState> _anaSayfaKey = GlobalKey<AnaSayfaState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NurdanVecizelerApp());
}

class NurdanVecizelerApp extends StatelessWidget {
  const NurdanVecizelerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nurdan Vecizeler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF14532D),
      ),
      home: GirisEkrani(
        sonrakiSayfa: AnaSayfa(key: _anaSayfaKey),
      ),
    );
  }
}

class _TemaPaleti {
  final String ad;
  final Color arkaPlan;
  final Color kartArkaPlan;
  final Color vurgu;
  final Color metin;
  final Color altMetin;
  final Color cerceve;
  final bool koyu;

  const _TemaPaleti({
    required this.ad,
    required this.arkaPlan,
    required this.kartArkaPlan,
    required this.vurgu,
    required this.metin,
    required this.altMetin,
    required this.cerceve,
    required this.koyu,
  });
}

const List<_TemaPaleti> _temalar = [
  _TemaPaleti(
    ad: 'Mushaf Parşömen',
    arkaPlan: Color(0xFFF6F1E3),
    kartArkaPlan: Color(0xFFFFFDF7),
    vurgu: Color(0xFF14532D),
    metin: Color(0xFF1F2937),
    altMetin: Color(0xFF57534E),
    cerceve: Color(0xFFD6C7A1),
    koyu: false,
  ),
  _TemaPaleti(
    ad: 'Osmanlı Sepya',
    arkaPlan: Color(0xFFEDE0C8),
    kartArkaPlan: Color(0xFFF7EFE0),
    vurgu: Color(0xFF6B3E1E),
    metin: Color(0xFF2C1A0E),
    altMetin: Color(0xFF6E4E37),
    cerceve: Color(0xFFC7AD82),
    koyu: false,
  ),
  _TemaPaleti(
    ad: 'Gece Zümrütü',
    arkaPlan: Color(0xFF0A1F16),
    kartArkaPlan: Color(0xFF112E22),
    vurgu: Color(0xFFD4AF37),
    metin: Color(0xFFF5F1E6),
    altMetin: Color(0xFFCBD5E1),
    cerceve: Color(0xFF2B5944),
    koyu: true,
  ),
  _TemaPaleti(
    ad: 'Gece Laciverti',
    arkaPlan: Color(0xFF0B1324),
    kartArkaPlan: Color(0xFF131F38),
    vurgu: Color(0xFFE5C158),
    metin: Color(0xFFF1F5F9),
    altMetin: Color(0xFF94A3B8),
    cerceve: Color(0xFF27395E),
    koyu: true,
  ),
];

const List<String> _sabitKitaplar = [
  'Kur’an-ı Kerim',
  'Hadis-i Şerif',
  'Sözler',
  'Mektubat',
  'Lem’alar',
  'Şualar',
  'İşârâtü’l-İ’câz',
  'Mesnevî-i Nuriye',
  'Barla Lâhikası',
  'Kastamonu Lâhikası',
  'Emirdağ Lâhikası',
  'Tarihçe-i Hayat',
  'Sikke-i Tasdik-i Gaybî',
  'Asâ-yı Mûsâ',
  'Muhâkemât',
  'İman ve Küfür Muvazeneleri',
];

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => AnaSayfaState();
}

class AnaSayfaState extends State<AnaSayfa> {
  List<Vecize> _tumVecizeler = List<Vecize>.from(varsayilanVecizeler);
  List<Vecize> _havuzVecizeler = List<Vecize>.from(varsayilanVecizeler);
  Set<String> _gizliMetinler = {};

  int _sekmeIndex = 0;
  int _aktifIndex = 0;
  String _seciliEser = 'Tümü';
  String _seciliFavoriEser = 'Tümü';
  String _aramaMetni = '';

  Set<String> _favoriler = {};
  List<String> _saatler = ['09:00', '14:00', '21:00'];
  bool _periyodikAktif = false;
  int _periyodikDk = 120;

  int _temaIndex = 0;
  double _yaziBoyutu = 19.0;
  String _yaziTipi = 'KitapSerif';

  bool _alarmIzniVar = true;
  String? _sonrakiBildirimSaati;

  final TextEditingController _aramaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _baslangicKurulumu();
  }

  Future<void> _baslangicKurulumu() async {
    await bildirimBaslat(
      onBildirimPaylas: (Vecize v) {
        paylasSecenekleriGoster(v);
      },
      onBildirimFavori: (String metin) async {
        setState(() {
          _favoriler.add(metin);
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('favoriler', _favoriler.toList());
      },
    );
    await _ayarlariYukle();
    await _izinVePlanla();
  }

  Future<void> _ayarlariYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final ozeller = await ozelVecizeleriGetir();
    final gizliler =
        (prefs.getStringList('sprz_duzenlenen_eskiler_v1') ?? []).toSet();

    final birlesik = <Vecize>[
      ...ozeller,
      ...varsayilanVecizeler.where((v) => !gizliler.contains(v.metin)),
    ];

    final kayitliFav = prefs.getStringList('favoriler') ?? [];
    final kayitliSaatler = prefs.getStringList('saatler');
    final periyodik = prefs.getBool('periyodikAktif') ?? false;
    final periyodikDk = prefs.getInt('periyodikDk') ?? 120;
    final tema = prefs.getInt('temaIndex') ?? 0;
    final boyut = prefs.getDouble('yaziBoyutu') ?? 19.0;
    final font = prefs.getString('yaziTipi') ?? 'KitapSerif';
    final sonIdx = prefs.getInt('aktifIndex') ?? 0;

    final adilListe = adilKitapTuruHavuzu(birlesik, karistir: false);

    if (!mounted) return;
    setState(() {
      _gizliMetinler = gizliler;
      _tumVecizeler = birlesik;
      _havuzVecizeler = adilListe.isNotEmpty ? adilListe : birlesik;
      _favoriler = kayitliFav.toSet();
      if (kayitliSaatler != null && kayitliSaatler.isNotEmpty) {
        _saatler = kayitliSaatler;
      }
      _periyodikAktif = periyodik;
      _periyodikDk = periyodikDk;
      _temaIndex = tema.clamp(0, _temalar.length - 1);
      _yaziBoyutu = boyut.clamp(15.0, 28.0);
      _yaziTipi = font;
      _aktifIndex =
          _havuzVecizeler.isEmpty ? 0 : sonIdx % _havuzVecizeler.length;
    });
  }

  Future<void> _izinVePlanla() async {
    final ok = await alarmIzniKontrol();
    final planliHavuz = adilKitapTuruHavuzu(_tumVecizeler, karistir: true);
    final sonraki = await bildirimleriPlanla(
      havuz: planliHavuz.isNotEmpty ? planliHavuz : _tumVecizeler,
      saatler: _saatler,
      periyodikAktif: _periyodikAktif,
      periyodikDk: _periyodikDk,
      baslangicIndex: _aktifIndex,
    );
    if (!mounted) return;
    setState(() {
      _alarmIzniVar = ok;
      _sonrakiBildirimSaati = sonraki;
    });
  }

  Future<void> _ayarlariKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriler', _favoriler.toList());
    await prefs.setStringList('saatler', _saatler);
    await prefs.setBool('periyodikAktif', _periyodikAktif);
    await prefs.setInt('periyodikDk', _periyodikDk);
    await prefs.setInt('temaIndex', _temaIndex);
    await prefs.setDouble('yaziBoyutu', _yaziBoyutu);
    await prefs.setString('yaziTipi', _yaziTipi);
    await prefs.setInt('aktifIndex', _aktifIndex);
  }

  Future<void> _ozelListeyiKaydet(List<Vecize> liste) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'sprz_ozel_vecizeler_v1',
      liste.map((v) => jsonEncode(v.toMap())).toList(),
    );
  }

  String _tamKaynakMetni(Vecize v) {
    final e = v.eser.trim();
    final k = v.kaynak.trim();
    if (k.isEmpty || k.toLowerCase() == e.toLowerCase()) return e;
    if (k.toLowerCase().startsWith(e.toLowerCase())) return k;
    return '$e, $k';
  }

  String _kaynakBirlestir(String eser, String hamKaynak) {
    final e = eser.trim();
    final k = hamKaynak.trim();
    if (k.isEmpty || k.toLowerCase() == e.toLowerCase()) return e;
    if (k.toLowerCase().startsWith(e.toLowerCase())) return k;
    return '$e, $k';
  }

  String _bolumAyikla(String eser, String kaynak) {
    final e = eser.trim();
    final k = kaynak.trim();
    if (k.isEmpty || k.toLowerCase() == e.toLowerCase()) return '';
    if (k.toLowerCase().startsWith('${e.toLowerCase()},')) {
      return k.substring(e.length + 1).trim();
    }
    if (k.toLowerCase().startsWith('${e.toLowerCase()} -')) {
      return k.substring(e.length + 2).trim();
    }
    return k;
  }

  void paylasSecenekleriGoster(Vecize v) {
    final kaynak = _tamKaynakMetni(v);
    final metin = v.arapca.isNotEmpty
        ? '${v.arapca}\n\n“${v.metin}”\n\n— $kaynak'
        : '“${v.metin}”\n\n— $kaynak';
    Share.share(metin);
  }

  List<String> get _eserListesi {
    final set = <String>{'Tümü'};
    for (final v in _tumVecizeler) {
      if (v.eser.trim().isNotEmpty) {
        set.add(v.eser.trim());
      }
    }
    return set.toList();
  }

  List<Vecize> get _filtreliVecizeler {
    return _havuzVecizeler.where((v) {
      final eserUygun = _seciliEser == 'Tümü' || v.eser == _seciliEser;
      if (!eserUygun) return false;
      if (_aramaMetni.trim().isEmpty) return true;
      final q = _aramaMetni.toLowerCase();
      return v.metin.toLowerCase().contains(q) ||
          v.eser.toLowerCase().contains(q) ||
          v.kaynak.toLowerCase().contains(q);
    }).toList();
  }

  List<Vecize> get _favoriVecizeler {
    return _tumVecizeler.where((v) => _favoriler.contains(v.metin)).toList();
  }

  void _favoriDegistir(Vecize v) async {
    setState(() {
      if (_favoriler.contains(v.metin)) {
        _favoriler.remove(v.metin);
      } else {
        _favoriler.add(v.metin);
      }
    });
    await _ayarlariKaydet();
  }

  Future<void> _tekVecizeEklePenceresi() async {
    String seciliKitap =
        _sabitKitaplar.contains(_seciliEser) ? _seciliEser : 'Sözler';
    final metinCtrl = TextEditingController();
    final kaynakCtrl = TextEditingController();
    final arapcaCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              title: const Text('Yeni Vecize Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: seciliKitap,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Kitap Seçin',
                        border: OutlineInputBorder(),
                      ),
                      items: _sabitKitaplar
                          .map((k) => DropdownMenuItem(
                                value: k,
                                child: Text(k, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => seciliKitap = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: metinCtrl,
                      maxLines: 4,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Vecize Metni *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: kaynakCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bölüm / Sayfa Kaynağı (Örn: 1. Söz, s. 12)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: arapcaCtrl,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        labelText: 'Arapça Metin (İsteğe bağlı)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('İptal'),
                ),
                FilledButton(
                  onPressed: () async {
                    final m = metinCtrl.text.trim();
                    if (m.isEmpty) return;
                    final e = seciliKitap;
                    final k = _kaynakBirlestir(e, kaynakCtrl.text);
                    final a = arapcaCtrl.text.trim();

                    final yeni =
                        Vecize(metin: m, kaynak: k, eser: e, arapca: a);
                    final ozeller = await ozelVecizeleriGetir();
                    ozeller.removeWhere((v) => v.metin.trim() == m);
                    ozeller.insert(0, yeni);
                    await _ozelListeyiKaydet(ozeller);
                    await _ayarlariYukle();

                    if (mounted) {
                      _aramaCtrl.clear();
                      setState(() {
                        _seciliEser = 'Tümü';
                        _aramaMetni = '';
                        final idx = _filtreliVecizeler
                            .indexWhere((v) => v.metin == yeni.metin);
                        _aktifIndex = idx != -1 ? idx : 0;
                      });
                      await _ayarlariKaydet();
                    }

                    await _izinVePlanla();

                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Vecize kaydedildi ve ana ekranda açıldı.')),
                      );
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }
    Future<void> _vecizeDuzenlePenceresi(Vecize eskiVecize) async {
    final kitapListesi = _sabitKitaplar.contains(eskiVecize.eser)
        ? _sabitKitaplar
        : [eskiVecize.eser, ..._sabitKitaplar];
    String seciliKitap = eskiVecize.eser;
    final metinCtrl = TextEditingController(text: eskiVecize.metin);
    final kaynakCtrl = TextEditingController(
      text: _bolumAyikla(eskiVecize.eser, eskiVecize.kaynak),
    );
    final arapcaCtrl = TextEditingController(text: eskiVecize.arapca);

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              title: const Text('Vecizeyi Düzenle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: seciliKitap,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Kitap Seçin',
                        border: OutlineInputBorder(),
                      ),
                      items: kitapListesi
                          .map((k) => DropdownMenuItem(
                                value: k,
                                child: Text(k, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => seciliKitap = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: metinCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Vecize Metni *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: kaynakCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bölüm / Sayfa Kaynağı (Örn: 1. Söz, s. 12)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: arapcaCtrl,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        labelText: 'Arapça Metin (İsteğe bağlı)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('İptal'),
                ),
                FilledButton(
                  onPressed: () async {
                    final m = metinCtrl.text.trim();
                    if (m.isEmpty) return;
                    final e = seciliKitap;
                    final k = _kaynakBirlestir(e, kaynakCtrl.text);
                    final a = arapcaCtrl.text.trim();

                    final guncel =
                        Vecize(metin: m, kaynak: k, eser: e, arapca: a);
                    final ozeller = await ozelVecizeleriGetir();
                    final ozelIdx = ozeller.indexWhere((v) =>
                        v.metin == eskiVecize.metin &&
                        v.eser == eskiVecize.eser);

                    if (ozelIdx != -1) {
                      ozeller[ozelIdx] = guncel;
                    } else {
                      ozeller.insert(0, guncel);
                      _gizliMetinler.add(eskiVecize.metin);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setStringList(
                        'sprz_duzenlenen_eskiler_v1',
                        _gizliMetinler.toList(),
                      );
                    }

                    await _ozelListeyiKaydet(ozeller);

                    if (_favoriler.contains(eskiVecize.metin)) {
                      _favoriler.remove(eskiVecize.metin);
                      _favoriler.add(guncel.metin);
                      await _ayarlariKaydet();
                    }

                    await _ayarlariYukle();

                    if (mounted) {
                      _aramaCtrl.clear();
                      setState(() {
                        _seciliEser = 'Tümü';
                        _aramaMetni = '';
                        final idx = _filtreliVecizeler
                            .indexWhere((v) => v.metin == guncel.metin);
                        _aktifIndex = idx != -1 ? idx : 0;
                      });
                      await _ayarlariKaydet();
                    }

                    await _izinVePlanla();

                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vecize güncellendi.')),
                      );
                    }
                  },
                  child: const Text('Güncelle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _bildirimAyarlariPenceresi() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Bildirim & Alarm Saatleri',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._saatler.map((saat) {
                          return Chip(
                            label: Text(saat,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            onDeleted: () {
                              setModalState(() {
                                _saatler.remove(saat);
                              });
                            },
                          );
                        }),
                        ActionChip(
                          avatar: const Icon(Icons.add_alarm, size: 18),
                          label: const Text('Saat Ekle'),
                          onPressed: () async {
                            final secilen = await showTimePicker(
                              context: ctx,
                              initialTime: const TimeOfDay(hour: 9, minute: 0),
                            );
                            if (secilen != null) {
                              final h = secilen.hour.toString().padLeft(2, '0');
                              final m =
                                  secilen.minute.toString().padLeft(2, '0');
                              final yeni = '$h:$m';
                              if (!_saatler.contains(yeni)) {
                                setModalState(() {
                                  _saatler.add(yeni);
                                  _saatler.sort();
                                });
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Periyodik Hatırlatma'),
                      subtitle: Text('Her $_periyodikDk dakikada bir vecize'),
                      value: _periyodikAktif,
                      onChanged: (val) {
                        setModalState(() {
                          _periyodikAktif = val;
                        });
                      },
                    ),
                    if (_periyodikAktif)
                      DropdownButtonFormField<int>(
                        value: [30, 60, 90, 120, 180, 240]
                                .contains(_periyodikDk)
                            ? _periyodikDk
                            : 120,
                        decoration: const InputDecoration(
                          labelText: 'Periyot Süresi',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 30, child: Text('30 Dakikada Bir')),
                          DropdownMenuItem(
                              value: 60, child: Text('1 Saatte Bir')),
                          DropdownMenuItem(
                              value: 90, child: Text('1.5 Saatte Bir')),
                          DropdownMenuItem(
                              value: 120, child: Text('2 Saatte Bir')),
                          DropdownMenuItem(
                              value: 180, child: Text('3 Saatte Bir')),
                          DropdownMenuItem(
                              value: 240, child: Text('4 Saatte Bir')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              _periyodikDk = val;
                            });
                          }
                        },
                      ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF14532D),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Saatleri Kaydet ve Bildirimleri Kur'),
                      onPressed: () async {
                        await _ayarlariKaydet();
                        await _izinVePlanla();
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_sonrakiBildirimSaati != null
                                  ? 'Kuruldu! İlk bildirim $_sonrakiBildirimSaati saatinde gelecek.'
                                  : 'Bildirim ayarları güncellendi.'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _gorunumAyarlariPenceresi() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Kitap Görünümü & Yazı Ayarları',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Tema Seçimi',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_temalar.length, (i) {
                        final t = _temalar[i];
                        return ChoiceChip(
                          label: Text(t.ad),
                          selected: _temaIndex == i,
                          onSelected: (_) async {
                            setModalState(() => _temaIndex = i);
                            setState(() => _temaIndex = i);
                            await _ayarlariKaydet();
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    const Text('Yazı Tipi',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Kitap Serif'),
                          selected: _yaziTipi == 'KitapSerif',
                          onSelected: (_) async {
                            setModalState(() => _yaziTipi = 'KitapSerif');
                            setState(() => _yaziTipi = 'KitapSerif');
                            await _ayarlariKaydet();
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Hat Başlık'),
                          selected: _yaziTipi == 'HatBaslik',
                          onSelected: (_) async {
                            setModalState(() => _yaziTipi = 'HatBaslik');
                            setState(() => _yaziTipi = 'HatBaslik');
                            await _ayarlariKaydet();
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Sade'),
                          selected: _yaziTipi == '',
                          onSelected: (_) async {
                            setModalState(() => _yaziTipi = '');
                            setState(() => _yaziTipi = '');
                            await _ayarlariKaydet();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Yazı Boyutu: ${_yaziBoyutu.round()} pt',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Slider(
                      min: 15,
                      max: 28,
                      divisions: 13,
                      value: _yaziBoyutu,
                      onChanged: (val) async {
                        setModalState(() => _yaziBoyutu = val);
                        setState(() => _yaziBoyutu = val);
                        await _ayarlariKaydet();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = _temalar[_temaIndex];

    return Scaffold(
      backgroundColor: tema.arkaPlan,
      appBar: AppBar(
        backgroundColor: tema.arkaPlan,
        foregroundColor: tema.metin,
        elevation: 0,
        title: Text(
          'Nurdan Vecizeler',
          style: TextStyle(
            fontFamily: 'HatBaslik',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: tema.metin,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Anlık Bildirim Testi',
            icon: Icon(Icons.notifications_active_outlined, color: tema.vurgu),
            onPressed: () => anlikTestBildirim(_havuzVecizeler, _aktifIndex),
          ),
          IconButton(
            tooltip: '10 Saniyelik Zamanlı Test',
            icon: Icon(Icons.timer_outlined, color: tema.vurgu),
            onPressed: () =>
                zamanliTestBildirim(context, _havuzVecizeler, _aktifIndex),
          ),
          IconButton(
            tooltip: 'Bildirim Saatleri',
            icon: Icon(Icons.alarm, color: tema.vurgu),
            onPressed: _bildirimAyarlariPenceresi,
          ),
          IconButton(
            tooltip: 'Word Yükle & Tam Yedekleme',
            icon: Icon(Icons.folder_special_outlined, color: tema.vurgu),
            onPressed: () => yedekVeTopluYuklePenceresi(
              context: context,
              onVerilerGuncellendi: () async {
                await _ayarlariYukle();
                await _izinVePlanla();
              },
            ),
          ),
          IconButton(
            tooltip: 'Tema & Yazı Ayarları',
            icon: Icon(Icons.palette_outlined, color: tema.vurgu),
            onPressed: _gorunumAyarlariPenceresi,
          ),
        ],
      ),
      body: _sekmeIndex == 0 ? _vecizelerGovdesi(tema) : _favorilerGovdesi(tema),
      floatingActionButton: _sekmeIndex == 0
          ? FloatingActionButton.small(
              backgroundColor: tema.vurgu,
              foregroundColor: tema.koyu ? Colors.black : Colors.white,
              tooltip: 'Tek Vecize Ekle',
              onPressed: _tekVecizeEklePenceresi,
              child: const Icon(Icons.edit_note_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: tema.kartArkaPlan,
        selectedIndex: _sekmeIndex,
        onDestinationSelected: (idx) => setState(() => _sekmeIndex = idx),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Külliyat',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _favoriler.isNotEmpty,
              label: Text('${_favoriler.length}'),
              child: const Icon(Icons.bookmark_border),
            ),
            selectedIcon: const Icon(Icons.bookmark),
            label: 'Favorilerim',
          ),
        ],
      ),
    );
  }
    Widget _vecizelerGovdesi(_TemaPaleti tema) {
    final liste = _filtreliVecizeler;
    final guvenliIndex = liste.isEmpty ? 0 : _aktifIndex % liste.length;
    final aktifVecize = liste.isNotEmpty ? liste[guvenliIndex] : null;
    final favoriMi =
        aktifVecize != null && _favoriler.contains(aktifVecize.metin);

    return Column(
      children: [
        alarmIzinUyarisi(_alarmIzniVar),
        VakitKarsilamaSeridi(
          siradakiBildirimSaati: _sonrakiBildirimSaati,
          vurguRengi: tema.vurgu,
          koyuTema: tema.koyu,
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: _eserListesi.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final eser = _eserListesi[i];
              final secili = _seciliEser == eser;
              return ChoiceChip(
                label: Text(eser),
                selected: secili,
                selectedColor: tema.vurgu.withOpacity(0.22),
                labelStyle: TextStyle(
                  color: secili ? tema.vurgu : tema.altMetin,
                  fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12.5,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
          child: TextField(
            controller: _aramaCtrl,
            style: TextStyle(color: tema.metin, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Külliyatta ara (${_tumVecizeler.length} vecize)...',
              hintStyle: TextStyle(color: tema.altMetin, fontSize: 13),
              prefixIcon: Icon(Icons.search, color: tema.altMetin, size: 20),
              suffixIcon: _aramaMetni.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: tema.altMetin, size: 18),
                      onPressed: () {
                        _aramaCtrl.clear();
                        setState(() {
                          _aramaMetni = '';
                          _aktifIndex = 0;
                        });
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: tema.kartArkaPlan,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: tema.cerceve),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: tema.cerceve),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _aramaMetni = val;
                _aktifIndex = 0;
              });
            },
          ),
        ),
        Expanded(
          child: aktifVecize == null
              ? Center(
                  child: Text(
                    'Aramaya uygun vecize bulunamadı.',
                    style: TextStyle(color: tema.altMetin),
                  ),
                )
              : GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if ((details.primaryVelocity ?? 0) < -200) {
                      setState(() => _aktifIndex = (guvenliIndex + 1) % liste.length);
                      _ayarlariKaydet();
                    } else if ((details.primaryVelocity ?? 0) > 200) {
                      setState(() => _aktifIndex =
                          (guvenliIndex - 1 + liste.length) % liste.length);
                      _ayarlariKaydet();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: tema.kartArkaPlan,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tema.cerceve, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: tema.vurgu.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                aktifVecize.eser,
                                style: TextStyle(
                                  color: tema.vurgu,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              '${guvenliIndex + 1} / ${liste.length}',
                              style: TextStyle(
                                color: tema.altMetin,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (aktifVecize.arapca.isNotEmpty) ...[
                                    Text(
                                      aktifVecize.arapca,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontFamily: 'MushafFont',
                                        fontSize: _yaziBoyutu + 3,
                                        height: 1.8,
                                        color: tema.vurgu,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                  Text(
                                    '“${aktifVecize.metin}”',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: _yaziTipi.isEmpty
                                          ? null
                                          : _yaziTipi,
                                      fontSize: _yaziBoyutu,
                                      height: 1.65,
                                      color: tema.metin,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '— ${_tamKaynakMetni(aktifVecize)} —',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'KitapSerif',
                            fontStyle: FontStyle.italic,
                            fontSize: 13.5,
                            color: tema.altMetin,
                          ),
                        ),
                        const Divider(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              tooltip: 'Önceki',
                              icon: Icon(Icons.arrow_back_ios_new_rounded,
                                  color: tema.metin),
                              onPressed: () {
                                setState(() => _aktifIndex =
                                    (guvenliIndex - 1 + liste.length) %
                                        liste.length);
                                _ayarlariKaydet();
                              },
                            ),
                            IconButton(
                              tooltip: 'Rastgele Vecize',
                              icon: Icon(Icons.shuffle_rounded,
                                  color: tema.vurgu),
                              onPressed: () {
                                if (liste.length > 1) {
                                  setState(() => _aktifIndex =
                                      Random().nextInt(liste.length));
                                  _ayarlariKaydet();
                                }
                              },
                            ),
                            IconButton(
                              tooltip: favoriMi
                                  ? 'Favorilerden Çıkar'
                                  : 'Favorilere Ekle',
                              icon: Icon(
                                favoriMi
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: favoriMi ? tema.vurgu : tema.metin,
                              ),
                              onPressed: () => _favoriDegistir(aktifVecize),
                            ),
                            IconButton(
                              tooltip: 'Vecizeyi Düzenle',
                              icon: Icon(Icons.edit_outlined,
                                  color: tema.vurgu),
                              onPressed: () =>
                                  _vecizeDuzenlePenceresi(aktifVecize),
                            ),
                            IconButton(
                              tooltip: 'Paylaş',
                              icon:
                                  Icon(Icons.share_outlined, color: tema.metin),
                              onPressed: () =>
                                  paylasSecenekleriGoster(aktifVecize),
                            ),
                            IconButton(
                              tooltip: 'Sonraki',
                              icon: Icon(Icons.arrow_forward_ios_rounded,
                                  color: tema.metin),
                              onPressed: () {
                                setState(() => _aktifIndex =
                                    (guvenliIndex + 1) % liste.length);
                                _ayarlariKaydet();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _favorilerGovdesi(_TemaPaleti tema) {
    final tumFav = _favoriVecizeler;
    final favEserler = <String>{'Tümü', ...tumFav.map((e) => e.eser)}.toList();
    if (!favEserler.contains(_seciliFavoriEser)) {
      _seciliFavoriEser = 'Tümü';
    }
    final filtreliFav = tumFav
        .where((v) =>
            _seciliFavoriEser == 'Tümü' || v.eser == _seciliFavoriEser)
        .toList();

    if (tumFav.isEmpty) {
      return Center(
        child: Text(
          'Henüz favorilere eklenmiş bir vecize yok.',
          style: TextStyle(color: tema.altMetin, fontSize: 15),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            scrollDirection: Axis.horizontal,
            itemCount: favEserler.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final eser = favEserler[i];
              final secili = _seciliFavoriEser == eser;
              return ChoiceChip(
                label: Text(eser),
                selected: secili,
                onSelected: (_) => setState(() => _seciliFavoriEser = eser),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: filtreliFav.length,
            itemBuilder: (context, i) {
              final v = filtreliFav[i];
              return Card(
                color: tema.kartArkaPlan,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: tema.cerceve),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (v.arapca.isNotEmpty) ...[
                        Text(
                          v.arapca,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: 'MushafFont',
                            fontSize: _yaziBoyutu + 1,
                            color: tema.vurgu,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        '“${v.metin}”',
                        style: TextStyle(
                          fontFamily: _yaziTipi.isEmpty ? null : _yaziTipi,
                          fontSize: _yaziBoyutu - 1,
                          height: 1.55,
                          color: tema.metin,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _tamKaynakMetni(v),
                              style: TextStyle(
                                fontSize: 12,
                                color: tema.altMetin,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Vecizeyi Düzenle',
                            icon: Icon(Icons.edit_outlined,
                                size: 20, color: tema.vurgu),
                            onPressed: () => _vecizeDuzenlePenceresi(v),
                          ),
                          IconButton(
                            icon: Icon(Icons.share_outlined,
                                size: 20, color: tema.vurgu),
                            onPressed: () => paylasSecenekleriGoster(v),
                          ),
                          IconButton(
                            icon: Icon(Icons.bookmark_remove_outlined,
                                size: 20, color: Colors.red.shade400),
                            onPressed: () => _favoriDegistir(v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
