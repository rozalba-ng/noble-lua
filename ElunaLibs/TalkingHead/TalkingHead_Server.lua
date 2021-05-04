
local AIO = AIO or require("AIO")

TalkingHeadHandlers = AIO.AddHandlers( "AIOTalkingHeadHandlers", {} )

function Player:TalkingHead( creature, text )
	if not creature:ToCreature() then
		creature = self:GetNearestCreature( 15, creature )
	end
	self:GossipComplete()
	self:GossipClearMenu()
	self:GossipMenuAddItem( 0, "TalkingHead", 1, 1 )
	self:GossipSendMenu( 100, creature )
	AIO.Handle( self, "AIOTalkingHeadHandlers", "ElunaTalkingHead", text, creature:GetName(), "technical" )
	self:GossipComplete()
end 