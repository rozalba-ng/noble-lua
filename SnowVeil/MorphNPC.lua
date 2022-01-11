local npc = 11013176
local disp = { 101524, 355160, 40816, 359577, 100464, 100543, 100645, 101249, 40107, 49084, 40323, 22349, 24055, 44655, 13730, 101151, 34189 }
local function on_gossip(event, player, creature)
	player:GossipClearMenu()
	player:GossipSetText('*Кринстик приглядывается к вам*\n\nХм, думаю здесь можно что-то поменять!', 1000)
	player:GossipMenuAddItem( 0, 'Измени мой облик!', 1, 1 )
	if player:GetData('CustomMorph') then
		player:GossipMenuAddItem( 0, 'С меня достаточно, верни мне мой облик.', 1, 2 )
	end
	player:GossipSendMenu( 1000, creature )
end

RegisterCreatureGossipEvent( npc, 1, on_gossip )

local function sel_gossip(event, player, creature, sender, intid, code, menu_id)
	if intid == 1 then
		if not player:GetData('CustomMorph') then
			player:SetData('CustomMorph', player:GetDisplayId())
		end
		local x = math.random(1, #disp)
		player:SetDisplayId( disp[x] )
	else 
		player:SetDisplayId( player:GetData('CustomMorph') )
		player:SetData('CustomMorph', nil)
	end
	player:GossipComplete()
	player:CastSpell( player, 24085, triggered )
end

RegisterCreatureGossipEvent( npc, 2, sel_gossip )

local function map_change(event, player)
	if player:GetData('CustomMorph') then
		player:SetDisplayId( player:GetData('CustomMorph') )
		player:SetData('CustomMorph', nil)
	end
end

RegisterPlayerEvent( 28, map_change )