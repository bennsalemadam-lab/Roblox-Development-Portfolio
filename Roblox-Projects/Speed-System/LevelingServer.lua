local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(plr)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = plr

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = 1
	level.Parent = stats

	local speed = Instance.new("IntValue")
	speed.Name = "Speed"
	speed.Value = 5
	speed.Parent = stats

	local hidden = Instance.new("Folder")
	hidden.Name = "hiddenStats"
	hidden.Parent = plr

	local progress = Instance.new("NumberValue")
	progress.Name = "Progress"
	progress.Value = 0
	progress.Parent = hidden

	local maxProgress = Instance.new("NumberValue")
	maxProgress.Name = "MaxProgress"
	maxProgress.Value = 100
	maxProgress.Parent = hidden

	plr.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum.WalkSpeed = speed.Value

		speed.Changed:Connect(function(val)
			if hum and hum.Parent then
				hum.WalkSpeed = val
			end
		end)
	end)

	task.spawn(function()
		while task.wait(0.2) do
			if not plr.Parent then break end

			local char = plr.Character
			local hum = char and char:FindFirstChild("Humanoid")

			if hum and hum.MoveDirection.Magnitude > 0 then
				progress.Value += 1

				if progress.Value >= maxProgress.Value then
					progress.Value = 0
					level.Value += 1
					speed.Value += 5
					maxProgress.Value = 100 + (level.Value - 1) * 50
				end
			end
		end
	end)
end)