local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local ACTION_FLIP = "ToggleFlipAction"

local isFlipped = false
local defaultHipHeight = 0
local originalC0 = nil
local steppedConnection = nil

-- Keeps character limbs from colliding with the ground while flipped
local function disableLimbCollisions(character)
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.CanCollide = false
		end
	end
end

-- Finds the joint that connects the visible body to the invisible RootPart
local function getRootJoint(character, humanoid)
	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		-- R15 uses 'Root' inside LowerTorso
		local lowerTorso = character:FindFirstChild("LowerTorso")
		if lowerTorso then
			return lowerTorso:FindFirstChild("Root")
		end
	else
		-- R6 uses 'RootJoint' inside HumanoidRootPart
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			return rootPart:FindFirstChild("RootJoint")
		end
	end
	return nil
end

local function toggleFlip(actionName, inputState)
	if inputState ~= Enum.UserInputState.Begin then return end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart or not humanoid then return end

	local rootJoint = getRootJoint(character, humanoid)
	if not rootJoint then return end

	isFlipped = not isFlipped

	if isFlipped then
		-- Save default values
		defaultHipHeight = humanoid.HipHeight
		originalC0 = rootJoint.C0
		
		-- Flip the visible body 180 degrees like a cartwheel
		rootJoint.C0 = originalC0 * CFrame.Angles(0, 0, math.rad(180))
		
		-- Raise the HumanoidRootPart so the upside-down head doesn't clip the floor
		local offset = humanoid.RigType == Enum.HumanoidRigType.R15 and 3.5 or 3.0
		humanoid.HipHeight = defaultHipHeight + offset
		
		-- Continuously ensure limb collisions stay off so arms/head don't drag
		steppedConnection = RunService.Stepped:Connect(function()
			if isFlipped and character then
				disableLimbCollisions(character)
			end
		end)
	else
		-- Restore normal upright state
		if steppedConnection then 
			steppedConnection:Disconnect() 
			steppedConnection = nil 
		end
		
		-- Restore joint and height
		rootJoint.C0 = originalC0
		humanoid.HipHeight = defaultHipHeight
		
		-- Restore collisions
		for _, part in ipairs(character:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.CanCollide = true
			end
		end
	end
end

-- Reset variables on respawn
player.CharacterAdded:Connect(function()
	isFlipped = false
	if steppedConnection then 
		steppedConnection:Disconnect() 
		steppedConnection = nil 
	end
end)

-- Bind controls (F key for PC, on-screen button for Mobile)
ContextActionService:BindAction(ACTION_FLIP, toggleFlip, true, Enum.KeyCode.F)
ContextActionService:SetTitle(ACTION_FLIP, "Flip")
ContextActionService:SetPosition(ACTION_FLIP, UDim2.new(0.65, 0, 0.1, 0))
