-- Egg Manager (Improved UI + Features)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-------------------------------------------------
-- SETTINGS
-------------------------------------------------
local Settings = {
	TweenDuration = 5.0,
	MultiStepDelay = 0.45,
	MultiStepSteps = 14,
	AutoRefreshInterval = 12,          -- seconds
	NotificationDuration = 2.8,
}

-------------------------------------------------
-- STATE
-------------------------------------------------
local autoRefreshEnabled = false
local espEnabled = true
local isOpen = true
local currentSearch = ""
local eggButtons = {}          -- [button] = eggName
local espObjects = {}          -- [debugId] = BillboardGui

-------------------------------------------------
-- Cleanup old UI
-------------------------------------------------
if playerGui:FindFirstChild("EggTeleportUI") then
	playerGui.EggTeleportUI:Destroy()
end
if CoreGui:FindFirstChild("EggSizeESP") then
	CoreGui.EggSizeESP:Destroy()
end

-------------------------------------------------
-- MAIN UI
-------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggTeleportUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 540, 0, 520)
mainFrame.Position = UDim2.new(0, 30, 0.18, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(55, 55, 85)
mainStroke.Thickness = 1.2
mainStroke.Transparency = 0.25
mainStroke.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 16)
headerCover.Position = UDim2.new(0, 0, 1, -16)
headerCover.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
headerCover.BorderSizePixel = 0
headerCover.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Egg Manager"
title.TextColor3 = Color3.fromRGB(235, 235, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(55, 30, 35)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.AutoButtonColor = false
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Open Button (small floating button when closed)
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenBtn"
openBtn.Size = UDim2.new(0, 46, 0, 46)
openBtn.Position = UDim2.new(0, 20, 0.5, -23)
openBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
openBtn.Text = "Egg"
openBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 13
openBtn.Visible = false
openBtn.AutoButtonColor = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 12)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(80, 80, 130)
openStroke.Thickness = 1.2
openStroke.Parent = openBtn

-- Notification
local notifFrame = Instance.new("Frame")
notifFrame.Name = "Notification"
notifFrame.Size = UDim2.new(0, 280, 0, 36)
notifFrame.Position = UDim2.new(0.5, -140, 0, 20)
notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
notifFrame.BorderSizePixel = 0
notifFrame.Visible = false
notifFrame.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 10)
notifCorner.Parent = notifFrame

local notifStroke = Instance.new("UIStroke")
notifStroke.Color = Color3.fromRGB(70, 70, 110)
notifStroke.Thickness = 1
notifStroke.Parent = notifFrame

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, -16, 1, 0)
notifText.Position = UDim2.new(0, 8, 0, 0)
notifText.BackgroundTransparency = 1
notifText.TextColor3 = Color3.fromRGB(230, 230, 255)
notifText.Font = Enum.Font.GothamMedium
notifText.TextSize = 13
notifText.TextXAlignment = Enum.TextXAlignment.Center
notifText.Parent = notifFrame

-------------------------------------------------
-- Dragging
-------------------------------------------------
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

-------------------------------------------------
-- Panels
-------------------------------------------------
local leftPanel = Instance.new("ScrollingFrame")
leftPanel.Name = "LeftPanel"
leftPanel.Size = UDim2.new(0.5, -20, 1, -70)
leftPanel.Position = UDim2.new(0, 14, 0, 58)
leftPanel.BackgroundTransparency = 1
leftPanel.BorderSizePixel = 0
leftPanel.ScrollBarThickness = 3
leftPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
leftPanel.Parent = mainFrame

local leftList = Instance.new("UIListLayout")
leftList.Padding = UDim.new(0, 9)
leftList.SortOrder = Enum.SortOrder.LayoutOrder
leftList.Parent = leftPanel

local rightPanel = Instance.new("ScrollingFrame")
rightPanel.Name = "RightPanel"
rightPanel.Size = UDim2.new(0.5, -20, 1, -110)
rightPanel.Position = UDim2.new(0.5, 6, 0, 98)
rightPanel.BackgroundTransparency = 1
rightPanel.BorderSizePixel = 0
rightPanel.ScrollBarThickness = 3
rightPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
rightPanel.Parent = mainFrame

local rightList = Instance.new("UIListLayout")
rightList.Padding = UDim.new(0, 8)
rightList.SortOrder = Enum.SortOrder.LayoutOrder
rightList.Parent = rightPanel

-- Divider
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 1, -80)
divider.Position = UDim2.new(0.5, -0.5, 0, 58)
divider.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-- Search Box
local searchBox = Instance.new("TextBox")
searchBox.Name = "Search"
searchBox.Size = UDim2.new(0.5, -20, 0, 32)
searchBox.Position = UDim2.new(0.5, 6, 0, 58)
searchBox.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
searchBox.Text = ""
searchBox.PlaceholderText = "Search eggs..."
searchBox.TextColor3 = Color3.fromRGB(240, 240, 255)
searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 150)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.ClearTextOnFocus = false
searchBox.Parent = mainFrame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBox

local searchPadding = Instance.new("UIPadding")
searchPadding.PaddingLeft = UDim.new(0, 10)
searchPadding.Parent = searchBox

-------------------------------------------------
-- Helpers
-------------------------------------------------
local function notify(msg)
	notifText.Text = msg
	notifFrame.Visible = true
	notifFrame.BackgroundTransparency = 0
	notifText.TextTransparency = 0

	task.delay(Settings.NotificationDuration, function()
		local t1 = TweenService:Create(notifFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1})
		local t2 = TweenService:Create(notifText, TweenInfo.new(0.4), {TextTransparency = 1})
		t1:Play()
		t2:Play()
		t1.Completed:Wait()
		notifFrame.Visible = false
	end)
end

local function createAdvancedControl(parent, labelText, minVal, maxVal, defaultVal, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 70)
	frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -80, 0, 18)
	titleLabel.Position = UDim2.new(0, 10, 0, 6)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = labelText
	titleLabel.TextColor3 = Color3.fromRGB(190, 190, 220)
	titleLabel.Font = Enum.Font.GothamMedium
	titleLabel.TextSize = 12
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = frame

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(0, 60, 0, 20)
	textBox.Position = UDim2.new(1, -70, 0, 5)
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
	track.Size = UDim2.new(1, -20, 0, 6)
	track.Position = UDim2.new(0, 10, 0, 40)
	track.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	track.BorderSizePixel = 0
	track.Parent = frame

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(95, 130, 255)
	fill.BorderSizePixel = 0
	fill.Parent = track

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 14, 0, 14)
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
		knob.Position = UDim2.new(alpha, -7, 0.5, -7)
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
	btn.Size = UDim2.new(1, 0, 0, 38)
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
				math.min(bgColor.R + 0.09, 1),
				math.min(bgColor.G + 0.09, 1),
				math.min(bgColor.B + 0.09, 1)
			)
		}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = bgColor}):Play()
	end)

	btn.MouseButton1Click:Connect(callback)
	return btn
end

-------------------------------------------------
-- Teleport Helpers
-------------------------------------------------
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

	TweenService:Create(hrp, TweenInfo.new(Settings.TweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = base:GetPivot() * CFrame.new(0, 5, 0)
	}):Play()
	notify("Tweening to base...")
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

	notify("Multi-step started")

	for i = 1, Settings.MultiStepSteps do
		local targetPos = start:Lerp(goal, i / Settings.MultiStepSteps)
		local ray = workspace:Raycast(targetPos + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), rayParams)
		if ray then
			targetPos = Vector3.new(targetPos.X, ray.Position.Y + 3, targetPos.Z)
		end
		hrp.CFrame = CFrame.new(targetPos)
		task.wait(Settings.MultiStepDelay)
	end

	notify("Multi-step finished")
end

-------------------------------------------------
-- Egg List + Search
-------------------------------------------------
local function clearEggButtons()
	for btn in pairs(eggButtons) do
		btn:Destroy()
	end
	eggButtons = {}
end

local function refreshEggs()
	clearEggButtons()

	local rendered = workspace:FindFirstChild("RenderedEggs")
	if not rendered then
		notify("No RenderedEggs found")
		return
	end

	local unique = {}
	local count = 0

	for _, egg in ipairs(rendered:GetChildren()) do
		if not unique[egg.Name] then
			unique[egg.Name] = true

			-- Apply search filter
			if currentSearch == "" or egg.Name:lower():find(currentSearch:lower(), 1, true) then
				count += 1
				local btn = createButton(rightPanel, "Egg • " .. egg.Name, Color3.fromRGB(36, 36, 50), function()
					teleportTo(egg)
					notify("Teleported to " .. egg.Name)
				end)
				eggButtons[btn] = egg.Name
			end
		end
	end

	notify("Loaded " .. count .. " eggs")
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	currentSearch = searchBox.Text
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
	if not espEnabled then return end

	local id = tostring(egg:GetDebugId())
	if espObjects[id] then return end

	local part = egg:FindFirstChild("EggBase") or egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = id
	billboard.Adornee = part
	billboard.Size = UDim2.new(0, 140, 0, 42)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = ESPFolder

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.Parent = billboard

	local text, color = getSizeLabel(egg)
	label.Text = egg.Name .. "\n" .. text
	label.TextColor3 = color

	espObjects[id] = billboard
end

local function clearAllESP()
	for id, gui in pairs(espObjects) do
		gui:Destroy()
	end
	espObjects = {}
end

-- ESP updater (cleaner)
task.spawn(function()
	while task.wait(0.7) do
		if not espEnabled then
			clearAllESP()
			continue
		end

		local folder = workspace:FindFirstChild("RenderedEggs")
		if not folder then
			clearAllESP()
			continue
		end

		local alive = {}

		for _, egg in ipairs(folder:GetChildren()) do
			local id = tostring(egg:GetDebugId())
			alive[id] = true
			createESP(egg)
		end

		-- Clean dead ones
		for id, gui in pairs(espObjects) do
			if not alive[id] then
				gui:Destroy()
				espObjects[id] = nil
			end
		end
	end
end)

-------------------------------------------------
-- Controls
-------------------------------------------------
createAdvancedControl(leftPanel, "Tween Speed (s)", 2.0, 12.0, Settings.TweenDuration, function(v)
	Settings.TweenDuration = v
end)

createAdvancedControl(leftPanel, "Multi-Step Delay (s)", 0.20, 1.20, Settings.MultiStepDelay, function(v)
	Settings.MultiStepDelay = v
end)

createButton(leftPanel, "Instant Return to Base", Color3.fromRGB(30, 100, 70), function()
	local base = getBase()
	if base then
		teleportTo(base)
		notify("Returned to base")
	else
		notify("Base not found")
	end
end)

createButton(leftPanel, "Smooth Tween to Base", Color3.fromRGB(40, 85, 150), function()
	tweenToBase()
end)

createButton(leftPanel, "Multi-Step (Grounded)", Color3.fromRGB(90, 55, 140), function()
	multiStepToBase()
end)

-- ESP Toggle
local espBtn
espBtn = createButton(leftPanel, "ESP: ON", Color3.fromRGB(40, 110, 70), function()
	espEnabled = not espEnabled
	if espEnabled then
		espBtn.Text = "ESP: ON"
		espBtn.BackgroundColor3 = Color3.fromRGB(40, 110, 70)
		notify("ESP enabled")
	else
		espBtn.Text = "ESP: OFF"
		espBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 40)
		clearAllESP()
		notify("ESP disabled")
	end
end)

-- Auto Refresh Toggle
local autoBtn
autoBtn = createButton(leftPanel, "Auto Refresh: OFF", Color3.fromRGB(90, 40, 40), function()
	autoRefreshEnabled = not autoRefreshEnabled
	if autoRefreshEnabled then
		autoBtn.Text = "Auto Refresh: ON"
		autoBtn.BackgroundColor3 = Color3.fromRGB(40, 110, 70)
		notify("Auto refresh enabled")
	else
		autoBtn.Text = "Auto Refresh: OFF"
		autoBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 40)
		notify("Auto refresh disabled")
	end
end)

createButton(rightPanel, "Refresh Eggs", Color3.fromRGB(45, 45, 70), function()
	refreshEggs()
end)

-------------------------------------------------
-- Close / Open
-------------------------------------------------
closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	openBtn.Visible = true
	isOpen = false
	notify("UI closed")
end)

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openBtn.Visible = false
	isOpen = true
end)

-- Hover effects for close/open
closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(90, 35, 45)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 30, 35)}):Play()
end)

-------------------------------------------------
-- Auto Refresh Loop
-------------------------------------------------
task.spawn(function()
	while task.wait(Settings.AutoRefreshInterval) do
		if autoRefreshEnabled and isOpen then
			refreshEggs()
		end
	end
end)

-- Initial load
refreshEggs()
notify("Egg Manager loaded")
print("Egg Manager (Improved) loaded")
