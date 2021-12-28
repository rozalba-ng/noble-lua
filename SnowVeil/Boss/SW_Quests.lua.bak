local ENGINEER_ENTRY = 987853
local ICE_ITEM_ENTRY = 5061736 
local BRIDGE_TIME = 15*60*1000
local ICE_GOB_ENTRY = 5051949
local ICE_PLATFORM_ENTRY = 5051948
local currentIceCount = 0
local iceBridge = false

local STORY_NPC = 987847 
local STORY_QUEST =  110204  

local GIFTS_ENTRY = {5051941,5051943,5051944,5051945,5051946, 5051947}


local ITEM_QUEST =5061694
local ITEM_BOSS = 5061695

local KID_QUEST_STARTER = 987839 
local KID_QUEST = 110206 
local KID_ENTRY = 987845  
local KID_GIFT_ENTRY =5061737 

local DEER_QUEST_STARTER = 987839 
local DEER_QUEST = 110208 
local DEER_ENTRY = 987846
local DEER_FOOD_ENTRY =5061733 

local SNOWMAN_ITEM_ENTRY = 5061734  
local SNOWMAN_QUEST = 110207 
local SNOWMAN_ENTRY = 13636
local SNOWMAN_QUEST_STARTER = 987839 
local PLATFORMS_COORDS = 
    {   
        {x=-1113,y=-15,z=0,o=0},
        {x=-1118,y=18,z=0,o=0},
        {x=-1115,y=47,z=0,o=0},
        {x=-1107,y=80,z=0,o=0},
        {x=-1114,y=112,z=0,o=0},
        {x=-1125,y=131,z=0,o=0},

    }

local GNOMES = {
    [987848]={entry = 987848, item = 5061729, text = "Составляли список хороших и послушных детей с Дедушкой Зимой. Он попросил меня сходить за горячим какао для него и для меня. Ну я и сбегал, зараза!.. Как вернулся, дак его уже и нет нигде! Так удивился, так удивился, аж кружки выронил! Жаль какао, но больше, конечно, жаль Дедушку Зиму. Куда подевался?!"},
    [987849]={entry = 987849, item = 5061730, text = "Каждое утро я слышу, как Дедушка Зима напевает свою любимую песенку. На втором куплете я обычно успеваю проснуться, умыться и присоединиться к пениям. Но сегодня никакой песенки не было. Потому что Дедушка пропал! А ещё я проспал!! И теперь отстаю от графика! А-А-А!"},
    [987850]={entry = 987850, item = 5061731, text = 'Раз Дедушка Зима пропал, я не знаю, куда отсортировывать письма, адресованные "Дидушке Зыме", "Деду Морозу", "Кланте Саусу" и-и-и... "Самому доброму старичку". Кто все эти люди?!'},
    [987851]={entry = 987851, item = 5061732, text = "Вату в мягкую игрушку. Мягкую игрушку в упаковку. Упаковку в коробку. Коробку под ёлку. Ёлку в дом. Или... Или сначала игрушку в коробку, а коробку в упаковку?! А если уже ёлка стоит в доме?! Да что ж ты будешь делать! Я не могу запомнить последовательность без Дедушки Зимы!"},

}
local GNOME_QUEST = 110205 

local currentPlaytform = 1
local spawnedPlatform = 1
local function RemoveBridges()
    iceBridge = false
end

local function SpawnPlatform(_,_,_,cannonObj)
    local data =PLATFORMS_COORDS[spawnedPlatform]
    cannonObj:SummonGameObject(ICE_PLATFORM_ENTRY,data.x,data.y,data.z,data.o,BRIDGE_TIME/1000)
    spawnedPlatform = spawnedPlatform + 1
end

local function ShootPlatform(_,_,_,cannonObj)
    local data =PLATFORMS_COORDS[currentPlaytform]
    cannonObj:CastSpellAoF(data.x,data.y,data.z,100278,true)
    local dist = cannonObj:GetDistance(data.x,data.y,data.z)
    local flyTime = dist/40
    cannonObj:RegisterEvent(SpawnPlatform,flyTime*250,1)
    currentPlaytform = currentPlaytform + 1
    if currentPlaytform < #PLATFORMS_COORDS then
        cannonObj:RegisterEvent(ShootPlatform,0.5*1000,1)
    end

end

local function Interface_AddIce(player,npc,intid)
    local iceCount = player:GetItemCount(ICE_ITEM_ENTRY)
    currentIceCount = currentIceCount + iceCount
    if currentIceCount > 10 then
        currentIceCount = 0
        iceBridge = true
        CreateLuaEvent(RemoveBridges,BRIDGE_TIME,1)
        npc:RegisterEvent(ShootPlatform,0.5*1000,1)
    end
    player:RemoveItem(ICE_ITEM_ENTRY,iceCount)
end


local function OnEngineerClick(event, player, npc)
    if iceBridge == true then
        return false
    end
	local interace = player:CreateInterface()
    local itemCount = player:GetItemCount(ICE_ITEM_ENTRY)
    if itemCount > 0 then
        interace:AddRow("Передать мана-лед",Interface_AddIce,true)
    end

    interace:AddClose():SetIcon(0)
	interace:Send("Вы слашали про это изобретение в деревне. Его поставили инженеры Сноувейла чтобы добраться до проклятого Анрилча, но использовать его придется вам! Однако... для его зарядки нужен мана-лед",npc)
end
local function OnEngineerSelect(event, player, object, sender, intid, code, menu_id)
	player:CurrentInterface():Click(intid,object,code)
end



local function  Story1Option(player,npc,intid)
    local interace = player:CreateInterface()
    interace:AddClose("Назад"):SetIcon(0)
    interace:Send("Это секретная резиденция Дедушки Зимы. Мы надеялись, что его худший враг последних лет - злобный, коварный Анрилч, не найдёт нас тут, если мы никому не будем рассказывать об этом месте. Но он нашёл и впихнул свой дом за горой.",npc)
    player:SetInfo("NewYear_Story1",tostring(1))
    if player:GetInfo("NewYear_Story4") == "1" and player:GetInfo("NewYear_Story1") == "1" and player:GetInfo("NewYear_Story2") == "1"  and player:GetInfo("NewYear_Story3") == "1" then
        if player:HasQuest(STORY_QUEST) then
            player:CompleteQuest(STORY_QUEST)
        end
    end
end

local function  Story2Option(player,npc,intid)
    local interace = player:CreateInterface()
    interace:AddClose("Назад"):SetIcon(0)
    interace:Send("Странно? Ты с дуба рухнул? Зимний Покров же на носу! Мы просто наряжаемся в традиционный наряд. Половину свитеров вязала моя бабка... ",npc)
    player:SetInfo("NewYear_Story2",tostring(1))
    if player:GetInfo("NewYear_Story4") == "1" and player:GetInfo("NewYear_Story1") == "1" and player:GetInfo("NewYear_Story2") == "1"  and player:GetInfo("NewYear_Story3") == "1" then
        if player:HasQuest(STORY_QUEST) then
            player:CompleteQuest(STORY_QUEST)
        end
    end
end

local function  Story3Option(player,npc,intid)
    local interace = player:CreateInterface()
    interace:AddClose("Назад"):SetIcon(0)
    interace:Send("Площадь! Сейчас там проходит ярмарка, а приезжие уже занимают там дома, украшая и участвуя в конкурсе от нашего бургомистра. А ещё сам дом Дедушки Зимы! За городом есть ещё парочка озёр, но там очень, очень холодно. И зайцы могут отгрызть задницу. Что? Нет, тебе не послышалось. ",npc)
    player:SetInfo("NewYear_Story3",tostring(1))
    if player:GetInfo("NewYear_Story4") == "1" and player:GetInfo("NewYear_Story1") == "1" and player:GetInfo("NewYear_Story2") == "1"  and player:GetInfo("NewYear_Story3") == "1" then
        if player:HasQuest(STORY_QUEST) then
            player:CompleteQuest(STORY_QUEST)
        end
    end
end

local function  Story4Option(player,npc,intid)
    local interace = player:CreateInterface()
    interace:AddClose("Назад"):SetIcon(0)
    interace:Send("О-о-о-о, этот злобный лепрогном не даёт нам жизни! Он пьёт холодный какао, он топит снег, он ломает игрушки на ёлке. Нет, ну ты слышал(а)? Холодный какао!",npc)
    player:SetInfo("NewYear_Story4",tostring(1))
    if player:GetInfo("NewYear_Story4") == "1" and player:GetInfo("NewYear_Story1") == "1" and player:GetInfo("NewYear_Story2") == "1"  and player:GetInfo("NewYear_Story3") == "1" then
        if player:HasQuest(STORY_QUEST) then
            player:CompleteQuest(STORY_QUEST)
        end
    end
end

local function OnStoryClick(event, player, npc)
    local interace = player:CreateInterface()
    interace:AddRow("Почему я не слышал(а) о вас раньше? ",Story1Option,false)
    interace:AddRow("Почему тут все так странно одеты?",Story2Option,false)
    interace:AddRow("Какие места мне стоит посетить в первую очередь?",Story3Option,false)
    interace:AddRow("А что за Анрилч?",Story4Option,false)
    interace:AddClose():SetIcon(0)
    interace:Send("По глазам вижу у тебя много вопросов!",npc)
end
local function OnStorySelect(event, player, object, sender, intid, code, menu_id)
	player:CurrentInterface():Click(intid,object,code)
end

local function OnIceClick(event, player, object)
	object:Despawn()
    player:AddItem(ICE_ITEM_ENTRY,1)
    player:Print("Вы успешно вскапываете мана-лед!")
end





local ITEMS = {
    5061697,5061698,5061699,5061700,5061701,5061702,5061703,5061704,5061705,5061706,5061707,5061708,5061709,5061710,5061711,5061713,5061724,5061725,5061713,5061714,5061726,5061727,5061728
    }
local ITEMS_BOSS = {
    5061714,5061715,5061716,5061714,5061715,5061716,5061717,5061718,5061719,5061720,5061722,5061735,5061721
    }

local function Interface_GiftQuest(player,obj,intid)
    local entry = ITEMS[math.random(1,#ITEMS)]
    local item = player:AddItem(entry)
    if item then
        player:Print("|cffff7588Снежинка падает на поверхность подарка и тот магическим образом сам распутывает банты и обнажает перед вами|r "..item:GetItemLink())
        player:RemoveItem(ITEM_QUEST,1)
        obj:Despawn()
    else
        player:Print("Повторите со свободным местом в инвентаре.")
    end
    
end

local function Interface_GiftBoss(player,obj,intid)
    local entry = ITEMS_BOSS[math.random(1,#ITEMS_BOSS)]
    local item = player:AddItem(entry)
    if item then
        player:Print("|cffff7588Снежинка падает на поверхность подарка и тот магическим образом сам распутывает банты и обнажает перед вами|r "..item:GetItemLink())
        player:RemoveItem(ITEM_BOSS,1)
        obj:Despawn()
    else
        player:Print("Повторите со свободным местом в инвентаре.")
    end
    
end

local function Interface_GiftHand(player,obj,intid)
    player:Print("|cffff7588Ваши ладони тут же примерзают к подарку. Отлепить их получается далеко не сразу... Видимо, подарок надо заслужить.")
end




local function OnGiftClick(event, player, object)
    local interace = player:CreateInterface()
    local hasItem = false
	if player:HasItem(ITEM_QUEST) then
        hasItem = true
        interace:AddRow("Сдуть снежинку на подарок",Interface_GiftQuest,true)
	end
    if player:HasItem(ITEM_BOSS) then
        hasItem = true
        interace:AddRow("Сдуть большую снежинку на подарок",Interface_GiftBoss,true)
    end
	if hasItem == false then
        interace:AddRow("Разорвать обертку",Interface_GiftHand,true)
	end
    interace:AddClose():SetIcon(0)
	interace:Send("Перед вами набитая сделаными жителями Сноувейла подарками коробочка. ",object)
end

local function OnGnomeClick(event, player, gnome)
    if player:HasQuest(GNOME_QUEST) then
        local gnome_entry = gnome:GetEntry()
        local needItem = GNOMES[gnome_entry].item
        local text = GNOMES[gnome_entry].text
        if not player:HasItem(needItem) then
            local item = player:AddItem(needItem)
            if item then
                gnome:SendChatMessageToPlayer(1,0,text,player)
            else
                player:Print("Повторите со свободным местом в инвентаре.")
            end
        end
    end
end





for i, gnomeData in pairs(GNOMES) do
    print('123')
    RegisterCreatureGossipEvent(i,1,OnGnomeClick)
end
local function OnGiftSelect(event, player, object, sender, intid, code, menu_id)
	player:CurrentInterface():Click(intid,object,code)
end

for i,entry in ipairs(GIFTS_ENTRY) do
    RegisterGameObjectGossipEvent(entry,1,OnGiftClick)
    RegisterGameObjectGossipEvent(entry,2,OnGiftSelect)
end
RegisterGameObjectGossipEvent(ICE_GOB_ENTRY,1,OnIceClick)
RegisterCreatureGossipEvent(ENGINEER_ENTRY,2,OnEngineerSelect)
RegisterCreatureGossipEvent(ENGINEER_ENTRY,1,OnEngineerClick)


RegisterCreatureGossipEvent(STORY_NPC,2,OnStorySelect)
RegisterCreatureGossipEvent(STORY_NPC,1,OnStoryClick)


local function OnKidQuestStart(event, player, creature, quest)
    player:SetInfo("NewYear_KidCount",tostring(0))
end


local function OnKidClick(event, player, kid)
    if not player:GetInfo("NewYear_KidCount") then
        player:SetInfo("NewYear_KidCount",tostring(0))
    end
    if player:HasQuest(KID_QUEST) and  not kid:GetData(player:GetName()) and  tonumber(player:GetInfo("NewYear_KidCount")) < 5 then

        
        if player:HasItem(KID_GIFT_ENTRY) then
            kid:SetData(player:GetName(),1)
            player:RemoveItem(KID_GIFT_ENTRY,1)
            local currentKid = tonumber(player:GetInfo("NewYear_KidCount")) + 1
            player:SetInfo("NewYear_KidCount",tostring(currentKid))
            if currentKid == 1 then
                kid:SendUnitSay("Ура! Я уже думал теперь мы останемся без подарков!",0)
            elseif currentKid == 2 then
                kid:SendUnitSay("У тебя конечно не такое большое пузо как Деды Зимы, но тоже ничего, хи-хи.",0)
            elseif currentKid == 3 then
                kid:SendUnitSay("*Визги счастья*",0)
            elseif currentKid == 4 then
                kid:SendUnitSay("Я ДОСТОИН! В ЭТОМ ГОДУ Я ДОСТОИН!! УРА!...",0)
            elseif currentKid == 5 then
                kid:SendUnitSay("Фух.. а я уж думал Деда Зима узнал про мою выходку с соседским котом и что я останусь без подарка... Спасибо! Только не говори ему...",0)
            end
            player:SendAreaTriggerMessage("Раздано подарков "..currentKid.."/5")
            if currentKid == 5 then
                player:CompleteQuest(KID_QUEST)
            end
        end
    end
end



RegisterCreatureGossipEvent(KID_ENTRY,1,OnKidClick)
RegisterCreatureEvent( KID_QUEST_STARTER,31, OnKidQuestStart )






local function OnDeerQuestStart(event, player, creature, quest)
    player:SetInfo("NewYear_deerCount",tostring(0))
end


local function OnDeerClick(event, player, deer)
    if not player:GetInfo("NewYear_deerCount") then
        player:SetInfo("NewYear_deerCount",tostring(0))
    end
    if player:HasQuest(DEER_QUEST) and  not deer:GetData(player:GetName()) and  tonumber(player:GetInfo("NewYear_deerCount")) < 5 then

        if player:HasItem(DEER_FOOD_ENTRY) then
            deer:SetData(player:GetName(),1)
            player:RemoveItem(DEER_FOOD_ENTRY,1)
            local currentdeer = tonumber(player:GetInfo("NewYear_deerCount")) + 1
            player:SetInfo("NewYear_deerCount",tostring(currentdeer))
            player:SendAreaTriggerMessage("Сытых оленей "..currentdeer.."/5")
            if currentdeer == 5 then
                player:CompleteQuest(DEER_QUEST)
            end
        end
    end
end



RegisterCreatureGossipEvent(DEER_ENTRY,1,OnDeerClick)
RegisterCreatureEvent( DEER_QUEST_STARTER,31, OnDeerQuestStart )


local function OnSnowmanComplectUsed(event, player, item, target)
    if not (player:GetMapId() == 9008 and player:GetY()>270 and player:GetY()<680 and player:GetX()>-512 and player:GetX()<-240) then
        player:SendAreaTriggerMessage("Вы должны находится на главной площади")
        return false
    end
    if not player:GetInfo("NewYear_SnowmanCount") then
        player:SetInfo("NewYear_SnowmanCount",tostring(0))
    end
    if player:HasQuest(SNOWMAN_QUEST) and  tonumber(player:GetInfo("NewYear_SnowmanCount")) < 4 then
        local snowman = player:GetNearestCreature(15,SNOWMAN_ENTRY)
        if not snowman then
            local currentsnowman = tonumber(player:GetInfo("NewYear_SnowmanCount")) + 1
            local snowman = player:SpawnCreature(SNOWMAN_ENTRY,player:GetX(),player:GetY(),player:GetZ(),player:GetO(),1,15*60*1000)
            snowman:SetScale(2.5)
            player:RemoveItem(SNOWMAN_ITEM_ENTRY,1)
            player:SetInfo("NewYear_SnowmanCount",tostring(currentsnowman))
            player:SendAreaTriggerMessage("Слеплено снеговиков "..currentsnowman.."/4")
            if currentsnowman == 4 then
                player:CompleteQuest(SNOWMAN_QUEST)
            end
        else
            player:SendAreaTriggerMessage("Рядом уже есть созданный снеговик")
        end
        
        
    else
        return false
    end

end

local function OnSnowmanQuestStart(event, player, creature, quest)
    player:SetInfo("NewYear_SnowmanCount",tostring(0))
end


RegisterItemEvent( SNOWMAN_ITEM_ENTRY, 2, OnSnowmanComplectUsed )
RegisterCreatureEvent( SNOWMAN_QUEST_STARTER,31, OnSnowmanQuestStart )

local function CheckWater(eventid, delay, repeats, player)
    if player:IsInWater() or player:IsUnderWater() then
        player:DealDamage(90)
    end
end
local function OnMapChanged(event, player)
    local oldId = player:GetData("NewYear_WaterCheck")
    if oldId then
        player:RemoveEventById(oldId)
    end
    if player:GetMapId() == 9008 then
        local id = player:RegisterEvent(CheckWater,2*1000,0)
    end
    
end

RegisterPlayerEvent( 28, OnMapChanged )
RegisterPlayerEvent( 3, OnMapChanged )