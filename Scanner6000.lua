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

local guis = game:GetObjects("rbxassetid://106513443340293")[1]
guis.Parent = localplayer:WaitForChild("PlayerGui")

local svapos = guis.staticPng.Position
local numbershaky = 10
local resultShake = numbershaky

local rng = Random.new()

-- Screen Shake
RunService.RenderStepped:Connect(function()
	guis.staticPng.Position = svapos + UDim2.new(
		0, rng:NextNumber(-resultShake, resultShake), 
		0, rng:NextNumber(-resultShake, resultShake)
	)
end)

local normalspeed = 2.35
local foundspeed = 3
guis.Sound:Play()

local numberoftanpo = Instance.new("NumberValue", guis)
numberoftanpo.Value = 0.885
numberoftanpo.Name = "NumberofTanpo"

local colorEffect = guis.Vistion
colorEffect:Clone().Parent = workspace.CurrentCamera

local Entitylist = {
	"A60", "A120", "monster2", "AmbushMoving", "CeaseMoving", 
	"Specimen 8", "Frostbite", "Rebound", "RipperMoving", 
	"RushMoving", "Silence", "Eyes", "BackdoorRush", 
	"Shocker", "SingularityZone"
}

-- TABLE FOR REAL-TIME LIGHT TRACKING
local activeItemLights = {}

local function createTrackedLight(TargetInstance: Instance, ColorCustom: Color3, bright: number, range: number)
	if not TargetInstance then return end
	if activeItemLights[TargetInstance] then return end

	-- FIXED: Attachments must be parented to Terrain or a Part, not a Folder
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

local function checkAndAddLight(child: Instance)
	if child:IsA("Model") and child.Name == "KeyObtain" then
		createTrackedLight(child, Color3.new(1, 1, 1), rng:NextNumber(0.5, 1.5), 30)
	elseif child:IsA("BasePart") and child.Name == "RoomExit" then
		createTrackedLight(child, Color3.new(1, 1, 1), rng:NextNumber(0.5, 1), 15)
	elseif child:IsA("BasePart") and child.Name == "BookBase" then
		createTrackedLight(child, Color3.new(1, 1, 1), rng:NextNumber(0.5, 1), 10)
	elseif child:IsA("Model") and child.Name == "FuseObtain" then
		createTrackedLight(child, Color3.new(1, 1, 1), rng:NextNumber(0.5, 1), 10)
	end
end

-- Hook up map tracking
if workspace:FindFirstChild("CurrentRooms") then
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		for _, child in pairs(room:GetDescendants()) do
			checkAndAddLight(child)
		end
	end
	workspace.CurrentRooms.DescendantAdded:Connect(checkAndAddLight)
end

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

-- ESP TRACKING TABLE
local activeGlowParts = {}

local Highlight = {}

local valueSpeed = 2.35

local stt = 0.885

-- Main RenderStepped Loop
local RenderCheck
RenderCheck = RunService.RenderStepped:Connect(function()

	if numberoftanpo then
		guis.staticPng.ImageTransparency = numberoftanpo.Value
	end

	if workspace.CurrentCamera and attachment then
		attachment.WorldPosition = workspace.CurrentCamera.CFrame.Position
	end

	-- ==========================================
	-- REAL-TIME KEY/DOOR LIGHT UPDATES & FLICKER
	-- ==========================================
	for item, lightData in pairs(activeItemLights) do
		if not item or not item.Parent then
			if lightData.Att then lightData.Att:Destroy() end
			activeItemLights[item] = nil
			continue
		end

		local itemPos = item:IsA("Model") and item:GetPivot().Position or item.Position
		lightData.Att.WorldPosition = itemPos

		lightData.Light.Brightness = lightData.BaseBright + rng:NextNumber(-0.3, 0.3)
		lightData.Light.Range = lightData.BaseRange + rng:NextNumber(-1, 1)
	end

	-- ==========================================
	-- ENTITY ESP TRACKING (FIXED ADORNEE OFFSET)
	-- ==========================================
	local EntityCount = 0
	local currentlyTrackedEntities = {}

	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") and table.find(Entitylist, v.Name) then
			EntityCount += 1
			currentlyTrackedEntities[v] = true

			-- If ESP isn't created yet
			if not activeGlowParts[v] then
				-- Create an anchor attachment in Terrain
				local entAtt = Instance.new("Attachment", workspace.Terrain)
				entAtt.Name = "ESP_Att_" .. v.Name

				local Clone = glowpartBB:Clone()
				Clone.Parent = guis -- Put inside the GUI to keep workspace clean
				Clone.Name = "GlowPart_" .. v.Name
				Clone.Adornee = entAtt -- Connect the Billboard to the Attachment
				Clone.StudsOffsetWorldSpace = Vector3.new(0, 0, 0) -- Reset offset to prevent glitching
				Clone.Enabled = true

				activeGlowParts[v] = {
					Gui = Clone,
					Att = entAtt
				}
			end

			-- Update the Attachment position instead of the GUI offset
			if activeGlowParts[v] then
				activeGlowParts[v].Att.WorldPosition = v:GetPivot().Position
			end
		end
	end
	
	local currt3DEntitytrack = {}
	
	if workspace:FindFirstChild("CurrentRooms") then
		local currentroom: Folder = workspace.CurrentRooms
		
		for i, v in pairs(currentroom:GetDescendants()) do
			
			currt3DEntitytrack[v] = true
			
			if v:IsA("Model") and v.Name == "FigureRig" then
				
				if nil  then
					return
				end
				
				if Highlight[v] then
					return
				end
				
				
				local Model = v
				
				local highlightRig = Instance.new("Highlight", Model)
				highlightRig.FillTransparency = 0.875
				highlightRig.OutlineColor = Color3.new(1, 0.333333, 0)
				highlightRig.OutlineTransparency = 1
				highlightRig.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlightRig.Enabled = true
				
				Highlight[v] = {
					HighlightOne = highlightRig;
				}
			end
		end
	end
	
	-- Clean up destroyed entities
	for entity, espData in pairs(activeGlowParts) do
		if not currentlyTrackedEntities[entity] then
			if espData.Gui then espData.Gui:Destroy() end
			if espData.Att then espData.Att:Destroy() end
			activeGlowParts[entity] = nil
		end
	end
	
	for i, v in pairs(Highlight) do
		if not currt3DEntitytrack[i] then
			if Highlight[v].HighlightOne then
				Highlight[v].HighlightOne:Destroy()
			end
		end
	end
	
	guis.Sound.PlaybackSpeed += (valueSpeed - guis.Sound.PlaybackSpeed) / 0.65
	numberoftanpo += (stt - numberoftanpo) / 0.65
	
	
	
	

	-- Audio Speed based on Entities
	if EntityCount == 0 or EntityCount < 0 then
		valueSpeed = normalspeed
		stt = 0.885
	else
		valueSpeed = foundspeed
		stt = 0.485
	end

end)
