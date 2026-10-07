-- Paste in Edit mode. Both labels remain editable in Studio.
local sale = game.StarterGui.FeedbackHUD.SaleTemplate
sale.Text = "+25$"
sale.TextStrokeTransparency = 1
local stroke = sale:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke",sale)
stroke.Thickness, stroke.Color, stroke.Transparency = 3, Color3.new(0,0,0), 0
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
stroke.StrokeSizingMode = Enum.StrokeSizingMode.FixedSize
local label = workspace["showcase npc"].Head.gui.dialog
label.TextScaled, label.TextWrapped, label.TextSize = false, true, 28
label:SetAttribute("FixedDialogueText",true)
