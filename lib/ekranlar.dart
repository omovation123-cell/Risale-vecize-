import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'vecizeler.dart';

Widget favorilerSayfasi({
  required List<Vecize> tumVecizeler,
  required List<String> favoriler,
  required Future<void> Function(String metin) onFavoriSil,
}) {
  final liste = tumVecizeler.where((v) => favoriler.contains(v.metin)).toList();
  if (liste.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Color(0xFFD97706)),
            SizedBox(height: 16),
            Text('Henüz favori vecizeniz yok.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Kalp simgesine dokunarak beğendiğiniz sözleri buraya kaydedebilirsiniz.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
  return ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: liste.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (ctx, i) {
      final v = liste[i];
      return Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('“${v.metin}”', style: const TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text(v.kaynak, style: const TextStyle(color: Color(0xFF14532D), fontWeight: FontWeight.bold, fontSize: 12))),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: '“${v.metin}”\n— ${v.kaynak}'));
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Kopyalandı.')));
                    },
                  ),
                  IconButton(icon: const Icon(Icons.share, size: 20, color: Color(0xFFD97706)), onPressed: () => Share.share('“${v.metin}”\n— ${v.kaynak}')),
                  IconButton(icon: const Icon(Icons.favorite, size: 20, color: Colors.red), onPressed: () => onFavoriSil(v.metin)),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget zamanSayfasi({
  required List<String> saatler,
  required bool periyodikAktif,
  required int periyodikDk,
  required VoidCallback onSaatEkle,
  required Future<void> Function(String s) onSaatSil,
  required Future<void> Function(bool val) onPeriyodikDegistir,
  required Future<void> Function(int dk) onDakikaSec,
  required VoidCallback onTestBildirim,
}) {
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
                  FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF14532D)), onPressed: onSaatEkle, icon: const Icon(Icons.add_alarm, size: 18), label: const Text('Saat Ekle')),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: saatler.map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), onDeleted: () => onSaatSil(s))).toList(),
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
                subtitle: Text(periyodikAktif ? 'Her $periyodikDk dakikada bir aktif' : 'Kapalı'),
                value: periyodikAktif,
                activeColor: const Color(0xFF14532D),
                onChanged: onPeriyodikDegistir,
              ),
              if (periyodikAktif)
                Wrap(
                  spacing: 8,
                  children: [15, 30, 45, 60, 120, 180].map((dk) => ChoiceChip(
                    label: Text('$dk dk'),
                    selected: periyodikDk == dk,
                    selectedColor: const Color(0xFF14532D),
                    labelStyle: TextStyle(color: periyodikDk == dk ? Colors.white : Colors.black87),
                    onSelected: (_) => onDakikaSec(dk),
                  )).toList(),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: onTestBildirim, icon: const Icon(Icons.notifications_active), label: const Text('Şimdi Test Bildirimi Gönder')),
    ],
  );
}

void vecizeEkleGoster({
  required BuildContext context,
  required List<Vecize> tumVecizeler,
  required Future<void> Function(List<Vecize> yeniler) onEkle,
}) {
  final metinCtrl = TextEditingController(), kaynakCtrl = TextEditingController(), topluCtrl = TextEditingController();
  String seciliEser = 'Sözler';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFDFBF7),
    builder: (ctx) => DefaultTabController(
      length: 2,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              const TabBar(labelColor: Color(0xFF14532D), indicatorColor: Color(0xFF14532D), tabs: [Tab(text: 'Tekli Ekle'), Tab(text: 'Toplu Yapıştır')]),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    StatefulBuilder(
                      builder: (_, setModalState) => ListView(
                        children: [
                          DropdownButtonFormField<String>(
                            value: seciliEser,
                            decoration: const InputDecoration(labelText: 'Eser', border: OutlineInputBorder()),
                            items: eserListesi.where((e) => e != 'Tümü').map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (v) { if (v != null) setModalState(() => seciliEser = v); },
                          ),
                          const SizedBox(height: 10),
                          TextField(controller: kaynakCtrl, decoration: const InputDecoration(labelText: 'Kaynak (Örn: Kastamonu Lâhikası)', border: OutlineInputBorder())),
                          const SizedBox(height: 10),
                          TextField(controller: metinCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Vecize Metni', border: OutlineInputBorder())),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF14532D), padding: const EdgeInsets.symmetric(vertical: 14)),
                            onPressed: () async {
                              final m = metinCtrl.text.trim();
                              if (m.isEmpty) return;
                              final k = kaynakCtrl.text.trim().isEmpty ? seciliEser : kaynakCtrl.text.trim();
                              await onEkle([Vecize(m, k, seciliEser)]);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Kaydet'),
                          ),
                        ],
                      ),
                    ),
                    ListView(
                      children: [
                        const Text('Her satıra bir vecize yapıştırın. İsterseniz sonuna | Kaynak | Eser yazın:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 8),
                        TextField(controller: topluCtrl, maxLines: 7, decoration: const InputDecoration(hintText: 'Vecize metni | Barla Lâhikası | Barla Lâhikası', border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF14532D), padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: () async {
                            final yeniler = <Vecize>[];
                            for (final s in topluCtrl.text.split('\n')) {
                              final temiz = s.trim();
                              if (temiz.isEmpty) continue;
                              final p = temiz.split('|');
                              final m = p[0].trim();
                              if (m.isEmpty || tumVecizeler.any((v) => v.metin == m)) continue;
                              final k = p.length >= 2 && p[1].trim().isNotEmpty ? p[1].trim() : 'Risale-i Nur';
                              final e = p.length >= 3 && eserListesi.contains(p[2].trim()) && p[2].trim() != 'Tümü' ? p[2].trim() : 'Sözler';
                              yeniler.add(Vecize(m, k, e));
                            }
                            if (yeniler.isNotEmpty) await onEkle(yeniler);
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.playlist_add),
                          label: const Text('Tümünü Arşive Ekle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
// --- EKRANLAR BİTTİ ---
