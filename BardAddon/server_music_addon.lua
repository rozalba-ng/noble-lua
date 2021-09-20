local AIO = AIO or require("AIO")
local MusicalHandlers = AIO.AddHandlers("MusicalHandlers", {})

--	Невидимый NPC который проигрывает музыку
local BARD_NPC = 1001177
--	Время в МС между обновлениями НПС (Телепорт, отправка музыки игрокам рядом)
local NPC_UPDATE_TIME = 2000

--	ID ауры с нотами над головой
local AURA = 87012																
	
local ALLOWED_SONGS = {
	stop = 100, -- Звук для остановки песни, функция IsSoundAllowed его не проверяет
	--[[
		СЮДА ДОБАВЛЯТЬ НОВЫЕ ПЕСНИ
		Просто их ID из SoundEntries.dbc через запятую
	]]--
	123,
	900007,
	900008,
	900009,
	900010,
	900011,
	900012,
	900013,
	900014,
	900015,
	900016,
}

local SOUNDS_DURATION = {
	[900007] = 47,
	[900008] = 53,
	[900009] = 38,
	[900010] = 45,
	[900011] = 48,
	[900012] = 51,
	[900013] = 47,
	[900014] = 43,
	[900015] = 42,
	[900016] = 48,
	

}

local actionsCooldown = {}

--	--	--	--	--	--

BardSystem = BardSystem or {}

function BardSystem.IsSoundAllowed(songId)
	for _, v in ipairs(ALLOWED_SONGS) do
		if (songId == v) then
			return true
		end
	end
	return false
end

BardSystem.songs = {}
BardSystem.npcs = {}
BardSystem.lastSongSessionId = 0


function BardSystem.RemoveNPCAfterSong(eventid, delay, repeats, npc)
	BardSystem.StopMusic(GetPlayerByName(npc:GetData("BardName")))


end


--	Проигрывание новой музыки
function BardSystem.StartNewMusic(player, songId)
	if actionsCooldown[player:GetName()] == nil or os.time() - actionsCooldown[player:GetName()] > 0.5 then
		if not BardSystem.IsSoundAllowed(songId) then
			return false
		end
		actionsCooldown[player:GetName()] = os.time()
		local playerName = player:GetName()
		
		--	Создание нового NPC
		local x,y,z,o = player:GetLocation()
		local npc = player:SpawnCreature( BARD_NPC, x, y, z, o, 8 ) -- TEMPSUMMON_MANUAL_DESPAWN
		local npcGuid = npc:GetGUID()
		print(npc:GetGUID())
		if player:GetData("SongSessionId") then
		--	Прекращение предыдущей песни
			BardSystem.StopMusic(player)
		end
		npc:MoveFollow( player, -2 )
		player:PlayDistanceSound( songId )
		
		local T = {
			playerName = playerName,
			npcGuid = npc:GetGUIDLow(),
			id = BardSystem.lastSongSessionId + 1,
			songId = songId,
		}
		BardSystem.songs[T.id] = T
		
		BardSystem.lastSongSessionId = BardSystem.lastSongSessionId + 1
		
		npc:SetData("SongSessionId", T.id)
		npc:SetData("BardName", playerName)
		BardSystem.npcs[npc:GetGUIDLow()] = T.id
		
		player:SetData("SongSessionId", T.id)
		npc:RegisterEvent(BardSystem.RemoveNPCAfterSong, SOUNDS_DURATION[songId]*1000,1)
		npc:RegisterEvent( BardSystem.OnNpcUpdate, NPC_UPDATE_TIME, 1 )
		AIO.Handle(player,"MusicalHandlers","SelfUpdate",songId)
		local players = GetPlayersInWorld()
		for i = 1, #GetPlayersInWorld() do
			if player:GetDistance(players[i]) < 80 then
				AIO.Handle(players[i],"MusicalHandlers","AroundUpdate",T.id)
			end
		end
		npc:SendUnitEmote( "&?0"..(T.id) )
		if not player:HasAura(AURA) then
			player:AddAura(AURA,player)
		end

		return true
	end
end

--	Подруб уже существующей музыки для тех кто подошёл позже
function BardSystem.StartExistingMusic(player, SongSessionId)
	if BardSystem.songs[SongSessionId] then
	
		local T = BardSystem.songs[SongSessionId]
		GetPlayerByName(T.playerName):PlayDistanceSound( T.songId, player )
	end
	return false
end
function MusicalHandlers.CallToPlayNearBardSong(player,SongSessionId)
	BardSystem.StartExistingMusic(player,tonumber(SongSessionId))
end
function MusicalHandlers.StartPlayingSong(player,SongSessionId)
	BardSystem.StartNewMusic(player,tonumber(SongSessionId))
end
function MusicalHandlers.StopPlayingSong(player)
	BardSystem.StopMusic(player)
end

--	Просто остановить музыку (Для автора)
function BardSystem.StopMusic(player)
	local SongSessionId = player:GetData("SongSessionId")
	if SongSessionId and BardSystem.songs[SongSessionId] then
		local T = BardSystem.songs[SongSessionId]
		if ( T.playerName == player:GetName() ) then
			local npc = player:GetMap():GetWorldObject( GetUnitGUID(T.npcGuid,BARD_NPC))

			if npc then
				npc:DespawnOrUnsummon()
			else
				BardSystem.npcs[T.npcGuid] = nil
				BardSystem.songs[SongSessionId] = nil
				player:SetData("SongSessionId", nil)
			end
			player:RemoveAura(AURA)
			player:PlayDistanceSound(ALLOWED_SONGS.stop)
			return true
		end
	end
	return false
end

--	Функции NPC
function BardSystem.OnNpcUpdate(eventid, delay, repeats, npc)
	if not npc or not npc:GetData("BardName") then
		return false
	end
	local player = GetPlayerByName( npc:GetData("BardName") )
	if player and ( player:GetMapId() == npc:GetMapId() ) then
		local x,y,z,o = player:GetLocation()
		npc:NearTeleport(x,y,z,o)
		npc:SendUnitEmote( "&?1"..( npc:GetData("SongSessionId") ) )
		npc:RegisterEvent( BardSystem.OnNpcUpdate, NPC_UPDATE_TIME, 1 )
		AIO.Handle(player,"MusicalHandlers","SelfUpdate",BardSystem.songs[npc:GetData("SongSessionId")].songId)
	else
		npc:DespawnOrUnsummon()
	end
end

function BardSystem.OnNpcDespawned(event, npc)
	local lowGuid = npc:GetGUIDLow()
	if BardSystem.npcs[lowGuid] then
		local id = BardSystem.npcs[lowGuid]
		BardSystem.npcs[lowGuid] = nil
		
		local player = GetPlayerByName( BardSystem.songs[id].playerName )
		if player then
			player:SetData("SongSessionId", nil)
		end
		BardSystem.songs[id] = nil
		AIO.Handle(player,"MusicalHandlers","SelfSongStop")
		npc:SendUnitEmote( "&?2"..id )
	end
end

local function OnPlayerLogout(event,player)
	BardSystem.StopMusic(player)

end

local function OnPlayerLogin(event,player)
	player:RemoveAura(AURA)

end
RegisterCreatureEvent( BARD_NPC, 37, BardSystem.OnNpcDespawned ) -- CREATURE_EVENT_ON_REMOVE
RegisterPlayerEvent(4,OnPlayerLogout)
RegisterPlayerEvent(3, OnPlayerLogin)
