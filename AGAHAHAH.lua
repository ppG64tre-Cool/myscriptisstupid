local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local ACTION_FLIP = "ToggleFlipAction"

local isFlipped = false
local alignOrientation = nil
local attachment = nil
local defaultHipHeight = 0
local steppedConnection = nil

-- Keeps character limbs from colliding with the ground while flipped
local function disableLimbCollisions(character)
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.CanCollide = false
		end
	end
end

local function restoreLimbCollisions(character)
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.CanCollide = true
		end
	end
end

local function toggleFlip(actionName, inputState)
	if inputState ~= Enum.UserInputState.Begin then return end

	local character = player.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid then return end

	isFlipped = not isFlipped

	if isFlipped then
		-- Save default HipHeight
		defaultHipHeight = humanoid.HipHeight

		-- Attachment for physics
		attachment = Instance.new("Attachment")
		attachment.Name = "FlipAttachment"
		attachment.Parent = rootPart

		-- AlignOrientation forces character upside down rigidly
		alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Name = "FlipAlign"
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.Attachment0 = attachment
		alignOrientation.RigidityEnabled = true
		alignOrientation.CFrame = rootPart.CFrame * CFrame.Angles(0, 0, math.rad(180))
		alignOrientation.Parent = rootPart

		-- Lift character so the upside-down head clears the floor
		humanoid.HipHeight = defaultHipHeight + 3.5

		-- Continuously ensure limb collisions stay off while walking
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

		if alignOrientation then alignOrientation:Destroy() alignOrientation = nil end
		if attachment then attachment:Destroy() attachment = nil end

		humanoid.HipHeight = defaultHipHeight
		restoreLimbCollisions(character)
	end
end

-- Reset variables on respawn
player.CharacterAdded:Connect(function()
	isFlipped = false
	if steppedConnection then steppedConnection:Disconnect() steppedConnection = nil end
end)

-- Bind controls (F key for PC, on-screen button for Mobile)
ContextActionService:BindAction(ACTION_FLIP, toggleFlip, true, Enum.KeyCode.F)
ContextActionService:SetTitle(ACTION_FLIP, "Flip")
ContextActionService:SetPosition(ACTION_FLIP, UDim2.new(0.65, 0, 0.1, 0))

