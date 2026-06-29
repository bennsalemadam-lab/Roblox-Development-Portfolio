local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local plr = Players.LocalPlayer
local hidden = plr:WaitForChild("hiddenStats")
local progress = hidden:WaitForChild("Progress")

local template = RS:WaitForChild("SpeedPopUp")
local LIFETIME = 0.55

local lastProgress = progress.Value

progress.Changed:Connect(function(val)
	local change = val - lastProgress
	lastProgress = val

	if val == 0 or change <= 0 then return end

	local char = plr.Character
	local head = char and char:FindFirstChild("Head")
	if not head then return end

	local popUp = template:Clone()
	local label = popUp:FindFirstChildOfClass("TextLabel")
	if not label then return end

	local rx = math.random(-12, 12) / 10
	popUp.StudsOffset = Vector3.new(rx, 1.5, 0)
	popUp.Parent = head

	label.Text = "+" .. change
	label.TextTransparency = 0
	label.Size = UDim2.new(0, 0, 0, 0)

	-- Animations
	TS:Create(label, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
	TS:Create(popUp, TweenInfo.new(LIFETIME, Enum.EasingStyle.Linear), {StudsOffset = Vector3.new(rx, 4.5, 0)}):Play()

	task.delay(LIFETIME - 0.18, function()
		if not label.Parent then return end
		TS:Create(label, TweenInfo.new(0.15), {TextTransparency = 1}):Play()

		local stroke = label:FindFirstChildOfClass("UIStroke")
		if stroke then
			TS:Create(stroke, TweenInfo.new(0.15), {Transparency = 1}):Play()
		end
	end)

	Debris:AddItem(popUp, LIFETIME)
end)