local AIO = AIO or require("AIO")

local Handlers = AIO.AddHandlers("TransmogHandlers", {})
local Tmog_presets = {};
Tmog_presets.names = {};
Tmog_presets.codes = {};

local ACCESSORIES_COUNT = 4	;
local Tmog_accessories = {};
Tmog_accessories.names = {};
Tmog_accessories.ids = {};

local Tmog_belts = {};
Tmog_belts.names = {};
Tmog_belts.ids = {};


local AuraWhiteList = {
	[84106] =1,
	[84107] =1,
	[84108] =1,
	[84109] =1,
	[84110] =1,
	[84111] =1,
	[84112] =1,
	[84113] =1,
	[84114] =1,
	[84115] =1,
	[84116] =1,
	[84117] =1,
	[84118] =1,
	[84119] =1,
	[84120] =1,
	[84121] =1,
	[84122] =1
};

local function UpdatePresetsAndAccessories()
	Tmog_accessories.names = {};
	Tmog_accessories.ids = {};
	Tmog_presets.names = {};
	Tmog_presets.codes = {};
	Tmog_belts.names = {}
	Tmog_belts.ids = {}
	local presetsQuery = WorldDBQuery("SELECT * FROM transmog_presets")
	if presetsQuery then
		for i = 1, presetsQuery:GetRowCount() do
			if presetsQuery:GetInt32(0) == 1 then
				table.insert(Tmog_presets.names,presetsQuery:GetString(2))
				table.insert(Tmog_presets.codes,presetsQuery:GetString(1))
				presetsQuery:NextRow()
			elseif presetsQuery:GetInt32(0) == 2 then
				table.insert(Tmog_accessories.names,presetsQuery:GetString(2))
				table.insert(Tmog_accessories.ids,presetsQuery:GetInt32(1))
				AuraWhiteList[presetsQuery:GetInt32(1)] = 1;
				presetsQuery:NextRow()
			elseif presetsQuery:GetInt32(0) == 3 then
				table.insert(Tmog_belts.names,presetsQuery:GetString(2))
				table.insert(Tmog_belts.ids,presetsQuery:GetInt32(1))
				AuraWhiteList[presetsQuery:GetInt32(1)] = 1;
				presetsQuery:NextRow()
			end
		end
	end
end
UpdatePresetsAndAccessories()

function Handlers.TransmogItem(player,slot,id)
	TransmogItem(player,tonumber(slot), tonumber(id))
end
function Handlers.TransmogSet(player,code, state)
	TransmogSet(player,code, state)
end
function Handlers.ResetTransmog(player,slot)
	ResetTransmog(player,slot)
end

function Handlers.CallIds(player)
	GetTransmogIds(player)
end
function Handlers.ChangeVisual(player,state,number)
	ChangeVisual(player,state,number)
end

local function LateModelFrameUpdate(eventid, delay, repeats, player)
	AIO.Handle(player,"TransmogHandlers","LateModelFrameUpdate")
end

function Handlers.ApplyAccessory(player,id)
	if AuraWhiteList[id] then
		local countSpells = 0
		local aurasOnChar = {}
		for i = 1, #Tmog_accessories.ids do
			if player:HasAura(tonumber(Tmog_accessories.ids[i])) then
				countSpells = countSpells + 1;
				if id ~= tonumber(Tmog_accessories.ids[i]) then
					table.insert(aurasOnChar,tonumber(Tmog_accessories.ids[i]))
				end
			end
		end
		for i = 1, #Tmog_belts.ids do
			if player:HasAura(tonumber(Tmog_belts.ids[i])) then
				countSpells = countSpells + 1;
				if id ~= tonumber(Tmog_belts.ids[i]) then
					table.insert(aurasOnChar,tonumber(Tmog_belts.ids[i]))
				end
			end
		end
		if player:HasAura(id) then
			player:RemoveAura(id)
		else
			if countSpells < ACCESSORIES_COUNT then
				player:AddAura(id,player)
				table.insert(aurasOnChar,id)
			else
				player:SendNotification("Вы не можете иметь больше "..ACCESSORIES_COUNT.." аксессуаров")
			end
		end

		AIO.Handle(player,"TransmogHandlers","UpdateUsedAura",aurasOnChar)
		player:RegisterEvent(LateModelFrameUpdate,500,1)
	end
end


local function OnPlayerLogin (event, player)
	player:LearnSpell(540638); -- Трансмогрификация
	player:LearnSpell(88032) --Прогулочный шаг
	player:AddAura(26659,player)
	player:RemoveAura(26659)
	AIO.Handle(player,"TransmogHandlers","UpdatePresets",Tmog_presets,Tmog_accessories,Tmog_belts)
end
local function OnPlayerCommand(event, player,command)
	if(string.match(command,'transreload')) then
		if player:GetGMRank() > 1 then
			player:SendBroadcastMessage("Перезагрузка пресетов, аксессуаров и поясов для трансмогрификатора...")
			UpdatePresetsAndAccessories()
			player:SendBroadcastMessage("Успешна")
		end
	elseif (string.match(command,'copyoutfit')) then
		local target = player:GetSelection()
		if target == nil then
			player:SendBroadcastMessage("Выберите НПС в цель!")
			return false
		elseif target:ToPlayer() then
			player:SendBroadcastMessage("Трансмоги можно брать только у НПС!")
			return false
		end
		local templateId = target:GetEntry()
		local modelId = GetModelCreature(templateId, true)
		if not modelId then
			player:SendBroadcastMessage("Не получилось найти модель НПС.")
			return false
		end
		local transmogQuery = WorldDBQuery(string.format(
		[[
			SELECT head, shoulders, body, chest, waist, legs, feet, wrists, hands, back, tabard
			FROM world.creature_template_outfits
			WHERE entry = %d 
		]], modelId))
		local mog = transmogQuery:GetRow()
		Handlers.TransmogItem(player, 0, mog.head)
		Handlers.TransmogItem(player, 2, mog.shoulders)
		Handlers.TransmogItem(player, 3, mog.body)
		Handlers.TransmogItem(player, 4, mog.chest)
		Handlers.TransmogItem(player, 5, mog.waist)
		Handlers.TransmogItem(player, 6, mog.legs)
		Handlers.TransmogItem(player, 7, mog.feet)
		Handlers.TransmogItem(player, 8, mog.wrists)
		Handlers.TransmogItem(player, 9, mog.hands)
		Handlers.TransmogItem(player, 14, mog.back)
		Handlers.TransmogItem(player, 18, mog.tabard)
	end
end

local function OnSpellCast(event, player, spell, skipCheck)
	local spellEntry = spell:GetEntry()	
	if spellEntry == 540638 then
		
		AIO.Handle(player,"TransmogHandlers","OpenTmog")
	end
end

RegisterPlayerEvent(5, OnSpellCast)
RegisterPlayerEvent(42, OnPlayerCommand)
RegisterPlayerEvent(3, OnPlayerLogin)