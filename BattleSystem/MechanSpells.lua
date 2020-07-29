local spellListToBuff = { 	[87001] = {type = 1, mod = 0.3},
							[87002] = {type = 1, mod = 0.3},
							[87003] = {type = 2, mod = 0.3},
							[87004] = {type = 2, mod = 0.3},
							[87005] = {type = 1, mod = 0.5},
							[87006] = {type = 2, mod = 0.5},
							[87007] = {type = 1, mod = 0.3},
							[87008] = {type = 1, mod = 0.3},
							[87009] = {type = 1, mod = 0.5},
							[87010] = {type = 1, mod = 0.3},
							[86003] = {type = 2, mod = 0.3},
							[86004] = {type = 2, mod = 0.5},
							[86006] = {type = 3, mod = 0.5},
							[86007] = {type = 3, mod = 0.5},
							[86008] = {type = 3, mod = 1},
							[86009] = {type = 3, mod = 0.5},
							[86010] = {type = 3, mod = 1},
							[86011] = {type = 3, mod = 0.5},
							[86012] = {type = 3, mod = 1},
							[86013] = {type = 3, mod = 1},
							[86014] = {type = 3, mod = 1},
							[86015] = {type = 3, mod = 0.5},
							[86016] = {type = 3, mod = 1},
							[86017] = {type = 3, mod = 1},
							[86018] = {type = 3, mod = 1},
							[86019] = {type = 3, mod = 1}
						}
local hpBuffAuraList = {	{id = 88044, bonus = 1},
							{id = 88045, bonus = 1},
							{id = 88046, bonus = 2},
							{id = 88047, bonus = 2},
							{id = 88048, bonus = 2},
							{id = 88049, bonus = 2}
						}

local DEF_HP_MULTIPLICATOR = 3

local DEF_STR_ID = 3
local DEF_DXT_ID = 4
local DEF_INT_ID = 5

local KALIMDOR_MID = 2105
local WARSONG_MID = 489


local function auraListContain(table,key)
	for i = 1, #table do
		if table[i].id == key then
			return i
		end
	end
	return false
end


local function OnUnitHitBySpell(event, unit, spell)
	local owner = spell:GetCaster()
	if spellListToBuff[spell:GetEntry()] then
		
		local stat = owner:GetRoleStat(spellListToBuff[spell:GetEntry()].type-1)
		local mod = spellListToBuff[spell:GetEntry()].mod
		if stat*mod > 0 then
			owner:DealDamage(unit,stat*mod,false,0,88004+spellListToBuff[spell:GetEntry()].type)
		end
	end
end

function Player:RescaleHP()
	local curHp = self:GetHealth()
	local hp = 100
	local mapid = self:GetMapId()
	if mapid == KALIMDOR_MID or mapid == WARSONG_MID then
		self:SetMaxHealth(500)
		self:SetHealth(500)
	else
		for i = 1, #hpBuffAuraList do
			if self:HasAura(hpBuffAuraList[i].id) then
				hp = hp + (hpBuffAuraList[i].bonus) * 30
			end
		end
		local defStats = self:GetRoleStat(DEF_STR_ID) + self:GetRoleStat(DEF_DXT_ID) + self:GetRoleStat(DEF_INT_ID)
		hp = hp + (defStats* DEF_HP_MULTIPLICATOR)
		self:SetMaxHealth(hp)
		self:SetHealth(curHp)
	end
end

local function Rescale(eventid, delay, repeats, player)
	player:RescaleHP()
end
local function OnMapChange(event, player)
	player:RegisterEvent( Rescale, 200,1)
end


local function OnPlayerLogin(event, player)
	player:RegisterEvent( Rescale, 200,1)
end



local function playerOnEquip(event, player, item, bag, slot)
	player:RegisterEvent( Rescale, 200,1)
end

local function auraApplyEvent(event, unit, aura)
	if auraListContain(hpBuffAuraList,aura:GetAuraId()) then
		if unit:ToPlayer() then
			unit:RegisterEvent( Rescale, 200,1)
		end
	end
end
local function auraRemoveEvent(event, unit, aura)
	if auraListContain(hpBuffAuraList,aura:GetAuraId()) then
		if unit:ToPlayer() then
			unit:RegisterEvent( Rescale, 200,1)
		end
	end
end
RegisterPlayerEvent (29, playerOnEquip);
RegisterPlayerEvent(44, auraRemoveEvent);
RegisterPlayerEvent(43, auraApplyEvent);
RegisterPlayerEvent(28,OnMapChange)
RegisterPlayerEvent(3,OnPlayerLogin)
RegisterPlayerEvent(48, OnUnitHitBySpell)
RegisterPlayerEvent(33, playerOnEquip)