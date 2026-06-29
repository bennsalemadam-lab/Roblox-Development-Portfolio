local TS = game:GetService("TweenService")
local plr = game:GetService("Players").LocalPlayer

local stats = plr:WaitForChild("leaderstats")
local level = stats:WaitForChild("Level")

local hidden = plr:WaitForChild("hiddenStats")
local progress = hidden:WaitForChild("Progress")
local maxProg = hidden:WaitForChild("MaxProgress")

local fillBar = script.Parent
local bg = fillBar.Parent
local lvlLabel = bg:WaitForChild("LevelLabel")
local progLabel = bg:WaitForChild("ProgressLabel")

local info = TweenInfo.new(0.05, Enum.EasingStyle.Linear)

local function updateText()
	lvlLabel.Text = "Level " .. level.Value
	progLabel.Text = math.floor(progress.Value) .. " / " .. maxProg.Value
end

updateText()
level.Changed:Connect(updateText)

progress.Changed:Connect(function()
	updateText()

	if progress.Value == 0 then
		fillBar.Size = UDim2.new(0, 0, 1, 0)
		return
	end

	local percent = progress.Value / maxProg.Value
	TS:Create(fillBar, info, {Size = UDim2.new(percent, 0, 1, 0)}):Play()
end)