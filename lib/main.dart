class Vecize {
  final String metin, kaynak, eser;
  const Vecize(this.metin, this.kaynak, this.eser);

  Map<String, dynamic> toMap() => {'m': metin, 'k': kaynak, 'e': eser};

  factory Vecize.fromMap(Map<String, dynamic> map) => Vecize(
        map['m'] ?? '',
        map['k'] ?? 'Risale-i Nur',
        map['e'] ?? 'Sözler',
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
];

const List<Vecize> varsayilanVecizeler = [
  Vecize('İman hem nurdur, hem kuvvettir. Evet, hakiki imanı elde eden adam, kâinata meydan okuyabilir.', 'Sözler, Yirmi Üçüncü Söz', 'Sözler'),
  Vecize('Kadere iman eden, kederden emin olur.', 'Sözler, Yirmi Altıncı Söz', 'Sözler'),
  Vecize('Bismillah her hayrın başıdır. Biz dahi başta ona başlarız.', 'Sözler, Birinci Söz', 'Sözler'),
  Vecize('Dost istersen Allah yeter. Evet, o dost ise her şey dosttur.', 'Sözler, Yirmi Üçüncü Söz', 'Sözler'),
  Vecize('Hayat bir sermayedir; sarf edilip gidiyor. Eğer meyvesi bulunmazsa zayi olur.', 'Sözler, Yirmi Dördüncü Söz', 'Sözler'),
  Vecize('Her şeyde, hattâ en çirkin görünen şeylerde, hakiki bir hüsün ciheti vardır.', 'Sözler, On Sekizinci Söz', 'Sözler'),
  Vecize('Ey nefis! Bil ki, dünkü gün senin elinden çıktı, yarın ise senin elinde senet yok ki ona maliksin. Öyle ise hakiki ömrünü bulunduğun gün bil.', 'Sözler, Yirmi Birinci Söz', 'Sözler'),
  Vecize('İman insanı insan eder, belki insanı sultan eder.', 'Sözler, Yirmi Üçüncü Söz', 'Sözler'),
  Vecize('Güzel gören güzel düşünür. Güzel düşünen hayatından lezzet alır.', 'Mektubat, Hakikat Çekirdekleri', 'Mektubat'),
  Vecize('Bâki hakikatler fâni şahsiyetler üzerine bina edilmez.', 'Mektubat, Yirmi Dokuzuncu Mektup', 'Mektubat'),
  Vecize('Zaman ihtiyarlandıkça Kur’ân gençleşiyor, rumuzu tavazzuh ediyor.', 'Mektubat, Yirmi Altıncı Mektup', 'Mektubat'),
  Vecize('Hakkın hatırı âlidir, hiçbir hatıra feda edilmez.', 'Mektubat, Yirmi İkinci Mektup', 'Mektubat'),
  Vecize('Fenalık fenalıkla def edilmez, belki iyilikle mukabele edilir.', 'Mektubat, Yirmi İkinci Mektup', 'Mektubat'),
  Vecize('Muhabbete en lâyık şey muhabbettir ve husumete en lâyık sıfat husumettir.', 'Mektubat, Yirmi İkinci Mektup', 'Mektubat'),
  Vecize('Şükür nimeti ziyadeleştirir, şekva musibeti ikileştirir.', 'Mektubat, Yirmi Sekizinci Mektup', 'Mektubat'),
  Vecize('İhlâs, amelinizde rıza-yı İlâhîyi gaye edinmektir.', 'Lem’alar, Yirmi Birinci Lem’a', 'Lem’alar'),
  Vecize('Elhasıl: Dünya madem fânidir. Hem madem ömür kısadır. Hem madem en lüzumlu vazifeler çoktur. Öyleyse ehemmiyetli vazifeleri öne almak gerektir.', 'Lem’alar, Yirmi Birinci Lem’a', 'Lem’alar'),
  Vecize('Kardeşlerinizin nefislerini nefsinize şerefte, makamda, teveccühte, hattâ menfaat-i maddiye gibi nefsin hoşuna giden şeylerde tercih ediniz.', 'Lem’alar, Yirmi Birinci Lem’a', 'Lem’alar'),
  Vecize('İktisat hem bir şükr-ü manevî, hem nimetlerdeki rahmet-i İlâhiyeye karşı bir hürmet, hem kat’î bir surette sebeb-i berekettir.', 'Lem’alar, On Dokuzuncu Lem’a', 'Lem’alar'),
  Vecize('Hastalık, sabredenler için bir keffaretü’z-zünub ve bir ibadet-i kübrâdır.', 'Lem’alar, Yirmi Beşinci Lem’a', 'Lem’alar'),
  Vecize('Tevazu, mahviyet ve terk-i enaniyet, bu zamanın en mühim bir düsturudur.', 'Lem’alar, Yirmi Birinci Lem’a', 'Lem’alar'),
  Vecize('Kur’ân-ı Hakîmin eczaları olan Risale-i Nur, bu asrın yaralarına en tesirli bir tiryaktır.', 'Şualar, On Üçüncü Şua', 'Şualar'),
  Vecize('İman tevhidi, tevhid teslimi, teslim tevekkülü, tevekkül saadet-i dâreyni iktiza eder.', 'Şualar, İkinci Şua', 'Şualar'),
  Vecize('Sabır ve şükür ve tevekkül ile her musibet hafifleşir, rahmete inkılâp eder.', 'Şualar, On Birinci Şua', 'Şualar'),
  Vecize('Biz muhabbet fedaileriyiz; husumete vaktimiz yoktur.', 'Şualar, On Dördüncü Şua', 'Şualar'),
  Vecize('Hakiki saadet ve lezzet, ancak iman ve marifetullah dairesinde bulunabilir.', 'Şualar, Yedinci Şua', 'Şualar'),
  Vecize('Sabır, üç kısımdır: Biri masiyetten kendini çekmek, ikincisi musibetlere karşı sabır, üçüncüsü ibadet üzerinde sabırdır.', 'Mesnevî-i Nuriye', 'Mesnevî-i Nuriye'),
  Vecize('Ey insan! Senin elinde bulunan nefis ve malın senin mülkün değil, belki sana emanettir.', 'Mesnevî-i Nuriye', 'Mesnevî-i Nuriye'),
  Vecize('Acz ve fakr ve şefkat ve tefekkür tarîkı, en kısa ve en selâmetli bir yoldur.', 'Mesnevî-i Nuriye', 'Mesnevî-i Nuriye'),
  Vecize('Helâl dairesi geniştir, keyfe kâfi gelir; harama girmeye hiç lüzum yoktur.', 'Mesnevî-i Nuriye', 'Mesnevî-i Nuriye'),
  Vecize('Kalb ancak zikrullah ile mutmain olur ve ruh ancak marifetullah ile huzur bulur.', 'Mesnevî-i Nuriye', 'Mesnevî-i Nuriye'),
  Vecize('Eğer hakiki sadakat ve ihlâs ve tesanüd ile hareket edilse, birimiz bin hükmüne geçer.', 'Barla Lâhikası', 'Barla Lâhikası'),
  Vecize('Cenâb-ı Hak, kemâl-i merhametinden, bu asrın yaralarına tiryak olarak Risale-i Nur’u ihsan etmiştir.', 'Barla Lâhikası', 'Barla Lâhikası'),
  Vecize('Madem hakikat böyledir; biz dahi bütün kuvvetimizle hizmet-i Kur’âniyeye sarılmalıyız.', 'Barla Lâhikası', 'Barla Lâhikası'),
  Vecize('Risale-i Nur’un dairesine sadakat ve sebat ile girenler, inşaallah imanla kabre gireceklerdir.', 'Barla Lâhikası', 'Barla Lâhikası'),
  Vecize('Kur’ân-ı Hakîmin nurlarıyla iştigal, kalbe sürur, ruha inşirah, akla nur verir.', 'Barla Lâhikası', 'Barla Lâhikası'),
  Vecize('Bu zaman cemaat zamanıdır. Ehemmiyet ve kıymet, şahs-ı manevîye göre olur.', 'Kastamonu Lâhikası', 'Kastamonu Lâhikası'),
  Vecize('Birbirinize karşı en büyük vazifeniz, tesanüd ve birbirinizin kusuruna bakmamaktır.', 'Kastamonu Lâhikası', 'Kastamonu Lâhikası'),
  Vecize('Evet, ümitvar olunuz; şu istikbal inkılâbı içinde en yüksek gür sadâ İslâmın sadâsı olacaktır.', 'Kastamonu Lâhikası', 'Kastamonu Lâhikası'),
  Vecize('Risale-i Nur şakirtleri, şahısların değil, doğrudan doğruya Kur’ân’ın ve imanın hizmetkârlarıdır.', 'Kastamonu Lâhikası', 'Kastamonu Lâhikası'),
  Vecize('Her bir mü’min kardeşimizin hasenatından bize de bir hisse geçmesi, şahs-ı manevînin sırrıdır.', 'Kastamonu Lâhikası', 'Kastamonu Lâhikası'),
  Vecize('Bizim vazifemiz hizmettir; neticeye karışmayız. Vazife-i İlâhiyeye müdahale edilmez.', 'Emirdağ Lâhikası', 'Emirdağ Lâhikası'),
  Vecize('Risale-i Nur, yalnız bir cüz’î tahribatı, bir küçük haneyi tamir etmiyor; belki İslâmiyeti içine alan muhit bir kal’ayı tamir ediyor.', 'Emirdağ Lâhikası', 'Emirdağ Lâhikası'),
  Vecize('Asayişi muhafaza etmek, en büyük bir vazife-i vataniye ve diniyedir; zira asayiş bozulsa, masumlar zarar görür.', 'Emirdağ Lâhikası', 'Emirdağ Lâhikası'),
  Vecize('Kur’ân’ın elmas gibi hakikatlerini, dünya menfaatlerine âlet etmemek lâzımdır.', 'Emirdağ Lâhikası', 'Emirdağ Lâhikası'),
  Vecize('Uhuvvet ve muhabbet ve tesanüdümüzü muhafaza etmek, en mühim bir esasımızdır.', 'Emirdağ Lâhikası', 'Emirdağ Lâhikası'),
  Vecize('Hizmet-i imaniye, hiçbir siyasete ve hiçbir tarafgirliğe âlet edilemez; her şeyin fevkindedir.', 'Emirdağ Lâhikası', 'Emirdağ Lâhikası'),
];
// --- VECİZELER SONU ---
