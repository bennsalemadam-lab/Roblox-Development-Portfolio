local SS = game:GetService("ServerStorage")
local egg = script.Parent
local prompt = egg:WaitForChild("ProximityPrompt") 

local petsFolder = SS:WaitForChild("Pets")
local allPets = petsFolder:GetChildren()

-- Configuration
local SPACING = 3
local DIST_BEHIND = 4
local HEIGHT_OFFSET = 1

local function updatePetPositions(char)
	local currentPets = char:FindFirstChild("CurrentPets")
	if not currentPets then return end

	local pets = currentPets:GetChildren()
	local totalPets = #pets

	local startX = -((totalPets - 1) * SPACING) / 2

	for i, pet in ipairs(pets) do
		local ap = pet:FindFirstChildOfClass("AlignPosition")
		if ap and ap.Attachment1 then
			local xOffset = startX + (i - 1) * SPACING
			ap.Attachment1.Position = Vector3.new(xOffset, HEIGHT_OFFSET, DIST_BEHIND)
		end
	end
end

prompt.Triggered:Connect(function(player)
	if #allPets == 0 then return end

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	-- Get random pet
	local randomPet = allPets[math.random(1, #allPets)]
	local clone = randomPet:Clone()

	-- Pet folder setup
	local currentPets = char:FindFirstChild("CurrentPets")
	if not currentPets then
		currentPets = Instance.new("Folder")
		currentPets.Name = "CurrentPets"
		currentPets.Parent = char
	end

	clone.CFrame = hrp.CFrame * CFrame.new(0, 5, 0) 
	clone.Anchored = false
	clone.CanCollide = false
	clone.Massless = true
	clone.Parent = currentPets

	-- Physics setup
	local petAtt = Instance.new("Attachment")
	petAtt.Parent = clone

	local charAtt = Instance.new("Attachment")
	charAtt.Parent = hrp

	local ap = Instance.new("AlignPosition")
	ap.Attachment0 = petAtt
	ap.Attachment1 = charAtt
	ap.Responsiveness = 15
	ap.Parent = clone

	local ao = Instance.new("AlignOrientation")
	ao.Attachment0 = petAtt
	ao.Attachment1 = charAtt
	ao.Responsiveness = 15
	ao.Parent = clone

	updatePetPositions(char)
end)