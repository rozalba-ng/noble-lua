ItemSet = {} -- перековка предмеов

local itemSetSpells = {
    [88117] = 922, -- приключенец
    [88118] = 923, -- авантюрист
}

local itemSetSpellsItems = {
    [88117] = 301583, -- приключенец
    [88118] = 301584, -- авантюрист
}

function ItemSet.CheckIsItemSetSpell(spellID)
    if itemSetSpells[spellID] ~= nil then
        return true
    end

    return false
end

function ItemSet.GetSetID(spellID)
    if itemSetSpells[spellID] ~= nil then
        return itemSetSpells[spellID]
    end

    return 0
end

function ItemSet.GetItemID(spellID)
    if itemSetSpellsItems[spellID] ~= nil then
        return itemSetSpellsItems[spellID]
    end

    return 0
end

function ItemSet.OnForge(event, player, spell)
    local item = spell:GetTarget();
    local itemEntry = item:GetEntry();
    local spellId = spell:GetEntry();
    local setID = ItemSet.GetSetID(spellId)

    if setID == 0 then
        return false
    end

    if item:IsEquipped() == false then
        player:SendBroadcastMessage("|cffff0000 Для применения требуется надеть предмет на персонажа!")
        return false
    end

    local itemCountQuery = CharDBQuery('SELECT * FROM item_instance WHERE itemEntry = ' .. itemEntry);
    if itemCountQuery then
        local itemsCount = toDeleteQuery:GetRowCount()

        if itemsCount ~= 1 then
            player:SendBroadcastMessage("|cffff0000 Частью сета можно делать только предметы, существующие в единственном экземпляре.")
            return false
        end
    else
        return false
    end

    WorldDBExecute('update item_template set itemset = ' .. setID .. ' where entry = ' .. itemEntry)
    ReloadItemByEntry(itemEntry)
    player:SendBroadcastMessage("|cffff0000 Предмет обновлен. Для вступления изменений в силу - перезайдите в игру.")

    return true
end

function ItemSet.OnError(event, player, spell)
    local spellId = spell:GetEntry();
    local entry = ItemSet.GetItemID(spellId)
    if entry == 0 then
        return false
    end
    local item = player:AddItem(entry);
    if(item == nil)then
        player:SendBroadcastMessage("|cFF00CC99|r |cFFFFA500System: |r |cFF00CCFFНет места.|r");
        return false;
    end
    return false
end
