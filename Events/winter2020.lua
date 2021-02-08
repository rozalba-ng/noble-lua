
--[[	ГОССИП ЗИМНИХ ПИТОМЦЕВ	]]--

local function Gossip_WinterPet( event, player, creature )
	if event == 1 then
		local text = "<Дедушка Зима прислал вам это маленькое существо.>"
		if ( not player:GetData("WinterPet2020") ) or (  ( os.time() - player:GetData("WinterPet2020") ) > 60  ) then
			player:GossipMenuAddItem( 0, "<Использовать безобидную зимнюю магию.>", 1, 1 )
		else
			text = text.."\n\n<Зимняя магия перезаряжается.>"
		end
		player:GossipSetText( text, 30122004 )
		player:GossipSendMenu( 30122004, creature )
	else
		player:GossipComplete()
		player:SetData( "WinterPet2020", os.time() )
		local x,y,z = player:GetLocation()
		player:MoveJump( x, y, z+1, 0.15, 13 )
		player:AddAura( 56137, player )
	end
end
local creatures = { 1000200, 1000201, 1000202 }
for i = 1, #creatures do
	RegisterCreatureGossipEvent( creatures[i], 1, Gossip_WinterPet ) -- GOSSIP_EVENT_ON_HELLO
	RegisterCreatureGossipEvent( creatures[i], 2, Gossip_WinterPet ) -- GOSSIP_EVENT_ON_SELECT
end

--[[	ОГРАНИЧЕНИЕ СТРОИТЕЛЬСТВА	]]--

local function AntiGOB(event, player, item, target)
	local x,y = player:GetX(), player:GetY()
	if ( player:GetMapId() == 1 ) and ( x > 7436 and x < 8003 ) and ( y < -3160 and y > -3354 ) then
        player:SendBroadcastMessage("|cff80d2ff\"Тут и так полная неразбериха. Не думаю, что установить несколько ГОшек здесь - хорошая идея.\"")
        return false
    end
end

local function RegisterEvent_AntiGOB()
	local Q = WorldDBQuery("SELECT entry FROM item_template WHERE entry > 500000 and entry < 600000")
	for i = 1, Q:GetRowCount() do
		local entry = Q:GetInt32(0)
		RegisterItemEvent( entry, 2, AntiGOB )
		Q:NextRow()
	end
end
RegisterServerEvent( 33, RegisterEvent_AntiGOB ) -- ELUNA_EVENT_ON_LUA_STATE_OPEN

--[[	ЮЗАБЕЛЬНЫЙ РОГ	]]--

local entry_horn = 5057395

local function OnUse_Horn( event, player, item )
	player:PlayDirectSound( Roulette(6140, 7234) )
end
RegisterItemEvent( entry_horn, 2, OnUse_Horn ) -- ITEM_EVENT_ON_USE