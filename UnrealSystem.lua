--	СИСТЕМА АНРИЛА - Хитрый казах попросил сделать ему предмет, с помощью которого игроки смогут передвигаться на ограниченное расстояние.
--	Акостар сделал.

local timetomove = 8000
local entry_item = 2114498
local entry_sphere = 5049273
local sphere_radius = 3
local active_players = {}
local entry_spell = 65929 -- Оглушение

local function WhenTheMovementOver_Player( _,_,_, player )
	local phase = player:GetPhaseMask() - 2^( 20 + player:GetData("UNREAL_ID") )
	player:SetPhaseMask(phase)
	table.remove(active_players)
	player:SetData( "UNREAL_ID", false )
	local group = player:GetGroup()
	local players = group:GetMembers()
	for i = 1, #players do
		if players[i]:GetGMRank() > 0 then
			players[i]:SendBroadcastMessage("|cff00b7ff:::|r "..player:GetName().." завершает передвижение.")
		end
	end
end

local function Despawn_Sphere( _,_,_, object )
	local players = object:GetPlayersInRange( 25 )
	local creator = object:GetData("Creator")
	print(creator)
	print(#players)
	for i = 1, #players do
		print(players[i]:GetName())
		if players[i]:GetName() == creator then
			if players[i]:GetDistance(object) > sphere_radius+0.3 then
				local group = players[i]:GetGroup()
				local players2 = group:GetMembers()
				for i = 1, #players do
					if players2[i]:GetGMRank() > 0 then
						players2[i]:SendBroadcastMessage("|cff00b7ff:::|r "..players2[i]:GetName().." уходит слишком далеко.")
					end
				end
				local angle = object:GetAngle(players[i])
				local x,y,z = object:GetRelativePoint( sphere_radius, angle )
				local o = players[i]:GetO()
				players[i]:NearTeleport( x,y,z,o )
				players[i]:CastSpell( players[i], entry_spell, true )
				players[i]:SendBroadcastMessage("|cff00b7ff:::|r Вы ушли слишком далеко.")
			end
			break
		end
	end
	object:RemoveFromWorld(true)
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
			local object = PerformIngameSpawn( 2, entry_sphere, player:GetMapId(), 0, x, y, z, o, true, 0, newPhase )
			object:SetPhaseMask(newPhase)
			object:SetData( "Creator", player:GetName() )
			object:RegisterEvent( Despawn_Sphere, timetomove-500, 1  )
			player:RegisterEvent( WhenTheMovementOver_Player, timetomove+500, 1 )
			return true
		end
	end
	player:SendBroadcastMessage("|cff00b7ff:::|r Сейчас вы не можете использовать этот предмет.")
	return false
end
RegisterItemEvent( entry_item, 2, OnUse_Item ) -- ITEM_EVENT_ON_USE