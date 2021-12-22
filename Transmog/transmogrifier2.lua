--[[
4.0
Transmogrification for Classic & TBC & WoTLK - Gossip Menu
By Rochet2
Eluna version
TODO:
Make DB saving even better (Deleting)? What about coding?
Fix the cost formula
TODO in the distant future:
Are the qualities right? Blizzard might have changed the quality requirements.
What can and cant be used as source or target..?
Cant transmogrify:
rediculus items -- Foereaper: would be fun to stab people with a fish
-- Cant think of any good way to handle this easily
Cataclysm:
Test on cata : implement UI xD?
Item link icon to Are You sure text
]]

local NPC_Entry = 990000
local NPC_EntryElf = 990007
local NPC_EntryOrc = 990008
local NPC_EntryTroll = 990009

local RequireGold = 1
local GoldModifier = 0.0
local GoldCost = 0

local RequireToken = false
local TokenEntry = 49426
local TokenAmount = 1

local AllowMixedArmorTypes = true
local AllowMixedWeaponTypes = true

local Qualities =
{
    [0]  = true, -- AllowPoor
    [1]  = true, -- AllowCommon
    [2]  = true , -- AllowUncommon
    [3]  = true , -- AllowRare
    [4]  = true , -- AllowEpic
    [5]  = true, -- AllowLegendary
    [6]  = true, -- AllowArtifact
    [7]  = true , -- AllowHeirloom
}

local EQUIPMENT_SLOT_START        = 0
local EQUIPMENT_SLOT_HEAD         = 0
local EQUIPMENT_SLOT_NECK         = 1
local EQUIPMENT_SLOT_SHOULDERS    = 2
local EQUIPMENT_SLOT_BODY         = 3
local EQUIPMENT_SLOT_CHEST        = 4
local EQUIPMENT_SLOT_WAIST        = 5
local EQUIPMENT_SLOT_LEGS         = 6
local EQUIPMENT_SLOT_FEET         = 7
local EQUIPMENT_SLOT_WRISTS       = 8
local EQUIPMENT_SLOT_HANDS        = 9
local EQUIPMENT_SLOT_FINGER1      = 10
local EQUIPMENT_SLOT_FINGER2      = 11
local EQUIPMENT_SLOT_TRINKET1     = 12
local EQUIPMENT_SLOT_TRINKET2     = 13
local EQUIPMENT_SLOT_BACK         = 14
local EQUIPMENT_SLOT_MAINHAND     = 15
local EQUIPMENT_SLOT_OFFHAND      = 16
local EQUIPMENT_SLOT_RANGED       = 17
local EQUIPMENT_SLOT_TABARD       = 18
local EQUIPMENT_SLOT_END          = 19

local INVENTORY_SLOT_BAG_START    = 19
local INVENTORY_SLOT_BAG_END      = 23

local INVENTORY_SLOT_ITEM_START   = 23
local INVENTORY_SLOT_ITEM_END     = 39

local INVTYPE_CHEST               = 5
local INVTYPE_WEAPON              = 13
local INVTYPE_ROBE                = 20
local INVTYPE_WEAPONMAINHAND      = 21
local INVTYPE_WEAPONOFFHAND       = 22

local ITEM_CLASS_WEAPON           = 2
local ITEM_CLASS_ARMOR            = 4

local ITEM_SUBCLASS_WEAPON_BOW          = 2
local ITEM_SUBCLASS_WEAPON_GUN          = 3
local ITEM_SUBCLASS_WEAPON_CROSSBOW     = 18
local ITEM_SUBCLASS_WEAPON_FISHING_POLE = 20

local EXPANSION_WOTLK = 2
local EXPANSION_TBC = 1
local PLAYER_VISIBLE_ITEM_1_ENTRYID
local ITEM_SLOT_MULTIPLIER
if GetCoreExpansion() < EXPANSION_TBC then
    PLAYER_VISIBLE_ITEM_1_ENTRYID = 260
    ITEM_SLOT_MULTIPLIER = 12
elseif GetCoreExpansion() < EXPANSION_WOTLK then
    PLAYER_VISIBLE_ITEM_1_ENTRYID = 346
    ITEM_SLOT_MULTIPLIER = 16
else
    PLAYER_VISIBLE_ITEM_1_ENTRYID = 283
    ITEM_SLOT_MULTIPLIER = 2
end

local INVENTORY_SLOT_BAG_0        = 255

local SlotNames = {
    [EQUIPMENT_SLOT_HEAD      ] = {"Head",         nil, nil, nil, nil, nil, nil, nil, "Голова"},
    [EQUIPMENT_SLOT_SHOULDERS ] = {"Shoulders",    nil, nil, nil, nil, nil, nil, nil, "Плечо"},
    [EQUIPMENT_SLOT_BODY      ] = {"Shirt",        nil, nil, nil, nil, nil, nil, nil, "Рубашка"},
    [EQUIPMENT_SLOT_CHEST     ] = {"Chest",        nil, nil, nil, nil, nil, nil, nil, "Грудь"},
    [EQUIPMENT_SLOT_WAIST     ] = {"Waist",        nil, nil, nil, nil, nil, nil, nil, "Пояс"},
    [EQUIPMENT_SLOT_LEGS      ] = {"Legs",         nil, nil, nil, nil, nil, nil, nil, "Ноги"},
    [EQUIPMENT_SLOT_FEET      ] = {"Feet",         nil, nil, nil, nil, nil, nil, nil, "Ступни"},
    [EQUIPMENT_SLOT_WRISTS    ] = {"Wrists",       nil, nil, nil, nil, nil, nil, nil, "Запястья"},
    [EQUIPMENT_SLOT_HANDS     ] = {"Hands",        nil, nil, nil, nil, nil, nil, nil, "Кисти рук"},
    [EQUIPMENT_SLOT_BACK      ] = {"Back",         nil, nil, nil, nil, nil, nil, nil, "Спина"},
    [EQUIPMENT_SLOT_MAINHAND  ] = {"Main hand",    nil, nil, nil, nil, nil, nil, nil, "Правая рука"},
    [EQUIPMENT_SLOT_OFFHAND   ] = {"Off hand",     nil, nil, nil, nil, nil, nil, nil, "Левая рука"},
    [EQUIPMENT_SLOT_RANGED    ] = {"Ranged",       nil, nil, nil, nil, nil, nil, nil, "Оружие дальнего боя"},
    [EQUIPMENT_SLOT_TABARD    ] = {"Tabard",       nil, nil, nil, nil, nil, nil, nil, "Табард"},
}
local Locales = {
    {"Update menu", nil, nil, nil, nil, nil, nil, nil, "Update menu"},
    {"Remove all transmogrifications", nil, nil, nil, nil, nil, nil, nil, "Remove all transmogrifications"},
    {"Remove transmogrifications from all equipped items?", nil, nil, nil, nil, nil, nil, nil, "Remove transmogrifications from all equipped items?"},
    {"Using this item for transmogrify will bind it to you and make it non-refundable and non-tradeable.\nDo you wish to continue?", nil, nil, nil, nil, nil, nil, nil, "Using this item for transmogrify will bind it to you and make it non-refundable and non-tradeable.\nDo you wish to continue?"},
    {"Remove transmogrification from %s?", nil, nil, nil, nil, nil, nil, nil, "Remove transmogrification from %s?"},
    {"Back..", nil, nil, nil, nil, nil, nil, nil, "Back.."},
    {"Remove transmogrification", nil, nil, nil, nil, nil, nil, nil, "Remove transmogrification"},
    {"Transmogrifications removed from equipped items", nil, nil, nil, nil, nil, nil, nil, "Transmogrifications removed from equipped items"},
    {"You have no transmogrified items equipped", nil, nil, nil, nil, nil, nil, nil, "You have no transmogrified items equipped"},
    {"%s transmogrification removed", nil, nil, nil, nil, nil, nil, nil, "%s transmogrification removed"},
    {"No transmogrification on %s slot", nil, nil, nil, nil, nil, nil, nil, "No transmogrification on %s slot"},
    {"%s transmogrified", nil, nil, nil, nil, nil, nil, nil, "%s transmogrified"},
    {"Selected items are not suitable", nil, nil, nil, nil, nil, nil, nil, "Selected items are not suitable"},
    {"Selected item does not exist", nil, nil, nil, nil, nil, nil, nil, "Selected item does not exist"},
    {"Equipment slot is empty", nil, nil, nil, nil, nil, nil, nil, "Equipment slot is empty"},
    {"You don't have enough %ss", nil, nil, nil, nil, nil, nil, nil, "You don't have enough %ss"},
    {"Not enough money", nil, nil, nil, nil, nil, nil, nil, "Not enough money"},
}

local HUMAN_MALE = 49
local HUMAN_FEM = 50

local GNOME_MALE = 1563
local GNOME_FEM = 1564 

local ELF_MALE = 15476 
local ELF_FEM = 15475

local GOBLIN_MALE = 6894
local GOBLIN_FEM = 6895

local DWORF_MALE = 53
local DWORF_FEM = 54

local ORC_MALE = 51
local ORC_FEM = 52

local TROLL_MALE = 1479 
local TROLL_FEM = 1478

local TAUREN_MALE = 59
local TAUREN_FEM = 60

local DREN_MALE = 16125
local DREN_FEM = 16126

local UNDEAD_MALE = 57
local UNDEAD_FEM = 58

local NE_MALE = 55
local NE_FEM = 56


local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
local BarberValidation = {
[1] = {
	[0]= {
		[1]= 15,
		[9]= 17,
		[7]= 11,
		[3]= 15,
		[4]= 11,
		[10]= 15,
		[2]= 11,
		[11]= 13,
		[5]= 14,
		[6]= 12,
		[8]= 9,
		},
	[1]= {
		[1]= 23,
		[2]= 12,
		[3]= 18,
		[4]= 11,
		[5]= 14,
		[6]= 11,
		[7]= 11,
		[8]= 9,
		[9]= 16,
		[10]= 18,
		[11]= 15,
		},
},
[2] = {
[0]= {
    [1]= 9,
    [2]= 7,
    [3]= 9,
    [4]= 7,
    [5]= 9,
    [6]= 3,
    [7]= 8,
    [8]= 9,
    [9]= 8,
    [10]= 9,
    [11]= 6,
    },
[1]= {
    [1]= 9,
    [2]= 7,
    [3]= 9,
    [4]= 7,
    [5]= 9,
    [6]= 3,
    [7]= 8,
    [8]= 9,
    [9]= 8,
    [10]= 9,
    [11]= 6,
    },
},
[3] = {
	[0]= {
		[1]= 8,
		[2]= 10,
		[3]= 10,
		[4]= 5,
		[5]= 16,
		[6]= 6,
		[7]= 7,
		[8]= 10,
		[9]= 24,
		[10]= 9,
		[11]= 7,
		},
	[1]= {
		[1]= 6,
		[2]= 6,
		[3]= 5,
		[4]= 9,
		[5]= 7,
		[6]= 4,
		[7]= 6,
		[8]= 5,
		[9]= 24,
		[10]= 10,
		[11]= 6,
		},
},
[5] = {
	[0]= {
		[6]= 18,
		},
	[1]= {
		[6]= 10,
		 },
},
}


local function PlayerBarberValidation(player, state, number)
	if state == 5 and player:GetRace() ~= 6 then  player:SendBroadcastMessage("Ошибка изменение облика.")  return false end 
    if player:GetRace() == 4 and state == 2 and (number == 8 or number == 9) then player:SendBroadcastMessage("Ошибка изменение облика.")  return false end  ---Fix Blizz shit
    
    if not BarberValidation[state][player:GetGender()][player:GetRace()] then player:SendBroadcastMessage("Ошибка изменение облика.")  return false end
    if number < 0 then
		player:SendBroadcastMessage("Ошибка изменение облика.") 
        return false
    else
        if number > BarberValidation[state][player:GetGender()][player:GetRace()] then player:SendBroadcastMessage("Ошибка изменение облика.")  return false
        else return true
        end
    end
end


function ChangeVisual(player,changeId,visualId)
	if PlayerBarberValidation(player,changeId,visualId) then
		if changeId == 1 then -- HairStyel
			player:SetByteValue(6+142+5,2,visualId)
		elseif changeId == 2 then -- HairColor
			player:SetByteValue(6+142+5,3,visualId)
		elseif changeId == 3 then -- Features
			player:SetByteValue(6+142+6,0,visualId)
		
		elseif changeId == 4 then 
			player:SetByteValue(6+142+5,1,visualId)
		
		elseif changeId == 5 then 
			player:SetByteValue(6+142+5,0,visualId)
		end
	end
end
local transmog_blacklist = { [2113339] = {HUMAN_MALE,GNOME_MALE,ELF_MALE,GOBLIN_MALE,DWORF_MALE,ORC_MALE,ORC_FEM,TAUREN_FEM,TAUREN_MALE,DREN_MALE,UNDEAD_MALE,UNDEAD_FEM,NE_MALE },
							 [2113328] = {HUMAN_MALE,GNOME_MALE,ELF_MALE,GOBLIN_MALE,DWORF_MALE,ORC_MALE,ORC_FEM,TAUREN_FEM,TAUREN_MALE,DREN_MALE,UNDEAD_MALE,UNDEAD_FEM,NE_MALE },
							 [2113327] = {HUMAN_MALE,GNOME_MALE,ELF_MALE,GOBLIN_MALE,DWORF_MALE,ORC_MALE,ORC_FEM,TAUREN_FEM,TAUREN_MALE,DREN_MALE,UNDEAD_MALE,UNDEAD_FEM,NE_MALE }}

local function checkOnBlacklist(player,id)
	if transmog_blacklist[id] then
		if has_value(transmog_blacklist[id],player:GetDisplayId()) then
			player:PlayDirectSound(6943,player)
			return true
		end
	end
end

local function LocText(id, p) -- "%s":format("test")
    if Locales[id] then
        local s = Locales[id][p:GetDbcLocale()+1] or Locales[id][1]
        if s then
            return s
        end
    end
    return "Text not found: "..(id or 0)
end
--[[
typedef UNORDERED_MAP<uint32, uint32> transmogData
typedef UNORDERED_MAP<uint32, transmogData> transmogMap
static transmogMap entryMap -- entryMap[pGUID][iGUID] = entry
static transmogData dataMap -- dataMap[iGUID] = pGUID
]]
local entryMap = {}
local dataMap = {}

local function GetSlotName(slot, locale)
    if not SlotNames[slot] then return end
    return locale and SlotNames[slot][locale+1] or SlotNames[slot][1]
end

local function GetFakePrice(item)
    local sellPrice = item:GetSellPrice()
    local minPrice = 10000
    if sellPrice < minPrice then
        sellPrice = minPrice
    end
    return sellPrice
end

local function remmoveFakeAuraFromPlayer(item)
    print(1)
    local player = item:GetOwner()
    local playerAuraOld = CharDBQuery('SELECT FakeAura FROM custom_transmogrification where GUID = ' .. item:GetGUIDLow() );
    if playerAuraOld then
        print(2)
        local aura = tonumber(playerAuraOld:GetString(0))
        if(aura) > 0 and player:HasAura(aura) then -- удаляем старую ауру трансмога
            print(3)
            player:RemoveAura(aura);
        end
    end
end

function GetFakeEntry(item)
    local guid = item and item:GetGUIDLow()
    if guid and dataMap[guid] then
        if entryMap[dataMap[guid]] then
            return entryMap[dataMap[guid]][guid]
        end
    end
end

local function DeleteFakeFromDB(itemGUID)
    if dataMap[itemGUID] then
        if entryMap[dataMap[itemGUID]] then
            entryMap[dataMap[itemGUID]][itemGUID] = nil
        end
        dataMap[itemGUID] = nil
    end
    CharDBExecute("DELETE FROM custom_transmogrification WHERE GUID = "..itemGUID)
end

local function DeleteFakeEntry(item)
    if not GetFakeEntry(item) then
        return false
    end
    item:GetOwner():UpdateUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (item:GetSlot() * ITEM_SLOT_MULTIPLIER), item:GetEntry())
    remmoveFakeAuraFromPlayer(item)
    DeleteFakeFromDB(item:GetGUIDLow())
    return true
end

local function SetFakeEntry(item, entry)
    local player = item:GetOwner()
    if player then
        local pGUID = player:GetGUIDLow()
        local iGUID = item:GetGUIDLow()
        local iAuraNew = 0
        player:UpdateUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (item:GetSlot() * ITEM_SLOT_MULTIPLIER), entry)

        print(5)
        -- получаем ауру пояса
        if item:GetSlot() == EQUIPMENT_SLOT_WAIST and item:GetSpellId(1) > 0 then
            print(6)
            iAuraNew = item:GetSpellId(1)
            print(iAuraNew)
            player:AddAura( iAuraNew, player )
        end
        if not entryMap[pGUID] then
            entryMap[pGUID] = {}
        end
        entryMap[pGUID][iGUID] = entry
        dataMap[iGUID] = pGUID
        remmoveFakeAuraFromPlayer(item)

        CharDBExecute("REPLACE INTO custom_transmogrification (GUID, FakeEntry, FakeAura, Owner) VALUES ("..iGUID..", "..entry..", "..iAuraNew..", "..pGUID..")")
    end
end

local function IsRangedWeapon(Class, SubClass)
    return Class == ITEM_CLASS_WEAPON and (
    SubClass == ITEM_SUBCLASS_WEAPON_BOW or
    SubClass == ITEM_SUBCLASS_WEAPON_GUN or
    SubClass == ITEM_SUBCLASS_WEAPON_CROSSBOW)
end

local function SuitableForTransmogrification(player, transmogrified, transmogrifier)
    if not transmogrified or not transmogrifier then
        return false
    end

    if not Qualities[transmogrifier:GetQuality()] then
        return false
    end

    if not Qualities[transmogrified:GetQuality()] then
        return false
    end

    if transmogrified:GetDisplayId() == transmogrifier:GetDisplayId() then
        return false
    end

    local fentry = GetFakeEntry(transmogrified)
    if fentry and fentry == transmogrifier:GetEntry() then
        return false
    end

    if not player:CanUseItem(transmogrifier) then
        return false
    end
    
    if((transmogrifier:GetEntry() >= 301000 and transmogrifier:GetEntry() <= 301012) or (transmogrifier:GetEntry() >= 301100 and transmogrifier:GetEntry() <= 301112))then
        return false
    end

    local fierClass = transmogrifier:GetClass()
    local fiedClass = transmogrified:GetClass()
    local fierSubClass = transmogrifier:GetSubClass()
    local fiedSubClass = transmogrified:GetSubClass()
    local fierInventorytype = transmogrifier:GetInventoryType()
    local fiedInventorytype = transmogrified:GetInventoryType()

    if fiedInventorytype == INVTYPE_BAG or
    fiedInventorytype == INVTYPE_RELIC or
    -- fiedInventorytype == INVTYPE_BODY or
    fiedInventorytype == INVTYPE_FINGER or
    fiedInventorytype == INVTYPE_TRINKET or
    fiedInventorytype == INVTYPE_AMMO or
    fiedInventorytype == INVTYPE_QUIVER then
        return false
    end

    if fierInventorytype == INVTYPE_BAG or
    fierInventorytype == INVTYPE_RELIC or
    -- fierInventorytype == INVTYPE_BODY or
    fierInventorytype == INVTYPE_FINGER or
    fierInventorytype == INVTYPE_TRINKET or
    fierInventorytype == INVTYPE_AMMO or
    fierInventorytype == INVTYPE_QUIVER then
        return false
    end

    if fierClass ~= fiedClass then
        return false
    end

    if IsRangedWeapon(fiedClass, fiedSubClass) ~= IsRangedWeapon(fierClass, fierSubClass) then
        return false
    end

    if fierSubClass ~= fiedSubClass and not IsRangedWeapon(fiedClass, fiedSubClass) then
        if fierClass == ITEM_CLASS_ARMOR and not AllowMixedArmorTypes then
            return false
        end
        if fierClass == ITEM_CLASS_WEAPON and not AllowMixedWeaponTypes then
            return false
        end
    end

    if (fierInventorytype ~= fiedInventorytype) then
        if (fierClass == ITEM_CLASS_WEAPON and not ((IsRangedWeapon(fiedClass, fiedSubClass) or
            ((fiedInventorytype == INVTYPE_WEAPON or fiedInventorytype == INVTYPE_2HWEAPON) and
                (fierInventorytype == INVTYPE_WEAPON or fierInventorytype == INVTYPE_2HWEAPON)) or
            ((fiedInventorytype == INVTYPE_WEAPONMAINHAND or fiedInventorytype == INVTYPE_WEAPONOFFHAND) and
                (fierInventorytype == INVTYPE_WEAPON or fierInventorytype == INVTYPE_2HWEAPON))))) then
            return false
        end
        if (fierClass == ITEM_CLASS_ARMOR and
            not ((fierInventorytype == INVTYPE_CHEST or fierInventorytype == INVTYPE_ROBE) and
                (fiedInventorytype == INVTYPE_CHEST or fiedInventorytype == INVTYPE_ROBE))) then
            return false
        end
    end

    return true
end

local menu_id = math.random(1000)

local function OnGossipHello(event, player, creature)
    player:GossipClearMenu()
    for slot = EQUIPMENT_SLOT_START, EQUIPMENT_SLOT_END-1 do
        local transmogrified = player:GetItemByPos(INVENTORY_SLOT_BAG_0, slot)
        if transmogrified then
            if Qualities[transmogrified:GetQuality()] then
                local slotName = GetSlotName(slot, player:GetDbcLocale())
                if slotName then
                    local fentry = GetFakeEntry(transmogrified);
                    local currentEntry = ""
                    if(fentry)then
                        currentEntry = " [".. fentry .."]"
                    end
                    player:GossipMenuAddItem(3, slotName .. currentEntry, EQUIPMENT_SLOT_END, slot, true)
                end
            end
        end
    end
    player:GossipMenuAddItem(4, LocText(2, player), EQUIPMENT_SLOT_END+2, 0, false, LocText(3, player), 0)
    player:GossipMenuAddItem(7, LocText(1, player), EQUIPMENT_SLOT_END+1, 0)
    player:GossipSendMenu(100, creature, menu_id)
end

local _items = {}
local function OnGossipSelect(event, player, creature, slotid, uiAction, code)
    if slotid == EQUIPMENT_SLOT_END then -- Show items you can use
        local transmogrified = player:GetItemByPos(INVENTORY_SLOT_BAG_0, uiAction)
        local entry = tonumber(code)
		if checkOnBlacklist(player,entry) then
			return false
		end
        local item = player:AddItem( entry )
        local display = item:GetDisplayId()
        player:RemoveItem(item, 1)
        local price = 0
        if(display)then
            SetFakeEntry(transmogrified, entry)
            local questId = 110007;
            if (player:HasQuest(questId) and uiAction == 2) then
                player:CompleteQuest( questId )
            end
        end
        player:GossipComplete();        
        --[[if transmogrified then
            local lowGUID = player:GetGUIDLow()
            _items[lowGUID] = {} -- Remove this with logix
            local limit = 0
            local price = 0
            if RequireGold == 1 then
                price = GetFakePrice(transmogrified)*GoldModifier
            elseif RequireGold == 2 then
                price = GoldCost
            end
            for i = INVENTORY_SLOT_ITEM_START, INVENTORY_SLOT_ITEM_END-1 do
                if limit > 30 then
                    break
                end
                print(4)
                local transmogrifier = player:GetItemByPos(INVENTORY_SLOT_BAG_0, i)
                if transmogrifier then
                    print(5)
                    local display = transmogrifier:GetDisplayId()
                    if SuitableForTransmogrification(player, transmogrified, transmogrifier) then
                        print(6)
                        if not _items[lowGUID][display] then
                            print(7)
                            limit = limit + 1
                            _items[lowGUID][display] = {transmogrifier:GetBagSlot(), transmogrifier:GetSlot()}
                            local popup = LocText(4, player).."\n\n"..transmogrifier:GetItemLink(player:GetDbcLocale()).."\n"
                            if RequireToken then
                                print(8)
                                popup = popup.."\n"..TokenAmount.." x "..GetItemLink(TokenEntry, player:GetDbcLocale())
                            end
                            player:GossipMenuAddItem(4, transmogrifier:GetItemLink(player:GetDbcLocale()), uiAction, display, false, popup, price)
                        end
                    end
                end
            end

            for i = INVENTORY_SLOT_BAG_START, INVENTORY_SLOT_BAG_END-1 do
                local bag = player:GetItemByPos(INVENTORY_SLOT_BAG_0, i)
                if bag then
                    print(9)
                    for j = 0, bag:GetBagSize()-1 do
                        if limit > 30 then
                            break
                        end
                        print(10)
                        local transmogrifier = player:GetItemByPos(i, j)
                        if transmogrifier then
                            local display = transmogrifier:GetDisplayId()
                            if SuitableForTransmogrification(player, transmogrified, transmogrifier) then
                                if not _items[lowGUID][display] then
                                    limit = limit + 1
                                    _items[lowGUID][display] = {transmogrifier:GetBagSlot(), transmogrifier:GetSlot()}
                                    player:GossipMenuAddItem(4, transmogrifier:GetItemLink(player:GetDbcLocale()), uiAction, display, false, popup, price)
                                end
                            end
                        end
                    end
                end
            end

            player:GossipMenuAddItem(4, LocText(7, player), EQUIPMENT_SLOT_END+3, uiAction, false, LocText(5, player):format(GetSlotName(uiAction, player:GetDbcLocale())))
            player:GossipMenuAddItem(7, LocText(6, player), EQUIPMENT_SLOT_END+1, 0)
            player:GossipSendMenu(100, creature, menu_id)
        else
            OnGossipHello(event, player, creature)
        end
        ]]
    elseif slotid == EQUIPMENT_SLOT_END+1 then -- Back
        OnGossipHello(event, player, creature)
    elseif slotid == EQUIPMENT_SLOT_END+2 then -- Remove Transmogrifications
        local removed = false
        for slot = EQUIPMENT_SLOT_START, EQUIPMENT_SLOT_END-1 do
            local transmogrifier = player:GetItemByPos(INVENTORY_SLOT_BAG_0, slot)
            if transmogrifier then
                if DeleteFakeEntry(transmogrifier) and not removed then
                    removed = true
                end
            end
        end
        if removed then
            player:SendAreaTriggerMessage(LocText(8, player))
            -- player:PlayDirectSound(3337)
        else
            player:SendNotification(LocText(9, player))
        end
        OnGossipHello(event, player, creature)
    elseif slotid == EQUIPMENT_SLOT_END+3 then -- Remove Transmogrification from single item
        local transmogrifier = player:GetItemByPos(INVENTORY_SLOT_BAG_0, uiAction)
        if transmogrifier then
            if DeleteFakeEntry(transmogrifier) then
                player:SendAreaTriggerMessage(LocText(10, player):format(GetSlotName(uiAction, player:GetDbcLocale())))
                -- player:PlayDirectSound(3337)
            else
                player:SendNotification(LocText(11, player):format(GetSlotName(uiAction, player:GetDbcLocale())))
            end
        end
        OnGossipSelect(event, player, creature, EQUIPMENT_SLOT_END, uiAction)
    else -- Transmogrify
        local lowGUID = player:GetGUIDLow()
        if not RequireToken or player:GetItemCount(TokenEntry) >= TokenAmount then
            local transmogrified = player:GetItemByPos(INVENTORY_SLOT_BAG_0, slotid)
            if transmogrified then
                if _items[lowGUID] and _items[lowGUID][uiAction] and _items[lowGUID][uiAction] then
                    local transmogrifier = player:GetItemByPos(_items[lowGUID][uiAction][1], _items[lowGUID][uiAction][2])
                    if transmogrifier:GetOwnerGUID() == player:GetGUID() and (transmogrifier:IsInBag() or transmogrifier:GetBagSlot() == INVENTORY_SLOT_BAG_0) and SuitableForTransmogrification(player, transmogrified, transmogrifier) then
                        local price
                        if RequireGold == 1 then
                            price = GetFakePrice(transmogrified)*GoldModifier
                        elseif RequireGold == 2 then
                            price = GoldCost
                        end
                        if price then
                            if player:GetCoinage() >= price then
                                player:ModifyMoney(-1*price)
                                if RequireToken then
                                    player:RemoveItem(TokenEntry, TokenAmount)
                                end
                                SetFakeEntry(transmogrified, transmogrifier:GetEntry())
                                -- transmogrifier:SetNotRefundable(player)
                                transmogrifier:SetBinding(true)
                                -- player:PlayDirectSound(3337)
                                player:SendAreaTriggerMessage(LocText(12, player):format(GetSlotName(slotid, player:GetDbcLocale())))
                            else
                                player:SendNotification(LocText(17, player))
                            end
                        end
                    else
                        player:SendNotification(LocText(13, player))
                    end
                else
                    player:SendNotification(LocText(14, player))
                end
            else
                player:SendNotification(LocText(15, player))
            end
        else
            player:SendNotification(LocText(16, player):format(GetItemLink(TokenEntry, player:GetDbcLocale())))
        end
        _items[lowGUID] = {}
        OnGossipSelect(event, player, creature, EQUIPMENT_SLOT_END, slotid)
    end
end

local function OnLogin(event, player)
    local playerGUID = player:GetGUIDLow()
    entryMap[playerGUID] = {}
    local result = CharDBQuery("SELECT GUID, FakeEntry FROM custom_transmogrification WHERE Owner = "..playerGUID)
    if result then
        repeat
            local itemGUID = result:GetUInt32(0)
            local fakeEntry = result:GetUInt32(1)
            -- if sObjectMgr:GetItemTemplate(fakeEntry) then
            -- {
            dataMap[itemGUID] = playerGUID
            entryMap[playerGUID][itemGUID] = fakeEntry
            -- }
            -- else
            --     sLog:outError(LOG_FILTER_SQL, "Item entry (Entry: %u, itemGUID: %u, playerGUID: %u) does not exist, deleting.", fakeEntry, itemGUID, playerGUID)
            --     Transmogrification::DeleteFakeFromDB(itemGUID)
            -- end
        until not result:NextRow()

        for slot = EQUIPMENT_SLOT_START, EQUIPMENT_SLOT_END-1 do
            local item = player:GetItemByPos(INVENTORY_SLOT_BAG_0, slot)
            if item then
                if entryMap[playerGUID] then
                    if entryMap[playerGUID][item:GetGUIDLow()] then
                        player:UpdateUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (item:GetSlot() * ITEM_SLOT_MULTIPLIER), entryMap[playerGUID][item:GetGUIDLow()])
                        if((slot == 4 or slot == 14) and player:HasAura(84046))then
                            local trinket1 = player:GetItemByPos( 255, 12 );
                            local trinket2 = player:GetItemByPos( 255, 13 );
                            local coat_entry = nil;
                            
                            if(trinket1)then
                                if(trinket1:GetEntry() >= 301000 and trinket1:GetEntry() <= 301022)then
                                    coat_entry = trinket1:GetEntry();
                                end
                            end
                            
                            if(trinket2)then
                                if(trinket2:GetEntry() >= 301000 and trinket2:GetEntry() <= 301022)then
                                    coat_entry = trinket2:GetEntry();
                                end
                            end
                            
                            if(coat_entry)then
                                player:SetUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (slot * ITEM_SLOT_MULTIPLIER), coat_entry + ((slot-4)/10)*100)
                            end
                        end
                    end
                end
            end
        end
    end
end
function splitter(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end
local Transmog_ItemSetID = { ---// Порядок предметов и их айди
1,
3,
15,
5,
4,
19,
9,
10,
6,
7,
8,
16,
17,
18
}
local TRANSMOG_AURA = 540637

function TransmogItem(player,slot,id)
	if checkOnBlacklist(player,id) then
		return false
	end
	if player:HasAura(TRANSMOG_AURA) == false then
		player:AddAura(TRANSMOG_AURA,player)
		local transmogrified = player:GetItemByPos(INVENTORY_SLOT_BAG_0, slot)
		if transmogrified then
			
			local entry = tonumber(id)
			local item = player:AddItem( entry )
			if item == nil then
				entry = 44724
				item = player:AddItem( entry )
			end
			if item then
				local display = item:GetDisplayId()
				player:RemoveItem(item, 1)
				if(display)then
					SetFakeEntry(transmogrified, entry)
				end
			end
		end
		player:EmoteState(10)
		player:EmoteState(0)
	end
end
function TransmogSet(player,code, state)
	if player:HasAura(TRANSMOG_AURA) == false then
		player:AddAura(TRANSMOG_AURA,player)
		local ids = splitter(code,"#")
		if state == nil or state ~= 1 then
            for i = 1, #Transmog_ItemSetID-3 do
                if ids[i] == 0 then
                    ids[i]  = 44724
                end
                local transmogrified = player:GetItemByPos(INVENTORY_SLOT_BAG_0, Transmog_ItemSetID[i]-1)
                if transmogrified then
                    
                    local entry = tonumber(ids[i])
                    if checkOnBlacklist(player,ids[i]) then
                        return false
                    end
                    local item = player:AddItem( entry )

                    if item then
                        local display = item:GetDisplayId()
                        player:RemoveItem(item, 1)
                        if(display)then
                            SetFakeEntry(transmogrified, entry)
                        end
                    end
                end
            end
        elseif state == 1 then
            for i = 1, #Transmog_ItemSetID do
                if ids[i] == 0 then
                    ids[i]  = 44724
                end
                local transmogrified = player:GetItemByPos(INVENTORY_SLOT_BAG_0, Transmog_ItemSetID[i]-1)
                if transmogrified then
                    
                    local entry = tonumber(ids[i])
                    if checkOnBlacklist(player,ids[i]) then
                        return false
                    end
                    local item = player:AddItem( entry )

                    if item then
                        local display = item:GetDisplayId()
                        player:RemoveItem(item, 1)
                        if(display)then
                            SetFakeEntry(transmogrified, entry)
                        end
                    end
                end
            end
        end
		player:EmoteState(10)
		player:EmoteState(0)
	end
	
end
function ResetTransmog(player,slot)
	local transmogrifier = player:GetItemByPos(INVENTORY_SLOT_BAG_0, slot)
	if transmogrifier then
		DeleteFakeEntry(transmogrifier)
		player:EmoteState(10)
		player:EmoteState(0)
	end
end

function GetTransmogIds(player)
	local code
	for i = 1, #Transmog_ItemSetID do
        local transmogrified = player:GetItemByPos(INVENTORY_SLOT_BAG_0, Transmog_ItemSetID[i]-1)
        if transmogrified then
			local fentry = GetFakeEntry(transmogrified);
			if(fentry)then
				if i == 1 then
					code = tostring(fentry)
				else
					code = code.."#"..tostring(fentry)
				end
			else
				if i == 1 then
					code = "0"
				else
					code = code.."#0"
				end
			end
        else
			if i == 1 then
				code = "0"
			else
				code = code.."#0"
			end
		end
    end	
	player:SendAddonMessage("ELUNA_TRANSMOG",code,1,player)
end

local function OnLogout(event, player)
    local pGUID = player:GetGUIDLow()
    entryMap[pGUID] = nil
end

local function OnEquip(event, player, item, bag, slot)
    local fentry = GetFakeEntry(item)
    if fentry then
        if item:GetOwnerGUID() ~= player:GetGUID() then
            DeleteFakeFromDB(item:GetGUIDLow())
            return
        end
        player:SetUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (slot * ITEM_SLOT_MULTIPLIER), fentry)
    end
    
    if((slot == 4 or slot == 14) and player:HasAura(84046))then
        local trinket1 = player:GetItemByPos( 255, 12 );
        local trinket2 = player:GetItemByPos( 255, 13 );
        local coat_entry = nil;
        
        if(trinket1)then
            if(trinket1:GetEntry() >= 301000 and trinket1:GetEntry() <= 301022)then
                coat_entry = trinket1:GetEntry();
            end
        end
        
        if(trinket2)then
            if(trinket2:GetEntry() >= 301000 and trinket2:GetEntry() <= 301022)then
                coat_entry = trinket2:GetEntry();
            end
        end
        
        if(coat_entry)then
            player:SetUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (slot * ITEM_SLOT_MULTIPLIER), coat_entry + ((slot-4)/10)*100)
        end
    end
    
    if(item:GetEntry() >= 301000 and item:GetEntry() <= 301012)then
        player:SetUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (4 * ITEM_SLOT_MULTIPLIER), item:GetEntry())
        player:SetUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (14 * ITEM_SLOT_MULTIPLIER), item:GetEntry()+100)
    end
end

local function OnUnEquip(event, player, item, bag, slot)
    if((slot == 4 or slot == 14) and player:HasAura(84046))then
        local trinket1 = player:GetItemByPos( 255, 12 );
        local trinket2 = player:GetItemByPos( 255, 13 );
        local coat_entry = nil;
        
        if(trinket1)then
            if(trinket1:GetEntry() >= 301000 and trinket1:GetEntry() <= 301022)then
                coat_entry = trinket1:GetEntry();
            end
        end
        
        if(trinket2)then
            if(trinket2:GetEntry() >= 301000 and trinket2:GetEntry() <= 301022)then
                coat_entry = trinket2:GetEntry();
            end
        end
        
        if(coat_entry)then
            player:SetUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (slot * ITEM_SLOT_MULTIPLIER), coat_entry + ((slot-4)/10)*100)
        end
    end
    
    if(item:GetEntry() >= 301000 and item:GetEntry() <= 301012)then
        local chest = player:GetItemByPos( 255, 4 );
        local back = player:GetItemByPos( 255, 14 );
        local fentry1 = GetFakeEntry(chest)
        local fentry2 = GetFakeEntry(back)
        if fentry1 then
            if item:GetOwnerGUID() ~= player:GetGUID() then
                DeleteFakeFromDB(item:GetGUIDLow())
                return
            end
            player:SetUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (4 * ITEM_SLOT_MULTIPLIER), fentry1)
        else
            player:SetUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (4 * ITEM_SLOT_MULTIPLIER), 0)
        end
        if fentry2 then
            if item:GetOwnerGUID() ~= player:GetGUID() then
                DeleteFakeFromDB(item:GetGUIDLow())
                return
            end
            player:SetUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (14 * ITEM_SLOT_MULTIPLIER), fentry2)
        else
            player:SetUInt32Value(PLAYER_VISIBLE_ITEM_1_ENTRYID + (14 * ITEM_SLOT_MULTIPLIER), 0)
        end
    end
end

-- Note, Query is instant when Execute is delayed
CharDBQuery([[
CREATE TABLE IF NOT EXISTS `custom_transmogrification` (
`GUID` INT(10) UNSIGNED NOT NULL COMMENT 'Item guidLow',
`FakeEntry` INT(10) UNSIGNED NOT NULL COMMENT 'Item entry',
`FakeAura` INT(10) UNSIGNED NOT NULL COMMENT 'Item aura',
`Owner` INT(10) UNSIGNED NOT NULL COMMENT 'Player guidLow',
PRIMARY KEY (`GUID`)
)
COMMENT='version 4.0'
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB;
]])

print("Deleting non-existing transmogrification entries...")
CharDBQuery("DELETE FROM custom_transmogrification WHERE NOT EXISTS (SELECT 1 FROM item_instance WHERE item_instance.guid = custom_transmogrification.GUID)")

RegisterPlayerEvent(3, OnLogin)
RegisterPlayerEvent(4, OnLogout)
RegisterPlayerEvent(29, OnEquip)
RegisterPlayerEvent(46, OnUnEquip)

-- Test code
--RegisterPlayerEvent(18, function(e,p,m,t,l) if m == "test" then OnGossipHello(e,p,p) end end)
--RegisterPlayerGossipEvent(menu_id, 2, OnGossipSelect)

RegisterCreatureGossipEvent(NPC_Entry, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_Entry, 2, OnGossipSelect)
RegisterCreatureGossipEvent(NPC_EntryElf, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_EntryElf, 2, OnGossipSelect)
RegisterCreatureGossipEvent(NPC_EntryOrc, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_EntryOrc, 2, OnGossipSelect)
RegisterCreatureGossipEvent(NPC_EntryTroll, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_EntryTroll, 2, OnGossipSelect)

local plrs = GetPlayersInWorld()
if plrs then
    for k, player in ipairs(plrs) do
        OnLogin(k, player)
    end
end