import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vecizeler.dart';

const String _ozelVecizelerKey = 'sprz_ozel_vecizeler_v1';

/// Kullanıcının Word veya metin yoluyla eklediği özel vecizeleri getirir
Future<List<Vecize>> ozelVecizeleriGetir() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList(_ozelVecizelerKey) ?? [];
    final sonuc = <Vecize>[];
    for (final satir in liste) {
      try {
        final map = jsonDecode(satir) as Map<String, dynamic>;
        sonuc.add(Vecize.fromMap(map));
      } catch (_) {}
    }
    return sonuc;
  } catch (_) {
    return [];
  }
}

Future<void> _ozelVecizeleriKaydet(List<Vecize> vecizeler) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonListe = vecizeler.map((v) => jsonEncode(v.toMap())).toList();
  await prefs.setStringList(_ozelVecizelerKey, jsonListe);
}

/// Word (.docx) dosyasının içindeki tüm paragrafları okur
String _docxMetniniCikar(List<int> bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  for (final file in archive) {
    if (file.isFile && file.name == 'word/document.xml') {
      final xml = utf8.decode(file.content as List<int>, allowMalformed: true);
      final paragrafRegex = RegExp(r'<w:p\b[^>]*>(.*?)</w:p>', dotAll: true);
      final yaziRegex = RegExp(r'<w:t\b[^>]*>(.*?)</w:t>', dotAll: true);
      final satirlar = <String>[];

      for (final pMatch in paragrafRegex.allMatches(xml)) {
        final pIcerik = pMatch.group(1) ?? '';
        final tampon = StringBuffer();
        for (final tMatch in yaziRegex.allMatches(pIcerik)) {
          tampon.write(tMatch.group(1) ?? '');
        }
        final temiz = _xmlKarakterCoz(tampon.toString()).trim();
        if (temiz.isNotEmpty) {
          satirlar.add(temiz);
        }
      }
      return satirlar.join('\n');
    }
  }
  return '';
}

String _xmlKarakterCoz(String metin) {
  return metin
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');
}

/// Ham metin satırlarını akıllı şekilde Vecize nesnelerine dönüştürür
List<Vecize> _metniVecizelereAyir(String hamMetin) {
  final satirlar = hamMetin.split(RegExp(r'\r?\n'));
  final bulunanlar = <Vecize>[];

  for (var satir in satirlar) {
    satir = satir.trim();
    // Çok kısa başlık veya sayfa numaralarını atla
    if (satir.length < 10) continue;

    String metin = satir;
    String eser = 'Kişisel Arşivim';
    String kaynak = 'Özel Vecize';

    // Satır sonunda " — Eser, Kaynak" veya " - Eser" varsa ayır
    final tireAyrim = RegExp(r'^(.*?)\s+[—–-]\s+([^—–-]{2,60})$').firstMatch(satir);
    if (tireAyrim != null && (tireAyrim.group(1)?.length ?? 0) >= 12) {
      metin = tireAyrim.group(1)!.trim();
      final sag = tireAyrim.group(2)!.trim();
      final virgulIndex = sag.indexOf(',');
      if (virgulIndex > 0) {
        eser = sag.substring(0, virgulIndex).trim();
        kaynak = sag.substring(virgulIndex + 1).trim();
      } else {
        eser = sag;
        kaynak = sag;
      }
    } else {
      // Satır sonunda "(Eser / Kaynak)" varsa ayır
      final parantezAyrim = RegExp(r'^(.*?)\s*\(([^()]{2,60})\)\s*$').firstMatch(satir);
      if (parantezAyrim != null && (parantezAyrim.group(1)?.length ?? 0) >= 12) {
        metin = parantezAyrim.group(1)!.trim();
        final sag = parantezAyrim.group(2)!.trim();
        final virgulIndex = sag.indexOf(',');
        if (virgulIndex > 0) {
          eser = sag.substring(0, virgulIndex).trim();
          kaynak = sag.substring(virgulIndex + 1).trim();
        } else {
          eser = sag;
          kaynak = sag;
        }
      }
    }

    bulunanlar.add(Vecize.fromMap({
      'metin': metin,
      'kaynak': kaynak,
      'eser': eser,
      'arapca': '',
    }));
  }

  return bulunanlar;
}

/// Toplu vecize metnini mevcut özel arşive tekrar etmeden ekler
Future<int> topluVecizeKaydet(String hamMetin) async {
  final yeniler = _metniVecizelereAyir(hamMetin);
  if (yeniler.isEmpty) return 0;

  final mevcutlar = await ozelVecizeleriGetir();
  final mevcutMetinler = mevcutlar.map((e) => e.metin.trim()).toSet();

  int eklenen = 0;
  for (final v in yeniler) {
    if (!mevcutMetinler.contains(v.metin.trim())) {
      mevcutlar.add(v);
      mevcutMetinler.add(v.metin.trim());
      eklenen++;
    }
  }

  if (eklenen > 0) {
    await _ozelVecizeleriKaydet(mevcutlar);
  }
  return eklenen;
}

/// Uygulamadaki TÜM verileri (favoriler, saatler, ayarlar, özel vecizeler) tek JSON dosyasına yedekler
Future<File> tamYedekDosyasiOlustur() async {
  final prefs = await SharedPreferences.getInstance();
  final veriler = <String, dynamic>{};

  for (final key in prefs.getKeys()) {
    final val = prefs.get(key);
    if (val is String) {
      veriler[key] = {'t': 's', 'v': val};
    } else if (val is int) {
      veriler[key] = {'t': 'i', 'v': val};
    } else if (val is double) {
      veriler[key] = {'t': 'd', 'v': val};
    } else if (val is bool) {
      veriler[key] = {'t': 'b', 'v': val};
    } else if (val is List<String>) {
      veriler[key] = {'t': 'l', 'v': val};
    }
  }

  final paket = {
    'uygulama': 'Nurdan Vecizeler',
    'imza': 'SPRZ CANTER',
    'tarih': DateTime.now().toIso8601String(),
    'veriler': veriler,
  };

  final jsonMetin = const JsonEncoder.withIndent('  ').convert(paket);
  const dosyaAdi = 'Nurdan_Vecizeler_Tam_Yedek.json';

  // Öncelik: Telefonun genel İndirilenler (Download) klasörü (uygulama silinse bile kalır)
  try {
    final downloadDir = Directory('/storage/emulated/0/Download');
    if (await downloadDir.exists()) {
      final dosya = File('${downloadDir.path}/$dosyaAdi');
      await dosya.writeAsString(jsonMetin, flush: true);
      return dosya;
    }
  } catch (_) {}

  // Yedek konum: Harici uygulama dizini veya belgeler klasörü
  final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
  final dosya = File('${dir.path}/$dosyaAdi');
  await dosya.writeAsString(jsonMetin, flush: true);
  return dosya;
}

/// Seçilen yedek dosyasından tüm verileri geri yükler
Future<bool> yedekDosyasindanGeriYukle() async {
  final sonuc = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
    withData: true,
  );
  if (sonuc == null || sonuc.files.isEmpty) return false;

  final secilen = sonuc.files.single;
  String icerik = '';
  if (secilen.bytes != null) {
    icerik = utf8.decode(secilen.bytes!, allowMalformed: true);
  } else if (secilen.path != null) {
    icerik = await File(secilen.path!).readAsString();
  }

  if (icerik.trim().isEmpty) return false;

  final paket = jsonDecode(icerik) as Map<String, dynamic>;
  final veriler = paket['veriler'] as Map<String, dynamic>?;
  if (veriler == null) return false;

  final prefs = await SharedPreferences.getInstance();
  for (final entry in veriler.entries) {
    final kayit = entry.value as Map<String, dynamic>;
    final tip = kayit['t'];
    final deger = kayit['v'];

    if (tip == 's' && deger is String) {
      await prefs.setString(entry.key, deger);
    } else if (tip == 'i' && deger is int) {
      await prefs.setInt(entry.key, deger);
    } else if (tip == 'd' && deger is num) {
      await prefs.setDouble(entry.key, deger.toDouble());
    } else if (tip == 'b' && deger is bool) {
      await prefs.setBool(entry.key, deger);
    } else if (tip == 'l' && deger is List) {
      await prefs.setStringList(entry.key, deger.map((e) => e.toString()).toList());
    }
  }

  return true;
}

/// Yedekleme ve Word'den Toplu Vecize Yükleme Penceresi
Future<void> yedekVeTopluYuklePenceresi({
  required BuildContext context,
  required Future<void> Function() onVerilerGuncellendi,
}) async {
  final ozelListe = await ozelVecizeleriGetir();
  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Toplu Vecize & Tam Yedekleme',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Eklenen Özel Vecize: ${ozelListe.length} adet',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 18),

              // 1. Word (.docx) veya .txt Dosyasından Yükle
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14532D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.description_outlined),
                label: const Text('Word (.docx) / Metin Dosyasından Ekle'),
                onPressed: () async {
                  try {
                    final secim = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['docx', 'txt'],
                      withData: true,
                    );
                    if (secim == null || secim.files.isEmpty) return;
                    final f = secim.files.single;
                    final bytes = f.bytes ?? (f.path != null ? await File(f.path!).readAsBytes() : null);
                    if (bytes == null) return;

                    final ext = (f.extension ?? '').toLowerCase();
                    final metin = ext == 'docx'
                        ? _docxMetniniCikar(bytes)
                        : utf8.decode(bytes, allowMalformed: true);

                    final adet = await topluVecizeKaydet(metin);
                    await onVerilerGuncellendi();
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$adet yeni vecize havuza ve bildirimlere eklendi.')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dosya okunamadı: $e')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 10),

              // 2. Word'den Kopyala - Yapıştır ile Toplu Ekle
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.paste_rounded),
                label: const Text('Metin Yapıştırarak Toplu Ekle'),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _yapistirarakEklePenceresi(context, onVerilerGuncellendi);
                },
              ),
              const Divider(height: 26),

              // 3. Tam Yedek Al (İndirilenler klasörüne kaydeder)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.save_alt_rounded),
                label: const Text('Tam Yedek Al (İndirilenler Klasörüne)'),
                onPressed: () async {
                  try {
                    final dosya = await tamYedekDosyasiOlustur();
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 6),
                          content: Text('Yedek kaydedildi: ${dosya.path}'),
                          action: SnackBarAction(
                            label: 'Paylaş',
                            onPressed: () {
                              Share.shareXFiles([XFile(dosya.path)], text: 'Nurdan Vecizeler Tam Yedek');
                            },
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Yedekleme hatası: $e')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 10),

              // 4. Yedekten Geri Yükle
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.restore_page_outlined),
                label: const Text('Yedekten Geri Yükle (Silinse Bile)'),
                onPressed: () async {
                  try {
                    final ok = await yedekDosyasindanGeriYukle();
                    if (ok) {
                      await onVerilerGuncellendi();
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tüm favoriler, ayarlar ve vecizeler geri yüklendi!')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Geri yükleme hatası: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _yapistirarakEklePenceresi(
  BuildContext context,
  Future<void> Function() onVerilerGuncellendi,
) async {
  final controller = TextEditingController();
  await showDialog(
    context: context,
    builder: (dCtx) {
      return AlertDialog(
        title: const Text('Toplu Vecize Yapıştır'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Word belgesinden kopyaladığınız vecizeleri her satıra bir vecize gelecek şekilde yapıştırın (İsterseniz sonuna "— Sözler" gibi kaynak ekleyebilirsiniz):',
                style: TextStyle(fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Güzel gören güzel düşünür... — Mektubat\nİman hem nurdur, hem kuvvettir. — Sözler',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              final adet = await topluVecizeKaydet(controller.text);
              await onVerilerGuncellendi();
              if (dCtx.mounted) Navigator.pop(dCtx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$adet yeni vecize eklendi.')),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      );
    },
  );
}
// --- YEDEK VE YÜKLE DOSYASI BİTTİ ---
