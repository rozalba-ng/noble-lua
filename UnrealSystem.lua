--	СИСТЕМА АНРИЛА - Хитрый казах попросил сделать ему предмет, с помощью которого игроки смогут передвигаться на ограниченное расстояние.
--	Акостар сделал.

--	Время дающееся на передвижение:
local timetomove = 8000
--	Радиус сферы:
local sphere_radius = 4
--	Айдишники
local entry_item = 2114498
local entry_item_antodias = 5057339
local entry_sphere = 5049273
local entry_spell = 65929 -- Оглушение

local active_players = {}

local function WhenTheMovementOver_Player( _,_,_, player )
	local guidLow = player:GetData("UNREAL_Guid")
	local objects = player:GetGameObjectsInRange( 25, entry_sphere )
	local warn
	if objects then for i = 1, #objects do
		if objects[i]:GetGUIDLow() == guidLow then
			local object = objects[i]
			if player:GetDistance(object) > sphere_radius then
				local x,y,z = object:GetLocation()
				local o = player:GetO()
				player:NearTeleport( x,y,z+0.2,o )
				player:AddAura( entry_spell, player )
				player:SendBroadcastMessage("|cff00b7ff:::|r Вы ушли слишком далеко.")
				warn = true
			end
			object:RemoveFromWorld(true)
			break
		end
	end end
	
	local phase = player:GetPhaseMask() - 2^( 20 + player:GetData("UNREAL_ID") )
	player:SetPhaseMask(phase)
	table.remove(active_players)
	player:SetData( "UNREAL_ID", false )
	
	local group = player:GetGroup()
	local players = group:GetMembers()
	for i = 1, #players do
		if players[i]:GetGMRank() > 0 then
			if warn then players[i]:SendBroadcastMessage("|cff00b7ff:::|r "..players[i]:GetName().." уходит слишком далеко.")
			else players[i]:SendBroadcastMessage("|cff00b7ff:::|r "..player:GetName().." завершает передвижение.") end
		end
	end
end

local function OnUse_Item( event, player, item, target )
	if player:IsInGroup() and not player:GetData("UNREAL_ID") then
		local group = player:GetGroup()
		local players = group:GetMembers()
		local permission = false
		for i = 1, #players do
			if players[i]:GetGMRank() > 0 then
				players[i]:SendBroadcastMessage("|cff00b7ff:::|r "..player:GetName().." использует передвижение.")
				permission = true
			end
		end
		if player:GetPhaseMask() == 8 then permission = true end
		if permission then
			local phase = player:GetPhaseMask()
			table.insert( active_players, player:GetName() )
			player:SetData( "UNREAL_ID", #active_players )
			local newPhase
			if #active_players < 6 then
				newPhase =  2^(20+#active_players)
			else newPhase = 134217728 end
			player:SetPhaseMask( phase+newPhase )
			local x,y,z,o = player:GetLocation()
			local object = PerformIngameSpawn( 2, entry_sphere, player:GetMapId(), 0, x, y, z, o, true, 0 )
			object:SetPhaseMask(newPhase)
			player:SetData( "UNREAL_Guid", object:GetGUIDLow() )
			player:RegisterEvent( WhenTheMovementOver_Player, timetomove, 1 )
			return true
		end
	end
	player:SendBroadcastMessage("|cff00b7ff:::|r Сейчас вы не можете использовать этот предмет.")
	return false
end
RegisterItemEvent( entry_item, 2, OnUse_Item ) -- ITEM_EVENT_ON_USE
RegisterItemEvent( entry_item_antodias, 2, OnUse_Item ) -- ITEM_EVENT_ON_USE

--[[	ТЕХНИЧЕСКАЯ КОМАНДА ДЛЯ АНТОДИАСА, ПОЗВОЛЯЕТ ВЫДАВАТЬ ПРЕДМЕТ ПЕРЕДВИЖЕНИЯ ЛЮДЯМ	]]--

local function OnCommand_Player( _, player, command )
	if ( command == "kirov" ) and ( player:GetGMRank() > 1 or player:GetAccountId() == 5879 ) then
		local target = player:GetSelection()
		if target and target:ToPlayer() then
			if target:HasItem( entry_item_antodias ) then
				target:RemoveItem( entry_item_antodias, 1 )
			end
			target:AddItem( entry_item_antodias )
			player:SendBroadcastMessage("|cff00b7ff:::|r "..target:GetName().." получает предмет для передвижения.")
		else player:SendAreaTriggerMessage("Нет цели.") end
	end
end
RegisterPlayerEvent( 42, OnCommand_Player ) -- PLAYER_EVENT_ON_COMMAND

--[[	НПС АНРИЛА НА ЛУННОЙ ПОЛЯНЕ 	]]--

local function UnrealGossip( _, player, creature )
	if player:GetDmLevel() > 0 then
		local text = "Любопытство это хорошо, но на твоём месте я бы водил интересные сюжеты и вовремя подавал заявку на продление доступа. А знаешь почему? Потому что я слежу за каждым мастером, "..player:GetName()
		player:GossipSetText( text, 08022101 )
		player:GossipSendMenu( 08022101, creature )
	end
end
RegisterCreatureGossipEvent( 9911244, 1, UnrealGossip ) -- GOSSIP_EVENT_ON_HELLO

--[[	ПОЗДРАВЛЯЛКА АНРИЛУ НА ДЕНЬ РОЖДЕНИЯ	]]--

if ( os.date("%d.%m") == "08.02" ) then
	local congratulations = {
		"Салам, брат!",
		"С ДР, братишка.",
		"Счастливых тебе гороскопов, незнакомец.",
		"С днём рождения, хозяин.",
	}
	local function FakeGossip( _, player, creature )
		if ( player:GetAccountId() == 7243 ) then -- 5194
			local text = congratulations[math.random(1,#congratulations)]
			player:GossipSetText( text, 08022102 )
			player:GossipSendMenu( 08022102, creature )
		else
			player:GossipSendMenu( creature:GetGossipTextId(), creature )
		end
	end
	local Q = WorldDBQuery("SELECT entry FROM creature_template WHERE npcflag = 1")
	for i = 1, Q:GetRowCount() do
		local entry = Q:GetUInt32(0)
		RegisterCreatureGossipEvent( entry, 1, FakeGossip ) -- GOSSIP_EVENT_ON_HELLO
		Q:NextRow()
	end
end