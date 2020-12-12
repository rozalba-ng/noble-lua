local AIO = AIO or require("AIO")
local MyHandlers = AIO.AddHandlers("SocialClassSelection", {})

--	������ ��������
local entry_creature = 9929463
local entry_quest = 110031
local aura = {
	91055, -- ��������
	91056, -- �����������
	91057, -- ����������
	91058, -- ������� ������
	91062, -- ������
}

function MyHandlers.ShowMenu( player )
	AIO.Handle(player, "SocialClassSelection","Storm_ShowMenu")
end

function MyHandlers.SelectClass( player, class )
    local creature = player:GetNearestCreature( 15, entry_creature )
	if creature and tonumber(class) then
		class = math.floor( tonumber(class) )
		if class > 0 and class < 5 then
			CharDBQuery("INSERT INTO character_citycraft_config ( character_guid, city_class ) values ("..player:GetGUIDLow()..", "..aura[class]..")")
			player:AddAura( aura[class], player )
			player:CompleteQuest( entry_quest )
			creature:SendChatMessageToPlayer( 12, 0, "���� ���� ������� � ������ � ������� �� ����... � ��� ��� �? ��� ����������!", player )
		end
	end
end

local function Creaure_Gossip( event, player, creature, sender, intid )
	if event == 1 then
	--	����� �������
		local text
		player:GossipAddQuests( creature )
		if player:HasAura(91055) then
		--	��������� � ���������
			text = "��� ������ ���, "..player:GetName().."! ��� � ���� ��� ������?"
		elseif player:HasAura(91056) then
		--	��������� � ����������
			text = "�� ������ ��� ����! ��� ���� ���� �������?"
		elseif player:HasAura(91057) then
		--	��������� � ����
			text = "���� �����������! ��� ���� ���� �������?"
		elseif player:HasAura(91058) then
		--	��������� � �������� ������
			text = "������� ����, ����! ���� ���-�� ����������?"
		elseif player:HasAura(91062) then
		--	���� ����� ����� ���� ����
			text = "�������� ����, �� �����. �� ������ �� �����������?"
		else
		--	����� ��� �� ������ �����.
			text = "����� ������� � ����� �����? ��, � ��� ��� ���� �����-��������?"
			if player:HasQuest( entry_quest ) then
				player:GossipMenuAddItem( 0, "<�������������.>", 1, 1 )
			end
		end
		player:GossipSetText( text, 13122001 )
		player:GossipSendMenu( 13122001, creature )
	elseif player:HasQuest( entry_quest ) then
	--	����� ��������
		player:GossipComplete()
		MyHandlers.ShowMenu( player )
	end
end
RegisterCreatureGossipEvent( entry_creature, 1, Creaure_Gossip ) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent( entry_creature, 2, Creaure_Gossip ) -- GOSSIP_EVENT_ON_SELECT