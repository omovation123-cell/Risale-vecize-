class Vecize {
  final String metin;
  final String kaynak;
  final String eser;
  final String arapca;

  const Vecize({
    required this.metin,
    required this.kaynak,
    required this.eser,
    this.arapca = '',
  });

  Map<String, dynamic> toMap() => {
        'metin': metin,
        'kaynak': kaynak,
        'eser': eser,
        'arapca': arapca,
      };

  factory Vecize.fromMap(Map<String, dynamic> map) => Vecize(
        metin: map['metin'] ?? '',
        kaynak: map['kaynak'] ?? '',
        eser: map['eser'] ?? 'Diğer',
        arapca: map['arapca'] ?? '',
      );
}

const List<String> eserListesi = [
  'Tümü',
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
  'Kur’an-ı Kerim',
  'Hadis-i Şerif',
  'Diğer',
];

const List<Vecize> varsayilanVecizeler = [
  // 1. SÖZLER (4)
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
    metin: 'İman hem nurdur, hem kuvvettir. Evet, hakikî imanı elde eden adam kâinata meydan okuyabilir ve imanın kuvvetine göre hâdisâtın tazyikatından kurtulabilir.',
    kaynak: 'Sözler, Yirmi Üçüncü Söz',
    eser: 'Sözler',
  ),
  Vecize(
    metin: 'Kadere iman eden kederden emin olur.',
    kaynak: 'Sözler, Yirmi Altıncı Söz',
    eser: 'Sözler',
  ),

  // 2. MEKTUBAT (4)
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
    metin: 'Bâki hakikatler fâni şahsiyetler üzerine bina edilmez.',
    kaynak: 'Mektubat, Yirmi Dokuzuncu Mektup',
    eser: 'Mektubat',
  ),
  Vecize(
    metin: 'Güzel gören güzel düşünür. Güzel düşünen hayatından lezzet alır.',
    kaynak: 'Mektubat, Hakikat Çekirdekleri',
    eser: 'Mektubat',
  ),

  // 3. LEM'ALAR (4)
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
    metin: 'Amelinizde rıza-yı İlâhî olmalı. Eğer O razı olsa, bütün dünya küsse ehemmiyeti yok.',
    kaynak: 'Lem’alar, Yirmi Birinci Lem’a',
    eser: 'Lem’alar',
  ),
  Vecize(
    metin: 'Ey hasta kardeş! Merak etme, sabret. Senin hastalığın sana dert değil, belki bir nevi dermandır.',
    kaynak: 'Lem’alar, Yirmi Beşinci Lem’a',
    eser: 'Lem’alar',
  ),

  // 4. ŞUALAR (4)
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

  // 5. İŞÂRÂTÜ'L-İ'CÂZ (4)
  Vecize(
    metin: 'İbadet, fikri sâir şeylerden çevirip yalnız Hâlıka hasretmekten ibarettir.',
    kaynak: 'İşârâtü’l-İ’câz, Bakara Sûresi 3. Âyet Tefsiri',
    eser: 'İşârâtü’l-İ’câz',
  ),
  Vecize(
    metin: 'İman, insanın fıtratında derc edilmiş bir nurdur ki, vicdanın içyüzünü ışıklandırıyor.',
    kaynak: 'İşârâtü’l-İ’câz, Bakara Sûresi 3. Âyet Tefsiri',
    eser: 'İşârâtü’l-İ’câz',
  ),
  Vecize(
    metin: 'Saadet-i ebediyenin medarı ve üssü’l-esası, ancak ve ancak imandır.',
    kaynak: 'İşârâtü’l-İ’câz, Bakara Sûresi 25. Âyet Tefsiri',
    eser: 'İşârâtü’l-İ’câz',
  ),
  Vecize(
    metin: 'Kur’ân-ı Kerîm’in en birinci maksadı, tevhid-i Bârîdir.',
    kaynak: 'İşârâtü’l-İ’câz, Fâtiha Sûresi Tefsiri',
    eser: 'İşârâtü’l-İ’câz',
  ),

  // 6. MESNEVÎ-İ NURİYE (4)
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
    metin: 'Ey insan! Sen bir yolcusun. Şu dünya ise büyük bir misafirhanedir.',
    kaynak: 'Mesnevî-i Nuriye, Habbe',
    eser: 'Mesnevî-i Nuriye',
  ),

  // 7. BARLA LÂHİKASI (4)
  Vecize(
    metin: 'Sıkıntı ve meşakkat ise, hizmetimizin kıymetini ve sevabını ziyadeleştirir.',
    kaynak: 'Barla Lâhikası',
    eser: 'Barla Lâhikası',
  ),
  Vecize(
    metin: 'Risale-i Nur’un hakikî şakirtleri, neşr-i envar-ı Kur’âniyeye kendilerini vakfetmişlerdir.',
    kaynak: 'Barla Lâhikası',
    eser: 'Barla Lâhikası',
  ),
  Vecize(
    metin: 'Kur’ân-ı Hakîmin hakikatleri güneş gibidir; üflemekle sönmez.',
    kaynak: 'Barla Lâhikası',
    eser: 'Barla Lâhikası',
  ),
  Vecize(
    metin: 'İhlâs ve hakikat yolunda çalışanlara inâyet-i İlâhiye her vakit yetişir.',
    kaynak: 'Barla Lâhikası',
    eser: 'Barla Lâhikası',
  ),

  // 8. KASTAMONU LÂHİKASI (4)
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
    metin: 'Cenâb-ı Hakkın rızası ihlâs ile kazanılır; kesret-i etbâ ile ve fazla muvaffakiyet ile değildir.',
    kaynak: 'Kastamonu Lâhikası',
    eser: 'Kastamonu Lâhikası',
  ),
  Vecize(
    metin: 'Bir adamın imanını kurtarmak, sahra dolusu kırmızı koyunlardan daha hayırlıdır.',
    kaynak: 'Kastamonu Lâhikası',
    eser: 'Kastamonu Lâhikası',
  ),

  // 9. EMİRDAĞ LÂHİKASI (4)
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
    metin: 'Risale-i Nur, Kur’ân’ın malıdır ve Kur’ân’dan süzülmüştür.',
    kaynak: 'Emirdağ Lâhikası',
    eser: 'Emirdağ Lâhikası',
  ),
  Vecize(
    metin: 'Hakikî teselli ve hakikî sürur, ancak iman ve Kur’ân dairesindedir.',
    kaynak: 'Emirdağ Lâhikası',
    eser: 'Emirdağ Lâhikası',
  ),

  // 10. TARİHÇE-İ HAYAT (4)
  Vecize(
    metin: 'Ben ekmeksiz yaşarım, hürriyetsiz yaşayamam.',
    kaynak: 'Tarihçe-i Hayat, İlk Hayatı',
    eser: 'Tarihçe-i Hayat',
  ),
  Vecize(
    metin: 'İman hem nurdur, hem kuvvettir. Hakikî imanı elde eden adam kâinata meydan okuyabilir.',
    kaynak: 'Tarihçe-i Hayat, Eski Said Dönemi',
    eser: 'Tarihçe-i Hayat',
  ),
  Vecize(
    metin: 'Kur’ân’ın sönmez ve söndürülmez mânevî bir güneş olduğunu ben dünyaya ispat edeceğim ve göstereceğim.',
    kaynak: 'Tarihçe-i Hayat, İlk Hayatı',
    eser: 'Tarihçe-i Hayat',
  ),
  Vecize(
    metin: 'Bütün ömrümde hak ve hakikatten başka hiçbir şeye baş eğmedim.',
    kaynak: 'Tarihçe-i Hayat',
    eser: 'Tarihçe-i Hayat',
  ),

  // 11. SİKKE-İ TASDİK-İ GAYBÎ (4)
  Vecize(
    metin: 'Risale-i Nur, bu asrın fehmine bir ders-i Kur’ânîdir.',
    kaynak: 'Sikke-i Tasdik-i Gaybî',
    eser: 'Sikke-i Tasdik-i Gaybî',
  ),
  Vecize(
    metin: 'İnâyet-i İlâhiye, hizmet-i Kur’âniyede çalışanları muhafaza eder ve muvaffak kılar.',
    kaynak: 'Sikke-i Tasdik-i Gaybî',
    eser: 'Sikke-i Tasdik-i Gaybî',
  ),
  Vecize(
    metin: 'Kur’ân’ın i’câz-ı mânevîsi, her asırda kendini göstermektedir.',
    kaynak: 'Sikke-i Tasdik-i Gaybî',
    eser: 'Sikke-i Tasdik-i Gaybî',
  ),
  Vecize(
    metin: 'Hizmet-i imaniye, en büyük ve en kudsî bir vazifedir.',
    kaynak: 'Sikke-i Tasdik-i Gaybî',
    eser: 'Sikke-i Tasdik-i Gaybî',
  ),

  // 12. ASÂ-YI MÛSÂ (4)
  Vecize(
    metin: 'Ey insan! Sen kendini kendi kendine mâlik sayma. Çünki sen kendini idare edemezsin, o yük ağırdır.',
    kaynak: 'Asâ-yı Mûsâ, Birinci Kısım, İkinci Hüccet-i İmâniye',
    eser: 'Asâ-yı Mûsâ',
  ),
  Vecize(
    metin: 'Her bir zîhayat, Sâni-i Zülcelâlin bir kaside-i san’atıdır.',
    kaynak: 'Asâ-yı Mûsâ, İkinci Kısım, Birinci Mesele',
    eser: 'Asâ-yı Mûsâ',
  ),
  Vecize(
    metin: 'Dünya hayatı fânidir; bâki bir hayat ise bizi bekliyor.',
    kaynak: 'Asâ-yı Mûsâ, Birinci Kısım, Birinci Mesele',
    eser: 'Asâ-yı Mûsâ',
  ),
  Vecize(
    metin: 'İman, insanı hayvanlıktan çıkarıp hakikî insanlık mertebesine yükseltir.',
    kaynak: 'Asâ-yı Mûsâ, Birinci Kısım, Dördüncü Mesele',
    eser: 'Asâ-yı Mûsâ',
  ),

  // 13. MUHÂKEMÂT (4)
  Vecize(
    metin: 'Güzel gören güzel düşünür. Güzel düşünen hayatından lezzet alır.',
    kaynak: 'Muhâkemât, Birinci Makale',
    eser: 'Muhâkemât',
  ),
  Vecize(
    metin: 'Hakikatin hatırı, her hatırdan âlîdir.',
    kaynak: 'Muhâkemât, Birinci Makale',
    eser: 'Muhâkemât',
  ),
  Vecize(
    metin: 'Zaman ihtiyarlandıkça Kur’ân gençleşiyor, rumuzu tavazzuh ediyor.',
    kaynak: 'Muhâkemât, Birinci Makale',
    eser: 'Muhâkemât',
  ),
  Vecize(
    metin: 'Delil ve burhan üzerine müesses olan İslâmiyet, akıl ve hikmete muvafıktır.',
    kaynak: 'Muhâkemât, Birinci Makale',
    eser: 'Muhâkemât',
  ),

  // 14. İMAN VE KÜFÜR MUVAZENELERİ (4)
  Vecize(
    metin: 'İman tevhidi, tevhid teslimi, teslim tevekkülü, tevekkül saadet-i dâreyni iktiza eder.',
    kaynak: 'İman ve Küfür Muvazeneleri',
    eser: 'İman ve Küfür Muvazeneleri',
  ),
  Vecize(
    metin: 'İman insanı insan eder; belki insanı sultan eder.',
    kaynak: 'İman ve Küfür Muvazeneleri',
    eser: 'İman ve Küfür Muvazeneleri',
  ),
  Vecize(
    metin: 'Küfür insanı gayet âciz bir canavar hayvan eder.',
    kaynak: 'İman ve Küfür Muvazeneleri',
    eser: 'İman ve Küfür Muvazeneleri',
  ),
  Vecize(
    metin: 'İman şems-i ezelîden bir nurdur; küfür ise zulmettir.',
    kaynak: 'İman ve Küfür Muvazeneleri',
    eser: 'İman ve Küfür Muvazeneleri',
  ),

  // 15. KUR'AN-I KERİM (4)
  Vecize(
    arapca: 'لَا يُكَلِّفُ اللّٰهُ نَفْسًا اِلَّا وُسْعَهَاۜ',
    metin: 'Allah, bir kimseyi ancak gücünün yettiği şeyle yükümlü kılar.',
    kaynak: 'Kur’an-ı Kerim, Bakara Sûresi, 286. Âyet',
    eser: 'Kur’an-ı Kerim',
  ),
  Vecize(
    arapca: 'فَاِنَّ مَعَ الْعُسْرِ يُسْرًاۙ اِنَّ مَعَ الْعُسْرِ يُسْرًاۜ',
    metin: 'Şüphesiz güçlükle beraber bir kolaylık vardır. Gerçekten, güçlükle beraber bir kolaylık vardır.',
    kaynak: 'Kur’an-ı Kerim, İnşirâh Sûresi, 5-6. Âyetler',
    eser: 'Kur’an-ı Kerim',
  ),
  Vecize(
    arapca: 'اَلَا بِذِكْرِ اللّٰهِ تَطْمَئِنُّ الْقُلُوبُۜ',
    metin: 'Bilesiniz ki, kalpler ancak Allah’ı anmakla huzur bulur.',
    kaynak: 'Kur’an-ı Kerim, Ra’d Sûresi, 28. Âyet',
    eser: 'Kur’an-ı Kerim',
  ),
  Vecize(
    arapca: 'وَمَنْ يَتَوَكَّلْ عَلَى اللّٰهِ فَهُوَ حَسْبُهُۜ',
    metin: 'Kim Allah’a tevekkül ederse, O kendisine yeter.',
    kaynak: 'Kur’an-ı Kerim, Talâk Sûresi, 3. Âyet',
    eser: 'Kur’an-ı Kerim',
  ),

  // 16. HADİS-İ ŞERİF (4)
  Vecize(
    metin: 'Ameller niyetlere göredir. Herkese ancak niyet ettiği şey vardır.',
    kaynak: 'Hadis-i Şerif, Buhârî, Bed’ü’l-Vahy, 1',
    eser: 'Hadis-i Şerif',
  ),
  Vecize(
    metin: 'Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.',
    kaynak: 'Hadis-i Şerif, Buhârî, İlim, 11',
    eser: 'Hadis-i Şerif',
  ),
  Vecize(
    metin: 'İnsanların en hayırlısı, insanlara faydalı olanıdır.',
    kaynak: 'Hadis-i Şerif, Taberânî, el-Mu’cemü’l-Evsat, 5787',
    eser: 'Hadis-i Şerif',
  ),
  Vecize(
    metin: 'Mü’minin durumu ne hoştur! Her hâli kendisi için hayırlıdır.',
    kaynak: 'Hadis-i Şerif, Müslim, Zühd, 64',
    eser: 'Hadis-i Şerif',
  ),
];
// --- VECİZELER DOSYASI BİTTİ ---
