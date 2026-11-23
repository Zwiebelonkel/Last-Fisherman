extends Control

@onready var type_timer: Timer = Timer.new()


# ------------------------------
#   EXPORT VARIABLES
# ------------------------------
@export var dialog_lines := {
	"dlg_01": { "de": "Ich habe das Gefühl, dass heute etwas Großes anbeißt.", "en": "I have a feeling something big will bite today.", "ru": "Чувствую, сегодня клюнет что-то крупное.", "tr": "Bugün büyük bir şeyin oltaya takılacağını hissediyorum.", "es": "Presiento que hoy picará algo grande.", "fr": "Je sens que quelque chose de gros va mordre aujourd'hui.", "pl": "Czuję, że dziś weźmie coś dużego." },
	"dlg_02": { "de": "Wenn du pleite bist, tu zumindest so als wärst du reich.", "en": "If you're broke, at least pretend you're rich.", "ru": "Если ты на мели, хотя бы притворись богатым.", "tr": "Beş parasızsan en azından zenginmiş gibi yap.", "es": "Si estás sin blanca, al menos finge que eres rico.", "fr": "Si tu es fauché, fais au moins semblant d'être riche.", "pl": "Jeśli jesteś spłukany, przynajmniej udawaj bogatego." },
	"dlg_03": { "de": "Manche Fische verkaufen sich besser als deine Zukunft.", "en": "Some fish sell better than your future.", "ru": "Некоторые рыбы продаются лучше твоего будущего.", "tr": "Bazı balıklar senin geleceğinden daha iyi satılıyor.", "es": "Algunos peces se venden mejor que tu futuro.", "fr": "Certains poissons se vendent mieux que ton avenir.", "pl": "Niektóre ryby sprzedają się lepiej niż twoja przyszłość." },
	"dlg_04": { "de": "Ich würde selbst angeln, aber ich habe Rücken… und Stolz.", "en": "I'd fish myself, but I have a bad back… and pride.", "ru": "Я бы сам рыбачил, но у меня спина… и гордость.", "tr": "Kendim tutardım ama sırtım kötü… bir de gururum var.", "es": "Yo pescaría, pero tengo la espalda mal… y orgullo.", "fr": "Je pêcherais bien moi-même, mais j'ai mal au dos… et ma fierté.", "pl": "Sam bym łowił, ale mam chory kręgosłup… i dumę." },
	"dlg_05": { "de": "Die Stadt stinkt, aber das Geld hier riecht fantastisch.", "en": "The city stinks, but the money here smells fantastic.", "ru": "Город воняет, зато деньги здесь пахнут чудесно.", "tr": "Şehir leş gibi ama buradaki para harika kokuyor.", "es": "La ciudad apesta, pero el dinero aquí huele de maravilla.", "fr": "La ville pue, mais l'argent sent bon ici.", "pl": "Miasto śmierdzi, ale pieniądze pachną tu fantastycznie." },
	"dlg_06": { "de": "Köder sind wie Beziehungen: Je teurer, desto besser.", "en": "Bait is like relationships: the more expensive, the better.", "ru": "Наживка как отношения: чем дороже, тем лучше.", "tr": "Yem ilişkiler gibidir: Ne kadar pahalıysa o kadar iyi.", "es": "El cebo es como las relaciones: cuanto más caro, mejor.", "fr": "Les appâts, c'est comme les relations : plus c'est cher, mieux c'est.", "pl": "Przynęta jest jak związek: im droższa, tym lepsza." },
	"dlg_07": { "de": "Pass auf deine Finger auf, ein Fisch hat sie schon vermisst.", "en": "Watch your fingers, a fish already misses them.", "ru": "Береги пальцы, одна рыба уже по ним скучает.", "tr": "Parmaklarına dikkat et, bir balık onları şimdiden özlüyor.", "es": "Cuida tus dedos, un pez ya los echa de menos.", "fr": "Attention à tes doigts, un poisson les regrette déjà.", "pl": "Uważaj na palce, jakaś ryba już za nimi tęskni." },
	"dlg_08": { "de": "Wenn du das kaufst, tu so als wär es kein Fehlkauf.", "en": "If you buy this, pretend it wasn't a bad decision.", "ru": "Купишь — делай вид, что покупка удачная.", "tr": "Bunu alırsan kötü bir karar değilmiş gibi yap.", "es": "Si lo compras, finge que no fue una mala decisión.", "fr": "Si tu achètes ça, fais comme si ce n'était pas une mauvaise décision.", "pl": "Jeśli to kupisz, udawaj, że to nie była zła decyzja." },
	"dlg_09": { "de": "Ich habe gehört, im Wald verschwinden gerade Leute.", "en": "I heard people have been disappearing in the forest.", "ru": "Слышал, в лесу начали пропадать люди.", "tr": "Ormanda insanların kaybolduğunu duydum.", "es": "He oído que está desapareciendo gente en el bosque.", "fr": "J'ai entendu dire que des gens disparaissent dans la forêt.", "pl": "Słyszałem, że w lesie znikają ludzie." },
	"dlg_10": { "de": "Die Wüste brennt, aber mein Angebot ist eiskalt billig.", "en": "The desert burns, but my offer is ice-cold cheap.", "ru": "Пустыня пылает, а мои цены ледяные.", "tr": "Çöl yanıyor ama teklifim buz gibi ucuz.", "es": "El desierto arde, pero mis precios te dejarán helado.", "fr": "Le désert brûle, mais mes prix te laisseront de glace.", "pl": "Pustynia płonie, ale moje ceny są lodowato niskie." },

	"dlg_11": { "de": "Wenn du mich anlächelst, mache ich den Preis nicht günstiger.", "en": "If you smile at me, I still won't lower the price.", "ru": "Улыбайся сколько хочешь — цену не снижу.", "tr": "Bana gülümsesen de fiyatı düşürmem.", "es": "Aunque me sonrías, no bajaré el precio.", "fr": "Même si tu me souris, je ne baisserai pas le prix.", "pl": "Nawet jeśli się do mnie uśmiechniesz, nie obniżę ceny." },
	"dlg_12": { "de": "Fische lügen nicht. Menschen schon. Rate, wer mehr kauft.", "en": "Fish don't lie. People do. Guess who buys more.", "ru": "Рыбы не лгут. Люди — да. Угадай, кто больше покупает.", "tr": "Balıklar yalan söylemez. İnsanlar söyler. Bil bakalım kim daha çok alıyor.", "es": "Los peces no mienten. Las personas sí. Adivina quién compra más.", "fr": "Les poissons ne mentent pas. Les gens, si. Devine qui achète le plus.", "pl": "Ryby nie kłamią. Ludzie tak. Zgadnij, kto więcej kupuje." },
	"dlg_13": { "de": "Ich habe ein gutes Gefühl bei deinem nächsten Fang.", "en": "I have a good feeling about your next catch.", "ru": "Чувствую, следующий улов тебя порадует.", "tr": "Bir sonraki avın için içimde iyi bir his var.", "es": "Tengo un buen presentimiento sobre tu próxima captura.", "fr": "J'ai un bon pressentiment pour ta prochaine prise.", "pl": "Mam dobre przeczucie co do twojego następnego połowu." },
	"dlg_14": { "de": "Wenn du zu viel fragst, erhöhe ich die Preise sofort.", "en": "Ask too many questions and I raise the prices instantly.", "ru": "Будешь много спрашивать — сразу подниму цены.", "tr": "Çok soru sorarsan fiyatları anında artırırım.", "es": "Haz demasiadas preguntas y subiré los precios al instante.", "fr": "Pose trop de questions et j'augmente les prix sur-le-champ.", "pl": "Zadasz za dużo pytań, a natychmiast podniosę ceny." },
	"dlg_15": { "de": "Ich hatte heute schon drei Kunden. Zwei waren tot.", "en": "I've already had three customers today. Two were dead.", "ru": "Сегодня было уже три клиента. Двое мертвы.", "tr": "Bugün üç müşterim oldu bile. İkisi ölüydü.", "es": "Hoy ya he tenido tres clientes. Dos estaban muertos.", "fr": "J'ai déjà eu trois clients aujourd'hui. Deux étaient morts.", "pl": "Miałem już dziś trzech klientów. Dwóch było martwych." },
	"dlg_16": { "de": "Man sagt, ein alter Geist beobachtet jeden deiner Käufe.", "en": "They say an old spirit watches every purchase you make.", "ru": "Говорят, древний дух следит за каждой твоей покупкой.", "tr": "Kadim bir ruhun her alışverişini izlediği söyleniyor.", "es": "Dicen que un viejo espíritu observa cada compra que haces.", "fr": "On dit qu'un vieil esprit observe chacun de tes achats.", "pl": "Podobno stary duch obserwuje każdy twój zakup." },
	"dlg_17": { "de": "Der letzte Kunde wollte Rabatt. Er ist jetzt verschwunden.", "en": "The last customer asked for a discount. He's gone now.", "ru": "Последний клиент просил скидку. Теперь он исчез.", "tr": "Son müşteri indirim istedi. Artık ortada yok.", "es": "El último cliente pidió un descuento. Ahora ha desaparecido.", "fr": "Le dernier client a demandé une réduction. Il a disparu depuis.", "pl": "Ostatni klient poprosił o rabat. Teraz zniknął." },
	"dlg_18": { "de": "Willkommen zurück! Ich wusste, du kommst wieder… irgendwann.", "en": "Welcome back! I knew you'd return… eventually.", "ru": "С возвращением! Знал, что вернёшься… когда-нибудь.", "tr": "Tekrar hoş geldin! Döneceğini biliyordum… eninde sonunda.", "es": "¡Bienvenido de nuevo! Sabía que volverías… tarde o temprano.", "fr": "Te revoilà ! Je savais que tu reviendrais… un jour.", "pl": "Witaj ponownie! Wiedziałem, że wrócisz… kiedyś." },
	"dlg_19": { "de": "Wenn du seltene Fische willst, hör auf schwach zu sein.", "en": "If you want rare fish, stop being weak.", "ru": "Хочешь редких рыб — перестань быть слабаком.", "tr": "Nadir balık istiyorsan güçsüz olmayı bırak.", "es": "Si quieres peces raros, deja de ser débil.", "fr": "Si tu veux des poissons rares, arrête d'être faible.", "pl": "Jeśli chcesz rzadkich ryb, przestań być słaby." },
	"dlg_20": { "de": "Je besser der Köder, desto weniger musst du weinen.", "en": "The better the bait, the less you'll cry.", "ru": "Чем лучше наживка, тем меньше слёз.", "tr": "Yem ne kadar iyiyse o kadar az ağlarsın.", "es": "Cuanto mejor sea el cebo, menos llorarás.", "fr": "Plus l'appât est bon, moins tu pleureras.", "pl": "Im lepsza przynęta, tym mniej będziesz płakać." },

	"dlg_21": { "de": "Ich verkaufe nur Qualität. Oder Müll. Schwer zu unterscheiden.", "en": "I sell only quality. Or trash. Hard to tell.", "ru": "Продаю только качество. Или хлам. Трудно отличить.", "tr": "Sadece kalite satarım. Ya da çöp. Ayırt etmek zor.", "es": "Solo vendo calidad. O basura. Cuesta distinguirlo.", "fr": "Je ne vends que de la qualité. Ou des déchets. Difficile à dire.", "pl": "Sprzedaję tylko jakość. Albo śmieci. Trudno odróżnić." },
	"dlg_22": { "de": "Fische aus der Kanalisation? Ja, die leben wirklich noch.", "en": "Fish from the sewers? Yes, they're actually still alive.", "ru": "Рыба из канализации? Да, ещё живая.", "tr": "Kanalizasyondan balık mı? Evet, gerçekten hâlâ canlılar.", "es": "¿Peces de alcantarilla? Sí, de verdad siguen vivos.", "fr": "Des poissons des égouts ? Oui, ils sont vraiment encore vivants.", "pl": "Ryby z kanałów? Tak, naprawdę jeszcze żyją." },
	"dlg_23": { "de": "Die alten Artefakte machen mir ein bisschen Angst.", "en": "The ancient artifacts scare me a little.", "ru": "Древние артефакты меня немного пугают.", "tr": "Kadim eserler beni biraz korkutuyor.", "es": "Los artefactos antiguos me dan un poco de miedo.", "fr": "Les artefacts anciens me font un peu peur.", "pl": "Pradawne artefakty trochę mnie przerażają." },
	"dlg_24": { "de": "Ich bete, dass du mehr kaufst. Für dich. Und für mich.", "en": "I pray you buy more. For you. And for me.", "ru": "Молюсь, чтобы ты купил побольше. Ради тебя. И меня.", "tr": "Daha çok alman için dua ediyorum. Senin için. Benim için de.", "es": "Rezo para que compres más. Por ti. Y por mí.", "fr": "Je prie pour que tu achètes davantage. Pour toi. Et pour moi.", "pl": "Modlę się, żebyś kupował więcej. Dla ciebie. I dla mnie." },
	"dlg_25": { "de": "Ein Blick in dein Inventar lässt mich immer schmunzeln.", "en": "One look at your inventory always makes me smile.", "ru": "Один взгляд в твой инвентарь — и я уже улыбаюсь.", "tr": "Envanterine bir bakış beni hep gülümsetir.", "es": "Una mirada a tu inventario siempre me hace sonreír.", "fr": "Un coup d'œil à ton inventaire me fait toujours sourire.", "pl": "Jeden rzut oka na twój ekwipunek zawsze mnie rozśmiesza." },
	"dlg_26": { "de": "Wenn du sparen willst, geh angeln. Wenn du gewinnen willst, kauf.", "en": "If you want to save money, go fishing. If you want to win, buy.", "ru": "Хочешь сэкономить — рыбачь. Хочешь выиграть — покупай.", "tr": "Tasarruf istiyorsan balık tut. Kazanmak istiyorsan satın al.", "es": "Si quieres ahorrar, pesca. Si quieres ganar, compra.", "fr": "Pour économiser, va pêcher. Pour gagner, achète.", "pl": "Jeśli chcesz oszczędzać, idź na ryby. Jeśli chcesz wygrywać, kupuj." },
	"dlg_27": { "de": "Ich hatte mal Träume. Dann wurde ich Shopkeeper.", "en": "I used to have dreams. Then I became a shopkeeper.", "ru": "У меня когда-то были мечты. Потом стал торговцем.", "tr": "Eskiden hayallerim vardı. Sonra dükkâncı oldum.", "es": "Antes tenía sueños. Luego me hice tendero.", "fr": "Autrefois, j'avais des rêves. Puis je suis devenu marchand.", "pl": "Kiedyś miałem marzenia. Potem zostałem sklepikarzem." },
	"dlg_28": { "de": "Falls du schreist, hören die Fische dich lachen.", "en": "If you scream, the fish will hear you laughing.", "ru": "Если закричишь, рыбы услышат твой смех.", "tr": "Çığlık atarsan balıklar gülüşünü duyar.", "es": "Si gritas, los peces te oirán reír.", "fr": "Si tu cries, les poissons t'entendront rire.", "pl": "Jeśli krzykniesz, ryby usłyszą twój śmiech." },
	"dlg_29": { "de": "Es gibt Gerüchte über ein neues Biom im Norden.", "en": "There are rumors about a new biome in the north.", "ru": "Ходят слухи о новом биоме на севере.", "tr": "Kuzeyde yeni bir biyom olduğu söyleniyor.", "es": "Hay rumores de un nuevo bioma al norte.", "fr": "On parle d'un nouveau biome au nord.", "pl": "Krążą plotki o nowym biomie na północy." },
	"dlg_30": { "de": "Du siehst motiviert aus! Oder müde. Schwer zu sagen.", "en": "You look motivated! Or tired. Hard to tell.", "ru": "Выглядишь полным сил! Или уставшим. Не разберёшь.", "tr": "Hevesli görünüyorsun! Ya da yorgun. Anlamak zor.", "es": "¡Pareces motivado! O cansado. Cuesta saberlo.", "fr": "Tu as l'air motivé ! Ou fatigué. Difficile à dire.", "pl": "Wyglądasz na zmotywowanego! Albo zmęczonego. Trudno powiedzieć." },

	"dlg_31": { "de": "Ich habe die Preise gesenkt. Also eigentlich nicht.", "en": "I lowered the prices. Well, not really.", "ru": "Я снизил цены. Ну, вообще-то нет.", "tr": "Fiyatları düşürdüm. Yani, aslında hayır.", "es": "He bajado los precios. Bueno, en realidad no.", "fr": "J'ai baissé les prix. Enfin, pas vraiment.", "pl": "Obniżyłem ceny. No, właściwie to nie." },
	"dlg_32": { "de": "Seltene Fische mögen dich. Aus irgendeinem Grund.", "en": "Rare fish seem to like you. For some reason.", "ru": "Редкие рыбы тебя любят. Почему-то.", "tr": "Nadir balıklar seni seviyor gibi. Nedense.", "es": "Parece que gustas a los peces raros. Por algún motivo.", "fr": "Les poissons rares semblent t'aimer. Pour une raison inconnue.", "pl": "Rzadkie ryby chyba cię lubią. Z jakiegoś powodu." },
	"dlg_33": { "de": "Wenn du ein Geräusch hörst, ignoriere es einfach.", "en": "If you hear a noise, just ignore it.", "ru": "Услышишь шум — просто не обращай внимания.", "tr": "Bir ses duyarsan görmezden gel.", "es": "Si oyes un ruido, ignóralo.", "fr": "Si tu entends un bruit, ignore-le.", "pl": "Jeśli usłyszysz hałas, po prostu go zignoruj." },
	"dlg_34": { "de": "Die Legenden sagen: 'Mehr Köder, mehr Glück'.", "en": "The legends say: 'More bait, more luck'.", "ru": "Легенды гласят: «Больше наживки — больше удачи».", "tr": "Efsaneler der ki: Daha çok yem, daha çok şans.", "es": "Las leyendas dicen: «Más cebo, más suerte».", "fr": "Les légendes disent : « Plus d'appâts, plus de chance ».", "pl": "Legendy mówią: „Więcej przynęty, więcej szczęścia”." },
	"dlg_35": { "de": "Ich würde dir helfen, aber dann wäre ich arbeitslos.", "en": "I'd help you, but then I'd be unemployed.", "ru": "Я бы помог, но тогда остался бы без работы.", "tr": "Sana yardım ederdim ama o zaman işsiz kalırdım.", "es": "Te ayudaría, pero entonces me quedaría sin trabajo.", "fr": "Je t'aiderais, mais je me retrouverais au chômage.", "pl": "Pomógłbym ci, ale wtedy byłbym bezrobotny." },
	"dlg_36": { "de": "Fang du die Fische, ich nehme das Geld. Gute Aufteilung.", "en": "You catch the fish, I take the money. Fair deal.", "ru": "Ты ловишь рыбу, я забираю деньги. Честная сделка.", "tr": "Sen balıkları yakala, parayı ben alayım. Adil anlaşma.", "es": "Tú pescas, yo me llevo el dinero. Un trato justo.", "fr": "Tu attrapes les poissons, je prends l'argent. Marché équitable.", "pl": "Ty łowisz ryby, ja biorę pieniądze. Uczciwy układ." },
	"dlg_37": { "de": "Ich habe heute ein seltsames Leuchten am See gesehen.", "en": "I saw a strange glow at the lake today.", "ru": "Сегодня видел странное свечение у озера.", "tr": "Bugün gölde garip bir parıltı gördüm.", "es": "Hoy he visto un extraño resplandor en el lago.", "fr": "J'ai vu une étrange lueur au lac aujourd'hui.", "pl": "Widziałem dziś dziwny blask nad jeziorem." },
	"dlg_38": { "de": "Pass auf, manche Köder ziehen… Dinge an. Nicht nur Fische.", "en": "Careful, some bait attracts… things. Not just fish.", "ru": "Осторожно, некоторые наживки привлекают… кое-что. Не только рыб.", "tr": "Dikkat, bazı yemler… şeyleri çeker. Sadece balıkları değil.", "es": "Cuidado, algunos cebos atraen… cosas. Además de peces.", "fr": "Attention, certains appâts attirent… des choses. Pas seulement des poissons.", "pl": "Uważaj, niektóre przynęty przyciągają… rzeczy. Nie tylko ryby." },
	"dlg_39": { "de": "Wenn du mutig bist, probier mal den teuren Köder.", "en": "If you're brave, try the expensive bait.", "ru": "Если смелый, попробуй дорогую наживку.", "tr": "Cesursan pahalı yemi dene.", "es": "Si eres valiente, prueba el cebo caro.", "fr": "Si tu es courageux, essaie l'appât le plus cher.", "pl": "Jeśli jesteś odważny, spróbuj drogiej przynęty." },
	"dlg_40": { "de": "Die anderen Händler reden schlecht über dich. Ich nicht.", "en": "The other merchants talk badly about you. Not me.", "ru": "Другие торговцы плохо о тебе говорят. Я — нет.", "tr": "Diğer tüccarlar arkandan kötü konuşuyor. Ben değil.", "es": "Los otros comerciantes hablan mal de ti. Yo no.", "fr": "Les autres marchands disent du mal de toi. Pas moi.", "pl": "Inni handlarze źle o tobie mówią. Ja nie." },
	"dlg_41": { "de": "Ich bin stolz auf dich. Ein bisschen. Nicht übertreiben.", "en": "I'm proud of you. A little. Don't overdo it.", "ru": "Я тобой горжусь. Чуть-чуть. Не зазнавайся.", "tr": "Seninle gurur duyuyorum. Biraz. Abartma.", "es": "Estoy orgulloso de ti. Un poco. No te crezcas.", "fr": "Je suis fier de toi. Un peu. N'en fais pas trop.", "pl": "Jestem z ciebie dumny. Trochę. Nie przesadzaj." },
	"dlg_42": { "de": "Soll ich dir sagen, wie du einen Wall-Sack-Kilt bauen kannst?", "en": "Should i tell you how to create a whale-ballsack-kilt?", "ru": "Рассказать, как сделать килт из китовой мошонки?", "tr": "Balina testis torbasından kilt yapmayı anlatayım mı?", "es": "¿Quieres que te diga cómo hacer un kilt con un escroto de ballena?", "fr": "Tu veux savoir comment faire un kilt en scrotum de baleine ?", "pl": "Mam ci powiedzieć, jak zrobić kilt z moszny wieloryba?" },
	"dlg_43": { "de": "Ich existiere nur in deinem Kopf.", "en": "I am only existing in your head.", "ru": "Я существую только в твоей голове.", "tr": "Sadece senin kafanda varım.", "es": "Solo existo en tu cabeza.", "fr": "Je n'existe que dans ta tête.", "pl": "Istnieję tylko w twojej głowie." },
	"dlg_44": { "de": "Versuch mal 1234 als Code.", "en": "Try 1234 as code.", "ru": "Попробуй код 1234.", "tr": "Kod olarak 1234'ü dene.", "es": "Prueba el código 1234.", "fr": "Essaie le code 1234.", "pl": "Spróbuj kodu 1234." }



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

	timer -= delta
	if timer <= 0:
		_show_new_random_dialog()


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

func _on_Panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:

		if typing:
			typing = false
			type_timer.stop()
			dialog_label.text = current_text
			_update_panel_size()
			return

		_show_new_random_dialog()



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
