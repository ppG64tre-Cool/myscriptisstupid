local function genname(long: number)
	local name = ""
	for i = 1, long do
		name = name .. string.char(math.random(32, 126))
	end
	return name
end

local localplayer = game.Players.LocalPlayer
local mouse = localplayer:GetMouse()
local UIP = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local guis: ScreenGui = game:GetObjects("rbxassetid://77380567008109")[1]
guis.Parent = localplayer:WaitForChild("PlayerGui")
guis.ResetOnSpawn = false

local svapos = guis.staticPng.Position
local numbershaky = 10
local resultShake = numbershaky

local rng = Random.new()

RunService.RenderStepped:Connect(function()
	guis.staticPng.Position = svapos + UDim2.new(
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
	"Specimen 8", "Frostbite", "Rebound", "RipperMoving", 
	"RushMoving", "Silence", "Eyes", "BackdoorRush", "SingularityZone",
	"BackdoorLookman", "Death", "RushCounterpart", "Deer God"
}

local EntitylistCount = {
	"A60", "A120", "monster2", "AmbushMoving", 
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
	else
		if guis:FindFirstChild("turnoff") and guis:FindFirstChild("turnoff"):IsA("Sound") then
			guis:FindFirstChild("turnoff"):Play()
			colorEffect.Enabled = false
			guis.Enabled = false
		end
	end
end

toggleScanner()

-- toggle keybind
UIP.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.T then
		toggleScanner()
	end
end)


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

	-- AUDIO & VALUE LERPING
	if guis.Sound.PlaybackSpeed ~= valueSpeed then
		guis.Sound.PlaybackSpeed += (valueSpeed - guis.Sound.PlaybackSpeed) / 17.75
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
	elseif EntityCount == 0 then 
		valueSpeed = normalspeed
		stt = 0.885
	elseif EntityCount > 0 then
		valueSpeed = foundspeed
		stt = 0.7175
	end

end)

--- custom badge by viuy

local CustomAchievements = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/DOORS-Custom-Achievements/main/init.luau"))()

CustomAchievements:Grant({
    Identifier = "NVCS-6000",
    Title = "Did You Happy?",
    Desc = "This Thing So Useful.",
    Reason = "Reach The End Of Th-",
    Image = "rbxassetid://12309073114"
}, {
    CheckOwned = true,
    Remember = true
})




