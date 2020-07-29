
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                               Lira NPC Script                           ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local LiraNPC = 9915956
local LiraCoords = {
{7860, -2583, 487, 0.39},
{7884, -2520, 487, 5.3},
{7923.6, -2609.6, 486, 4},
{8001, -2544, 490.5, 2.5},
{7928, -2423, 494.2, 2.32},
}
local LiraPhrases = {
"Ты - маг? Нет? Тогда пока.",
"Мне пора...",
"Я не для Вас здесь прячусь.",
"Эй!",
}
local RandomMath

local LiraTeleportPoint = 1
local function LiraCastSpell(event, player, creature)
  if math.random(10) > 6 then
    creature:SendUnitSay(LiraPhrases[math.random(#LiraPhrases)], 0 )
  end
  creature:CastSpell( creature, 7077, false );
end

local function LiraRandomTeleport(event, player, creature, caster, spellid)
  RandomMath = math.random(#LiraCoords);
  if LiraTeleportPoint == RandomMath then
    while LiraTeleportPoint == RandomMath do
        RandomMath = math.random(#LiraCoords);
    end
  end
  LiraTeleportPoint = RandomMath
  creature:NearTeleport( LiraCoords[RandomMath][1], LiraCoords[RandomMath][2], LiraCoords[RandomMath][3], LiraCoords[RandomMath][4] )
  creature:Emote( 45 )
  creature:EmoteState( 45 )
end
RegisterCreatureGossipEvent(LiraNPC, 1, LiraCastSpell)
RegisterCreatureEvent(LiraNPC, 14, LiraRandomTeleport)


--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                               FG NPC Script                             ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local FG_NPC = 9921831
local FG_TelegaEntry = 5047180
local FG_cooldown = {
["Time"] = 20,
["LastClick"] = 0,
}
local FG_Phrases = {
"Я же сказал: 4 за штуку. Ни больше, ни меньше. Нет, погоди, можно больше.",
"Уговорил, чертяка. Уступлю за 3,99!",
"Не ведись на спекулянтов. Монеты ровно по 4.",
"У меня стабильный курс в любую погоду.",
"Клавдии кончились? Клавдии кончились для ТЕБЯ.",
"Позволь задать тебе вопрос. Когда ты подходил ко мне, ты видел у меня перед телегой знак «Склад халявных клавдиев»?",
}

local FG_PhrasesTelega = {
"Эй! Телегу не трогай.",
"Я серьезно. Телегу лучше не трогать. Я ее занял у одной бойкой дамы и если на ней останется хоть царапина - я тебя найду.",
"Моя телега, ставлю где хочу. Законом не запрещено.",
"Телега неплохая, но запашок от нее - будь здоров. Что в ней только возили?",
"Эта телега пол мира объездила, так что я попрошу! Аккуратнее с антиквариатом.",
}
function FG_NPCSay(event, player, creature)
if (os.time() - FG_cooldown["LastClick"]) < FG_cooldown["Time"] then return end
    creature:SendUnitSay(FG_Phrases[math.random(#FG_Phrases)], 0 )
    FG_cooldown["LastClick"] = os.time()
end
RegisterCreatureGossipEvent(FG_NPC, 1, FG_NPCSay)

function FG_Telega(event, go, player)
if (os.time() - FG_cooldown["LastClick"]) < FG_cooldown["Time"] then return end
        go:GetNearestCreature( 10, FG_NPC ):SendUnitSay(FG_PhrasesTelega[math.random(#FG_PhrasesTelega)], 0 )
        FG_cooldown["LastClick"] = os.time()
end

RegisterGameObjectEvent(FG_TelegaEntry, 14, FG_Telega)
