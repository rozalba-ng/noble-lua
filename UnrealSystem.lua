--	СИСТЕМА АНРИЛА - Хитрый казах попросил сделать ему предмет, с помощью которого игроки смогут передвигаться на ограниченное расстояние.
--	Акостар сделал.

--	Время дающееся на передвижение:
local timetomove = 8000
--	Радиус сферы:
local sphere_radius = 1
--	Айдишники
local entry_item = 2114498
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