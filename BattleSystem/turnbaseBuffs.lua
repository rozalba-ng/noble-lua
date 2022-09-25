sql_createAuraData = [[
CREATE TABLE IF NOT EXISTS `turnbase_system_aura_data` (
	`aura_id` INT(11) NULL DEFAULT NULL,
	`on_attack` INT(11) NULL DEFAULT NULL,
	`on_damage` INT(11) NULL DEFAULT NULL,
	`turn_count` INT(11) NULL DEFAULT NULL,
	`type` INT(11) NULL DEFAULT NULL COMMENT '1 - Бафф, 2 - Дебафф, 3 - Антибаф, 4 - Антидебафф, 5 - Не снимаемый'
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]


local TYPE_BUFF = 1
local TYPE_DEBUFF = 2
local TYPE_ANTIBUFF = 3
local TYPE_ANTIDEBUFF = 4
local TYPE_NONE_DISPELEBLE = 5
local TYPE_CONTROL = 6
turnBaseAurasData = {}
local lastAuras = {}

local function LoadAurasData()
	WorldDBQuery(sql_createAuraData)
	local Q = WorldDBQuery("SELECT * FROM turnbase_system_aura_data")
	if Q then
		repeat
			local auraid, on_attack, on_damage, turn_count, type = Q:GetUInt32(0), Q:GetUInt32(1),Q:GetUInt32(2),Q:GetInt32(3),Q:GetUInt32(4)
			if on_attack == 1 then
				on_attack = true
			else
				on_attack = false
			end
			if on_damage == 1 then
				on_damage = true
			else
				on_damage = false
			end
			local auradata = {}
			auradata.auraid = auraid
			auradata.on_attack = on_attack
			auradata.on_damage = on_damage
			auradata.turn_count = turn_count
			auradata.type = type
			turnBaseAurasData[auraid] = auradata

			
		until not Q:NextRow()
	end
end
LoadAurasData()

local function IsAuraNew(caster,auraid)
	if lastAuras[caster:GetGUIDLow()] then
		if lastAuras[caster:GetGUIDLow()][auraid] then
			if os.time() - lastAuras[caster:GetGUIDLow()][auraid] < 0.1 then
				return true
			end
		end
	end
	return false
end

local function OnDamageTaken(event,caster,victim, damage)
	if not caster then
		return true
	end
	if damage > 0 then
		if caster:HasAura(IS_IN_BATTLE_AURA) then
			for id,data in pairs(turnBaseAurasData) do
				if caster:HasAura(id) and not IsAuraNew(caster,id) then
					if data.on_attack and caster ~= victim then
						caster:RemoveAura(id)	
						break
					end
				end
			end
		end
		if victim:HasAura(IS_IN_BATTLE_AURA) then
			for id,data in pairs(turnBaseAurasData) do
				if victim:HasAura(id) and not IsAuraNew(victim,id) then
					if data.on_damage and caster ~= victim then
						victim:RemoveAura(id)	
						break
					end
				end
			end
		end
	end
end

local function OnSpellEffects(event,spell,caster,victim,damage,heal)
	if damage >= 0 then
		if not caster then
			return true
		end
		if caster:HasAura(IS_IN_BATTLE_AURA) then
			for id,data in pairs(turnBaseAurasData) do
				if caster:HasAura(id) and not IsAuraNew(caster,id) then
					if data.on_attack and caster ~= victim then
						caster:RemoveAura(id)	
					end
				end
			end
		end
		if victim:HasAura(IS_IN_BATTLE_AURA) then
			for id,data in pairs(turnBaseAurasData) do
				if victim:HasAura(id) and not IsAuraNew(victim,id) then
					if data.on_damage and caster ~= victim then
						victim:RemoveAura(id)	

					end
				end
			end
		end
		
	else	
		if not caster then
			return true
		end
		
		if caster:HasAura(IS_IN_BATTLE_AURA) then
			for id,data in pairs(turnBaseAurasData) do
				if caster:HasAura(id) then
					if data.on_attack and caster ~= victim and not IsAuraNew(caster,id) then
						caster:RemoveAura(id)	
					end
				end
			end
			caster:SetFFA(true)
		end
	
	
	end
end


local TECHICAL_HIT_BY_GUNNER_AURA = 104059

local WEAK_AMMO_AURA = 104017
local DEBUFF_ARMOR_AMMO_AURA = 104018 

local WEAK_EFFECT_SPELL = 104060 
local DEBUFF_ARMOR_SPELL = 104061 

local eventDispels = {}
local function LateDispelEnvoke(eventid, delay, repeats, worldobject)
	worldobject:RemoveAura(eventDispels[eventid])
end

function Creature:LateDispel(auraid)
	eventDispels[self:RegisterEvent(LateDispelEnvoke,550,1)] = auraid
end
function Player:LateDispel(auraid)
	eventDispels[self:RegisterEvent(LateDispelEnvoke,550,1)] = auraid
end
local function LateAddEnvoke(eventid, delay, repeats, worldobject)
	worldobject:AddAura(eventDispels[eventid],worldobject)
end

function Creature:LateAddAura(auraid)
	eventDispels[self:RegisterEvent(LateAddEnvoke,300,1)] = auraid
end
function Player:LateAddAura(auraid)
	eventDispels[self:RegisterEvent(LateAddEnvoke,300,1)] = auraid
end
local DEBUFF_DISPEL_AURA = 104037  
local BUFF_DISPEL_AURA = 104046 
local UNIVERSAL_DISPEL_AURA = 104031  

local CONTROL_IMMUNE_AURA = 104054



local function OnAuraApply(event, player, aura)
	if lastAuras[player:GetGUIDLow()] == nil then
		lastAuras[player:GetGUIDLow()]={}
	end
	lastAuras[player:GetGUIDLow()][aura:GetAuraId()] = os.time()
	if aura:GetAuraId() == TECHICAL_HIT_BY_GUNNER_AURA then
		local caster = aura:GetCaster()
		if caster:HasAura(WEAK_AMMO_AURA) then
			caster:CastSpell(player,WEAK_EFFECT_SPELL,true)
		end
		if caster:HasAura(DEBUFF_ARMOR_AMMO_AURA) then
			player:LateAddAura(DEBUFF_ARMOR_SPELL)
		end
	end
	local newAuraData = turnBaseAurasData[aura:GetAuraId()]
	if newAuraData then
		if newAuraData.type == TYPE_CONTROL then
			if player:HasAura(CONTROL_IMMUNE_AURA) then
				aura:SetDuration(0)
				aura:Remove()
				return false
			else
				player:AddAura(CONTROL_IMMUNE_AURA,player)
			end
		end
		for id,data in pairs(turnBaseAurasData) do
			if player:HasAura(id) then
				if newAuraData.type == TYPE_BUFF and data.type == TYPE_ANTIBUFF then
					player:RemoveAura(id)
					aura:Remove()
					return false
				end
				if (newAuraData.type == TYPE_DEBUFF or newAuraData.type == TYPE_CONTROL) and data.type == TYPE_ANTIDEBUFF then
					player:RemoveAura(id)
					aura:Remove()
					return false
				end
				if data.type == TYPE_BUFF and newAuraData.type == TYPE_ANTIBUFF then
					aura:Remove()
					player:RemoveAura(id)
					return false
				end
				if (data.type == TYPE_DEBUFF  or data.type == TYPE_CONTROL) and newAuraData.type == TYPE_ANTIDEBUFF then
					aura:Remove()
					player:RemoveAura(id)
					return false
				end
			end
			
		end
	end
	if aura:GetAuraId() == UNIVERSAL_DISPEL_AURA then
		local caster = aura:GetCaster()
		local friendlyUnits = caster:GetFriendlyUnitsInRange(50)
		local isFriendly = false
		for i, unit in ipairs(friendlyUnits) do
			if unit == player then
				isFriendly = true
			end
		end
		if isFriendly or caster == player then
			aura:Remove()
			caster:AddAura(DEBUFF_DISPEL_AURA,player)
		else
			aura:Remove()
			caster:AddAura(BUFF_DISPEL_AURA,player)
		end
	end

end
RegisterPlayerEvent(43, OnAuraApply)

local function OnHealTaken(event,caster,victim, heal)
	if not caster then
		return true
	end
	
	if caster:HasAura(IS_IN_BATTLE_AURA) then
		for id,data in pairs(turnBaseAurasData) do
			if caster:HasAura(id) then
				if data.on_attack and not IsAuraNew(caster,id) then
					caster:RemoveAura(id)	
				end
			end
		end
	end

end

RegisterPlayerEvent( 54, OnSpellEffects )
RegisterPlayerEvent( 52, OnDamageTaken )
RegisterPlayerEvent( 53, OnHealTaken )


