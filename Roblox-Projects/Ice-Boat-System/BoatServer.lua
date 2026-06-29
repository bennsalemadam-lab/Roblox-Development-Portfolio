local Players = game:GetService("Players")
local CS = game:GetService("CollectionService")

Players.CharacterAutoLoads = false

-- Config
local BOAT_SIZE = Vector3.new(4, 1.5, 8)
local SPAWN_HEIGHT = 5
local RESPAWN_DELAY = 0.5
local INIT_DELAY = 2

local boatsFolder = workspace:FindFirstChild("ActiveBoats") or Instance.new("Folder")
boatsFolder.Name = "ActiveBoats"
boatsFolder.Parent = workspace

local function getSpawn()
	local spawnPart = workspace:FindFirstChild("SpawnLocation")
	if not spawnPart then
		spawnPart = Instance.new("Part")
		spawnPart.Name = "SpawnLocation"
		spawnPart.Size = Vector3.new(4, 1, 4)
		spawnPart.CFrame = CFrame.new(0, 10, 0)
		spawnPart.Anchored = true
		spawnPart.CanCollide = false
		spawnPart.Transparency = 0.5
		spawnPart.Color = Color3.fromRGB(0, 255, 0)
		spawnPart.Parent = workspace
	end
	return spawnPart
end

local function createBoat(owner)
	local boat = Instance.new("Model")
	boat.Name = owner.DisplayName .. "'s IceBoat"

	local hull = Instance.new("Part")
	hull.Name = "Hull"
	hull.Size = BOAT_SIZE
	hull.Shape = Enum.PartType.Block
	hull.Material = Enum.Material.SmoothPlastic
	hull.Color = Color3.fromRGB(45, 45, 45)
	hull.CustomPhysicalProperties = PhysicalProperties.new(1, 0, 0, 100, 100) 
	hull.Parent = boat

	local seat = Instance.new("VehicleSeat")
	seat.Name = "VehicleSeat"
	seat.Size = Vector3.new(1.8, 0.5, 2)
	seat.CFrame = CFrame.new(0, 1, 0)
	seat.Material = Enum.Material.SmoothPlastic
	seat.Color = Color3.fromRGB(70, 70, 70)
	seat.Parent = boat

	local wedge = Instance.new("WedgePart")
	wedge.Name = "Front"
	wedge.Size = Vector3.new(4, 1.5, 2)
	wedge.CFrame = CFrame.new(0, 0, 3)
	wedge.Material = Enum.Material.SmoothPlastic
	wedge.Color = Color3.fromRGB(50, 50, 50)
	wedge.Parent = boat

	local back = Instance.new("Part")
	back.Name = "Back"
	back.Size = Vector3.new(4, 1, 1)
	back.CFrame = CFrame.new(0, 0, -3.5)
	back.Material = Enum.Material.SmoothPlastic
	back.Color = Color3.fromRGB(60, 60, 60)
	back.Parent = boat

	for i = 1, 2 do
		local side = Instance.new("Part")
		side.Name = "Side" .. i
		side.Size = Vector3.new(0.5, 0.5, 6)
		side.CFrame = CFrame.new(i == 1 and 2.25 or -2.25, 0.5, 0)
		side.Material = Enum.Material.SmoothPlastic
		side.Color = Color3.fromRGB(55, 55, 55)
		side.Parent = boat
	end

	for _, part in ipairs(boat:GetDescendants()) do
		if part:IsA("BasePart") and part ~= hull then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = part
			weld.Part1 = hull
			weld.Parent = part

			part.CanCollide = false
			part.Massless = true
		end
	end

	boat.PrimaryPart = hull

	local attUpright = Instance.new("Attachment")
	attUpright.Name = "UprightAttachment"
	attUpright.Axis = Vector3.new(0, 1, 0) 
	attUpright.Parent = hull

	local attMove = Instance.new("Attachment")
	attMove.Name = "MoveAttachment"
	attMove.Parent = hull

	local ao = Instance.new("AlignOrientation")
	ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	ao.Attachment0 = attUpright
	ao.AlignType = Enum.AlignType.PrimaryAxisParallel
	ao.PrimaryAxis = Vector3.new(0, 1, 0)
	ao.RigidityEnabled = true 
	ao.Parent = hull

	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = attMove
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	lv.MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge)
	lv.VectorVelocity = Vector3.zero
	lv.Parent = hull

	local av = Instance.new("AngularVelocity")
	av.MaxTorque = math.huge
	av.AngularVelocity = Vector3.zero
	av.Attachment0 = attMove
	av.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	av.Parent = hull

	CS:AddTag(boat, "IceBoat")
	return boat
end

local playerBoats = {}

local function spawnPlayerBoat(player)
	if playerBoats[player] then
		playerBoats[player]:Destroy()
	end

	local spawnPart = getSpawn()
	local boat = createBoat(player)
	boat:SetPrimaryPartCFrame(spawnPart.CFrame * CFrame.new(0, SPAWN_HEIGHT, 0))
	boat.Parent = boatsFolder
	playerBoats[player] = boat

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid", 5)
	if not hum then return end

	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") then
			local ncc = Instance.new("NoCollisionConstraint")
			ncc.Part0 = boat.PrimaryPart
			ncc.Part1 = part
			ncc.Parent = boat.PrimaryPart
		end
	end

	local seat = boat:FindFirstChild("VehicleSeat")
	if seat then
		seat:Sit(hum)

		task.delay(0.1, function()
			if boat.PrimaryPart then
				local lv = boat.PrimaryPart:FindFirstChildOfClass("LinearVelocity")
				if lv then
					lv.MaxAxesForce = Vector3.new(math.huge, 0, math.huge)
				end
				boat.PrimaryPart:SetNetworkOwner(player)
			end
		end)
	end

	hum.Died:Connect(function()
		task.wait(RESPAWN_DELAY)
		if player.Parent then
			player:LoadCharacter()
			task.wait(0.2)
			spawnPlayerBoat(player)
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	task.wait(INIT_DELAY)
	player:LoadCharacter()
	spawnPlayerBoat(player)
end)

Players.PlayerRemoving:Connect(function(player)
	if playerBoats[player] then
		playerBoats[player]:Destroy()
		playerBoats[player] = nil
	end
end)