local rus = mods.RussianLanguagePack
local RegisterRussianName = rus and rus.RegisterRussianName

if RegisterRussianName then
	if GORGE_EVENT == SPECIAL_EVENTS.WINTERS_FEAST then
		STRINGS.GOATMUM_VICTORY[5] = "Счасливого Зимнего Пира, добрые незнакомцы!"
	end
	STRINGS.CHARACTER_DETAILS.STARTING_ITEMS_TITLE = "Попадает в мир Глодки с"

	STRINGS.ACTIONS.SALT = "Посолить"
	
	STRINGS.GORGE.CHANGABLEFEMUSIC_DISABLED = "Системы смены музыки отключена\n на этом сервере."
	
	STRINGS.GORGE.MMMURDER	= "Ты Убийца!"
	STRINGS.GORGE.MMINNOCENT	= "Ты невинный!"
	STRINGS.GORGE.MMACTIONS = {
		REGORGEMURDER = "Убить",
		REGORGEREPORT = "Сообщить о мёртвом теле",
	}
	STRINGS.GORGE.MMVOTING = {
		VOTE = "Проголосовать",
		TITLE = "Кто Убийца?",
		SKIPVOTE = "Пропустить",
		CLOSE = "Вернуться к обсуждению",
		SKIPPEDVOTES = "Пропущенные голоса: ",
		VOTES = "Голоса: "
	}

	STRINGS.GORGE.CURRENT_GORGE_MUSIC = "Текущая музыка: "
	STRINGS.GORGE.GORGE_MUSIC =
	{
		"Тема The Gorge",
		"Тема The Forge",
		"Тема Winter Feast",
		"Тема Year of Carrat",
		"Тема Rag Time",
		"Тема Don't Starve",
		"Тема Creepy Forest",
		"Тема Wigfrid",
		"Тишина",
	}

	STRINGS.GORGE.POWER_F = "Способность: %d"
	STRINGS.GORGE.POWER = "Способность: "
	STRINGS.GORGE.POWER_DISABLED = "Способности отключены создателем сервера"
	
	STRINGS.GORGE.ACHIEVEMENTS = "Достижения:"

	STRINGS.GORGE.VOTE.CLEARED = "Все голосования отменены."
	STRINGS.GORGE.VOTE.NO_PLAYERS = "Нужно как минимум 3 игрока для создания голосования."
	STRINGS.GORGE.VOTE.PASSED = "Голосование завершено."
	STRINGS.GORGE.VOTE.VOTED = "Игрок %s проголосовал за кик игрока %s. (%i/%i)"
	STRINGS.GORGE.VOTE.MODE_VOTED = "Игрок %s проголосовал за смену режима на \"%s\". (%i/%i)"
	STRINGS.GORGE.VOTE.MODE_CHANGED = "Изменяем режим на \"%s\". Увидимся в новом мире!"

	STRINGS.GORGE.VOTE.KICK = "Выгнать"
	STRINGS.GORGE.VOTE.TIP = "Все игроки должны проголосовать чтоб изменить режим"
	STRINGS.GORGE.VOTE.NO_PLAYERS_TIP = "Нужно больше игроков для голосования"

	STRINGS.GORGE.VOTE.DISABLED = "Голосования отключены на этом сервере"

	STRINGS.GORGE.VOTE.GAME_MODE = "Изменить режим"

	STRINGS.GORGE.MESSAGES.VOTE = "[Голосование]"
	STRINGS.GORGE.MESSAGES.ANNOUNCE = "[Оповещение]"

	STRINGS.GORGE.GAMEMODES.NAMES.default = "Классика"
	STRINGS.GORGE.GAMEMODES.NAMES.hungry = "Голодная глотка"
	STRINGS.GORGE.GAMEMODES.NAMES.darkness = "Кромешная тьма"
	STRINGS.GORGE.GAMEMODES.NAMES.hard = "Хардкор"
	STRINGS.GORGE.GAMEMODES.NAMES.scaling = "Растущая сложность"
	STRINGS.GORGE.GAMEMODES.NAMES.endless = "Бесконечное выживание"
	STRINGS.GORGE.GAMEMODES.NAMES.no_sweat = "Без пота"
	STRINGS.GORGE.GAMEMODES.NAMES.thieves = "Теневые воры"
	STRINGS.GORGE.GAMEMODES.NAMES.confusion = "Путаница"
	STRINGS.GORGE.GAMEMODES.NAMES.rush = "Спешка"
	STRINGS.GORGE.GAMEMODES.NAMES.sandbox = "Песочница"
	STRINGS.GORGE.GAMEMODES.NAMES.sick = "Больная Глотка"
	STRINGS.GORGE.GAMEMODES.NAMES.murder_mystery = "Секретный Убийца"
	STRINGS.GORGE.GAMEMODES.NAMES.moon_curse = "Проклятье лунного сияния"
	
	STRINGS.GORGE.GAMEMODES.MORE_PLAYER_REQUIRED = "%s можно играть\n только с %s+ игроками"
	STRINGS.GORGE.GAMEMODES.LESS_PLAYER_REQUIRED = "%s можно играть\nbe только с %s или меньше игроками"
			
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.default = "Попробуй стандарную \"Глотку\"!."
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.hungry = "Глотка стала в 5 раз голоднее!."
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.darkness = "Глотка съела солнце! Готовьте в полной темноте."
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.hard = "Глотка очень зла на вас. Еда готовится дольше, ресурсов меньше, и еще множество неприятностей."
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.scaling = "Чем больше игроков - тем сложнее игра."
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.endless = "Глотка не дает сувениры, но восстанавливает растения и дает торговцам некоторые ингредиенты. Готовьте больше 30 минут чтоб победить!"
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.no_sweat = "Глотка... рада вас видеть? Ее голод замедлен в 2 раза!"
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.thieves = "Тени прокрались в этот мир через портал! Он крадут всю еду, упавшую на землю."
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.confusion = "Глотка поменяла всё местами! Вы перестаёте видеть реальные вещи, всё меняется между собой."
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.rush = "Глотка никогда не будет довольна вашей едой..."
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.sandbox = "Похоже, что глотка вас не замечает. Делайте что хотите!"
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.sick = "Глотка заболела. Каждый ее рык будет сбрасывать на вас сопли."
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.murder_mystery = "Среди вас есть убийца! Будь осторожнее с теми, кто готовит с тобой."
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS.moon_curse = "Глотка видимо съела луну! Глотка излучает лунное сияние..."

	STRINGS.GORGE.CURRENT_MODE = "Режим игры:\n%s"
	STRINGS.GORGE.GAME_MODE_SAME = "Этот режим уже активен"
	STRINGS.GORGE.MODE_INFO = "Режим: %s"
	
	STRINGS.GORGE.IN_DEVELOPMENT = "Мод Re-Gorge-itated: в разработке"

	STRINGS.GORGE.COOLDOWN = "Откат: %s"
	
	STRINGS.GORGE.CHAR_DESC[1] = "*Бегает быстрее всех\n\n\n*Специальность:\nСобиратель"
	STRINGS.GORGE.CHAR_DESC[2] = "*Собирает всё очень быстро\n\n\n*Специальность:\nФермер"
	STRINGS.GORGE.CHAR_DESC[3] = "*Готовит быстрее на казане\n\n\n*Специальность:\nПовар"
	
	STRINGS.GORGE.PERKS.willow[2] = "*Начинает игру с зажигалкой\n*Может готовить на ней еду"
	STRINGS.GORGE.PERKS.wolfgang[2] = "*Может использовать гирю что бы ускорить себя"
	STRINGS.GORGE.PERKS.wendy[2] = "*При сборе гнилого урожая может получить свежий овощ с 25% шансом"
	STRINGS.GORGE.PERKS.wx78[2] = "*Имеет с собой Джимми, который может следить за грядками, солью, блюдами или соком"
	STRINGS.GORGE.PERKS.wathgrithr[2] = "*Может быстро рубить деревья"
	STRINGS.GORGE.PERKS.walter[2] = "*Может купить рогатку и снаряды к ней"
	STRINGS.GORGE.PERKS.webber[2] = "*Имеет маленьких паучков которые помогают ему с садоводством"

	STRINGS.CHARACTERS.GENERIC.DESCRIBE_CONFUSION = {"Ну... Что это?","Эхм... Мне кажется, или оно живое?","Что это?","Это блюдо?"}
	STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.wortox = "*Собирает потерянные души этого мрачного царства\n\n\n*Специальность:\nСобиратель"
	STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.wormwood = "*Растения растут быстрее и гниют медленнее, если он рядом\n\n\n*Специальность:\nФермер"
	STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.warly = "*Готовит быстрее на всей кухонной утвари\n\n\n\n*Специальность:\nПовар"
	STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.wurt = "*Бегает быстрее по болотному дерну\n*Может поймать 2 рыбы\n\n\n*Специальность:\nСобиратель"
	STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.walter = "*Появляется со своей напарницей Уоби\n*Может складировать в неё вещи\n\n\n*Специальность:\nСобиратель"
end
