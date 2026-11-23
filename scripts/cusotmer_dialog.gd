extends Control

@onready var type_timer: Timer = Timer.new()


# ------------------------------
#   EXPORT VARIABLES
# ------------------------------
@export var dialog_lines := {
	# Normale Kunden
	"cust_01": { "de": "Ich hab gehört, hier gibt's die besten Fische der Stadt!", "en": "I heard you have the best fish in town!", "ru": "Говорят, у тебя лучшая рыба в городе!", "tr": "Şehirdeki en iyi balıkların sende olduğunu duydum!", "es": "¡He oído que tienes el mejor pescado de la ciudad!", "fr": "On m'a dit que tu avais les meilleurs poissons de la ville !", "pl": "Słyszałem, że masz najlepsze ryby w mieście!" },
	"cust_02": { "de": "Zeig mir, was du heute gefangen hast.", "en": "Show me what you caught today.", "ru": "Покажи, что сегодня поймал.", "tr": "Bugün ne yakaladığını göster.", "es": "Enséñame lo que has pescado hoy.", "fr": "Montre-moi ce que tu as pêché aujourd'hui.", "pl": "Pokaż, co dziś złowiłeś." },
	"cust_03": { "de": "Meine Frau will Fisch zum Abendessen. Hilf mir.", "en": "My wife wants fish for dinner. Help me out.", "ru": "Жена хочет рыбу на ужин. Выручи.", "tr": "Karım akşam yemeğinde balık istiyor. Yardım et.", "es": "Mi mujer quiere pescado para cenar. Échame una mano.", "fr": "Ma femme veut du poisson pour le dîner. Aide-moi.", "pl": "Moja żona chce rybę na kolację. Pomóż mi." },
	"cust_04": { "de": "Ich zahle gut für seltene Exemplare.", "en": "I pay well for rare specimens.", "ru": "За редкие экземпляры хорошо плачу.", "tr": "Nadir örnekler için iyi para öderim.", "es": "Pago bien por ejemplares raros.", "fr": "Je paie bien pour les spécimens rares.", "pl": "Dobrze płacę za rzadkie okazy." },
	"cust_05": { "de": "Der Laden nebenan hat nichts. Du bist meine letzte Hoffnung.", "en": "The shop next door has nothing. You're my last hope.", "ru": "У соседей пусто. Ты моя последняя надежда.", "tr": "Yan dükkânda hiçbir şey yok. Son umudum sensin.", "es": "La tienda de al lado no tiene nada. Eres mi última esperanza.", "fr": "La boutique d'à côté n'a rien. Tu es mon dernier espoir.", "pl": "W sklepie obok nic nie ma. Jesteś moją ostatnią nadzieją." },
	
	# Mysteriöse/Lore Kunden
	"cust_06": { "de": "Hast du in letzter Zeit… seltsame Dinge im Wasser gesehen?", "en": "Have you seen… strange things in the water lately?", "ru": "Не видел в последнее время… странностей в воде?", "tr": "Son zamanlarda suda… garip şeyler gördün mü?", "es": "¿Has visto… cosas extrañas en el agua últimamente?", "fr": "Tu as vu… des choses étranges dans l'eau, dernièrement ?", "pl": "Widziałeś ostatnio… dziwne rzeczy w wodzie?" },
	"cust_07": { "de": "Die alten Fischer warnen vor dem tiefen See.", "en": "The old fishermen warn about the deep lake.", "ru": "Старые рыбаки предупреждают об опасностях глубокого озера.", "tr": "Yaşlı balıkçılar derin göle karşı uyarıyor.", "es": "Los viejos pescadores advierten sobre el lago profundo.", "fr": "Les vieux pêcheurs mettent en garde contre le lac profond.", "pl": "Starzy rybacy ostrzegają przed głębokim jeziorem." },
	"cust_08": { "de": "Man munkelt, im Wald verschwinden nachts Leute.", "en": "Rumor has it people disappear in the forest at night.", "ru": "Говорят, по ночам в лесу пропадают люди.", "tr": "Söylentiye göre geceleri ormanda insanlar kayboluyormuş.", "es": "Se rumorea que la gente desaparece en el bosque por la noche.", "fr": "On raconte que des gens disparaissent la nuit dans la forêt.", "pl": "Podobno nocami w lesie znikają ludzie." },
	"cust_09": { "de": "Ich brauche Fisch für ein… spezielles Ritual.", "en": "I need fish for a… special ritual.", "ru": "Мне нужна рыба для… особого ритуала.", "tr": "Bir… özel ayin için balığa ihtiyacım var.", "es": "Necesito pescado para un… ritual especial.", "fr": "J'ai besoin de poisson pour un rituel… particulier.", "pl": "Potrzebuję ryby do… specjalnego rytuału." },
	"cust_10": { "de": "Die Stadt verändert sich. Hast du es auch bemerkt?", "en": "The city is changing. Have you noticed too?", "ru": "Город меняется. Тоже заметил?", "tr": "Şehir değişiyor. Sen de fark ettin mi?", "es": "La ciudad está cambiando. ¿También lo has notado?", "fr": "La ville change. Tu l'as remarqué aussi ?", "pl": "Miasto się zmienia. Też to zauważyłeś?" },
	
	# Ungeduldig/Fordernd
	"cust_11": { "de": "Ich habe nicht den ganzen Tag Zeit!", "en": "I don't have all day!", "ru": "У меня не весь день в запасе!", "tr": "Bütün gün bekleyemem!", "es": "¡No tengo todo el día!", "fr": "Je n'ai pas toute la journée !", "pl": "Nie mam całego dnia!" },
	"cust_12": { "de": "Hoffentlich ist dein Fisch frisch.", "en": "I hope your fish is fresh.", "ru": "Надеюсь, рыба свежая.", "tr": "Umarım balıkların tazedir.", "es": "Espero que el pescado sea fresco.", "fr": "J'espère que ton poisson est frais.", "pl": "Mam nadzieję, że twoja ryba jest świeża." },
	"cust_13": { "de": "Gib mir das Beste, was du hast. Preis ist egal.", "en": "Give me the best you have. Price doesn't matter.", "ru": "Дай лучшее, что есть. Цена не важна.", "tr": "En iyisini ver. Fiyat önemli değil.", "es": "Dame lo mejor que tengas. El precio no importa.", "fr": "Donne-moi ce que tu as de mieux. Peu importe le prix.", "pl": "Daj mi to, co masz najlepszego. Cena nie gra roli." },
	"cust_14": { "de": "Ich bin in Eile, mach schnell!", "en": "I'm in a hurry, be quick!", "ru": "Я спешу, давай быстрее!", "tr": "Acelem var, çabuk ol!", "es": "¡Tengo prisa, date prisa!", "fr": "Je suis pressé, dépêche-toi !", "pl": "Spieszę się, pospiesz się!" },
	"cust_15": { "de": "Wenn die Qualität stimmt, komme ich wieder.", "en": "If the quality is good, I'll come back.", "ru": "Если качество хорошее, вернусь.", "tr": "Kalite iyiyse yine gelirim.", "es": "Si la calidad es buena, volveré.", "fr": "Si la qualité est bonne, je reviendrai.", "pl": "Jeśli jakość będzie dobra, wrócę." },
	
	# Freundlich/Gesprächig
	"cust_16": { "de": "Schöner Tag zum Fischen, nicht wahr?", "en": "Nice day for fishing, isn't it?", "ru": "Хороший день для рыбалки, правда?", "tr": "Balık tutmak için güzel bir gün, değil mi?", "es": "Buen día para pescar, ¿verdad?", "fr": "Belle journée pour pêcher, non ?", "pl": "Ładny dzień na ryby, prawda?" },
	"cust_17": { "de": "Dein Laden hat einen guten Ruf!", "en": "Your shop has a good reputation!", "ru": "У твоей лавки хорошая репутация!", "tr": "Dükkânının itibarı iyi!", "es": "¡Tu tienda tiene buena reputación!", "fr": "Ta boutique a bonne réputation !", "pl": "Twój sklep ma dobrą reputację!" },
	"cust_18": { "de": "Ich bin Stammkunde. Du erkennst mich nicht?", "en": "I'm a regular. Don't you recognize me?", "ru": "Я постоянный клиент. Не узнаёшь?", "tr": "Daimi müşteriyim. Beni tanımadın mı?", "es": "Soy cliente habitual. ¿No me reconoces?", "fr": "Je suis un habitué. Tu ne me reconnais pas ?", "pl": "Jestem stałym klientem. Nie poznajesz mnie?" },
	"cust_19": { "de": "Meine Kinder lieben deinen Fisch!", "en": "My children love your fish!", "ru": "Мои дети обожают твою рыбу!", "tr": "Çocuklarım balıklarına bayılıyor!", "es": "¡A mis hijos les encanta tu pescado!", "fr": "Mes enfants adorent ton poisson !", "pl": "Moje dzieci uwielbiają twoje ryby!" },
	"cust_20": { "de": "Was empfiehlst du heute?", "en": "What do you recommend today?", "ru": "Что сегодня посоветуешь?", "tr": "Bugün ne önerirsin?", "es": "¿Qué recomiendas hoy?", "fr": "Que me conseilles-tu aujourd'hui ?", "pl": "Co dziś polecasz?" },
	
	# Wüste/Biom-bezogen
	"cust_21": { "de": "Die Hitze in der Wüste ist unerträglich.", "en": "The heat in the desert is unbearable.", "ru": "В пустыне невыносимая жара.", "tr": "Çölde sıcak dayanılmaz.", "es": "El calor del desierto es insoportable.", "fr": "La chaleur du désert est insupportable.", "pl": "Upał na pustyni jest nie do zniesienia." },
	"cust_22": { "de": "Gibt es auch Wüstenfische? Das würde mich interessieren.", "en": "Are there desert fish? That would interest me.", "ru": "А пустынные рыбы бывают? Мне интересно.", "tr": "Çöl balıkları var mı? İlgimi çekerdi.", "es": "¿Hay peces del desierto? Me interesaría.", "fr": "Il y a aussi des poissons du désert ? Ça m'intéresse.", "pl": "Są też ryby pustynne? To mnie ciekawi." },
	"cust_23": { "de": "Im Norden soll ein gefrorener See sein.", "en": "They say there's a frozen lake in the north.", "ru": "Говорят, на севере есть замёрзшее озеро.", "tr": "Kuzeyde donmuş bir göl varmış.", "es": "Dicen que hay un lago helado al norte.", "fr": "On dit qu'il y a un lac gelé au nord.", "pl": "Podobno na północy jest zamarznięte jezioro." },
	"cust_24": { "de": "Die Kanalisation ist gefährlich, aber profitabel.", "en": "The sewers are dangerous but profitable.", "ru": "Канализация опасна, но прибыльна.", "tr": "Kanalizasyon tehlikeli ama kârlı.", "es": "Las alcantarillas son peligrosas, pero rentables.", "fr": "Les égouts sont dangereux, mais rentables.", "pl": "Kanały są niebezpieczne, ale dochodowe." },
	"cust_25": { "de": "Hast du schon mal im verfluchten Sumpf geangelt?", "en": "Have you ever fished in the cursed swamp?", "ru": "Рыбачил когда-нибудь в проклятом болоте?", "tr": "Lanetli bataklıkta hiç balık tuttun mu?", "es": "¿Has pescado alguna vez en el pantano maldito?", "fr": "Tu as déjà pêché dans le marais maudit ?", "pl": "Łowiłeś kiedyś w przeklętym bagnie?" },
	
	# Aberglaube/Mystik
	"cust_26": { "de": "Ein alter Geist soll nachts am Wasser wandeln.", "en": "An old spirit is said to walk by the water at night.", "ru": "Говорят, по ночам у воды бродит старый дух.", "tr": "Geceleri su kenarında yaşlı bir ruh dolaşıyormuş.", "es": "Dicen que un viejo espíritu pasea junto al agua de noche.", "fr": "On dit qu'un vieil esprit rôde près de l'eau la nuit.", "pl": "Podobno stary duch przechadza się nocą nad wodą." },
	"cust_27": { "de": "Manche Fische bringen Glück, andere… Pech.", "en": "Some fish bring luck, others… misfortune.", "ru": "Одни рыбы приносят удачу, другие… несчастье.", "tr": "Bazı balıklar şans getirir, bazıları… felaket.", "es": "Algunos peces traen suerte; otros… desgracias.", "fr": "Certains poissons portent bonheur, d'autres… malheur.", "pl": "Niektóre ryby przynoszą szczęście, inne… pecha." },
	"cust_28": { "de": "Die Vollmondnächte sind am besten zum Angeln.", "en": "Full moon nights are best for fishing.", "ru": "В полнолуние рыбачить лучше всего.", "tr": "Dolunay geceleri balık tutmak için en iyisidir.", "es": "Las noches de luna llena son las mejores para pescar.", "fr": "Les nuits de pleine lune sont les meilleures pour pêcher.", "pl": "Noce z pełnią księżyca są najlepsze na ryby." },
	"cust_29": { "de": "Ich habe ein Leuchten im Wasser gesehen. Warst du das?", "en": "I saw a glow in the water. Was that you?", "ru": "Видел свечение в воде. Это был ты?", "tr": "Suda bir parıltı gördüm. Sen miydin?", "es": "Vi un resplandor en el agua. ¿Eras tú?", "fr": "J'ai vu une lueur dans l'eau. C'était toi ?", "pl": "Widziałem blask w wodzie. To byłeś ty?" },
	"cust_30": { "de": "Pass auf die großen Fische auf. Sie beißen zurück.", "en": "Watch out for the big fish. They bite back.", "ru": "Берегись больших рыб. Они кусаются в ответ.", "tr": "Büyük balıklara dikkat et. Onlar da ısırır.", "es": "Cuidado con los peces grandes. También muerden.", "fr": "Méfie-toi des gros poissons. Ils mordent aussi.", "pl": "Uważaj na duże ryby. One też gryzą." },
	
	# Humorvoll/Sarkastisch
	"cust_31": { "de": "Ich hoffe, du verkaufst mir keinen Gummifisch.", "en": "I hope you're not selling me a rubber fish.", "ru": "Надеюсь, ты не продашь мне резиновую рыбу.", "tr": "Umarım bana lastik balık satmıyorsundur.", "es": "Espero que no me vendas un pez de goma.", "fr": "J'espère que tu ne me vends pas un poisson en caoutchouc.", "pl": "Mam nadzieję, że nie sprzedajesz mi gumowej ryby." },
	"cust_32": { "de": "Riechen deine Fische immer so… interessant?", "en": "Do your fish always smell so… interesting?", "ru": "Твоя рыба всегда пахнет так… интересно?", "tr": "Balıkların hep bu kadar… ilginç mi kokar?", "es": "¿Tu pescado siempre huele tan… interesante?", "fr": "Tes poissons sentent toujours aussi… curieusement ?", "pl": "Czy twoje ryby zawsze pachną tak… interesująco?" },
	"cust_33": { "de": "Mein letzter Fischer ist verschwunden. Lange Geschichte.", "en": "My last fisherman disappeared. Long story.", "ru": "Мой прошлый рыбак исчез. Долгая история.", "tr": "Önceki balıkçım kayboldu. Uzun hikâye.", "es": "Mi anterior pescador desapareció. Es una larga historia.", "fr": "Mon dernier pêcheur a disparu. Une longue histoire.", "pl": "Mój poprzedni rybak zniknął. Długa historia." },
	"cust_34": { "de": "Wenn der Preis stimmt, stelle ich keine Fragen.", "en": "If the price is right, I won't ask questions.", "ru": "Если цена устроит, лишних вопросов не задам.", "tr": "Fiyat uygunsa soru sormam.", "es": "Si el precio es bueno, no haré preguntas.", "fr": "Si le prix me convient, je ne poserai pas de questions.", "pl": "Jeśli cena będzie dobra, nie będę zadawać pytań." },
	"cust_35": { "de": "Du siehst aus wie jemand, der weiß, wo die guten Fische sind.", "en": "You look like someone who knows where the good fish are.", "ru": "Похоже, ты знаешь, где водится хорошая рыба.", "tr": "İyi balıkların nerede olduğunu bilen birine benziyorsun.", "es": "Tienes pinta de saber dónde está el buen pescado.", "fr": "Tu as l'air de savoir où trouver les bons poissons.", "pl": "Wyglądasz na kogoś, kto wie, gdzie są dobre ryby." },
	
	# Story/Lore Hints
	"cust_36": { "de": "Der alte Leuchtturm wird nachts wieder aktiv.", "en": "The old lighthouse is active again at night.", "ru": "Старый маяк снова работает по ночам.", "tr": "Eski deniz feneri geceleri yine çalışıyor.", "es": "El viejo faro vuelve a funcionar de noche.", "fr": "Le vieux phare se rallume la nuit.", "pl": "Stara latarnia znów świeci nocą." },
	"cust_37": { "de": "Jemand hat die verbotene Zone betreten. Dumme Idee.", "en": "Someone entered the forbidden zone. Bad idea.", "ru": "Кто-то вошёл в запретную зону. Плохая идея.", "tr": "Biri yasak bölgeye girmiş. Kötü fikir.", "es": "Alguien entró en la zona prohibida. Mala idea.", "fr": "Quelqu'un est entré dans la zone interdite. Mauvaise idée.", "pl": "Ktoś wszedł do zakazanej strefy. Zły pomysł." },
	"cust_38": { "de": "Die Regierung verheimlicht etwas über den See.", "en": "The government is hiding something about the lake.", "ru": "Правительство что-то скрывает об озере.", "tr": "Hükûmet göl hakkında bir şeyler saklıyor.", "es": "El gobierno oculta algo sobre el lago.", "fr": "Le gouvernement cache quelque chose au sujet du lac.", "pl": "Rząd ukrywa coś w sprawie jeziora." },
	"cust_39": { "de": "Ein Fischer hat ein Artefakt gefunden. Er verkauft es nicht.", "en": "A fisherman found an artifact. He won't sell it.", "ru": "Рыбак нашёл артефакт. Продавать не хочет.", "tr": "Bir balıkçı eser bulmuş. Satmıyor.", "es": "Un pescador encontró un artefacto. No quiere venderlo.", "fr": "Un pêcheur a trouvé un artefact. Il refuse de le vendre.", "pl": "Rybak znalazł artefakt. Nie chce go sprzedać." },
	"cust_40": { "de": "Hörst du auch manchmal… Stimmen aus dem Wasser?", "en": "Do you also sometimes hear… voices from the water?", "ru": "Ты тоже иногда слышишь… голоса из воды?", "tr": "Sen de bazen sudan gelen… sesler duyuyor musun?", "es": "¿También oyes a veces… voces que vienen del agua?", "fr": "Toi aussi, tu entends parfois… des voix venant de l'eau ?", "pl": "Też czasami słyszysz… głosy z wody?" },
	
	# Wiederholungskunden
	"cust_41": { "de": "Ich bin wieder da! Der letzte Fisch war perfekt.", "en": "I'm back! The last fish was perfect.", "ru": "Я вернулся! Прошлая рыба была отличной.", "tr": "Yine geldim! Son balık mükemmeldi.", "es": "¡He vuelto! El último pescado estaba perfecto.", "fr": "Me revoilà ! Le dernier poisson était parfait.", "pl": "Wróciłem! Ostatnia ryba była idealna." },
	"cust_42": { "de": "Du hast mich überzeugt. Was gibt's Neues?", "en": "You convinced me. What's new?", "ru": "Ты меня убедил. Что нового?", "tr": "Beni ikna ettin. Yeni ne var?", "es": "Me has convencido. ¿Qué hay de nuevo?", "fr": "Tu m'as convaincu. Quoi de neuf ?", "pl": "Przekonałeś mnie. Co nowego?" },
	"cust_43": { "de": "Ich vertraue nur dir. Die anderen sind Betrüger.", "en": "I only trust you. The others are frauds.", "ru": "Доверяю только тебе. Остальные — мошенники.", "tr": "Sadece sana güveniyorum. Diğerleri dolandırıcı.", "es": "Solo confío en ti. Los demás son unos estafadores.", "fr": "Je ne fais confiance qu'à toi. Les autres sont des escrocs.", "pl": "Ufam tylko tobie. Reszta to oszuści." },
	"cust_44": { "de": "Solange du lieferst, bleibe ich Kunde.", "en": "As long as you deliver, I'll stay a customer.", "ru": "Пока поставляешь рыбу, я твой клиент.", "tr": "Sen malı getirdikçe müşterin olmaya devam ederim.", "es": "Mientras cumplas, seguiré siendo tu cliente.", "fr": "Tant que tu assures, je reste client.", "pl": "Dopóki dostarczasz towar, zostaję klientem." },
	"cust_45": { "de": "Deine Preise sind fair. Das schätze ich.", "en": "Your prices are fair. I appreciate that.", "ru": "Цены честные. Я это ценю.", "tr": "Fiyatların adil. Bunu takdir ediyorum.", "es": "Tus precios son justos. Lo agradezco.", "fr": "Tes prix sont honnêtes. J'apprécie.", "pl": "Masz uczciwe ceny. Doceniam to." }
}

@export var change_interval := 5.0    # Zeit zwischen Textwechseln
@export var typewriter_speed := 0.03  # Zeit pro Zeichen

# ------------------------------
#   NODE REFERENCES
# ------------------------------
@onready var dialog_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/RichTextLabel
@onready var panel: Panel = $Panel

# ------------------------------
#   INTERNAL VARIABLES
# ------------------------------
var timer := 0.0
var typing := false
var current_text := ""
var current_dialog_key := ""  # 🌍 NEU - Speichert den Dialog-Key
var _type_text := ""
var _type_index := 0



func _ready() -> void:
	add_child(type_timer)
	type_timer.one_shot = false
	type_timer.timeout.connect(_on_type_timer_timeout)
	_show_new_random_dialog()



func _process(delta: float) -> void:
	if typing:
		return



# ---------------------------------------------------------------
#  RANDOM DIALOG + TYPEWRITER START (🌍 LOCALIZED)
# ---------------------------------------------------------------
func _show_new_random_dialog():
	if dialog_lines.is_empty():
		return

	# Wähle zufälligen Dialog-Key (Array aus Keys erstellen)
	var keys = dialog_lines.keys()
	current_dialog_key = keys[randi() % keys.size()]
	
	# 🌍 Hole Text in aktueller Sprache
	current_text = _get_localized_text(current_dialog_key)
	
	timer = change_interval
	_start_typewriter(current_text)


# ---------------------------------------------------------------
#  🌍 GET LOCALIZED TEXT
# ---------------------------------------------------------------
func _get_localized_text(dialog_key: String) -> String:
	var dialog_entry = dialog_lines.get(dialog_key, {})
	
	# Hole aktuelle Sprache aus Player (oder TranslationServer)
	var current_language = Player.current_language
	
	# Fallback: Wenn Sprache nicht gefunden, nutze Deutsch
	if dialog_entry.has(current_language):
		return dialog_entry[current_language]
	elif dialog_entry.has("de"):
		return dialog_entry["de"]
	else:
		return "???"


# ---------------------------------------------------------------
#  TYPEWRITER EFFECT
# ---------------------------------------------------------------
func _start_typewriter(text: String) -> void:
	typing = true
	dialog_label.text = ""
	var char_index := 0
	
	while char_index <= text.length():
		# ✅ Prüfe ob Node noch im Tree ist
		if not is_inside_tree() or not typing:
			typing = false
			return
		
		dialog_label.text = text.substr(0, char_index)
		await get_tree().process_frame
		_update_panel_size()
		char_index += 1
		
		# ✅ Nochmal prüfen vor Timer-Erstellung
		if not is_inside_tree():
			typing = false
			return
			
		await get_tree().create_timer(typewriter_speed).timeout

	typing = false



# ---------------------------------------------------------------
#  PANEL HEIGHT AUTO FIT
# ---------------------------------------------------------------
func _update_panel_size() -> void:
	var needed_height := dialog_label.get_content_height()
	panel.custom_minimum_size.y = needed_height + 60  # etwas Padding
	
func _on_type_timer_timeout() -> void:
	# Node wurde entfernt → sofort abbrechen
	if not is_inside_tree():
		type_timer.stop()
		return

	if not typing:
		type_timer.stop()
		return

	if _type_index >= _type_text.length():
		type_timer.stop()
		typing = false
		return

	_type_index += 1
	dialog_label.text = _type_text.substr(0, _type_index)
	_update_panel_size()
