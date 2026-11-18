class Vecize {
  final String metin;
  final String kaynak;
  final String eser;

  const Vecize({required this.metin, required this.kaynak, required this.eser});

  Map<String, dynamic> toMap() => {'metin': metin, 'kaynak': kaynak, 'eser': eser};

  factory Vecize.fromMap(Map<String, dynamic> map) => Vecize(
        metin: map['metin'] ?? '',
        kaynak: map['kaynak'] ?? '',
        eser: map['eser'] ?? 'Diğer',
      );
}

const List<String> eserListesi = [
  'Tümü',
  'Sözler',
  'Mektubat',
  'Lem’alar',
  'Şualar',
  'Mesnevî-i Nuriye',
  'Barla Lâhikası',
  'Kastamonu Lâhikası',
  'Emirdağ Lâhikası',
  'Diğer',
];

const List<Vecize> varsayilanVecizeler = [
  Vecize(
    metin: 'Bismillah her hayrın başıdır. Biz dahi başta ona başlarız.',
    kaynak: 'Sözler, Birinci Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Hakikî ve elemsiz lezzet yalnız imanda ve iman ile olabilir.',
    kaynak: 'Sözler, İkinci Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Meşru daire keyfe kâfidir; harama girmeye hiç lüzum yoktur.',
    kaynak: 'Sözler, Altıncı Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Ey nefis! Bil ki, dünkü gün senin elinden çıktı; yarın ise senin elinde senet yok ki ona mâliksin. Öyle ise hakikî ömrünü bulunduğun gün bil.',
    kaynak: 'Sözler, Yirmi Birinci Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Ey nefsim! Deme: "Zaman değişmiş, asır başkalaşmış, herkes dünyaya dalmış, hayata perestiş ediyor, derd-i maişetle sarhoştur." Çünkü ölüm değişmiyor.',
    kaynak: 'Sözler, Yirmi Birinci Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Namaz, ruhun ve kalbin ve aklın en büyük bir rahatıdır; hem cisme de o kadar ağır bir iş değildir.',
    kaynak: 'Sözler, Yirmi Birinci Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'İman hem nurdur, hem kuvvettir. Evet, hakikî imanı elde eden adam kâinata meydan okuyabilir ve imanın kuvvetine göre hâdisâtın tazyikatından kurtulabilir.',
    kaynak: 'Sözler, Yirmi Üçüncü Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'İman insanı insan eder; belki insanı sultan eder. Öyle ise insanın vazife-i asliyesi, iman ve duadır.',
    kaynak: 'Sözler, Yirmi Üçüncü Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Küfür insanı gayet âciz bir canavar hayvan eder.',
    kaynak: 'Sözler, Yirmi Üçüncü Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Evet, insan nur-u iman ile âlâ-yı illiyyîne çıkar, Cennete lâyık bir kıymet alır.',
    kaynak: 'Sözler, Yirmi Üçüncü Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Zulmet-i küfür ile esfel-i sâfilîne düşer, Cehenneme ehil olacak bir vaziyete girer.',
    kaynak: 'Sözler, Yirmi Üçüncü Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'İnsanın bu dünyaya gönderilmesinin hikmeti ve gayesi, Hâlık-ı Kâinatı tanımak ve Ona iman edip ibadet etmektir.',
    kaynak: 'Sözler, Yirmi Üçüncü Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Dünya bir misafirhanedir. İnsan ise onda az duracaktır ve vazifesi çok bir misafirdir.',
    kaynak: 'Sözler, Yirmi Üçüncü Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Kur’ân, şu kitab-ı kebîr-i kâinatın bir tercüme-i ezeliyesidir.',
    kaynak: 'Sözler, Yirmi Beşinci Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Kadere iman eden kederden emin olur.',
    kaynak: 'Sözler, Yirmi Altıncı Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Ey insan! Senin elinde gayet zayıf, fakat seyyiatta ve tahribatta eli gayet uzun ve hasenatta eli gayet kısa cüz’-i ihtiyarî namında bir iraden var.',
    kaynak: 'Sözler, Yirmi Altıncı Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Haksızlığı hak iddia edenlere karşı hak dâvâ etmek ve onlara müracaat etmek bir haksızlıktır, hakka karşı bir hürmetsizliktir.',
    kaynak: 'Mektubat, On Altıncı Mektup',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Elhasıl: Dünya, madem fânidir; değmiyor alâka-i kalbe.',
    kaynak: 'Mektubat, On Yedinci Mektup',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Muhabbet, uhuvvet, sevmek İslâmiyetin mizacıdır, rabıtasıdır.',
    kaynak: 'Mektubat, Yirmi İkinci Mektup',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Adâvet etmek istersen, kalbindeki adâvete adâvet et; onun ref’ine çalış.',
    kaynak: 'Mektubat, Yirmi İkinci Mektup',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Mü’min kardeşini sever ve sevmeli; fakat fenalığı için yalnız acır.',
    kaynak: 'Mektubat, Yirmi İkinci Mektup',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Bâki hakikatler fâni şahsiyetler üzerine bina edilmez.',
    kaynak: 'Mektubat, Yirmi Dokuzuncu Mektup',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Kardeş kardeşe peder olamaz, mürşid vaziyetini takınamaz.',
    kaynak: 'Mektubat, Yirmi Dokuzuncu Mektup',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Güzel gören güzel düşünür. Güzel düşünen hayatından lezzet alır.',
    kaynak: 'Mektubat, Hakikat Çekirdekleri',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'En büyük hile, hilesizliktir.',
    kaynak: 'Mektubat, Hakikat Çekirdekleri',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Hayat bir faaliyet ve harekettir; şevk ise matiyyesidir.',
    kaynak: 'Mektubat, Hakikat Çekirdekleri',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Ümitvar olunuz; şu istikbal inkılâbı içinde en yüksek gür sadâ İslâmın sadâsı olacaktır!',
    kaynak: 'Mektubat, Hakikat Çekirdekleri',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Sünnet-i Seniyyeye ittibâ etmeyen, tembellik ederse, hasâret-i azîme; ehemmiyetsiz görürse, cinayet-i azîme; tekzibini işmam eden tenkit ise, dalâlet-i azîmedir.',
    kaynak: 'Lem’alar, On Birinci Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'Gençlik gidecek. Sefahatte gitmiş ise hem dünyada, hem kabirde, hem âhirette binler belâ ve elemler netice verdiğini ve vereceğini, binler vukuatla ve tecrübelerle ve şahitlerle sabittir.',
    kaynak: 'Lem’alar, On Üçüncü Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'Nefis, cümleden ednâ; vazife, cümleden âlâ.',
    kaynak: 'Lem’alar, On Yedinci Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'İktisat hem bir şükr-ü mânevî, hem nimetlerdeki rahmet-i İlâhiyeye karşı bir hürmet, hem kat’î bir surette sebeb-i berekettir.',
    kaynak: 'Lem’alar, On Dokuzuncu Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'İsraf ise, şükre zıt olduğu için nimetteki berekete mânidir.',
    kaynak: 'Lem’alar, On Dokuzuncu Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'Amelinizde rıza-yı İlâhî olmalı. Eğer O razı olsa, bütün dünya küsse ehemmiyeti yok.',
    kaynak: 'Lem’alar, Yirmi Birinci Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'Kardeşlerinizin meziyetlerini şahıslarınızda ve faziletlerini kendinizde tasavvur edip, onların şerefleriyle şâkirâne iftihar etmektir.',
    kaynak: 'Lem’alar, Yirmi Birinci Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'Fenâ bir adama "İyisin, iyisin" desen iyileşmesi ve iyi adama "Fenasın, fenasın" desen fenalaşması çok vuku bulur.',
    kaynak: 'Lem’alar, Yirmi İkinci Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'Ey hasta kardeş! Merak etme, sabret. Senin hastalığın sana dert değil, belki bir nevi dermandır.',
    kaynak: 'Lem’alar, Yirmi Beşinci Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'Madem O var, her şey var. Madem O yok, hiçbir şey yoktur.',
    kaynak: 'Şualar, Dördüncü Şua',
    eser: 'Şualar',
  ),
  Vecize(
    metin: 'Evet, insan, ebed için halk olunmuş ve ebede gidecektir. Bu dünya ise onun için bir misafirhanedir ve âhiretine bir intizar salonudur.',
    kaynak: 'Şualar, On Birinci Şua',
    eser: 'Şualar',
  ),
  Vecize(
    metin: 'Ecel gizlidir. Her vakit ölüm, başını kesmek için gelebiliyor. Genç, ihtiyar farkı yoktur.',
    kaynak: 'Şualar, On Birinci Şua',
    eser: 'Şualar',
  ),
  Vecize(
    metin: 'Hâlıkımız kim ise, bizi en ziyade O bilir. Madem O bilir, elbette en ziyade O merhamet eder.',
    kaynak: 'Şualar, On Birinci Şua',
    eser: 'Şualar',
  ),
  Vecize(
    metin: 'Lâ ilâhe illâllah kelâm-ı kudsîsi, kalbin bütün yaralarına merhem olduğu gibi, aklın da bütün ukdelerini halleder.',
    kaynak: 'Mesnevî-i Nuriye, Katre',
    eser: 'Mesnevî-i Nuriye',
  ),
  Vecize(
    metin: 'Bütün eşyada, hususan zîhayatta, gayet hikmetli bir intizam ve gayet mizanlı bir san’at görünüyor.',
    kaynak: 'Mesnevî-i Nuriye, Katre',
    eser: 'Mesnevî-i Nuriye',
  ),
  Vecize(
    metin: 'İnsan, küçük bir âlemdir; âlem ise büyük bir insandır.',
    kaynak: 'Mesnevî-i Nuriye, Nokta',
    eser: 'Mesnevî-i Nuriye',
  ),
  Vecize(
    metin: 'Sıkıntı ve meşakkat ise, hizmetimizin kıymetini ve sevabını ziyadeleştirir.',
    kaynak: 'Barla Lâhikası',
    eser: 'Barla Lâhikası',
  ),
  Vecize(
    metin: 'Bizim vazifemiz hizmettir; neticeye karışmayız. Çünki netice Cenâb-ı Hakka aittir.',
    kaynak: 'Kastamonu Lâhikası',
    eser: 'Kastamonu Lâhikası',
  ),
  Vecize(
    metin: 'Risale-i Nur şakirtlerinin hasları olan hakikî kardeşlerimin en mühim bir hasletleri, birbirine karşı tesanüd ve birbirinin kusuruna bakmamaktır.',
    kaynak: 'Kastamonu Lâhikası',
    eser: 'Kastamonu Lâhikası',
  ),
  Vecize(
    metin: 'Bizim vazifemiz, yalnız iman kurtarmaktır.',
    kaynak: 'Emirdağ Lâhikası',
    eser: 'Emirdağ Lâhikası',
  ),
  Vecize(
    metin: 'Evet, her musibette iki cihet var: Biri rahmet ve hikmet ciheti, diğeri zahirî elem cihetidir.',
    kaynak: 'Emirdağ Lâhikası',
    eser: 'Emirdağ Lâhikası',
  ),
  Vecize(
    metin: 'Cenâb-ı Hakkın rızası ihlâs ile kazanılır; kesret-i etbâ ile ve fazla muvaffakiyet ile değildir.',
    kaynak: 'Kastamonu Lâhikası',
    eser: 'Kastamonu Lâhikası',
  ),
];
// --- VECİZELER DOSYASI BİTTİ ---
