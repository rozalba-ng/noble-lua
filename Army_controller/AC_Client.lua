local NPCSelected = {}

local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end
function CreateButton(Frame, name, width, height, Ox, Oy)
    local Button = CreateFrame("Button", Frame:GetName().."_"..name, Frame, "UIPanelButtonTemplate")
    Button:SetSize(width, height)
    Button:SetText(name)
    Button:SetPoint("TOP", Frame, "TOP", Ox, Oy-10)
    Button:SetScript("OnClick", function(self) if(self.OnClick) then self:OnClick(Frame) end end)
    return Button
end
local ArmyHandlers = AIO.AddHandlers("ArmyHandlers", {})
local ArmyCounterFrame = CreateFrame("Frame", "ArmyCounterFrame", UIParent)
local ArmyCounterText = ArmyCounterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
local ArmyCounterNumber = ArmyCounterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ArmyCounterFrame:SetSize(150, 35)

ArmyCounterFrame:EnableMouse(true)
ArmyCounterFrame:Hide()
ArmyCounterFrame:SetPoint("BOTTOM",-90,45)

ArmyCounterText:SetFont("Fonts\\MORPHEUS.TTF", 14, "OUTLINE")
ArmyCounterText:SetPoint("LEFT",-10,0)
ArmyCounterText:SetText("Выделено NPC:")
ArmyCounterText:Show();

ArmyCounterNumber:SetFont("Fonts\\MORPHEUS.TTF", 14,"OUTLINE")
ArmyCounterNumber:SetPoint("RIGHT",0,0)
ArmyCounterNumber:SetText("0")
ArmyCounterNumber:Show();
local Frame_ArmySetEmote = CreateFrame("Frame", "Frame_ArmySetEmote", UIParent)
local ArmyEmoteLabel = Frame_ArmySetEmote:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Frame_ArmySetEmote:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = true, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
Frame_ArmySetEmote:SetBackdropColor(0,0,0,1);
Frame_ArmySetEmote:SetSize(150, 100)
Frame_ArmySetEmote:Hide()
Frame_ArmySetEmote:SetPoint("CENTER")
ArmyEmoteLabel:SetFont("Fonts\\MORPHEUS.TTF", 14, "OUTLINE")
ArmyEmoteLabel:SetPoint("CENTER",0,30)
ArmyEmoteLabel:SetText("Введите ID стойки")
ArmyEmoteLabel:Show();

local BoxEmoteID = CreateFrame("EditBox", "BoxEmoteID", Frame_ArmySetEmote)
BoxEmoteID:SetPoint("CENTER")
BoxEmoteID:SetSize(80, 30)
BoxEmoteID:SetAltArrowKeyMode(false)
BoxEmoteID:SetAutoFocus(false)
local function OnEditBoxEnterText(self)
	self:ClearFocus()
end
BoxEmoteID:SetMaxLetters(4)
BoxEmoteID:SetFont("Fonts\\MORPHEUS.TTF", 20, "OUTLINE")
BoxEmoteID:SetScript("OnEscapePressed", OnEditBoxEnterText);
BoxEmoteID:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = true, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
BoxEmoteID:SetScript("OnEnterPressed", OnEditBoxEnterText);
local Button_EmoteEnter = CreateButton(Frame_ArmySetEmote, "Ок", 50, 25,0, -55)
function Button_EmoteEnter:OnClick()
	AIO.Handle("ArmyHandlers","SetEmoteToNPC", NPCSelected,BoxEmoteID:GetText())
	BoxEmoteID:SetText("")
	Frame_ArmySetEmote:Hide()
end
function ArmyHandlers.CallEmoteFrame(player)
	Frame_ArmySetEmote:Show()
	
end


local function UpdateNPCCount()
	ArmyCounterNumber:SetText(#NPCSelected)
	ArmyCounterFrame:Show()
end
function ArmyHandlers.UnselectAll(player)
	ArmyCounterFrame:Hide()
	NPCSelected = {}
	print("|cff00ccff[ARMY CONTROLLER]|r  Выделение с группы снято.")
end
function ArmyHandlers.CallTableToDel(player)
	AIO.Handle("ArmyHandlers","DeleteAllNpcInGroup", NPCSelected)
	ArmyCounterFrame:Hide()
	NPCSelected = {}
	print("|cff00ccff[ARMY CONTROLLER]|r  Все NPC в группе задеспавнены.")
end
function ArmyHandlers.CallTableToDelPerm(player)
	AIO.Handle("ArmyHandlers","DeleteAllNpcInGroupPerm", NPCSelected)
	ArmyCounterFrame:Hide()
	NPCSelected = {}
	print("|cff00ccff[ARMY CONTROLLER]|r  Все NPC в группе полностью удалены из мира.")
end

function ArmyHandlers.CallTableToCommand(player,callType,xPos,yPos,zPos)
	AIO.Handle("ArmyHandlers","CommandToNPC", NPCSelected,callType,xPos,yPos,zPos)
end
function ArmyHandlers.SelectNewNPCs(player,NPCTable)
	if #NPCSelected == 0 then
		NPCSelected = NPCTable
		UpdateNPCCount()
	else
		for z = 1, #NPCTable do
			for i = 1, #NPCSelected do
				if NPCSelected[i].guid == NPCTable[z].guid then
					break
				end
				if i == #NPCSelected then
					table.insert(NPCSelected,NPCTable[z])
				end
			end
		end
		UpdateNPCCount()
	end
end