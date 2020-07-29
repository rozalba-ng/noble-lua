local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local QuestBarHandlers = AIO.AddHandlers("QuestBarHandlers", {})
local QBFrame = CreateFrame("Frame", "QBFrame", UIParent)
QBFrame:Hide()
QBFrame:SetWidth(150)
QBFrame:SetHeight(50)
QBFrame:SetPoint("TOP", UIParent)
QBFrame:EnableMouse()
QBFrame:SetScript("OnMouseDown",function(self) 
QBFrame.AnimaHide:Play()

end)

local Text = QBFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
Text:SetPoint("CENTER", QBFrame, "CENTER", 0, -10)
Text:SetFont("Fonts\\MORPHEUS.TTF", 21.5, "OUTLINE")
Text:SetWidth(700)
Text:SetHeight(40)
Text:SetText("")
Text:SetJustifyH("CENTER")
Text:SetAlpha(0.9)

function QuestBarHandlers.ShowQuest(player,text)
	QBFrame:Show()
	Text:SetText(text)
	QBFrame.AnimaShow:Play()
	PlaySound(73277)
end

QBFrame.AnimaHide = QBFrame:CreateAnimationGroup() 

QBFrame.AlphaOut = QBFrame.AnimaHide:CreateAnimation("Alpha")
QBFrame.AlphaOut:SetChange(-1)
QBFrame.AlphaOut:SetDuration(2)
QBFrame.AlphaOut:SetSmoothing("OUT")
QBFrame.AnimaHide:SetScript("OnFinished", function(self)
    QBFrame:Hide()
end)

QBFrame.AnimaShow = QBFrame:CreateAnimationGroup() 

QBFrame.AlphaIn2 = QBFrame.AnimaShow:CreateAnimation("Alpha")
QBFrame.AlphaIn2:SetChange(-1)
QBFrame.AlphaIn2:SetDuration(0)
QBFrame.AlphaIn2:SetSmoothing("OUT")

QBFrame.AlphaIn = QBFrame.AnimaShow:CreateAnimation("Alpha")
QBFrame.AlphaIn:SetChange(1)
QBFrame.AlphaIn:SetDuration(2)
QBFrame.AlphaIn:SetSmoothing("OUT")
QBFrame.AnimaShow:SetScript("OnFinished", function(self)
    QBFrame:SetAlpha(1)
end)
