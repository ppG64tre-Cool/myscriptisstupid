local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local currentRotation = CFrame.new()

-- Store physical sensor data from the hardware
local deviceGravity = Vector3.new(0, -9.81, 0)
local deviceAcceleration = Vector3.new(0, -9.81, 0)

-- Real-world tracking variables
local realWorldVelocity = Vector3.new()
local realWorldPosition = Vector3.new()

-- Tuning parameters (Adjust these to make movement feel better)
local MOVEMENT_SCALE = 2.0     -- Multiplier for how much real-life movement translates to the game
local DEADZONE = 0.15          -- Ignores tiny sensor micro-vibrations
local FRICTION = 5.0           -- Slows down movement quickly to prevent infinite drifting

local function setupGyroCamera(character)
	task.wait()
	local Head = character:WaitForChild("Head", 5)
	
	if not Head then return end
	
	-- Reset the real-world tracking every time the character respawns
	realWorldVelocity = Vector3.new()
	realWorldPosition = Vector3.new()
	
	if UserInputService.AccelerometerEnabled and UserInputService.GyroscopeEnabled then
		
		-- 1. Track Phone Rotation
		local rotationConnection = UserInputService.DeviceRotationChanged:Connect(function(rotationVector, cframe)
			currentRotation = CFrame.Angles(rotationVector.Position.X, rotationVector.Position.Y, rotationVector.Position.Z) * CFrame.Angles(math.rad(-90), 0, 0)
		end)
		
		-- 2. Track Phone Gravity Direction
		local gravityConnection = UserInputService.DeviceGravityChanged:Connect(function(input)
			deviceGravity = input.Position
		end)
		
		-- 3. Track Total Phone Physical Acceleration
		local accelConnection = UserInputService.DeviceAccelerationChanged:Connect(function(input)
			deviceAcceleration = input.Position
		end)
		
		local renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
			if camera.CameraType ~= Enum.CameraType.Scriptable then
				camera.CameraType = Enum.CameraType.Scriptable
			end
			
			-- Calculate true physical movement (Total Acceleration minus Gravity)
			-- Note: These vectors are relative to the phone's physical screen
			local pureAccelLocal = deviceAcceleration - deviceGravity
			
			-- Apply a deadzone to stop micro-drifting when you are standing still
			if pureAccelLocal.Magnitude < DEADZONE then
				pureAccelLocal = Vector3.new(0, 0, 0)
			end
			
			-- Convert the phone's local movement into global world directions
			local pureAccelWorld = currentRotation * pureAccelLocal
			
			-- Calculate Speed (Velocity = Acceleration * Time)
			realWorldVelocity = realWorldVelocity + (pureAccelWorld * deltaTime)
			
			-- Apply a drag/friction to velocity so the camera doesn't float away indefinitely
			realWorldVelocity = realWorldVelocity:Lerp(Vector3.new(0,0,0), deltaTime * FRICTION)
			
			-- Calculate Real-Life Distance Traveled (Distance = Velocity * Time)
			realWorldPosition = realWorldPosition + (realWorldVelocity * deltaTime * MOVEMENT_SCALE)
			
			-- Apply everything to the camera
			local headPosition = Head.Position
			local finalCameraPos = headPosition + realWorldPosition
			
			-- Multiply positional offset first, then rotation, then the final minor offset
			camera.CFrame = CFrame.new(finalCameraPos) * currentRotation * CFrame.new(0, 0, -0.75)
		end)
		
		character:WaitForChild("Humanoid").Died:Connect(function()
			rotationConnection:Disconnect()
			gravityConnection:Disconnect()
			accelConnection:Disconnect()
			renderConnection:Disconnect()
			camera.CameraType = Enum.CameraType.Custom
		end)
	end
end

if player.Character then
	task.spawn(setupGyroCamera, player.Character)
end

player.CharacterAdded:Connect(setupGyroCamera)

