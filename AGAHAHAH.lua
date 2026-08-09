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
local jumpConnection = nil -- Added to handle manual jumping

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

		-- 1. Prevent the engine from tripping the character when upside down
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

		-- Attachment for physics
		attachment = Instance.new("Attachment")
		attachment.Name = "FlipAttachment"
		-- Set the attachment's main axis to the character's Local Y-Axis (Up)
		attachment.Axis = Vector3.new(0, 1, 0)
		attachment.Parent = rootPart

		-- 2. Instead of locking the whole CFrame, ONLY align the Y-Axis
		alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Name = "FlipAlign"
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.AlignType = Enum.AlignType.PrimaryAxisParallel
		-- Force the character's Local Up to point towards World Down
		alignOrientation.PrimaryAxis = Vector3.new(0, -1, 0) 
		alignOrientation.RigidityEnabled = true
		alignOrientation.Parent = rootPart

		-- Lift character so the upside-down head clears the floor
		humanoid.HipHeight = defaultHipHeight + 3.5

		-- 3. Custom Jump Logic (Default jumping fails when upside down)
		jumpConnection = humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
			if isFlipped and humanoid.Jump then
				local state = humanoid:GetState()
				-- Ensure they are on the ground before jumping
				if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics or humanoid.FloorMaterial ~= Enum.Material.Air then
					
					-- Account for whether the game uses JumpPower or JumpHeight
					local jumpVelocity = humanoid.UseJumpPower and humanoid.JumpPower or math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight)

					-- Apply the upward force
					rootPart.AssemblyLinearVelocity = Vector3.new(
						rootPart.AssemblyLinearVelocity.X,
						jumpVelocity,
						rootPart.AssemblyLinearVelocity.Z
					)
					humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
				end
			end
		end)

		-- Continuously ensure limb collisions stay off while walking
		steppedConnection = RunService.Stepped:Connect(function()
			if isFlipped and character then
				disableLimbCollisions(character)
			end
		end)
	else
		-- Restore normal upright state
		if steppedConnection then steppedConnection:Disconnect() steppedConnection = nil end
		if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end

		if alignOrientation then alignOrientation:Destroy() alignOrientation = nil end
		if attachment then attachment:Destroy() attachment = nil end

		-- Restore normal states
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)

		humanoid.HipHeight = defaultHipHeight
		restoreLimbCollisions(character)
	end
end

-- Reset variables on respawn
player.CharacterAdded:Connect(function()
	isFlipped = false
	if steppedConnection then steppedConnection:Disconnect() steppedConnection = nil end
	if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end
end)

-- Bind controls (F key for PC, on-screen button for Mobile)
ContextActionService:BindAction(ACTION_FLIP, toggleFlip, true, Enum.KeyCode.F)
ContextActionService:SetTitle(ACTION_FLIP, "Flip")
ContextActionService:SetPosition(ACTION_FLIP, UDim2.new(0.65, 0, 0.1, 0))
