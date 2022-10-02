local sql_auraReqs = [[
CREATE TABLE IF NOT EXISTS `turnbase_system_aura_require` (
	`spellid` INT(11) NULL DEFAULT NULL,
	`auraid` INT(11) NULL DEFAULT NULL,
	`need` INT(11) NULL DEFAULT '1',
	`take` INT(11) NULL DEFAULT '1',
	`isself` INT(11) NULL DEFAULT '1',
	`aura_name` VARCHAR(255) NULL DEFAULT '' COLLATE 'utf8_general_ci'
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]

spellReqs = {}


local function LoadSpellReqs()
	WorldDBQuery(sql_auraReqs)
	local Q = WorldDBQuery("SELECT * FROM turnbase_system_aura_require")
	if Q then
		repeat
			local spellid, auraid, need, take, is_self, name = Q:GetUInt32(0), Q:GetUInt32(1),Q:GetUInt32(2),Q:GetUInt32(3),Q:GetUInt32(4), Q:GetString(5)
			if is_self == 1 then
				is_self = true
			else
				is_self = false
			end
			
			local reqs = {}
			reqs.aura = auraid
			reqs.need = need
			reqs.take = take
			reqs.is_self = is_self
			reqs.name = name
			if spellReqs[spellid] == nil then
				spellReqs[spellid] = {}
			end
			table.insert(spellReqs[spellid],reqs)
			
		until not Q:NextRow()
	end
end
LoadSpellReqs()

local function handlePlayerSpell(event, player, spell, skipCheck)
	local spellid = spell:GetEntry()
	if not spellReqs[spellid] then
		return true
	end
	if not player then
		return true
	end
	
	player = player:ToPlayer()
	if not player then
		return true
	end
	local reqs = spellReqs[spellid]
	for i,req in ipairs(reqs) do
		local target = spell:GetTarget()
		if req.is_self then
			target = player
		end
		local aura = target:GetAura(req.aura)
		if aura then
			local currentStack = aura:GetStackAmount()
			local newStack = currentStack-req.take
			if newStack < 1 then
				aura:Remove()
			else
				aura:SetStackAmount(newStack)
			end
		end
		
	end
	return true
end
RegisterPlayerEvent( 5, handlePlayerSpell )
local function handeOnPlayerStartSpell(event, player, spell,triggered)
	local spellid = spell:GetEntry()
	if not spellReqs[spellid] then
		return true
	end
	if not player then
		return true
	end
	
	player = player:ToPlayer()
	if not player then
		return true
	end
	
	local reqs = spellReqs[spellid]
	for i,req in ipairs(reqs) do
		local target = spell:GetTarget()
		if req.is_self then
			target = player
		end
		local aura = target:GetAura(req.aura)
		if req.need > 0 then
			if aura then
				local count = aura:GetStackAmount()
				
				if count < req.need  then
					player:SendNotification("Необходимо "..req.need..' заряд(а) "'..req.name..'" для использования способности.')
					return false
				end
			else
				player:SendNotification("Необходимо "..req.need..' заряд(а) "'..req.name..'" для использования способности.')
				return false
			end
		end
	end
	return true
end
--
RegisterPlayerEvent( 50, handeOnPlayerStartSpell )

