import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'vecizeler.dart';

class UygulamaTemasi {
  final String ad;
  final Color ana;
  final Color vurgu;
  final Color zemin;
  final Color kart;
  final Color yazi;
  final bool koyuMu;

  const UygulamaTemasi({
    required this.ad,
    required this.ana,
    required this.vurgu,
    required this.zemin,
    required this.kart,
    required this.yazi,
    this.koyuMu = false,
  });
}

const List<UygulamaTemasi> temalar = [
  UygulamaTemasi(
    ad: 'Zümrüt Yeşili',
    ana: Color(0xFF14532D),
    vurgu: Color(0xFFC58B2A),
    zemin: Color(0xFFFAF6EE),
    kart: Color(0xFFFFFDF9),
    yazi: Color(0xFF1C1917),
  ),
  UygulamaTemasi(
    ad: 'Cilt Bordosu',
    ana: Color(0xFF6B1D2F),
    vurgu: Color(0xFFC58B2A),
    zemin: Color(0xFFFAF6EE),
    kart: Color(0xFFFFFDF9),
    yazi: Color(0xFF1C1917),
  ),
  UygulamaTemasi(
    ad: 'Gece Siyahı',
    ana: Color(0xFF1B4332),
    vurgu: Color(0xFFD4A037),
    zemin: Color(0xFF121413),
    kart: Color(0xFF1C201E),
    yazi: Color(0xFFF3EFE6),
    koyuMu: true,
  ),
];

String _temizle(String s) => s.trim().replaceAll(RegExp(r'^[“"]|[”"]$'), '').trim();

Future<void> vecizeEkleGoster({
  required BuildContext context,
  required List<Vecize> tumVecizeler,
  required UygulamaTemasi tema,
  required Future<void> Function(List<Vecize>) onEkle,
}) async {
  final eserler = eserListesi.where((e) => e != 'Tümü').toList();
  String seciliEser = eserler.first;
  final metinCtrl = TextEditingController();
  final kaynakCtrl = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: tema.zemin,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(ctx).viewInsets.bottom + 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Yeni Vecize Ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tema.koyuMu ? tema.vurgu : tema.ana)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: seciliEser,
                dropdownColor: tema.kart,
                style: TextStyle(color: tema.yazi, fontFamily: 'serif'),
                decoration: InputDecoration(labelText: 'Eser', filled: true, fillColor: tema.kart, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: eserler.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) { if (v != null) setModalState(() => seciliEser = v); },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: metinCtrl,
                maxLines: 4,
                style: TextStyle(color: tema.yazi, fontFamily: 'serif'),
                decoration: InputDecoration(
                  labelText: 'Vecize Metni',
                  hintText: 'Birden fazla eklemek için araya boş satır bırakın...',
                  filled: true,
                  fillColor: tema.kart,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: kaynakCtrl,
                style: TextStyle(color: tema.yazi, fontFamily: 'serif'),
                decoration: InputDecoration(
                  labelText: 'Kaynak (Örn: Sözler, Yirmi Üçüncü Söz)',
                  filled: true,
                  fillColor: tema.kart,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: tema.ana, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  final bloklar = metinCtrl.text.split(RegExp(r'\n\s*\n'));
                  final yeniler = <Vecize>[];
                  for (final b in bloklar) {
                    if (b.trim().isEmpty) continue;
                    String m = b;
                    String k = kaynakCtrl.text.trim();
                    if (b.contains('|')) {
                      final idx = b.lastIndexOf('|');
                      m = b.substring(0, idx);
                      k = b.substring(idx + 1).trim();
                    }
                    m = _temizle(m);
                    if (k.isEmpty) k = seciliEser;
                    if (m.isNotEmpty && !tumVecizeler.any((v) => v.metin == m) && !yeniler.any((v) => v.metin == m)) {
                      yeniler.add(Vecize(metin: m, kaynak: k, eser: seciliEser));
                    }
                  }
                  if (yeniler.isEmpty) return;
                  await onEkle(yeniler);
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

Future<void> vecizeDuzenleGoster({
  required BuildContext context,
  required Vecize vecize,
  required UygulamaTemasi tema,
  required Future<void> Function(Vecize) onKaydet,
}) async {
  final eserler = eserListesi.where((e) => e != 'Tümü').toList();
  String seciliEser = eserler.contains(vecize.eser) ? vecize.eser : eserler.last;
  final metinCtrl = TextEditingController(text: vecize.metin);
  final kaynakCtrl = TextEditingController(text: vecize.kaynak);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: tema.zemin,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Padding(
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
                style: TextStyle(color: tema.yazi, fontFamily: 'serif'),
                decoration: InputDecoration(labelText: 'Eser', filled: true, fillColor: tema.kart, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: eserler.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) { if (v != null) setModalState(() => seciliEser = v); },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: metinCtrl,
                maxLines: 4,
                style: TextStyle(color: tema.yazi, fontFamily: 'serif'),
                decoration: InputDecoration(labelText: 'Vecize Metni', filled: true, fillColor: tema.kart, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: kaynakCtrl,
                style: TextStyle(color: tema.yazi, fontFamily: 'serif'),
                decoration: InputDecoration(labelText: 'Kaynak', filled: true, fillColor: tema.kart, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: tema.ana, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  final m = _temizle(metinCtrl.text);
                  final k = kaynakCtrl.text.trim().isEmpty ? seciliEser : kaynakCtrl.text.trim();
                  if (m.isEmpty) return;
                  await onKaydet(Vecize(metin: m, kaynak: k, eser: seciliEser));
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

Widget favorilerSayfasi({
  required List<Vecize> tumVecizeler,
  required List<String> favoriler,
  required UygulamaTemasi tema,
  required Future<void> Function(String) onFavoriSil,
}) {
  final favListe = tumVecizeler.where((v) => favoriler.contains(v.metin)).toList();
  if (favListe.isEmpty) return Center(child: Text('Henüz favori vecize eklemediniz.', style: TextStyle(color: tema.yazi)));
  return ListView.separated(
    padding: const EdgeInsets.all(14),
    itemCount: favListe.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (ctx, i) {
      final v = favListe[i];
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: tema.kart, borderRadius: BorderRadius.circular(18), border: Border.all(color: tema.vurgu, width: 1.2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('“${v.metin}”', style: TextStyle(fontSize: 17, height: 1.5, fontWeight: FontWeight.w600, fontFamily: 'serif', color: tema.yazi)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Text('— ${v.kaynak}', style: TextStyle(color: tema.koyuMu ? tema.vurgu : tema.ana, fontWeight: FontWeight.bold, fontFamily: 'serif'))),
                IconButton(
                  icon: Icon(Icons.copy, size: 20, color: tema.yazi),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '“${v.metin}”\n— ${v.kaynak}'));
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Kopyalandı.')));
                  },
                ),
                IconButton(icon: Icon(Icons.share, size: 20, color: tema.yazi), onPressed: () => Share.share('“${v.metin}”\n— ${v.kaynak}')),
                IconButton(icon: const Icon(Icons.favorite, color: Colors.red, size: 22), onPressed: () => onFavoriSil(v.metin)),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget zamanSayfasi({
  required List<String> saatler,
  required bool periyodikAktif,
  required int periyodikDk,
  required UygulamaTemasi tema,
  required VoidCallback onSaatEkle,
  required Future<void> Function(String) onSaatSil,
  required Future<void> Function(bool) onPeriyodikDegistir,
  required Future<void> Function(int) onDakikaSec,
  required VoidCallback onTestBildirim,
}) {
  const secenekler = [15, 30, 45, 60, 120, 180];
  return ListView(
    padding: const EdgeInsets.all(14),
    children: [
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
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: tema.ana),
                  onPressed: onSaatEkle,
                  icon: const Icon(Icons.more_time, size: 18),
                  label: const Text('Saat Ekle'),
                ),
              ],
            ),
            if (saatler.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: saatler.map((s) => InputChip(label: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)), onDeleted: () => onSaatSil(s))).toList(),
              ),
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
                return ChoiceChip(
                  label: Text('$dk dk'),
                  selected: s,
                  selectedColor: tema.ana,
                  backgroundColor: tema.zemin,
                  labelStyle: TextStyle(color: s ? Colors.white : tema.yazi, fontWeight: FontWeight.w600),
                  onSelected: (_) => onDakikaSec(dk),
                );
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
// --- EKRANLAR DOSYASI BİTTİ ---
