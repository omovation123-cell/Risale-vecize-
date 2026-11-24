import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'vecizeler.dart';

class UygulamaTemasi {
  final String ad;
  final Color ana, vurgu, zemin, kart, yazi;
  final bool koyuMu;
  const UygulamaTemasi({required this.ad, required this.ana, required this.vurgu, required this.zemin, required this.kart, required this.yazi, this.koyuMu = false});
}

const List<UygulamaTemasi> temalar = [
  UygulamaTemasi(ad: 'Zümrüt Yeşili', ana: Color(0xFF14532D), vurgu: Color(0xFFC58B2A), zemin: Color(0xFFFAF6EE), kart: Color(0xFFFFFDF9), yazi: Color(0xFF1C1917)),
  UygulamaTemasi(ad: 'Cilt Bordosu', ana: Color(0xFF6B1D2F), vurgu: Color(0xFFC58B2A), zemin: Color(0xFFFAF6EE), kart: Color(0xFFFFFDF9), yazi: Color(0xFF1C1917)),
  UygulamaTemasi(ad: 'Gece Siyahı', ana: Color(0xFF1B4332), vurgu: Color(0xFFD4A037), zemin: Color(0xFF121413), kart: Color(0xFF1C201E), yazi: Color(0xFFF3EFE6), koyuMu: true),
];

String? fontAilesiGetir(String secim) => (secim == 'KitapSerif' || secim == 'HatBaslik') ? secim : null;

class AcilisEkrani extends StatefulWidget {
  final Widget hedef;
  const AcilisEkrani({super.key, required this.hedef});
  @override
  State<AcilisEkrani> createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _gecildi = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..forward();
    Future.delayed(const Duration(milliseconds: 2800), _gec);
  }

  void _gec() {
    if (_gecildi || !mounted) return;
    _gecildi = true;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => widget.hedef,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _gec,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF6EE),
        body: Container(
          margin: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFC58B2A), width: 2)),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFFC58B2A), width: 0.8)),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final t = Curves.easeInOut.transform(_ctrl.value);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 280, height: 180, child: CustomPaint(painter: _KalemVeElCizici(ilerleme: t))),
                    const SizedBox(height: 8),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: t.clamp(0.05, 1.0),
                        child: const Text('Risale-i Nur', style: TextStyle(fontFamily: 'HatBaslik', fontSize: 38, fontWeight: FontWeight.bold, color: Color(0xFF991B1B), letterSpacing: 1.2)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: (t > 0.5 ? (t - 0.5) * 2 : 0.0).clamp(0.0, 1.0),
                      child: const Text('Külliyattan Vecizeler • Kur’an • Hadis', style: TextStyle(fontFamily: 'KitapSerif', fontSize: 14, color: Color(0xFF14532D), fontWeight: FontWeight.w600)),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _KalemVeElCizici extends CustomPainter {
  final double ilerleme;
  _KalemVeElCizici({required this.ilerleme});

  @override
  void paint(Canvas canvas, Size size) {
    final x = 35 + (size.width - 130) * ilerleme;
    final y = size.height - 16 + ((ilerleme * 28).floor().isEven ? 0.0 : -3.5);
    final uc = Offset(x, y);

    canvas.drawLine(Offset(35, size.height - 16), uc, Paint()..color = const Color(0xFF991B1B)..strokeWidth = 3..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(uc.dx + 8, uc.dy - 15), Offset(uc.dx + 46, uc.dy - 88), Paint()..color = const Color(0xFF7F1D1D)..strokeWidth = 9..strokeCap = StrokeCap.round);

    final altin = Path()..moveTo(uc.dx, uc.dy)..lineTo(uc.dx + 12, uc.dy - 13)..lineTo(uc.dx + 4, uc.dy - 17)..close();
    canvas.drawPath(altin, Paint()..color = const Color(0xFFD97706));

    final ten = Paint()..color = const Color(0xFFD6A37A);
    final golge = Paint()..color = const Color(0xFF9A6B47)..style = PaintingStyle.stroke..strokeWidth = 1.6;
    final el = Path()
      ..moveTo(uc.dx + 14, uc.dy - 24)
      ..quadraticBezierTo(uc.dx + 34, uc.dy - 62, uc.dx + 72, uc.dy - 74)
      ..lineTo(uc.dx + 96, uc.dy - 44)
      ..quadraticBezierTo(uc.dx + 64, uc.dy - 14, uc.dx + 22, uc.dy - 12)
      ..close();
    canvas.drawPath(el, ten);
    canvas.drawPath(el, golge);

    final parmak = Path()
      ..moveTo(uc.dx + 12, uc.dy - 20)
      ..quadraticBezierTo(uc.dx + 26, uc.dy - 36, uc.dx + 42, uc.dy - 30)
      ..quadraticBezierTo(uc.dx + 30, uc.dy - 14, uc.dx + 14, uc.dy - 16)
      ..close();
    canvas.drawPath(parmak, ten);
    canvas.drawPath(parmak, golge);

    final manset = Path()..moveTo(uc.dx + 68, uc.dy - 76)..lineTo(uc.dx + 112, uc.dy - 92)..lineTo(uc.dx + 132, uc.dy - 54)..lineTo(uc.dx + 92, uc.dy - 40)..close();
    canvas.drawPath(manset, Paint()..color = const Color(0xFF14532D));
  }

  @override
  bool shouldRepaint(covariant _KalemVeElCizici old) => old.ilerleme != ilerleme;
}

String _temizle(String s) => s.trim().replaceAll(RegExp(r'^[“"]|[”"]$'), '').trim();

Future<void> vecizeEkleGoster({required BuildContext context, required List<Vecize> tumVecizeler, required UygulamaTemasi tema, required Future<void> Function(List<Vecize>) onEkle}) async {
  final eserler = eserListesi.where((e) => e != 'Tümü').toList();
  String seciliEser = eserler.contains('Sözler') ? 'Sözler' : eserler.first;
  final metinCtrl = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: tema.zemin,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModal) => Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(ctx).viewInsets.bottom + 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Vecize Ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tema.koyuMu ? tema.vurgu : tema.ana)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: seciliEser,
                dropdownColor: tema.kart,
                style: TextStyle(color: tema.yazi, fontFamily: 'KitapSerif'),
                decoration: InputDecoration(labelText: 'Kitap Seçin', filled: true, fillColor: tema.kart, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: eserler.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) { if (v != null) setModal(() => seciliEser = v); },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: metinCtrl,
                maxLines: 5,
                minLines: 3,
                autofocus: true,
                style: TextStyle(color: tema.yazi, fontFamily: 'KitapSerif'),
                decoration: InputDecoration(labelText: 'Vecize', hintText: 'Vecizeyi buraya yazın...', alignLabelWithHint: true, filled: true, fillColor: tema.kart, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: tema.ana, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  final m = _temizle(metinCtrl.text);
                  if (m.isEmpty) return;
                  if (!tumVecizeler.any((v) => v.metin == m)) {
                    await onEkle([Vecize(metin: m, kaynak: seciliEser, eser: seciliEser, arapca: '')]);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                icon: const Icon(Icons.check),
                label: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> vecizeDuzenleGoster({required BuildContext context, required Vecize vecize, required UygulamaTemasi tema, required Future<void> Function(Vecize) onKaydet}) async {
  final eserler = eserListesi.where((e) => e != 'Tümü').toList();
  String seciliEser = eserler.contains(vecize.eser) ? vecize.eser : eserler.last;
  final arapcaCtrl = TextEditingController(text: vecize.arapca), metinCtrl = TextEditingController(text: vecize.metin), kaynakCtrl = TextEditingController(text: vecize.kaynak);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: tema.zemin,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModal) => Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(ctx).viewInsets.bottom + 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Vecizeyi Düzenle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tema.koyuMu ? tema.vurgu : tema.ana)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: seciliEser,
                dropdownColor: tema.kart,
                style: TextStyle(color: tema.yazi, fontFamily: 'KitapSerif'),
                decoration: InputDecoration(labelText: 'Kitap / Bölüm', filled: true, fillColor: tema.kart, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: eserler.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) { if (v != null) setModal(() => seciliEser = v); },
              ),
              if (seciliEser == 'Kur’an-ı Kerim' || arapcaCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                TextField(controller: arapcaCtrl, textDirection: TextDirection.rtl, maxLines: 2, style: TextStyle(color: tema.yazi, fontFamily: 'MushafFont', fontSize: 20), decoration: InputDecoration(labelText: 'Arapça Âyet Metni', filled: true, fillColor: tema.kart, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              ],
              const SizedBox(height: 10),
              TextField(controller: metinCtrl, maxLines: 4, style: TextStyle(color: tema.yazi, fontFamily: 'KitapSerif'), decoration: InputDecoration(labelText: 'Metin', filled: true, fillColor: tema.kart, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: kaynakCtrl, style: TextStyle(color: tema.yazi, fontFamily: 'KitapSerif'), decoration: InputDecoration(labelText: 'Kaynak', filled: true, fillColor: tema.kart, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: tema.ana, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  final m = _temizle(metinCtrl.text);
                  final k = kaynakCtrl.text.trim().isEmpty ? seciliEser : kaynakCtrl.text.trim();
                  if (m.isEmpty) return;
                  await onKaydet(Vecize(metin: m, kaynak: k, eser: seciliEser, arapca: arapcaCtrl.text.trim()));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Güncelle'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
// --- PARÇA 1 SONU ---
// --- PARÇA 2 BAŞLANGICI ---
class FavorilerSayfasi extends StatefulWidget {
  final List<Vecize> tumVecizeler;
  final List<String> favoriler;
  final UygulamaTemasi tema;
  final String? aktifFont;
  final Future<void> Function(String) onFavoriSil;
  final Future<void> Function(Vecize) onPaylasSecenekli;

  const FavorilerSayfasi({super.key, required this.tumVecizeler, required this.favoriler, required this.tema, required this.aktifFont, required this.onFavoriSil, required this.onPaylasSecenekli});
  @override
  State<FavorilerSayfasi> createState() => _FavorilerSayfasiState();
}

class _FavorilerSayfasiState extends State<FavorilerSayfasi> {
  String _seciliKitap = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final t = widget.tema;
    final tumFavlar = widget.tumVecizeler.where((v) => widget.favoriler.contains(v.metin)).toList();
    if (tumFavlar.isEmpty) return Center(child: Text('Henüz favori vecize eklemediniz.', style: TextStyle(color: t.yazi, fontFamily: widget.aktifFont)));

    final kitaplar = ['Tümü', ...eserListesi.where((e) => e != 'Tümü' && tumFavlar.any((v) => v.eser == e))];
    if (!kitaplar.contains(_seciliKitap)) _seciliKitap = 'Tümü';
    final liste = _seciliKitap == 'Tümü' ? tumFavlar : tumFavlar.where((v) => v.eser == _seciliKitap).toList();

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
            scrollDirection: Axis.horizontal,
            itemCount: kitaplar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final k = kitaplar[i];
              final adet = k == 'Tümü' ? tumFavlar.length : tumFavlar.where((v) => v.eser == k).length;
              final s = _seciliKitap == k;
              return ChoiceChip(label: Text('$k ($adet)'), selected: s, selectedColor: t.ana, backgroundColor: t.kart, labelStyle: TextStyle(color: s ? Colors.white : t.yazi, fontWeight: FontWeight.w600), onSelected: (_) => setState(() => _seciliKitap = k));
            },
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: liste.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final v = liste[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: t.kart, borderRadius: BorderRadius.circular(18), border: Border.all(color: t.vurgu, width: 1.2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: t.zemin, borderRadius: BorderRadius.circular(10), border: Border.all(color: t.vurgu, width: 0.7)),
                      child: Text(v.eser, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.koyuMu ? t.vurgu : t.ana)),
                    ),
                    if (v.arapca.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SizedBox(width: double.infinity, child: Text(v.arapca, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: TextStyle(fontFamily: 'MushafFont', fontSize: 22, height: 1.7, color: t.yazi))),
                    ],
                    const SizedBox(height: 8),
                    Text('“${v.metin}”', style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, fontFamily: widget.aktifFont, color: t.yazi)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text('— ${v.kaynak}', style: TextStyle(color: t.koyuMu ? t.vurgu : t.ana, fontWeight: FontWeight.bold, fontFamily: widget.aktifFont))),
                        IconButton(
                          icon: Icon(Icons.copy, size: 20, color: t.yazi),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: v.arapca.isNotEmpty ? '${v.arapca}\n\n“${v.metin}”\n— ${v.kaynak}' : '“${v.metin}”\n— ${v.kaynak}'));
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Kopyalandı.')));
                          },
                        ),
                        IconButton(icon: Icon(Icons.share, size: 20, color: t.yazi), onPressed: () => widget.onPaylasSecenekli(v)),
                        IconButton(icon: const Icon(Icons.favorite, color: Colors.red, size: 22), onPressed: () => widget.onFavoriSil(v.metin)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget zamanSayfasi({
  required List<String> saatler,
  required bool periyodikAktif,
  required int periyodikDk,
  required bool huSesi,
  required UygulamaTemasi tema,
  required VoidCallback onSaatEkle,
  required Future<void> Function(String) onSaatSil,
  required Future<void> Function(bool) onPeriyodikDegistir,
  required Future<void> Function(int) onDakikaSec,
  required Future<void> Function(bool) onHuSesiDegistir,
  required VoidCallback onTestBildirim,
}) {
  const secenekler = [15, 30, 45, 60, 120, 180];
  return ListView(
    padding: const EdgeInsets.all(14),
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: tema.kart, borderRadius: BorderRadius.circular(18), border: Border.all(color: tema.vurgu, width: 0.8)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bildirim Sesi (Hû Sesi)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tema.yazi)),
                  Text(huSesi ? 'Özel ney / Hû tınısı aktif' : 'Telefonun varsayılan sesi aktif', style: TextStyle(color: tema.koyuMu ? Colors.white70 : Colors.black54)),
                ],
              ),
            ),
            Switch(value: huSesi, activeColor: tema.ana, onChanged: onHuSesiDegistir),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: tema.kart, borderRadius: BorderRadius.circular(18), border: Border.all(color: tema.vurgu, width: 0.8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Belirli Saat & Dakika', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tema.yazi)),
                FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: tema.ana), onPressed: onSaatEkle, icon: const Icon(Icons.more_time, size: 18), label: const Text('Saat Ekle')),
              ],
            ),
            if (saatler.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: saatler.map((s) => InputChip(label: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)), onDeleted: () => onSaatSil(s))).toList()),
            ],
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: tema.kart, borderRadius: BorderRadius.circular(18), border: Border.all(color: tema.vurgu, width: 0.8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dakika Aralıklı Hatırlatıcı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tema.yazi)),
                      Text(periyodikAktif ? 'Her $periyodikDk dakikada bir aktif' : 'Kapalı', style: TextStyle(color: tema.koyuMu ? Colors.white70 : Colors.black54)),
                    ],
                  ),
                ),
                Switch(value: periyodikAktif, activeColor: tema.ana, onChanged: onPeriyodikDegistir),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: secenekler.map((dk) {
                final s = periyodikDk == dk;
                return ChoiceChip(label: Text('$dk dk'), selected: s, selectedColor: tema.ana, backgroundColor: tema.zemin, labelStyle: TextStyle(color: s ? Colors.white : tema.yazi, fontWeight: FontWeight.w600), onSelected: (_) => onDakikaSec(dk));
              }).toList(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: tema.vurgu)),
        onPressed: onTestBildirim,
        icon: Icon(Icons.notifications_active_outlined, color: tema.koyuMu ? tema.vurgu : tema.ana),
        label: Text('Şimdi Test Bildirimi Gönder', style: TextStyle(color: tema.yazi, fontWeight: FontWeight.w600)),
      ),
    ],
  );
}

Widget ayarlarSayfasi({
  required BuildContext context,
  required UygulamaTemasi tema,
  required String seciliFont,
  required double yaziBoyutu,
  required List<String> aktifKitaplar,
  required List<Vecize> ozelVecizeler,
  required List<String> favoriler,
  required Future<void> Function(String) onFontDegistir,
  required Future<void> Function(double) onBoyutDegistir,
  required Future<void> Function(List<String>) onKitaplarDegistir,
  required Future<void> Function(List<Vecize>, List<String>) onYedekYukle,
}) {
  final tumKitaplar = eserListesi.where((e) => e != 'Tümü').toList();
  const fontlar = [{'kod': 'KitapSerif', 'ad': 'Klasik Kitap'}, {'kod': 'HatBaslik', 'ad': 'Zarif Kaligrafi'}, {'kod': 'Varsayilan', 'ad': 'Sade Okuma'}];

  return ListView(
    padding: const EdgeInsets.all(14),
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: tema.kart, borderRadius: BorderRadius.circular(18), border: Border.all(color: tema.vurgu, width: 0.9)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yazı Tipi ve Boyutu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tema.yazi)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fontlar.map((f) {
                final s = seciliFont == f['kod'];
                return ChoiceChip(label: Text(f['ad']!), selected: s, selectedColor: tema.ana, backgroundColor: tema.zemin, labelStyle: TextStyle(color: s ? Colors.white : tema.yazi, fontWeight: FontWeight.w600), onSelected: (_) => onFontDegistir(f['kod']!));
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('A', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: tema.yazi)),
                Expanded(child: Slider(value: yaziBoyutu, min: 16, max: 28, divisions: 12, activeColor: tema.ana, label: '${yaziBoyutu.round()}', onChanged: onBoyutDegistir)),
                Text('A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: tema.yazi)),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: tema.zemin, borderRadius: BorderRadius.circular(12), border: Border.all(color: tema.vurgu, width: 0.6)),
              child: Column(
                children: [
                  Text('اَلَا بِذِكْرِ اللّٰهِ تَطْمَئِنُّ الْقُلُوبُۜ', textDirection: TextDirection.rtl, style: TextStyle(fontFamily: 'MushafFont', fontSize: yaziBoyutu + 3, color: tema.yazi)),
                  const SizedBox(height: 4),
                  Text('“Güzel gören güzel düşünür. Güzel düşünen hayatından lezzet alır.”', textAlign: TextAlign.center, style: TextStyle(fontFamily: fontAilesiGetir(seciliFont), fontSize: yaziBoyutu, color: tema.yazi)),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: tema.kart, borderRadius: BorderRadius.circular(18), border: Border.all(color: tema.vurgu, width: 0.9)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bugün Hangi Kitaplar Çıksın?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tema.yazi)),
                      Text(aktifKitaplar.isEmpty ? 'Tümü aktif (16 bölüm)' : '${aktifKitaplar.length} kitap seçili', style: TextStyle(fontSize: 12, color: tema.koyuMu ? Colors.white70 : Colors.black54)),
                    ],
                  ),
                ),
                TextButton(onPressed: () => onKitaplarDegistir([]), child: Text('Tümünü Aç', style: TextStyle(color: tema.koyuMu ? tema.vurgu : tema.ana, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tumKitaplar.map((k) {
                final secili = aktifKitaplar.isEmpty || aktifKitaplar.contains(k);
                return FilterChip(
                  label: Text(k, style: const TextStyle(fontSize: 12)),
                  selected: secili,
                  selectedColor: tema.ana,
                  checkmarkColor: Colors.white,
                  backgroundColor: tema.zemin,
                  labelStyle: TextStyle(color: secili ? Colors.white : tema.yazi, fontWeight: FontWeight.w600),
                  onSelected: (val) {
                    List<String> yeni = aktifKitaplar.isEmpty ? List.from(tumKitaplar) : List.from(aktifKitaplar);
                    if (val) { if (!yeni.contains(k)) yeni.add(k); } else { if (yeni.length <= 1) return; yeni.remove(k); }
                    if (yeni.length == tumKitaplar.length) yeni = [];
                    onKitaplarDegistir(yeni);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: tema.kart, borderRadius: BorderRadius.circular(18), border: Border.all(color: tema.vurgu, width: 0.9)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yedekleme (Özel Vecizeler & Favoriler)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tema.yazi)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: tema.ana),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: jsonEncode({'ozel': ozelVecizeler.map((v) => v.toMap()).toList(), 'favoriler': favoriler})));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yedek kodu panoya kopyalandı.')));
                    },
                    icon: const Icon(Icons.copy_all, size: 18),
                    label: const Text('Yedeği Kopyala'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: BorderSide(color: tema.vurgu)),
                    onPressed: () async {
                      final ctrl = TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Yedekten Geri Yükle'),
                          content: TextField(controller: ctrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Yedek kodunu yapıştırın...')),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: tema.ana),
                              onPressed: () async {
                                try {
                                  final data = jsonDecode(ctrl.text.trim()) as Map<String, dynamic>;
                                  final ozel = (data['ozel'] as List<dynamic>? ?? []).map((e) => Vecize.fromMap(e as Map<String, dynamic>)).toList();
                                  final fav = (data['favoriler'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
                                  await onYedekYukle(ozel, fav);
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yedek geri yüklendi.')));
                                } catch (_) {
                                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geçersiz yedek kodu.')));
                                }
                              },
                              child: const Text('Yükle'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.restore, size: 18, color: tema.koyuMu ? tema.vurgu : tema.ana),
                    label: Text('Yedek Yükle', style: TextStyle(color: tema.yazi)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
// --- EKRANLAR DOSYASI BİTTİ ---
