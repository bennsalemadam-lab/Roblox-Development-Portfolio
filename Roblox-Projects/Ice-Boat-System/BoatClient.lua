local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Config
local MAX_SPEED = 100          
local REVERSE_MAX = 15   
local BASE_ACCEL = 30          
local TOP_ACCEL = 40           
local REVERSE_ACCEL = 20       
local TURN_SPEED = 4.0         
local DECEL_RATE = 0.15 
local TURN_SMOOTH = 1.5    

local currentTurn = 0

local function getBoat()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum or not hum.SeatPart then return nil end
	return hum.SeatPart:FindFirstAncestorOfClass("Model")
end

runService.Heartbeat:Connect(function(dt)
	local boat = getBoat()
	if not boat or not boat.PrimaryPart then return end
	local hull = boat.PrimaryPart

	local throttle = 0
	local steer = 0

	if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up) then throttle += 1 end
	if UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.Down) then throttle -= 1 end
	if UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.Left) then steer += 1 end
	if UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Right) then steer -= 1 end

	local lv = hull:FindFirstChildOfClass("LinearVelocity")
	local av = hull:FindFirstChildOfClass("AngularVelocity")
	if not lv or not av then return end

	local vel = hull.AssemblyLinearVelocity
	vel = Vector3.new(vel.X, 0, vel.Z)

	-- Friction
	vel = vel * math.max(0, 1 - (DECEL_RATE * dt))

	local speed = vel.Magnitude
	local accel = 0
	local braking = false
	local forwardVel = vel:Dot(hull.CFrame.LookVector)

	if throttle > 0 then
		local factor = math.clamp(speed / 50, 0, 1)
		accel = BASE_ACCEL + ((TOP_ACCEL - BASE_ACCEL) * factor)
	elseif throttle < 0 then
		if forwardVel > -1 and speed > 1 then
			braking = true
		else
			accel = REVERSE_ACCEL
		end
	end

	local nextVel = vel

	if braking then
		nextVel = vel * math.max(0, 1 - (4.0 * dt))
	else
		local thrust = hull.CFrame.LookVector * (throttle * accel * dt)
		nextVel = vel + thrust
	end

	-- Cap reverse
	local nextForwardVel = nextVel:Dot(hull.CFrame.LookVector)
	if throttle < 0 and not braking and nextForwardVel < -REVERSE_MAX then
		nextVel = vel
	end

	-- Cap forward
	if nextVel.Magnitude > MAX_SPEED then
		nextVel = nextVel.Unit * MAX_SPEED
	end

	lv.VectorVelocity = nextVel

	-- Steering
	local targetTurn = steer * TURN_SPEED
	currentTurn = currentTurn + (targetTurn - currentTurn) * (1 - math.exp(-TURN_SMOOTH * dt))
	av.AngularVelocity = Vector3.new(0, currentTurn, 0)
end)