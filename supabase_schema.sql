-- ============================================================
-- MATNSHUNOSLIK PLATFORMASI — SUPABASE SXEMASI
-- SQL Editor ga ko'chirib, "Run" tugmasini bosing
-- ============================================================

-- ── 1. MUALLIFLAR ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.mualliflar (
  id           uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  slug         text UNIQUE NOT NULL,
  ismi         jsonb NOT NULL DEFAULT '{}',
  tavallud     integer,
  vafot        integer,
  hudud        jsonb DEFAULT '{}',
  davr         text CHECK (davr IN ('ancient','medieval','modern','contemporary')),
  bio          jsonb DEFAULT '{}',
  ilmiy_muxit  jsonb DEFAULT '{}',
  asarlar_soni integer DEFAULT 0,
  rasm_url     text,
  badge        text,
  featured     boolean DEFAULT false,
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);

-- ── 2. ASARLAR ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.asarlar (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  slug          text UNIQUE NOT NULL,
  sarlavha      jsonb NOT NULL DEFAULT '{}',
  muallif_id    uuid REFERENCES public.mualliflar(id) ON DELETE SET NULL,
  yozilgan_yil  integer,
  janr          text[] DEFAULT '{}',
  asl_til       text,
  tavsif        jsonb DEFAULT '{}',
  matn_tarixi   jsonb DEFAULT '{}',
  badge         text,
  featured      boolean DEFAULT false,
  created_at    timestamptz DEFAULT now()
);

-- ── 3. QO'LYOZMALAR ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.qolyozmalar (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  asar_id     uuid REFERENCES public.asarlar(id) ON DELETE CASCADE,
  kutubxona   text NOT NULL,
  shahar      text,
  sana        text,
  holat       text DEFAULT 'unknown' CHECK (holat IN ('yaxshi','qoniqarli','yomon','unknown')),
  rasm_url    text,
  tavsif      text,
  created_at  timestamptz DEFAULT now()
);

-- ── 4. TADQIQOTCHILAR ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tadqiqotchilar (
  id              uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  slug            text UNIQUE NOT NULL,
  ismi            jsonb NOT NULL DEFAULT '{}',
  tavallud        integer,
  vafot           integer,
  muassasa        jsonb DEFAULT '{}',
  mutaxassislik   jsonb DEFAULT '{}',
  bio             jsonb DEFAULT '{}',
  nashrlar        jsonb DEFAULT '[]',
  tadqiqot_sohasi text[] DEFAULT '{}',
  rasm_url        text,
  created_at      timestamptz DEFAULT now()
);

-- ── 5. MANBALAR ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.manbalar (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  kategoriya  text NOT NULL CHECK (kategoriya IN ('adabiy','tarixiy','ilmiy','informatsion')),
  sarlavha    jsonb NOT NULL DEFAULT '{}',
  muallif     text,
  muharrir    text,
  yil         integer,
  nashriyot   text,
  shahar      text,
  tavsif      jsonb DEFAULT '{}',
  fayl_url    text,
  created_at  timestamptz DEFAULT now()
);

-- ── 6. XRONOLOGIYA ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.xronologiya (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  yil        integer NOT NULL,
  davr       text NOT NULL CHECK (davr IN ('ancient','medieval','modern','contemporary')),
  sarlavha   jsonb NOT NULL DEFAULT '{}',
  tavsif     jsonb DEFAULT '{}',
  ikon       text DEFAULT '📜',
  rang       text DEFAULT 'gold',
  created_at timestamptz DEFAULT now()
);

-- ── 7. TARMOQ GRAFIGI ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tarmoq_tugunlar (
  id    uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  label text NOT NULL,
  tur   text NOT NULL CHECK (tur IN ('author','researcher','work','school')),
  davr  text,
  rang  text DEFAULT '#c9a227',
  hajm  integer DEFAULT 30
);

CREATE TABLE IF NOT EXISTS public.tarmoq_boglar (
  id      uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  manba   uuid REFERENCES public.tarmoq_tugunlar(id) ON DELETE CASCADE,
  maqsad  uuid REFERENCES public.tarmoq_tugunlar(id) ON DELETE CASCADE,
  tur     text CHECK (tur IN ('authored','researched','collaboration','mentor','polemic','belongs','influence')),
  yorliq  text
);

-- ── RLS (Row Level Security) ──────────────────────────────────
ALTER TABLE public.mualliflar     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.asarlar        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.qolyozmalar    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tadqiqotchilar ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.manbalar       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.xronologiya    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tarmoq_tugunlar ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tarmoq_boglar  ENABLE ROW LEVEL SECURITY;

-- O'qish: hamma uchun ochiq (anon ham o'qiy oladi)
CREATE POLICY "public_read_mualliflar"     ON public.mualliflar     FOR SELECT USING (true);
CREATE POLICY "public_read_asarlar"        ON public.asarlar        FOR SELECT USING (true);
CREATE POLICY "public_read_qolyozmalar"    ON public.qolyozmalar    FOR SELECT USING (true);
CREATE POLICY "public_read_tadqiqotchilar" ON public.tadqiqotchilar FOR SELECT USING (true);
CREATE POLICY "public_read_manbalar"       ON public.manbalar       FOR SELECT USING (true);
CREATE POLICY "public_read_xronologiya"    ON public.xronologiya    FOR SELECT USING (true);
CREATE POLICY "public_read_tugunlar"       ON public.tarmoq_tugunlar FOR SELECT USING (true);
CREATE POLICY "public_read_boglar"         ON public.tarmoq_boglar  FOR SELECT USING (true);

-- Yozish: faqat autentifikatsiya qilingan (admin)
CREATE POLICY "auth_write_mualliflar"     ON public.mualliflar     FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth_write_asarlar"        ON public.asarlar        FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth_write_qolyozmalar"    ON public.qolyozmalar    FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth_write_tadqiqotchilar" ON public.tadqiqotchilar FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth_write_manbalar"       ON public.manbalar       FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth_write_xronologiya"    ON public.xronologiya    FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth_write_tugunlar"       ON public.tarmoq_tugunlar FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "auth_write_boglar"         ON public.tarmoq_boglar  FOR ALL USING (auth.role() = 'authenticated');


-- ============================================================
-- MA'LUMOTLAR (Seed Data) — Haqiqiy ilmiy ma'lumotlar
-- ============================================================

-- ── MUALLIFLAR ───────────────────────────────────────────────
INSERT INTO public.mualliflar (slug, ismi, tavallud, vafot, hudud, davr, bio, ilmiy_muxit, asarlar_soni, badge, featured) VALUES

('alisher-navoiy',
 '{"uz":"Alisher Navoiy","ru":"Алишер Навои","en":"Alisher Navoi","ar":"علي شير نوائي","fa":"علیشیر نوایی","tr":"Ali Şir Nevai"}',
 1441, 1501,
 '{"uz":"Hirot (hozirgi Afg''oniston)","ru":"Герат (ныне Афганистан)","en":"Herat (modern Afghanistan)"}',
 'medieval',
 '{"uz":"Alisher Navoiy (1441–1501) — o''zbek va umuman turkiy adabiyotining eng buyuk vakili, shoir, davlat arbobi va mutafakkir. Hirot shahri yaqinida tavallud topgan. Sulton Husayn Boyqaro saroyida vazir lavozimida xizmat qilgan. O''zbek adabiy tilining shakllanishiga ulkan hissa qo''shgan.","ru":"Алишер Навои (1441–1501) — величайший представитель узбекской и тюркской литературы в целом, поэт, государственный деятель и мыслитель.","en":"Alisher Navoi (1441–1501) was the greatest representative of Uzbek and Turkic literature, a poet, statesman and thinker who made enormous contributions to the formation of the Uzbek literary language."}',
 '{"uz":"Navoiy Hirotdagi Temuriylar madaniy muhitida, she''riyat va ilmga chuqur hurmat ko''rsatilgan davrda yashab ijod etdi. U Ahmad Jomiy bilan yaqin do''stlik munosabatlarida bo''lgan va Sulton Husayn Boyqaro saroyining ma''naviy ustuni hisoblangan.","en":"Navoi lived and created in the Timurid cultural environment of Herat, an era of deep reverence for poetry and scholarship."}',
 30, '⭐ Buyuk Muallif', true),

('zahiriddin-muhammad-bobur',
 '{"uz":"Zahiriddin Muhammad Bobur","ru":"Захириддин Мухаммад Бабур","en":"Zahiruddin Muhammad Babur","ar":"ظهير الدين محمد بابر","fa":"ظهیرالدین محمد بابر","tr":"Zahirüddin Muhammed Babür"}',
 1483, 1530,
 '{"uz":"Andijon (O''zbekiston) — Agra (Hindiston)","ru":"Андижан (Узбекистан) — Агра (Индия)","en":"Andijan (Uzbekistan) — Agra (India)"}',
 'medieval',
 '{"uz":"Zahiriddin Muhammad Bobur (1483–1530) — Temuriylar sulolasidan bo''lgan hukmdor, shoir va tarixchi. Boburiylar imperiyasini asos solgan. ''Boburnoma'' — dunyo adabiyotidagi eng qadimgi va mukammal tarjimai hollardan biri.","ru":"Захириддин Мухаммад Бабур (1483–1530) — правитель из династии Тимуридов, поэт и историк. Основатель империи Бабуридов.","en":"Zahiruddin Muhammad Babur (1483–1530) was a ruler of the Timurid dynasty, poet and historian. Founder of the Mughal Empire. Baburnama is one of the oldest and most complete autobiographies in world literature."}',
 '{"uz":"Bobur avval Samarqand va Farg''ona vodiysi uchun kurash olib borgan, keyin Kobul va nihoyat Hindistonda Boburiylar sulolasini barpo etgan. Chig''atoy o''zbek tilida ajoyib she''rlar va tarixiy asarlar yaratgan.","en":"Babur first struggled for Samarkand and the Fergana Valley, then established the Mughal dynasty in Kabul and India."}',
 12, '📖 Tarixchi-Shoir', true),

('abu-rayhon-beruniy',
 '{"uz":"Abu Rayhon Beruniy","ru":"Абу Рейхан Бируни","en":"Abu Rayhan al-Biruni","ar":"أبو ريحان البيروني","fa":"ابوریحان بیرونی","tr":"Ebû Reyhan el-Bîrûnî"}',
 973, 1048,
 '{"uz":"Xorazm (hozirgi O''zbekiston) — G''azna (hozirgi Afg''oniston)","ru":"Хорезм — Газна","en":"Khwarazm (modern Uzbekistan) — Ghazni (modern Afghanistan)"}',
 'medieval',
 '{"uz":"Abu Rayhon Muhammad ibn Ahmad al-Beruniy (973–1048) — o''rta asrning buyuk qomuschi olimi. Matematika, astronomiya, geografiya, mineralogiya, tarix, falsafa va boshqa sohalarda 150 dan ortiq asar yozgan. ''Hindiston'' asari qiyosiy dinlar tarixi bo''yicha birinchi ilmiy tadqiqot hisoblanadi.","ru":"Абу Рейхан Бируни (973–1048) — великий энциклопедист Средневековья. Написал более 150 трудов по математике, астрономии, географии, минералогии, истории и философии.","en":"Abu Rayhan al-Biruni (973–1048) was a great medieval polymath who wrote over 150 works on mathematics, astronomy, geography, mineralogy, history and philosophy."}',
 '{"uz":"Beruniy ilk tahsilini Xorazmda olgan. Sulton Mahmud G''aznaviy saroyida xizmat qilib, Hindistonga birga kelgan va hindlar hayoti, madaniyati va ilmini chuqur o''rgangan.","en":"Al-Biruni received his early education in Khwarazm. He served in the court of Sultan Mahmud of Ghazni and accompanied him to India, deeply studying Indian life, culture and science."}',
 18, '🔬 Olim-Qomuschi', true),

('mahmud-koshgariy',
 '{"uz":"Mahmud Koshg''ariy","ru":"Махмуд Кашгари","en":"Mahmud al-Kashgari","ar":"محمود الكاشغري","fa":"محمود کاشغری","tr":"Mahmud Kaşgarlı"}',
 1005, 1102,
 '{"uz":"Koshg''ar (hozirgi Xitoy)","ru":"Кашгар (современный Китай)","en":"Kashgar (modern China)"}',
 'medieval',
 '{"uz":"Mahmud Koshg''ariy (taxm. 1005–1102) — XI asrda yashagan buyuk turkshunos olim va leksikograf. Uning ''Devonu lug''otit turk'' asari turkiy xalqlarning tili, madaniyati, she''riyati va urf-odatlarini qamrab olgan noyob ensiklopedik lug''at hisoblanadi.","ru":"Махмуд Кашгари (ок. 1005–1102) — великий тюрколог и лексикограф XI века. Его ''Диван лугат ат-тюрк'' — уникальный энциклопедический словарь, охватывающий язык, культуру, поэзию и обычаи тюркских народов.","en":"Mahmud al-Kashgari (c. 1005–1102) was a great Turkologist and lexicographer of the 11th century. His Diwan Lughat al-Turk is a unique encyclopedic dictionary covering the language, culture, poetry and customs of Turkic peoples."}',
 '{"uz":"Koshg''ariy Qorahoniylar sulolasiga mansub bo''lgan va turkiy qabilalarni keng o''rganish maqsadida ko''plab sayohatlar qilgan. Asarini 1072–1074 yillarda Bag''dodda yozib tugatgan.","en":"Kashgari belonged to the Karakhanid dynasty and made extensive travels to study Turkic tribes. He completed his work in Baghdad in 1072–1074."}',
 3, '📚 Tilshunos', false),

('ibn-sino',
 '{"uz":"Abu Ali ibn Sino","ru":"Ибн Сина (Авиценна)","en":"Avicenna (Ibn Sina)","ar":"ابن سينا","fa":"ابن سینا","tr":"İbn Sina"}',
 980, 1037,
 '{"uz":"Buxoro (hozirgi O''zbekiston) — Hamadон (hozirgi Eron)","ru":"Бухара — Хамадан","en":"Bukhara (modern Uzbekistan) — Hamadan (modern Iran)"}',
 'medieval',
 '{"uz":"Abu Ali Husayn ibn Abdulloh ibn Sino (980–1037) — o''rta asrning buyuk faylasufi va tabibi. Uning ''Tib qonunlari'' asari XVII asrgacha Yevropa va Sharqda tibbiyot darsligiga aylangan. Falsafa, mantiq, matematika, astronomiya va musiqa bo''yicha ham muhim asarlar qoldirgan.","ru":"Ибн Сина (980–1037) — великий философ и врач Средневековья. Его ''Канон медицины'' служил учебником по медицине в Европе и на Востоке вплоть до XVII века.","en":"Avicenna (980–1037) was a great medieval philosopher and physician. His Canon of Medicine served as a medical textbook in Europe and the East until the 17th century."}',
 '{"uz":"Ibn Sino o''n yoshida Qur''onni yod olgan. O''n olti yoshida mashhur tabib bo''lgan. Somoniylar sulolasi parchalanganidan so''ng turli saroylarda xizmat qilgan.","en":"Ibn Sina memorized the Quran at age ten and became a renowned physician at sixteen. After the fall of the Samanid dynasty, he served at various courts."}',
 21, '⚕️ Faylasuf-Tabib', true);


-- ── ASARLAR ──────────────────────────────────────────────────
WITH navoiy AS (SELECT id FROM public.mualliflar WHERE slug = 'alisher-navoiy'),
     bobur  AS (SELECT id FROM public.mualliflar WHERE slug = 'zahiriddin-muhammad-bobur'),
     beruniy AS (SELECT id FROM public.mualliflar WHERE slug = 'abu-rayhon-beruniy'),
     koshgariy AS (SELECT id FROM public.mualliflar WHERE slug = 'mahmud-koshgariy'),
     ibnsino AS (SELECT id FROM public.mualliflar WHERE slug = 'ibn-sino')

INSERT INTO public.asarlar (slug, sarlavha, muallif_id, yozilgan_yil, janr, asl_til, tavsif, matn_tarixi, badge, featured)
SELECT * FROM (
  VALUES
  ('xamsa',
   '{"uz":"Xamsa","ru":"Хамса","en":"Khamsa","ar":"الخمسة","fa":"خمسه"}',
   (SELECT id FROM navoiy),
   1483,
   ARRAY['poetry','epic'],
   'uz_old',
   '{"uz":"Navoiyning besh dostondan iborat yirik she''riy to''plami. Hayrat ul-abror, Farhod va Shirin, Layli va Majnun, Sab''ai sayyor, Saddi Iskandariy dostonlarini o''z ichiga oladi.","ru":"Крупный поэтический сборник Навои из пяти поэм.","en":"Navoi''s major poetic collection of five epics."}',
   '{"uz":"Xamsa 1483–1485 yillarda yaratilgan. 200 dan ortiq qo''lyozma nusxasi jahon kutubxonalarida saqlanmoqda. Birinchi tanqidiy nashri Hamid Sulaymon tomonidan tayyorlangan.","en":"Khamsa was created in 1483–1485. Over 200 manuscript copies are preserved in world libraries."}',
   '⭐ Klassik', true),

  ('boburnoma',
   '{"uz":"Boburnoma (Vaqoye'')","ru":"Бабурнаме","en":"Baburnama","ar":"بابرناما","fa":"بابرنامه"}',
   (SELECT id FROM bobur),
   1526,
   ARRAY['autobiography','history','prose'],
   'chaghatai',
   '{"uz":"Boburning o''z qo''li bilan yozgan xotiralari. Dunyo adabiyotidagi eng qadimgi to''liq avtobiografiyalardan biri. Tarix, tabiat, odamlar va siyosat haqida nodir ma''lumotlar.","ru":"Мемуары, написанные рукой Бабура. Одна из старейших полных автобиографий в мировой литературе.","en":"Memoirs written in Babur''s own hand. One of the oldest complete autobiographies in world literature."}',
   '{"uz":"Boburnoma chig''atoy o''zbek tilida yozilgan. Ko''p qo''lyozmalar mavjud: Istanbul, London, Toshkent kutubxonalarida. Annette Beveridge inglizchaga tarjima qilgan (1921).","en":"Baburnama was written in Chagatai Uzbek. Many manuscripts exist in Istanbul, London, and Tashkent libraries. Annette Beveridge translated it into English in 1921."}',
   '📖 Tarixiy', true),

  ('devonu-lugotit-turk',
   '{"uz":"Devonu lug''otit turk","ru":"Диван лугат ат-тюрк","en":"Diwan Lughat al-Turk","ar":"ديوان لغات الترك"}',
   (SELECT id FROM koshgariy),
   1074,
   ARRAY['linguistics','encyclopedia'],
   'ar',
   '{"uz":"Turkiy xalqlarning tilini, she''riyatini, urf-odatlarini qamrab olgan ensiklopedik lug''at. Arab tilida yozilgan, lekin turkiy so''zlar va she''rlarni keng keltiradi.","ru":"Энциклопедический словарь тюркских народов, охватывающий их язык, поэзию и обычаи.","en":"An encyclopedic dictionary of Turkic peoples covering their language, poetry and customs, written in Arabic."}',
   '{"uz":"Yagona qo''lyozma nusxasi Istanbul kutubxonasida saqlanadi (Fatih 4189). 1917 yilda Kilisli Rifat tomonidan nashr etilgan. O''zbekcha tarjimasi Salim Mutallibov tomonidan amalga oshirilgan.","en":"The sole manuscript copy is preserved in the Istanbul library (Fatih 4189). Published by Kilisli Rifat in 1917."}',
   '📚 Lug''at', true),

  ('hindiston',
   '{"uz":"Hindiston (Tahqiq ma li-l-hind)","ru":"Индия (Разъяснение принадлежащего индийцам)","en":"Indica (Tahqiq ma li-l-Hind)","ar":"تحقيق ما للهند"}',
   (SELECT id FROM beruniy),
   1030,
   ARRAY['history','comparative_religion','geography'],
   'ar',
   '{"uz":"Beruniy Hindiston haqida yozgan keng qamrovli ilmiy asar. Hindu dini, falsafasi, astronomiyasi, geografiyasi va madaniyati haqida batafsil ma''lumot beradi. Qiyosiy dinlar tarixi bo''yicha ilk ilmiy tadqiqot.","ru":"Обширный научный труд Бируни о Индии — первое научное исследование по сравнительной истории религий.","en":"Al-Biruni''s comprehensive scientific work on India — the first scientific study in comparative religious history."}',
   '{"uz":"Arabcha yozilgan. Bir necha qo''lyozma nusxalari mavjud. Eduard Sakhau tomonidan inglizchaga tarjima qilingan (1888). O''zbekcha tarjima O.Bobojonov tomonidan tayyorlangan.","en":"Written in Arabic. Several manuscript copies exist. Translated into English by Eduard Sachau (1888)."}',
   '🌏 Ilmiy', false),

  ('tib-qonunlari',
   '{"uz":"Tib qonunlari (al-Qonun fit-tib)","ru":"Канон медицины","en":"The Canon of Medicine","ar":"القانون في الطب","fa":"قانون در طب"}',
   (SELECT id FROM ibnsino),
   1025,
   ARRAY['medicine','science'],
   'ar',
   '{"uz":"Ibn Sinoning tib sohasidagi asosiy asari. 5 kitobdan iborat bo''lib, tibbiyotning barcha sohalarini qamrab oladi. Yevropa universitetlarida XVII asrgacha darslik sifatida foydalanilgan.","ru":"Главный медицинский труд Ибн Сины в 5 книгах. Использовался как учебник в европейских университетах до XVII века.","en":"Ibn Sina''s major medical work in 5 books covering all areas of medicine. Used as a textbook in European universities until the 17th century."}',
   '{"uz":"Arabcha yozilgan. Ko''plab qo''lyozma nusxalari mavjud. XII asrda Gerardo Kremona tomonidan lotinchaga tarjima qilingan. Hozir ham tibbiyot tarixi bo''yicha muhim manba.","en":"Written in Arabic. Many manuscript copies exist. Translated into Latin by Gerard of Cremona in the 12th century."}',
   '⚕️ Tib', false)
) AS v(slug, sarlavha, muallif_id, yozilgan_yil, janr, asl_til, tavsif, matn_tarixi, badge, featured);


-- ── XRONOLOGIYA ───────────────────────────────────────────────
INSERT INTO public.xronologiya (yil, davr, sarlavha, tavsif, ikon, rang) VALUES
(-400, 'ancient',
 '{"uz":"Qadimiy yozuv tizimlarining rivojlanishi","en":"Development of ancient writing systems"}',
 '{"uz":"O''rta Osiyo hududida so''g''diy va xorazmiy yozuv tizimlari rivojlana boshladi. Bu yozuvlar keyinchalik arab yozuviga o''tish uchun zamin hozirladi.","en":"Sogdian and Khwarezmian writing systems began developing in Central Asia."}',
 '🏺', 'leather'),

(712, 'medieval',
 '{"uz":"Arab istilosi va islomning tarqalishi","en":"Arab conquest and spread of Islam"}',
 '{"uz":"Ma''mun ibn Muhammad Xurosonni va O''rta Osiyoni Arab xalifaligiga qo''shib oldi. Bu davrdan boshlab arab tili ilm-fan tili sifatida keng tarqaldi.","en":"Arab caliphate expanded into Central Asia, establishing Arabic as the language of science and scholarship."}',
 '☽', 'gold'),

(973, 'medieval',
 '{"uz":"Beruniy tavalludi","en":"Birth of al-Biruni"}',
 '{"uz":"Abu Rayhon Muhammad ibn Ahmad al-Beruniy Xorazmda tavallud topdi. U keyinchalik o''rta asrning eng ulug'' qomuschi olimiga aylandi.","en":"Abu Rayhan al-Biruni was born in Khwarazm. He would become the greatest polymath of the Middle Ages."}',
 '🔬', 'sapphire'),

(980, 'medieval',
 '{"uz":"Ibn Sino tavalludi","en":"Birth of Ibn Sina"}',
 '{"uz":"Abu Ali Husayn ibn Abdulloh ibn Sino Buxoro yaqinidagi Afshona qishlog''ida tavallud topdi.","en":"Avicenna was born in Afshona village near Bukhara."}',
 '⚕️', 'emerald'),

(1072, 'medieval',
 '{"uz":"Devonu lug''otit turk yaratildi","en":"Diwan Lughat al-Turk compiled"}',
 '{"uz":"Mahmud Koshg''ariy o''zining mashhur turkiy lug''atini Bag''dodda yozib tugatdi. Bu asar turkiy tillarni o''rganishda eng muhim manba hisoblanadi.","en":"Mahmud Kashgari completed his famous Turkic dictionary in Baghdad — the most important source for the study of Turkic languages."}',
 '📚', 'gold'),

(1441, 'medieval',
 '{"uz":"Alisher Navoiy tavalludi","en":"Birth of Alisher Navoi"}',
 '{"uz":"Kelajakda o''zbek adabiyotining buyuk namoyandasiga aylanadigan Alisher Navoiy Hirot yaqinida tavallud topdi.","en":"Alisher Navoi, who would become the greatest representative of Uzbek literature, was born near Herat."}',
 '✒️', 'gold'),

(1483, 'medieval',
 '{"uz":"Bobur tavalludi va Xamsa yaratildi","en":"Birth of Babur and Khamsa created"}',
 '{"uz":"Bir yilda ikkita muhim voqea: Zahiriddin Muhammad Bobur Andijonda tavallud topdi; Navoiy esa ''Xamsa''sini yaratishni boshladi.","en":"Two important events in one year: Babur was born in Andijan; Navoi began creating his Khamsa."}',
 '⭐', 'ruby'),

(1526, 'modern',
 '{"uz":"Boburiylar imperiyasi asos solindi","en":"Mughal Empire founded"}',
 '{"uz":"Bobur Panipat jangida g''alaba qozonib, Hindistonda Boburiylar imperiyasini barpo etdi va ''Boburnoma''ni yozishni davom ettirdi.","en":"Babur defeated Ibrahim Lodhi at the First Battle of Panipat and established the Mughal Empire in India."}',
 '👑', 'leather'),

(1876, 'contemporary',
 '{"uz":"O''zbek matnshunosligining boshlanishi","en":"Beginning of Uzbek textual studies"}',
 '{"uz":"Rus imperiyasi O''rta Osiyoni zabt etgandan so''ng, Toshkentda arxeologik tadqiqotlar va qo''lyozmalarni to''plash ishlari boshlandi.","en":"After the Russian Empire conquered Central Asia, archaeological research and manuscript collection began in Tashkent."}',
 '🔍', 'sapphire'),

(1941, 'contemporary',
 '{"uz":"O''zbekiston FA Qo''lyozmalar instituti tashkil etildi","en":"Institute of Manuscripts founded in Uzbekistan"}',
 '{"uz":"Toshkentda O''zbekiston Fanlar akademiyasi qoshida Qo''lyozmalar instituti tashkil etildi. Bu ilm dargohi hozirgi kunda 50,000 dan ortiq qo''lyozma va bosma kitobni saqlaydi.","en":"The Institute of Manuscripts was established under the Academy of Sciences of Uzbekistan in Tashkent."}',
 '🏛️', 'gold'),

(1991, 'contemporary',
 '{"uz":"O''zbekiston mustaqilligi va milliy meros","en":"Uzbekistan independence and national heritage"}',
 '{"uz":"O''zbekiston mustaqillikka erishgach, milliy adabiy va ilmiy merosni tiklash bo''yicha keng ko''lamli ishlar boshlandi. Ko''plab asarlar qayta nashr etildi.","en":"After Uzbekistan gained independence, large-scale work began to restore the national literary and scientific heritage."}',
 '🌟', 'emerald');


-- ── TADQIQOTCHILAR ────────────────────────────────────────────
INSERT INTO public.tadqiqotchilar (slug, ismi, tavallud, vafot, muassasa, mutaxassislik, bio, nashrlar, tadqiqot_sohasi) VALUES

('hamid-sulaymon',
 '{"uz":"Hamid Sulaymon","ru":"Хамид Сулейманов","en":"Hamid Sulaymon"}',
 1913, 1987,
 '{"uz":"O''zbekiston Fanlar Akademiyasi, Qo''lyozmalar instituti","ru":"Институт рукописей АН Узбекистана"}',
 '{"uz":"Navoiy asarlarining tanqidiy nashrlari, matnshunoslik","en":"Critical editions of Navoi''s works, textual criticism"}',
 '{"uz":"Hamid Sulaymon — o''zbek matnshunosligining asoschisi. U Navoiy asarlarining tanqidiy nashrlarini tayyorlashda katta hissa qo''shgan. Uning ilmiy merosida 200 dan ortiq maqola va bir necha monografiya bor.","en":"Hamid Sulaymon is the founder of Uzbek textual criticism. He made great contributions to the preparation of critical editions of Navoi''s works."}',
 '[{"sarlavha":"Navoiy va uning zamondoshlari","yil":1961,"nashriyot":"Fan"},{"sarlavha":"O''zbek adabiyoti tarixi","yil":1977,"nashriyot":"Fan"}]',
 ARRAY['navoiyshunoslik','matnshunoslik','qolyozmalar']),

('porso-shamsiev',
 '{"uz":"Porso Shamsiev","ru":"Порсо Шамсиев","en":"Porso Shamsiev"}',
 1906, 1973,
 '{"uz":"Toshkent Davlat Universiteti, O''zbek tili kafedrasi","ru":"Ташкентский государственный университет"}',
 '{"uz":"Chig''atoy tili, qo''lyozma lug''atlar, Navoiy devonlari","en":"Chagatai language, manuscript dictionaries, Navoi''s diwans"}',
 '{"uz":"Porso Shamsiev — o''zbek va chig''atoy tilshunosligining yetakchi mutaxassisi. Navoiyning lirik devonlari va lug''atlarini o''rganishda salmoqli hissa qo''shgan.","en":"Porso Shamsiev was a leading specialist in Uzbek and Chagatai linguistics."}',
 '[{"sarlavha":"Navoiy devonlarining lug''ati","yil":1968,"nashriyot":"Fan"},{"sarlavha":"Chig''atoy tili grammatikasi","yil":1958,"nashriyot":"TDU"}]',
 ARRAY['tilshunoslik','navoiyshunoslik','lugatshunoslik']);


-- ── TARMOQ GRAFIGI ────────────────────────────────────────────
WITH ins AS (
  INSERT INTO public.tarmoq_tugunlar (label, tur, davr, rang, hajm) VALUES
  ('Alisher Navoiy', 'author', 'XV asr', '#c9a227', 50),
  ('Zahiriddin Bobur', 'author', 'XV-XVI asr', '#c9a227', 45),
  ('Beruniy', 'author', 'X-XI asr', '#c9a227', 48),
  ('Ibn Sino', 'author', 'X-XI asr', '#c9a227', 46),
  ('M. Koshg''ariy', 'author', 'XI asr', '#c9a227', 38),
  ('Xamsa', 'work', 'XV asr', '#e8c84a', 40),
  ('Boburnoma', 'work', 'XVI asr', '#e8c84a', 38),
  ('Devonu lug''otit turk', 'work', 'XI asr', '#e8c84a', 36),
  ('Tib qonunlari', 'work', 'XI asr', '#e8c84a', 35),
  ('Hirot adabiy maktabi', 'school', 'XV asr', '#4caf8a', 42),
  ('Hamid Sulaymon', 'researcher', 'XX asr', '#5b9bd5', 32),
  ('Porso Shamsiev', 'researcher', 'XX asr', '#5b9bd5', 30)
  RETURNING id, label
)
INSERT INTO public.tarmoq_boglar (manba, maqsad, tur, yorliq)
SELECT
  src.id, tgt.id, rel.tur, rel.label
FROM (VALUES
  ('Alisher Navoiy',       'Xamsa',               'authored',    'muallif'),
  ('Alisher Navoiy',       'Hirot adabiy maktabi', 'belongs',     'a''zo'),
  ('Zahiriddin Bobur',     'Boburnoma',            'authored',    'muallif'),
  ('M. Koshg''ariy',       'Devonu lug''otit turk', 'authored',   'muallif'),
  ('Ibn Sino',             'Tib qonunlari',        'authored',    'muallif'),
  ('Alisher Navoiy',       'Zahiriddin Bobur',     'influence',   'ta''sir'),
  ('Hamid Sulaymon',       'Xamsa',                'researched',  'tadqiqot'),
  ('Porso Shamsiev',       'Xamsa',                'researched',  'tadqiqot'),
  ('Hamid Sulaymon',       'Porso Shamsiev',       'collaboration','hamkorlik')
) AS rel(src_label, tgt_label, tur, label)
JOIN ins AS src ON src.label = rel.src_label
JOIN ins AS tgt ON tgt.label = rel.tgt_label;
