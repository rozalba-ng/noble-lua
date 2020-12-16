local entry = {
	quest = {
		thief = 110052,
		law = 110053,
	},
	questgiver = {
		thief = 9929479,
		law = 9929478,
	}
}

--[[	����������� ������ �������	]]--
--	����� ����� ������� ������� ���� ���������� ������ ���� ���������� ���� �������� ������.

local function Creature_Gossip( event, player, creature, sender, intid )
	local text
	if player:HasAura(91058) then
	--	����� ������� ������
		text = "��������? ���� ���������� ������."
		player:GossipAddQuests( creature )
	else
	--	����� ����� ������ ���������� ����
		text = "� ���� ��� ���� ��� ���, ����������."
	end
	player:GossipSetText( text, 16122001 )
	player:GossipSendMenu( 16122001, creature )
end
RegisterCreatureGossipEvent( entry.questgiver.thief, 1, Creature_Gossip ) -- GOSSIP_EVENT_ON_HELLO