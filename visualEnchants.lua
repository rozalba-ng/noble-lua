local charactersSQL = [[
CREATE TABLE IF NOT EXISTS `custom_item_enchant_visuals` (
    `iguid` INT(10) UNSIGNED NOT NULL COMMENT 'item DB guid',
    `display` INT(10) UNSIGNED NOT NULL COMMENT 'enchantID',
    PRIMARY KEY (`iguid`)
)
COMMENT='stores the enchant IDs for the visuals'
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB;
]]
CharDBQuery(charactersSQL)

-- script variables:
local EQUIPMENT_SLOT_MAINHAND = 15
local EQUIPMENT_SLOT_OFFHAND = 16
local PLAYER_VISIBLE_ITEM_1_ENCHANTMENT = 284
local PERM_ENCHANTMENT_SLOT = 0
local DD

-- functions
local LoadDB, setVisual, applyVisuals, LOGIN

function LoadDB()
    DD = {}
    CharDBQuery("DELETE FROM custom_item_enchant_visuals WHERE NOT EXISTS(SELECT 1 FROM item_instance WHERE custom_item_enchant_visuals.iguid = item_instance.guid)")
    local Q = CharDBQuery("SELECT iguid, display FROM custom_item_enchant_visuals")
    if (Q) then
        repeat
            local iguid, display = Q:GetUInt32(0), Q:GetUInt32(1)
            DD[iguid] = display
        until not Q:NextRow()
    end
end
LoadDB()

function setVisual(player, item, display)
    if (not player or not item) then return
        false
    end
    local iguid = item:GetGUIDLow()
    local enID = item:GetEnchantmentId(PERM_ENCHANTMENT_SLOT) or 0
    if (enID ~= 0) then
        CharDBExecute("DELETE FROM custom_item_enchant_visuals WHERE iguid = "..iguid)
        DD[iguid] = nil
        display = enID
    elseif (not display) then
        if (not DD[iguid]) then
            return false
        end
        display = DD[iguid]
    else
        CharDBExecute("REPLACE INTO custom_item_enchant_visuals (iguid, display) VALUES ("..iguid..", "..display..")")
        DD[iguid] = display
    end
    if (item:IsEquipped()) then
        player:SetUInt16Value(PLAYER_VISIBLE_ITEM_1_ENCHANTMENT + (item:GetSlot() * 2), 0, display)
    end
    return true
end

function applyVisuals(player)
    if (not player) then
        return
    end
    for i = EQUIPMENT_SLOT_MAINHAND, EQUIPMENT_SLOT_OFFHAND do
        setVisual(player, player:GetItemByPos(255, i))
    end
end

function LOGIN(event, player)
    applyVisuals(player)
end

RegisterPlayerEvent(3, LOGIN)
RegisterPlayerEvent(29, function(e,p,i,b,s) setVisual(p, i) end)

-- Enchant IDs
local E = {[0] = 0, 3789, 3854, 3273, 3225, 3870, 1899, 2674, 2675, 2671, 2672, 3365, 2673, 2343, 425, 3855, 1894, 1103, 1898, 3345, 1743, 3093, 1900, 3846, 1606, 283, 1, 3265, 2, 3, 3266, 1903, 13, 26, 7, 803, 1896, 2666, 25}
local slots = {EQUIPMENT_SLOT_MAINHAND = EQUIPMENT_SLOT_MAINHAND, EQUIPMENT_SLOT_OFFHAND = EQUIPMENT_SLOT_OFFHAND}

local function OnCommand(event, player, command)
    local _, _, cmd, slot, enchantment = string.find(command, "(%S+)%s(%d+)%s(%d+)")
    
    if cmd == "setvisual" and slot and enchantment then
        slot = tonumber(slot)
        enchantment = tonumber(enchantment)
        
        if (slot == 1 or slot == 2) and E[enchantment] then
            local equippedItem = nil
            
            if slot == 1 then
                equippedItem = player:GetEquippedItemBySlot(EQUIPMENT_SLOT_MAINHAND)
            elseif slot == 2 then
                equippedItem = player:GetEquippedItemBySlot(EQUIPMENT_SLOT_OFFHAND)
            end
            
            if equippedItem then
                setVisual(player, equippedItem, E[enchantment]) 
            else
                player:SendBroadcastMessage("В руке нет оружия для установки зачарования.")
            end
        elseif not E[enchantment] then
            player:SendBroadcastMessage("Недопустимый номер зачарования.")
        else
            player:SendBroadcastMessage("Недопустимый слот руки.")
        end
    end
end

RegisterPlayerEvent(42, OnCommand)