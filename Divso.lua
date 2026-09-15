-- Egg Manager (Ride a Pet) - Fixed Refresh + Exact Rarities

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Settings
local TWEEN_DURATION = 5.0
local MULTISTEP_DELAY = 0.45
local MULTISTEP_STEPS = 14
local AUTO_KEY = Enum.KeyCode.F

-- Exact rarity priority
local RARITY_PRIORITY = {
	["Ethereal"]  = 80,
	["Divine"]    = 70,
	["Mythic"]    = 60,
	["Legendary"] = 50,
	["Epic"]      = 40,
	["Rare"]      = 30,
	["Uncommon"]  = 20,
	["Common"]    = 10,
}

-- State
local autoFarmEnabled = false
local sortedEggs = {}
local filteredEggs = {}
local currentAutoIndex = 1
local enabledRarities = {}
local rarityButtons = {}

-- Cleanup
if playerGui:FindFirstChild("EggTeleportUI") then
	playerGui.EggTeleportUI:Destroy()
end

-------------------------------------------------
-- UI
-------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggTeleportUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 540, 0, 580)
mainFrame.Position = UDim2.new(0, 30, 0.12, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(70, 70, 110)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 16)
headerCover.Position = UDim2.new(0, 0, 1, -16)
headerCover.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
headerCover.BorderSizePixel = 0
headerCover.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Egg Manager"
title.TextColor3 = Color3.fromRGB(240, 240, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Dragging
local dragging, dragStart, startPos = false, nil, nil

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- Left Panel
local leftPanel = Instance.new("ScrollingFrame")
leftPanel.Name = "LeftPanel"
leftPanel.Size = UDim2.new(0.5, -18, 1, -62)
leftPanel.Position = UDim2.new(0, 12, 0, 54)
leftPanel.BackgroundTransparency = 1
leftPanel.BorderSizePixel = 0
leftPanel.ScrollBarThickness = 4
leftPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
leftPanel.Parent = mainFrame

local leftList = Instance.new("UIListLayout")
leftList.Padding = UDim.new(0, 8)
leftList.SortOrder = Enum.SortOrder.LayoutOrder
leftList.Parent = leftPanel

-- Right Panel
local rightPanel = Instance.new("ScrollingFrame")
rightPanel.Name = "RightPanel"
rightPanel.Size = UDim2.new(0.5, -18, 1, -62)
rightPanel.Position = UDim2.new(0.5, 6, 0, 54)
rightPanel.BackgroundTransparency = 1
rightPanel.BorderSizePixel = 0
rightPanel.ScrollBarThickness = 4
rightPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
rightPanel.Parent = mainFrame

local rightList = Instance.new("UIListLayout")
rightList.Padding = UDim.new(0, 8)
rightList.SortOrder = Enum.SortOrder.LayoutOrder
rightList.Parent = rightPanel

-- Divider
local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.Size = UDim2.new(0, 1, 1, -70)
divider.Position = UDim2.new(0.5, -0.5, 0, 54)
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-------------------------------------------------
-- Helpers
-------------------------------------------------
local function createAdvancedControl(parent, labelText, minVal, maxVal, defaultVal, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 72)
	frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -80, 0, 18)
	titleLabel.Position = UDim2.new(0, 10, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = labelText
	titleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	titleLabel.Font = Enum.Font.GothamMedium
	titleLabel.TextSize = 12
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = frame

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(0, 64, 0, 20)
	textBox.Position = UDim2.new(1, -72, 0, 4)
	textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	textBox.Text = tostring(defaultVal)
	textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 12
	textBox.ClearTextOnFocus = false
	textBox.Parent = frame

	local tbCorner = Instance.new("UICorner")
	tbCorner.CornerRadius = UDim.new(0, 6)
	tbCorner.Parent = textBox

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 7)
	track.Position = UDim2.new(0, 10, 0, 40)
	track.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	track.BorderSizePixel = 0
	track.Parent = frame

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(90, 130, 255)
	fill.BorderSizePixel = 0
	fill.Parent = track

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.Parent = track

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local sliding = false

	local function setValue(val)
		val = math.clamp(val, minVal, maxVal)
		val = math.floor(val * 100 + 0.5) / 100
		local alpha = (val - minVal) / (maxVal - minVal)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, -8, 0.5, -8)
		textBox.Text = tostring(val)
		callback(val)
	end

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local rel = input.Position.X - track.AbsolutePosition.X
			local alpha = math.clamp(rel / track.AbsoluteSize.X, 0, 1)
			setValue(minVal + (maxVal - minVal) * alpha)
		end
	end)

	textBox.FocusLost:Connect(function()
		local num = tonumber(textBox.Text)
		if num then setValue(num) else textBox.Text = tostring(defaultVal) end
	end)

	setValue(defaultVal)
end

local function createButton(parent, text, bgColor, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.BackgroundColor3 = bgColor
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 13
	btn.AutoButtonColor = false
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.new(
				math.min(bgColor.R + 0.08, 1),
				math.min(bgColor.G + 0.08, 1),
				math.min(bgColor.B + 0.08, 1)
			)
		}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = bgColor}):Play()
	end)

	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function getBase()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	local plot = plots:FindFirstChild("Plot")
	if not plot then return nil end
	return plot:FindFirstChild("Baseplate")
end

local function teleportTo(target)
	local char = player.Character
	if not char or not target then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = target:GetPivot() * CFrame.new(0, 5, 0)
	end
end

local function tweenToBase()
	local base = getBase()
	local char = player.Character
	if not base or not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	TweenService:Create(hrp, TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = base:GetPivot() * CFrame.new(0, 5, 0)
	}):Play()
end

local function multiStepToBase()
	local base = getBase()
	local char = player.Character
	if not base or not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local start = hrp.Position
	local goal = (base:GetPivot() * CFrame.new(0, 3, 0)).Position

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {char}

	for i = 1, MULTISTEP_STEPS do
		local targetPos = start:Lerp(goal, i / MULTISTEP_STEPS)
		local ray = workspace:Raycast(targetPos + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), rayParams)
		if ray then
			targetPos = Vector3.new(targetPos.X, ray.Position.Y + 3, targetPos.Z)
		end
		hrp.CFrame = CFrame.new(targetPos)
		task.wait(MULTISTEP_DELAY)
	end
	print("Grounded multi-step finished")
end

-------------------------------------------------
-- Better Egg Detection
-------------------------------------------------
local function isEgg(obj)
	if not obj then return false end
	if obj:IsA("Model") or obj:IsA("BasePart") then
		-- Accept almost anything that looks like an egg
		if obj:FindFirstChild("EggBase") or obj.PrimaryPart or obj.Name:lower():find("egg") then
			return true
		end
		-- Also accept if it has any BasePart
		if obj:FindFirstChildWhichIsA("BasePart", true) then
			return true
		end
	end
	return false
end

local function getRarityScore(rarityName)
	return RARITY_PRIORITY[rarityName] or 5
end

local function rebuildFilteredList()
	filteredEggs = {}
	for _, data in ipairs(sortedEggs) do
		if enabledRarities[data.rarity] then
			table.insert(filteredEggs, data)
		end
	end
	currentAutoIndex = 1
	print("Filter active → " .. #filteredEggs .. " eggs")
end

local function refreshEggs()
	print("=== Refreshing Eggs ===")

	-- Clear right panel egg buttons
	for _, child in ipairs(rightPanel:GetChildren()) do
		if child:IsA("TextButton") and child.Text:find("•") then
			child:Destroy()
		end
	end

	-- Clear old rarity filter buttons
	for _, btn in pairs(rarityButtons) do
		if btn and btn.Parent then
			btn:Destroy()
		end
	end
	rarityButtons = {}

	local eggSpawns = workspace:FindFirstChild("EggSpawns")
	if not eggSpawns then
		warn("workspace.EggSpawns not found!")
		return
	end

	sortedEggs = {}
	local unique = {}
	local foundRarities = {}
	local totalFound = 0

	for _, rarityFolder in ipairs(eggSpawns:GetChildren()) do
		if rarityFolder:IsA("Folder") or rarityFolder:IsA("Model") then
			local rarityName = rarityFolder.Name
			foundRarities[rarityName] = true
			local score = getRarityScore(rarityName)

			-- Look deeper (GetDescendants) in case eggs are nested
			for _, obj in ipairs(rarityFolder:GetDescendants()) do
				if isEgg(obj) and not unique[obj.Name] then
					unique[obj.Name] = true
					table.insert(sortedEggs, {
						egg = obj,
						name = obj.Name,
						rarity = rarityName,
						score = score
					})
					totalFound += 1
				end
			end

			-- Also check direct children
			for _, obj in ipairs(rarityFolder:GetChildren()) do
				if isEgg(obj) and not unique[obj.Name] then
					unique[obj.Name] = true
					table.insert(sortedEggs, {
						egg = obj,
						name = obj.Name,
						rarity = rarityName,
						score = score
					})
					totalFound += 1
				end
			end
		end
	end

	print("Found " .. totalFound .. " unique eggs")

	-- Sort
	table.sort(sortedEggs, function(a, b)
		if a.score == b.score then
			return a.name < b.name
		end
		return a.score > b.score
	end)

	-- Create buttons
	for _, data in ipairs(sortedEggs) do
		local color = Color3.fromRGB(38, 38, 52)

		if data.rarity == "Ethereal" then
			color = Color3.fromRGB(180, 80, 255)
		elseif data.rarity == "Divine" then
			color = Color3.fromRGB(255, 215, 80)
		elseif data.rarity == "Mythic" then
			color = Color3.fromRGB(160, 50, 200)
		elseif data.rarity == "Legendary" then
			color = Color3.fromRGB(255, 170, 40)
		elseif data.rarity == "Epic" then
			color = Color3.fromRGB(170, 60, 200)
		elseif data.rarity == "Rare" then
			color = Color3.fromRGB(50, 120, 255)
		elseif data.rarity == "Uncommon" then
			color = Color3.fromRGB(50, 180, 90)
		elseif data.rarity == "Common" then
			color = Color3.fromRGB(140, 140, 150)
		end

		createButton(rightPanel, data.rarity .. " • " .. data.name, color, function()
			teleportTo(data.egg)
		end)
	end

	-- Create filter toggles in correct order
	local ordered = {"Ethereal", "Divine", "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"}

	for _, rarityName in ipairs(ordered) do
		if foundRarities[rarityName] then
			if enabledRarities[rarityName] == nil then
				enabledRarities[rarityName] = true
			end

			local isOn = enabledRarities[rarityName]
			local btnColor = isOn and Color3.fromRGB(40, 110, 70) or Color3.fromRGB(70, 40, 40)

			local btn = createButton(leftPanel, (isOn and "ON  " or "OFF ") .. rarityName, btnColor, function()
				enabledRarities[rarityName] = not enabledRarities[rarityName]
				local newState = enabledRarities[rarityName]
				btn.Text = (newState and "ON  " or "OFF ") .. rarityName
				btn.BackgroundColor3 = newState and Color3.fromRGB(40, 110, 70) or Color3.fromRGB(70, 40, 40)
				rebuildFilteredList()
			end)

			rarityButtons[rarityName] = btn
		end
	end

	rebuildFilteredList()
	print("Refresh complete")
end

-------------------------------------------------
-- Semi-Auto
-------------------------------------------------
local function doAutoTeleport()
	if #filteredEggs == 0 then
		refreshEggs()
		if #filteredEggs == 0 then
			print("No eggs match your current filter")
			return
		end
	end

	local attempts = 0
	while attempts < #filteredEggs do
		local data = filteredEggs[currentAutoIndex]
		if data and data.egg and data.egg.Parent then
			teleportTo(data.egg)
			print("Auto → " .. data.rarity .. " • " .. data.name)
			currentAutoIndex = currentAutoIndex % #filteredEggs + 1
			return
		end
		currentAutoIndex = currentAutoIndex % #filteredEggs + 1
		attempts += 1
	end

	refreshEggs()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == AUTO_KEY and autoFarmEnabled then
		doAutoTeleport()
	end
end)

-------------------------------------------------
-- Controls
-------------------------------------------------
createAdvancedControl(leftPanel, "Tween Speed (s)", 2.0, 12.0, 5.0, function(v)
	TWEEN_DURATION = v
end)

createAdvancedControl(leftPanel, "Multi-Step Delay (s)", 0.20, 1.20, 0.45, function(v)
	MULTISTEP_DELAY = v
end)

createButton(leftPanel, "Instant Return to Base", Color3.fromRGB(32, 95, 65), function()
	local base = getBase()
	if base then teleportTo(base) end
end)

createButton(leftPanel, "Smooth Tween to Base", Color3.fromRGB(35, 80, 140), function()
	tweenToBase()
end)

createButton(leftPanel, "Multi-Step (Grounded)", Color3.fromRGB(85, 55, 130), function()
	multiStepToBase()
end)

local autoBtn
autoBtn = createButton(leftPanel, "Semi-Auto Farm: OFF  (F)", Color3.fromRGB(90, 40, 40), function()
	autoFarmEnabled = not autoFarmEnabled
	if autoFarmEnabled then
		autoBtn.Text = "Semi-Auto Farm: ON   (F)"
		autoBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
		print("Semi-Auto ON")
	else
		autoBtn.Text = "Semi-Auto Farm: OFF  (F)"
		autoBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 40)
		print("Semi-Auto OFF")
	end
end)

local filterLabel = Instance.new("TextLabel")
filterLabel.Size = UDim2.new(1, 0, 0, 22)
filterLabel.BackgroundTransparency = 1
filterLabel.Text = "— Rarity Filter —"
filterLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
filterLabel.Font = Enum.Font.GothamMedium
filterLabel.TextSize = 12
filterLabel.Parent = leftPanel

createButton(rightPanel, "Refresh Eggs", Color3.fromRGB(45, 45, 70), function()
	refreshEggs()
end)

-------------------------------------------------
-- ESP
-------------------------------------------------
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "EggSizeESP"
ESPFolder.Parent = CoreGui

local function getSizeLabel(egg)
	local size = egg:GetExtentsSize()
	local volume = size.X * size.Y * size.Z
	if volume > 80 then return "HUGE", Color3.fromRGB(255, 70, 70)
	elseif volume > 40 then return "Large", Color3.fromRGB(255, 175, 50)
	elseif volume > 18 then return "Medium", Color3.fromRGB(60, 255, 130)
	else return "Small", Color3.fromRGB(170, 170, 180) end
end

local function createESP(egg)
	local id = egg.Name .. "_" .. egg:GetDebugId()
	if ESPFolder:FindFirstChild(id) then return end

	local part = egg:FindFirstChild("EggBase") or egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = id
	billboard.Adornee = part
	billboard.Size = UDim2.new(0, 140, 0, 44)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = ESPFolder

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextStrokeTransparency = 0.25
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.Parent = billboard

	local text, color = getSizeLabel(egg)
	label.Text = egg.Name .. "\n" .. text
	label.TextColor3 = color
end

task.spawn(function()
	while task.wait(0.8) do
		local eggSpawns = workspace:FindFirstChild("EggSpawns")
		if not eggSpawns then continue end

		for _, esp in ipairs(ESPFolder:GetChildren()) do
			local stillExists = false
			for _, rarityFolder in ipairs(eggSpawns:GetChildren()) do
				for _, obj in ipairs(rarityFolder:GetDescendants()) do
					if esp.Name:find(obj:GetDebugId()) then
						stillExists = true
						break
					end
				end
				if stillExists then break end
			end
			if not stillExists then esp:Destroy() end
		end

		for _, rarityFolder in ipairs(eggSpawns:GetChildren()) do
			for _, obj in ipairs(rarityFolder:GetDescendants()) do
				if isEgg(obj) then
					createESP(obj)
				end
			end
		end
	end
end)

-- Start
refreshEggs()
print("Egg Manager loaded - Fixed Refresh")
