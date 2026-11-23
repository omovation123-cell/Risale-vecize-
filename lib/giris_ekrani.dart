import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tam ekran, gerçekçi kalem yazısı animasyonlu açılış ekranı
class GirisEkrani extends StatefulWidget {
  final Widget sonrakiSayfa;

  const GirisEkrani({
    super.key,
    required this.sonrakiSayfa,
  });

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _gecisYapildi = false;

  @override
  void initState() {
    super.initState();
    // Tam ekran modu (üst durum çubuğu ve alt navigasyon tuşları gizlenir)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 450), _anaSayfayaGec);
      }
    });

    _controller.forward();
  }

  void _anaSayfayaGec() {
    if (_gecisYapildi || !mounted) return;
    _gecisYapildi = true;

    // Normal ekran çubuklarını geri yükle
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, __, ___) => widget.sonrakiSayfa,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2417),
      body: GestureDetector(
        onTap: _anaSayfayaGec,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _NurdanVecizelerKalemPainter(progress: _controller.value),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _NurdanVecizelerKalemPainter extends CustomPainter {
  final double progress;

  _NurdanVecizelerKalemPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Derin zümrüt - kadife kitap cildi arka planı
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.1),
        radius: 1.05,
        colors: [
          Color(0xFF174A31),
          Color(0xFF0D2E1E),
          Color(0xFF06170F),
        ],
        stops: [0.0, 0.58, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // İnce kağıt/cilt dokusu çizgileri
    final dokuPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.025)
      ..strokeWidth = 0.8;
    for (double y = 0; y < size.height; y += 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), dokuPaint);
    }

    // 2. Klasik Tezhip Altın Çerçeve
    _tezhipCerceveCiz(canvas, size);

    // 3. Üst Besmele (yumuşak belirme)
    final besmeleOpaklik = (progress / 0.22).clamp(0.0, 1.0);
    final besmelePainter = TextPainter(
      text: TextSpan(
        text: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيمِ',
        style: TextStyle(
          fontFamily: 'MushafFont',
          fontSize: 22,
          color: const Color(0xFFE6C875).withOpacity(0.85 * besmeleOpaklik),
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout(maxWidth: size.width - 64);

    besmelePainter.paint(
      canvas,
      Offset(
        (size.width - besmelePainter.width) / 2,
        size.height * 0.24,
      ),
    );

    // 4. "Nurdan" ve "Vecizeler" metin ölçümleri
    final yaziStili = TextStyle(
      fontFamily: 'HatBaslik',
      fontSize: size.width < 360 ? 38 : 44,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      letterSpacing: 1.4,
      foreground: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF3C4),
            Color(0xFFE5C158),
            Color(0xFFB88924),
          ],
        ).createShader(Rect.fromLTWH(0, size.height * 0.36, size.width, 150)),
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.55),
          offset: const Offset(0, 3),
          blurRadius: 6,
        ),
      ],
    );

    final nurdanPainter = TextPainter(
      text: TextSpan(text: 'Nurdan', style: yaziStili),
      textDirection: TextDirection.ltr,
    )..layout();

    final vecizelerPainter = TextPainter(
      text: TextSpan(text: 'Vecizeler', style: yaziStili),
      textDirection: TextDirection.ltr,
    )..layout();

    final nurdanX = (size.width - nurdanPainter.width) / 2;
    final nurdanY = size.height * 0.40;

    final vecizelerX = (size.width - vecizelerPainter.width) / 2;
    final vecizelerY = nurdanY + nurdanPainter.height + 10;

    // Zamanlama evreleri:
    // 0.10 - 0.48 : "Nurdan" yazılır
    // 0.48 - 0.56 : Kalem kalkar ve alt satıra geçer
    // 0.56 - 0.90 : "Vecizeler" yazılır
    // 0.90 - 1.00 : Kalem çekilir, alt süs çizgisi tamamlanır
    final pNurdan = ((progress - 0.10) / 0.38).clamp(0.0, 1.0);
    final pGecis = ((progress - 0.48) / 0.08).clamp(0.0, 1.0);
    final pVecizeler = ((progress - 0.56) / 0.34).clamp(0.0, 1.0);
    final pBitis = ((progress - 0.90) / 0.10).clamp(0.0, 1.0);

    // "Nurdan" yazısını kalemin geçtiği yere kadar göster
    if (pNurdan > 0) {
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(
          nurdanX - 10,
          nurdanY - 12,
          (nurdanPainter.width + 20) * pNurdan,
          nurdanPainter.height + 24,
        ),
      );
      nurdanPainter.paint(canvas, Offset(nurdanX, nurdanY));
      canvas.restore();
    }

    // "Vecizeler" yazısını kalemin geçtiği yere kadar göster
    if (pVecizeler > 0) {
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(
          vecizelerX - 10,
          vecizelerY - 12,
          (vecizelerPainter.width + 20) * pVecizeler,
          vecizelerPainter.height + 24,
        ),
      );
      vecizelerPainter.paint(canvas, Offset(vecizelerX, vecizelerY));
      canvas.restore();
    }

    // Alt ornamental altın cetvel çizgisi
    if (pBitis > 0) {
      final cizgiY = vecizelerY + vecizelerPainter.height + 22;
      final yarimGenislik = (size.width * 0.28) * pBitis;
      final merkezX = size.width / 2;
      final cetvelPaint = Paint()
        ..color = const Color(0xFFD4AF37).withOpacity(0.8 * pBitis)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(merkezX - yarimGenislik, cizgiY),
        Offset(merkezX + yarimGenislik, cizgiY),
        cetvelPaint,
      );

      final baklava = Path()
        ..moveTo(merkezX, cizgiY - 4.5)
        ..lineTo(merkezX + 4.5, cizgiY)
        ..lineTo(merkezX, cizgiY + 4.5)
        ..lineTo(merkezX - 4.5, cizgiY)
        ..close();
      canvas.drawPath(
        baklava,
        Paint()..color = const Color(0xFFFFE599).withOpacity(pBitis),
      );
    }

    // 5. Kalem Ucu Konumu ve Gerçekçi Yazım Hareketi
    if (progress >= 0.06 && pBitis < 1.0) {
      late Offset kalemUcu;
      double kaldirma = 0.0;
      double egim = -0.58;
      double kalemOpaklik = 1.0;

      if (progress < 0.10) {
        final inis = ((progress - 0.06) / 0.04).clamp(0.0, 1.0);
        kalemOpaklik = inis;
        kaldirma = (1.0 - inis) * 22.0;
        kalemUcu = Offset(nurdanX, nurdanY + nurdanPainter.height * 0.62);
      } else if (progress <= 0.48) {
        final dalga = math.sin(pNurdan * math.pi * 13);
        kalemUcu = Offset(
          nurdanX + nurdanPainter.width * pNurdan,
          nurdanY + nurdanPainter.height * 0.60 + dalga * 7.5,
        );
        egim = -0.58 + math.cos(pNurdan * math.pi * 13) * 0.07;
      } else if (progress < 0.56) {
        final bas = Offset(
          nurdanX + nurdanPainter.width,
          nurdanY + nurdanPainter.height * 0.60,
        );
        final son = Offset(
          vecizelerX,
          vecizelerY + vecizelerPainter.height * 0.60,
        );
        final yumusak = Curves.easeInOut.transform(pGecis);
        kalemUcu = Offset.lerp(bas, son, yumusak)!;
        kaldirma = math.sin(pGecis * math.pi) * 20.0;
        egim = -0.52;
      } else if (progress <= 0.90) {
        final dalga = math.sin(pVecizeler * math.pi * 19);
        kalemUcu = Offset(
          vecizelerX + vecizelerPainter.width * pVecizeler,
          vecizelerY + vecizelerPainter.height * 0.60 + dalga * 7.5,
        );
        egim = -0.58 + math.cos(pVecizeler * math.pi * 19) * 0.07;
      } else {
        kalemOpaklik = (1.0 - pBitis).clamp(0.0, 1.0);
        kaldirma = pBitis * 28.0;
        kalemUcu = Offset(
          vecizelerX + vecizelerPainter.width + pBitis * 16,
          vecizelerY + vecizelerPainter.height * 0.60 - pBitis * 18,
        );
      }

      if (kaldirma < 3.0 && kalemOpaklik > 0.3) {
        final pariltiPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFF6CC).withOpacity(0.85 * kalemOpaklik),
              const Color(0xFFD4AF37).withOpacity(0.25 * kalemOpaklik),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: kalemUcu, radius: 14));
        canvas.drawCircle(kalemUcu, 14, pariltiPaint);
      }

      _gercekciKalemCiz(
        canvas: canvas,
        ucNoktasi: kalemUcu,
        kaldirma: kaldirma,
        egim: egim,
        opaklik: kalemOpaklik,
      );
    }

    // Alt küçük külliyat imzası
    final altOpaklik = ((progress - 0.35) / 0.35).clamp(0.0, 1.0);
    final altPainter = TextPainter(
      text: TextSpan(
        text: 'RİSALE-İ NUR KÜLLİYATI',
        style: TextStyle(
          fontFamily: 'KitapSerif',
          fontSize: 11.5,
          letterSpacing: 3.2,
          color: const Color(0xFFD4AF37).withOpacity(0.65 * altOpaklik),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    altPainter.paint(
      canvas,
      Offset((size.width - altPainter.width) / 2, size.height * 0.84),
    );
  }

  void _tezhipCerceveCiz(Canvas canvas, Size size) {
    const disBosluk = 18.0;
    const icBosluk = 24.0;

    final disRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        disBosluk,
        disBosluk,
        size.width - disBosluk * 2,
        size.height - disBosluk * 2,
      ),
      const Radius.circular(18),
    );
    final icRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        icBosluk,
        icBosluk,
        size.width - icBosluk * 2,
        size.height - icBosluk * 2,
      ),
      const Radius.circular(14),
    );

    canvas.drawRRect(
      disRRect,
      Paint()
        ..color = const Color(0xFFD4AF37).withOpacity(0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawRRect(
      icRRect,
      Paint()
        ..color = const Color(0xFFD4AF37).withOpacity(0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _gercekciKalemCiz({
    required Canvas canvas,
    required Offset ucNoktasi,
    required double kaldirma,
    required double egim,
    required double opaklik,
  }) {
    canvas.save();
    canvas.translate(
      ucNoktasi.dx + 6 + kaldirma * 0.7,
      ucNoktasi.dy + 8 + kaldirma * 0.8,
    );
    canvas.rotate(egim);
    final golgePaint = Paint()
      ..color = Colors.black
          .withOpacity((0.42 - kaldirma * 0.01).clamp(0.1, 0.42) * opaklik)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 + kaldirma * 0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-4, -145, 9, 145),
        const Radius.circular(4),
      ),
      golgePaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(ucNoktasi.dx, ucNoktasi.dy - kaldirma);
    canvas.rotate(egim);

    final ucPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-7.5, -24)
      ..lineTo(-5.0, -34)
      ..lineTo(5.0, -34)
      ..lineTo(7.5, -24)
      ..close();

    final ucPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFFB58522).withOpacity(opaklik),
          const Color(0xFFFFF0B8).withOpacity(opaklik),
          const Color(0xFFD4AF37).withOpacity(opaklik),
        ],
      ).createShader(const Rect.fromLTWH(-8, -34, 16, 34));
    canvas.drawPath(ucPath, ucPaint);

    canvas.drawLine(
      const Offset(0, -1),
      const Offset(0, -18),
      Paint()
        ..color = const Color(0xFF3A2506).withOpacity(0.85 * opaklik)
        ..strokeWidth = 0.9,
    );
    canvas.drawCircle(
      const Offset(0, -18),
      1.6,
      Paint()..color = const Color(0xFF3A2506).withOpacity(0.9 * opaklik),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6.2, -39, 12.4, 5),
        const Radius.circular(1.5),
      ),
      Paint()..color = const Color(0xFFE8C564).withOpacity(opaklik),
    );

    final govdePath = Path()
      ..moveTo(-5.8, -39)
      ..lineTo(-7.2, -115)
      ..lineTo(-4.8, -168)
      ..lineTo(4.8, -168)
      ..lineTo(7.2, -115)
      ..lineTo(5.8, -39)
      ..close();

    final govdePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF1F1209).withOpacity(opaklik),
          const Color(0xFF5C381C).withOpacity(opaklik),
          const Color(0xFF2B180B).withOpacity(opaklik),
        ],
      ).createShader(const Rect.fromLTWH(-8, -168, 16, 130));
    canvas.drawPath(govdePath, govdePaint);

    canvas.drawRect(
      const Rect.fromLTWH(-6.7, -116, 13.4, 3.2),
      Paint()..color = const Color(0xFFD4AF37).withOpacity(opaklik),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NurdanVecizelerKalemPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Ana sayfa üstünde vakit selamlaması ve sıradaki bildirim şeridi
class VakitKarsilamaSeridi extends StatelessWidget {
  final String? siradakiBildirimSaati;
  final Color vurguRengi;
  final bool koyuTema;

  const VakitKarsilamaSeridi({
    super.key,
    required this.siradakiBildirimSaati,
    this.vurguRengi = const Color(0xFF14532D),
    this.koyuTema = false,
  });

  String _vakitSelami() {
    final saat = DateTime.now().hour;
    if (saat >= 5 && saat < 11) return 'Hayırlı Sabahlar';
    if (saat >= 11 && saat < 16) return 'Hayırlı Günler';
    if (saat >= 16 && saat < 19) return 'Hayırlı İkindiler';
    if (saat >= 19 && saat < 23) return 'Hayırlı Akşamlar';
    return 'Hayırlı Geceler';
  }

  String _turkceTarih() {
    const aylar = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    final simdi = DateTime.now();
    return '${simdi.day} ${aylar[simdi.month]} ${simdi.year}';
  }

  @override
  Widget build(BuildContext context) {
    final yaziRengi =
        koyuTema ? const Color(0xFFF3EFE6) : const Color(0xFF1F2937);
    final altYaziRengi =
        koyuTema ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563);
    final kartRengi = koyuTema
        ? Colors.white.withOpacity(0.06)
        : vurguRengi.withOpacity(0.07);
    final cerceveRengi = koyuTema
        ? const Color(0xFFD4AF37).withOpacity(0.35)
        : vurguRengi.withOpacity(0.22);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: kartRengi,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cerceveRengi, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _vakitSelami(),
                  style: TextStyle(
                    fontFamily: 'HatBaslik',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: yaziRengi,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _turkceTarih(),
                  style: TextStyle(
                    fontFamily: 'KitapSerif',
                    fontSize: 12,
                    color: altYaziRengi,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: vurguRengi.withOpacity(koyuTema ? 0.35 : 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: vurguRengi.withOpacity(0.35),
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  size: 15,
                  color: koyuTema ? const Color(0xFFE6C875) : vurguRengi,
                ),
                const SizedBox(width: 5),
                Text(
                  siradakiBildirimSaati != null &&
                          siradakiBildirimSaati!.isNotEmpty
                      ? 'Sıradaki: $siradakiBildirimSaati'
                      : 'Bildirim Hazır',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: koyuTema ? const Color(0xFFF5E6B8) : vurguRengi,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// --- GİRİŞ EKRANI DOSYASI BİTTİ ---

