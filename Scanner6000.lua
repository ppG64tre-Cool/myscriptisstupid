local function genname(long: number)
	local name = ""
	for i = 1, long do
		name = name .. string.char(math.random(32, 126))
	end
	return name
end

-- Values Of Closest Entity

local teapotofentity = 1

local tanpoofentity = 1

local vulom = 0

local changename = true

local localplayer = game.Players.LocalPlayer
local mouse = localplayer:GetMouse()
local UIP = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local guis: ScreenGui? = game:GetObjects("rbxassetid://77380567008109")[1]
guis.Parent = localplayer:WaitForChild("PlayerGui")
guis.ResetOnSpawn = false

local CameraAtt = Instance.new("Attachment", workspace.Terrain)

CameraAtt.Name = "CameraAtt"

local function UpdateCameraPos()
	CameraAtt.WorldPosition = workspace.Camera.CFrame.Position
	CameraAtt.WorldOrientation = Vector3.new(0, 0, 0)
end

local svapos: UDim2? = guis.staticPng.Position
local svaposE: UDim2? = guis.staticPngEntity.Position
local numbershaky = 10
local resultShake = numbershaky

local StaticSoundE: Sound? = guis.EntityStatic

local rng = Random.new()

StaticSoundE:Play()

RunService.RenderStepped:Connect(function()
	guis.staticPng.Position = svapos + UDim2.new(
		rng:NextNumber(-resultShake, resultShake), 0, 
		rng:NextNumber(-resultShake, resultShake), 0
	)
	guis.staticPngEntity.Position = svaposE + UDim2.new(
		rng:NextNumber(-resultShake, resultShake), 0, 
		rng:NextNumber(-resultShake, resultShake), 0
	)
end)

local normalspeed = 2.35
local foundspeed = 3
guis.Sound:Play()

local numberoftanpo = Instance.new("NumberValue", guis)
numberoftanpo.Value = 0.885
numberoftanpo.Name = "NumberofTanpo"

local colorEffect: ColorCorrectionEffect = guis.Vistion:Clone()
colorEffect.Parent = game:GetService("Lighting")

local Entitylist = {
	"A60", "A120", "monster2", "AmbushMoving", "CeaseMoving", 
	"A-60",
	"Specimen 8", "Frostbite", "Rebound", "RipperMoving", 
	"RushMoving", "Silence", "Eyes", "BackdoorRush", "SingularityZone",
	"BackdoorLookman", "Death", "RushCounterpart", "Deer God", "EyestalkMoving",
	"SeekMoving"
}

local EntitylistCount = {
	"A60", "A120", "monster2", "AmbushMoving", 
	"A-60",
	"Specimen 8", "Rebound", "RipperMoving", 
	"RushMoving", "BackdoorRush" , "Death"
}

-- TABLES FOR TRACKING (OPTIMIZED)
local activeItemLights = {}
local activeGlowParts = {}
local HighlightE = {}

local glowpartBB = guis.HelloHowdidYouSeethis:Clone()

local attachment = Instance.new("Attachment", workspace.Terrain)
attachment.Name = "Hello"
attachment.WorldPosition = Vector3.new(0, 0, 0)
attachment.Visible = false

local lige = Instance.new("PointLight", attachment)
lige.Range = 120
lige.Brightness = 1
lige.Color = Color3.new(1, 1, 1)
lige.Shadows = false

-- Value i made
local valueSpeed = 2.35
local stt = 0.885
local ScannerEnable = true

-- Mobile GUI defined globally for state updates
local mobileBtn: TextButton?
local mobileStroke: UIStroke?

-- [NEW] COLOR DEFINITIONS
local mobileColors = {
	OnText = Color3.fromRGB(0, 255, 255), -- Cyan Active Text/Border
	OffText = Color3.fromRGB(0, 150, 150), -- Dimmer Cyan Inactive Text/Border
	OnBg = Color3.fromRGB(0, 50, 50), -- Dark Cyan Background (On)
	OffBg = Color3.fromRGB(20, 20, 20) -- Dark Grey Background (Off)
}

-- toggle Scanner
local function toggleScanner()
	ScannerEnable = not ScannerEnable

	if ScannerEnable then
		numberoftanpo.Value = 0
		if guis:FindFirstChild("turnon") and guis:FindFirstChild("turnon"):IsA("Sound") then
			guis:FindFirstChild("turnon"):Play()
			colorEffect.Enabled = true
			guis.Enabled = true
		end
		
		teapotofentity = 1

		-- Update Mobile Colors
		if mobileBtn and mobileStroke then
			mobileBtn.BackgroundColor3 = mobileColors.OnBg
			mobileBtn.TextColor3 = mobileColors.OnText
			mobileStroke.Color = mobileColors.OnText
		end
	else
		if guis:FindFirstChild("turnoff") and guis:FindFirstChild("turnoff"):IsA("Sound") then
			guis:FindFirstChild("turnoff"):Play()
			colorEffect.Enabled = false
			guis.Enabled = false
		end

		-- Update Mobile Colors
		if mobileBtn and mobileStroke then
			mobileBtn.BackgroundColor3 = mobileColors.OffBg
			mobileBtn.TextColor3 = mobileColors.OffText
			mobileStroke.Color = mobileColors.OffText
		end
	end
end

toggleScanner()

-- toggle keybind (For PC)
UIP.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.T then
		toggleScanner()
	end
end)

-- Mobile Support (Creates a tap button if on a touch device)
if UIP.TouchEnabled then
	local mobileGui = Instance.new("ScreenGui")
	mobileGui.Name = "NVCS_MobileToggle"
	mobileGui.ResetOnSpawn = false
	mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mobileGui.Parent = localplayer:WaitForChild("PlayerGui")

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 75, 0, 75) -- Slightly larger for tap accuracy
	toggleBtn.Position = UDim2.new(1, -95, 0.5, 0)
	toggleBtn.AnchorPoint = Vector2.new(0, 0.5)

	-- Initializing Colors (Off state will be handled by the immediate toggleScanner call above)
	toggleBtn.BackgroundColor3 = mobileColors.OnBg
	toggleBtn.BackgroundTransparency = 0.3
	toggleBtn.TextColor3 = mobileColors.OnText
	toggleBtn.Text = "SCAN"
	toggleBtn.Font = Enum.Font.SourceSansBold
	toggleBtn.TextScaled = true
	toggleBtn.Parent = mobileGui
	mobileBtn = toggleBtn -- Set global reference

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0) -- Rounded
	corner.Parent = toggleBtn

	local stroke = Instance.new("UIStroke")
	stroke.Color = mobileColors.OnText
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = toggleBtn
	mobileStroke = stroke -- Set global reference

	toggleBtn.MouseButton1Click:Connect(function()
		toggleScanner()
	end)
end

-- ==========================================
-- EVENT-DRIVEN TRACKING FUNCTIONS (NO LAG)
-- ==========================================

local function createTrackedLight(TargetInstance: Instance, ColorCustom: Color3, bright: number, range: number)
	if not TargetInstance then return end
	if activeItemLights[TargetInstance] then return end

	local att = Instance.new("Attachment", workspace.Terrain)
	att.Name = "LightningSplashLIGHT"

	local pointlight = Instance.new("PointLight", att)
	pointlight.Range = range
	pointlight.Brightness = bright
	pointlight.Color = ColorCustom or Color3.new(1, 1, 1)

	activeItemLights[TargetInstance] = {
		Att = att,
		Light = pointlight,
		BaseBright = bright,
		BaseRange = range
	}
end

-- 1. Checks Rooms for Items and Figures
local function checkAndCacheRoomDescendant(child: Instance)
	if child:IsA("Model") and child.Name == "KeyObtain" then
		createTrackedLight(child, Color3.new(1, 1, 1), 1.5, 30)
	elseif child:IsA("Model") and child.Name == "LeverForGate" then
		createTrackedLight(child, Color3.new(1, 1, 1), 1.5, 30)
	elseif child:IsA("BasePart") and child.Name == "RoomExit" then
		createTrackedLight(child, Color3.new(1, 1, 1), 1.5, 15)
	elseif child:IsA("BasePart") and child.Name == "BookBase" then
		createTrackedLight(child, Color3.new(1, 1, 1), 1.5, 10)
	elseif child:IsA("Model") and child.Name == "FuseObtain" then
		createTrackedLight(child, Color3.new(1, 1, 1), 1.5, 10)
	elseif child:IsA("BasePart") and child.Name == "imstuff" then
		createTrackedLight(child, Color3.new(1, 1, 1), 1.5, 10)

		-- Figure Cache Check
	elseif child:IsA("Model") and (child.Name == "FigureRig" or child.Name == "FigureRagdoll") then
		if not HighlightE[child] then
			local highlightRig = Instance.new("Highlight", child)
			highlightRig.FillTransparency = 0.875
			highlightRig.OutlineColor = Color3.new(1, 0.333333, 0)
			highlightRig.OutlineTransparency = 1
			highlightRig.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlightRig.Enabled = true

			HighlightE[child] = {
				highlightrigmonster = highlightRig;
			}
		end
	end
end

-- 2. Checks Workspace for Active Entities (Rush, Ambush, etc.)
local function checkWorkspaceEntity(child: Instance)
	if child:IsA("Model") and table.find(Entitylist, child.Name) then
		if not activeGlowParts[child] then
			local entAtt = Instance.new("Attachment", workspace.Terrain)
			entAtt.Name = "ESP_Att_" .. child.Name

			local Clone: BillboardGui = glowpartBB:Clone()
			Clone.Parent = guis 
			Clone.Name = "GlowPart_" .. child.Name
			Clone.Adornee = entAtt 
			Clone.StudsOffsetWorldSpace = Vector3.new(0, 0, 0) 
			Clone.Enabled = true

			local isCounted = false
			if table.find(EntitylistCount, child.Name) then
				isCounted = true
			end

			activeGlowParts[child] = {
				Gui = Clone,
				Att = entAtt,
				Counted = isCounted
			}
		end
	end
end

-- Hook up event listeners for map tracking
if workspace:WaitForChild("CurrentRooms") then
	-- Scan existing
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		for _, child in pairs(room:GetDescendants()) do
			checkAndCacheRoomDescendant(child)
		end
	end
	-- Listen for new additions
	workspace.CurrentRooms.DescendantAdded:Connect(checkAndCacheRoomDescendant)
end

-- Hook up event listeners for Entities spawning
for _, v in pairs(workspace:GetChildren()) do
	checkWorkspaceEntity(v)
end
workspace.ChildAdded:Connect(checkWorkspaceEntity)


-- ==========================================
-- MAIN RENDERSTEPPED (VISUAL UPDATES ONLY)
-- ==========================================
local RenderCheck
RenderCheck = RunService.RenderStepped:Connect(function()
	
	-- Value
	local closestEntity = nil
	local closestDistance = math.huge
	local closestAttachment = nil
	
	
	-- change name all time
	
	if changename then
		guis.Name = genname(6)
	end
	
	-- ======================== --
	--	UPDATE CAMERA POSITION  --
	-- ======================== --
	
	-- do not edit this
	
	UpdateCameraPos()
	
	------------------------------

	if numberoftanpo.Value then
		guis.staticPng.ImageTransparency = numberoftanpo.Value
	end

	if workspace.CurrentCamera and attachment then
		attachment.WorldPosition = workspace.CurrentCamera.CFrame.Position
	end

	if lige then
		lige.Enabled = ScannerEnable
	end

	-- LIGHT UPDATES
	for item, lightData in pairs(activeItemLights) do
		if not item or item.Parent == nil then
			if lightData.Att then lightData.Att:Destroy() end
			activeItemLights[item] = nil
			continue
		end

		local itemPos = (item:IsA("Model")) and item:GetPivot().Position or item.Position
		lightData.Att.WorldPosition = itemPos

		lightData.Light.Brightness = lightData.BaseBright + rng:NextNumber(-0.3, 0.3)
		lightData.Light.Range = lightData.BaseRange + rng:NextNumber(-1, 1)
		lightData.Light.Enabled = ScannerEnable
	end

	-- ENTITY ESP UPDATES & COUNTING
	local EntityCount = 0

	for entity, espData in pairs(activeGlowParts) do
		-- If the entity was destroyed, clean it up
		if entity.Parent == nil then
			if espData.Gui then espData.Gui:Destroy() end
			if espData.Att then espData.Att:Destroy() end
			activeGlowParts[entity] = nil
		else
			-- Entity exists, update position
			espData.Att.WorldPosition = entity:GetPivot().Position
			espData.Gui.Enabled = ScannerEnable

			if espData.Counted then
				EntityCount += 1
				
				pcall(function()
					closestEntity = entity
					local distance = (attachment.WorldPosition - espData.Att.WorldPosition).Magnitude
					if distance < closestDistance then
						closestDistance = distance
						closestAttachment = espData.Att
					end
				end)
			end
		end
	end

	-- HIGHLIGHT UPDATES (FIGURE)
	for entity, v in pairs(HighlightE) do
		if entity.Parent == nil then
			if v.highlightrigmonster then
				v.highlightrigmonster:Destroy()
			end
			HighlightE[entity] = nil
		else
			if v.highlightrigmonster and v.highlightrigmonster:IsA("Highlight") then
				v.highlightrigmonster.Enabled = ScannerEnable
			end
		end	
	end
	
	if closestAttachment then
		local result = (closestAttachment.WorldPosition - CameraAtt.WorldPosition).Magnitude
		
		result += 275
		
		if result < 1000 then
			local A = math.clamp(result / 1000, 0, 0.3)
			
			tanpoofentity = 1 - A
		end
	else
		tanpoofentity = 1
	end
	
	-- Update

	StaticSoundE.Volume = vulom
	
	guis.staticPngEntity.ImageTransparency = teapotofentity

	-- AUDIO & VALUE LERPING
	if guis.Sound.PlaybackSpeed ~= valueSpeed then
		guis.Sound.PlaybackSpeed += (valueSpeed - guis.Sound.PlaybackSpeed) / 17.75
	end
	
	if teapotofentity ~= tanpoofentity then
		numberoftanpo += (tanpoofentity - teapotofentity) / 25
	end
	
	

	if numberoftanpo.Value ~= stt then
		numberoftanpo.Value += (stt - numberoftanpo.Value) / 17.75
	end

	if guis.Sound.PlaybackSpeed <= 0.1 then 
		guis.Sound.Volume = 0
	else
		guis.Sound.Volume = 0.675
	end

	-- AUDIO SPEED STATES
	if not ScannerEnable then
		valueSpeed = 0
		stt = 0
		vulom = 0
	elseif EntityCount == 0 then 
		valueSpeed = normalspeed
		stt = 0.885
		vulom = 0
	elseif EntityCount > 0 then
		valueSpeed = foundspeed
		stt = 0.7175
		
		if closestEntity then
			vulom = math.clamp(closestDistance / 1000, 0, 1)
		end
	end

end)

--- custom badge by viuy

local CustomAchievements = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/DOORS-Custom-Achievements/main/init.luau"))()

CustomAchievements:Grant({
	Identifier = "NVCS-6000",
	Title = "NVCS-6000",
	Desc = "Gold Aura Thing But I Lost My Legs Now.",
	Reason = "Reach The End Of Th- Press T or Tap to Use it",
	Image = "rbxassetid://132662854714596"
}, {
	CheckOwned = false,
	Remember = false
})
