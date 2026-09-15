-- Divine Soul - Ride a Pet

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-------------------------------------------------
-- SETTINGS + SAVE SYSTEM
-------------------------------------------------
local SAVE_FILE = "DivineSoul_RideAPet_Settings.json"

local Settings = {
	TweenDuration = 8.0,
	MultiStepDelay = 0.8,
	MultiStepSteps = 14,
	AutoRefreshInterval = 3,
	NotificationDuration = 2.6,
	ESPEnabled = true,
	AutoRefreshEnabled = false,
	EnabledRarities = {
		Ethereal = true,
		Divine = true,
		Mythic = true,
		Legendary = true,
		Epic = true,
		Rare = true,
		Uncommon = true,
		Common = true,
	},
}

local function loadSettings()
	if isfile and readfile and isfile(SAVE_FILE) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(SAVE_FILE))
		end)
		if success and type(data) == "table" then
			for k, v in pairs(data) do
				if Settings[k] ~= nil then
					Settings[k] = v
				end
			end
		end
	end
end

local function saveSettings()
	if writefile then
		local success, encoded = pcall(function()
			return HttpService:JSONEncode(Settings)
		end)
		if success then
			pcall(writefile, SAVE_FILE, encoded)
		end
	end
end

loadSettings()

-------------------------------------------------
-- RARITY SYSTEM (EDIT THIS PART MANUALLY)
-------------------------------------------------
local Rarities = {
	"Ethereal",
	"Divine",
	"Mythic",
	"Legendary",
	"Epic",
	"Rare",
	"Uncommon",
	"Common"
}

-- Manually put egg names under the rarity you want
local RarityEggs = {
	Ethereal = { "Cherub Egg" },
	Divine = { "Blackhole Egg", "Galaxy Egg", "Aurora Egg" },
	Mythic = { },
	Legendary = { },
	Epic = { },
	Rare = { },
	Uncommon = { },
	Common = { },
}

-------------------------------------------------
-- STATE
-------------------------------------------------
local isOpen = true
local currentSearch = ""
local eggButtons = {}
local espObjects = {}
local espEnabled = Settings.ESPEnabled
local autoRefreshEnabled = Settings.AutoRefreshEnabled
local enabledRarities = Settings.EnabledRarities
local rarityButtons = {}

-------------------------------------------------
-- Cleanup
-------------------------------------------------
if playerGui:FindFirstChild("DivineSoulUI") then
	playerGui.DivineSoulUI:Destroy()
end
if CoreGui:FindFirstChild("EggSizeESP") then
	CoreGui.EggSizeESP:Destroy()
end

-------------------------------------------------
-- MAIN UI
-------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DivineSoulUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 680, 0, 500)
main.Position = UDim2.new(0.5, -340, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(45, 45, 60)
mainStroke.Thickness = 1
mainStroke.Parent = main

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 150, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 12)
sideCorner.Parent = sidebar

local sideCover = Instance.new("Frame")
sideCover.Size = UDim2.new(0, 16, 1, 0)
sideCover.Position = UDim2.new(1, -16, 0, 0)
sideCover.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
sideCover.BorderSizePixel = 0
sideCover.Parent = sidebar

local sideTitle = Instance.new("TextLabel")
sideTitle.Size = UDim2.new(1, -16, 0, 36)
sideTitle.Position = UDim2.new(0, 10, 0, 8)
sideTitle.BackgroundTransparency = 1
sideTitle.Text = "Divine Soul"
sideTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
sideTitle.Font = Enum.Font.GothamBold
sideTitle.TextSize = 15
sideTitle.TextXAlignment = Enum.TextXAlignment.Left
sideTitle.Parent = sidebar

local sideSub = Instance.new("TextLabel")
sideSub.Size = UDim2.new(1, -16, 0, 16)
sideSub.Position = UDim2.new(0, 10, 0, 36)
sideSub.BackgroundTransparency = 1
sideSub.Text = "Ride a Pet"
sideSub.TextColor3 = Color3.fromRGB(140, 140, 170)
sideSub.Font = Enum.Font.Gotham
sideSub.TextSize = 11
sideSub.TextXAlignment = Enum.TextXAlignment.Left
sideSub.Parent = sidebar

-- Content
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -160, 1, -16)
content.Position = UDim2.new(0, 155, 0, 8)
content.BackgroundTransparency = 1
content.Parent = main

local headerBar = Instance.new("Frame")
headerBar.Size = UDim2.new(1, 0, 0, 40)
headerBar.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
headerBar.BorderSizePixel = 0
headerBar.Parent = content

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 9)
headerCorner.Parent = headerBar

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -50, 1, 0)
headerTitle.Position = UDim2.new(0, 12, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "Controls & Eggs"
headerTitle.TextColor3 = Color3.fromRGB(230, 230, 255)
headerTitle.Font = Enum.Font.GothamMedium
headerTitle.TextSize = 14
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = headerBar

-- Close button (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 26)
closeBtn.Position = UDim2.new(1, -38, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 35)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 17
closeBtn.AutoButtonColor = false
closeBtn.Parent = headerBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Open / Toggle button (DS)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 48, 0, 48)
openBtn.Position = UDim2.new(0, 40, 0, 100)
openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
openBtn.Text = "DS"
openBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.Visible = true
openBtn.AutoButtonColor = false
openBtn.Active = true
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 12)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(70, 70, 110)
openStroke.Thickness = 1.2
openStroke.Parent = openBtn

-- Notification
local notif = Instance.new("Frame")
notif.Size = UDim2.new(0, 260, 0, 34)
notif.Position = UDim2.new(0.5, -130, 0, 18)
notif.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
notif.BorderSizePixel = 0
notif.Visible = false
notif.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 9)
notifCorner.Parent = notif

local notifStroke = Instance.new("UIStroke")
notifStroke.Color = Color3.fromRGB(60, 60, 90)
notifStroke.Thickness = 1
notifStroke.Parent = notif

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, -12, 1, 0)
notifText.Position = UDim2.new(0, 6, 0, 0)
notifText.BackgroundTransparency = 1
notifText.TextColor3 = Color3.fromRGB(230, 230, 255)
notifText.Font = Enum.Font.GothamMedium
notifText.TextSize = 13
notifText.TextXAlignment = Enum.TextXAlignment.Center
notifText.Parent = notif

-------------------------------------------------
-- Dragging
-------------------------------------------------
local dragging, dragStart, startPos = false, nil, nil

headerBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

headerBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Open button drag
local openDragging = false
local openDragStart, openStartPos, openMoved = false, nil, nil

openBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		openDragging = true
		openMoved = false
		openDragStart = input.Position
		openStartPos = openBtn.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if openDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		openDragging = false
		if not openMoved then
			isOpen = not isOpen
			main.Visible = isOpen
			notify(isOpen and "UI opened" or "UI closed")
			if not isOpen then saveSettings() end
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if openDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - openDragStart
		if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
			openMoved = true
		end
		openBtn.Position = UDim2.new(openStartPos.X.Scale, openStartPos.X.Offset + delta.X, openStartPos.Y.Scale, openStartPos.Y.Offset + delta.Y)
	end
end)

-------------------------------------------------
-- Content Layout
-------------------------------------------------
local leftContent = Instance.new("ScrollingFrame")
leftContent.Size = UDim2.new(0.42, 0, 1, -50)
leftContent.Position = UDim2.new(0, 0, 0, 48)
leftContent.BackgroundTransparency = 1
leftContent.BorderSizePixel = 0
leftContent.ScrollBarThickness = 3
leftContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
leftContent.Parent = content

local leftList = Instance.new("UIListLayout")
leftList.Padding = UDim.new(0, 7)
leftList.SortOrder = Enum.SortOrder.LayoutOrder
leftList.Parent = leftContent

local rightContent = Instance.new("ScrollingFrame")
rightContent.Size = UDim2.new(0.55, 0, 1, -95)
rightContent.Position = UDim2.new(0.44, 0, 0, 88)
rightContent.BackgroundTransparency = 1
rightContent.BorderSizePixel = 0
rightContent.ScrollBarThickness = 3
rightContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
rightContent.Parent = content

local rightList = Instance.new("UIListLayout")
rightList.Padding = UDim.new(0, 6)
rightList.SortOrder = Enum.SortOrder.LayoutOrder
rightList.Parent = rightContent

-- Search
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.55, 0, 0, 32)
searchBox.Position = UDim2.new(0.44, 0, 0, 48)
searchBox.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
searchBox.Text = ""
searchBox.PlaceholderText = "Search eggs..."
searchBox.TextColor3 = Color3.fromRGB(240, 240, 255)
searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 150)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.ClearTextOnFocus = false
searchBox.Parent = content

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBox

local searchPad = Instance.new("UIPadding")
searchPad.PaddingLeft = UDim.new(0, 10)
searchPad.Parent = searchBox

-------------------------------------------------
-- Helpers
-------------------------------------------------
local function notify(msg)
	notifText.Text = msg
	notif.Visible = true
	notif.BackgroundTransparency = 0
	notifText.TextTransparency = 0

	task.delay(Settings.NotificationDuration, function()
		local t1 = TweenService:Create(notif, TweenInfo.new(0.35), {BackgroundTransparency = 1})
		local t2 = TweenService:Create(notifText, TweenInfo.new(0.35), {TextTransparency = 1})
		t1:Play()
		t2:Play()
		t1.Completed:Wait()
		notif.Visible = false
	end)
end

local function createSection(parent, title)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = title
	label.TextColor3 = Color3.fromRGB(140, 140, 170)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
end

local function createToggle(parent, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 34)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -55, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 240)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 40, 0, 20)
	toggle.Position = UDim2.new(1, -48, 0.5, -10)
	toggle.BackgroundColor3 = default and Color3.fromRGB(50, 140, 80) or Color3.fromRGB(60, 60, 75)
	toggle.Text = ""
	toggle.AutoButtonColor = false
	toggle.Parent = frame

	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(1, 0)
	tCorner.Parent = toggle

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = toggle

	local kCorner = Instance.new("UICorner")
	kCorner.CornerRadius = UDim.new(1, 0)
	kCorner.Parent = knob

	local state = default

	toggle.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(toggle, TweenInfo.new(0.18), {
			BackgroundColor3 = state and Color3.fromRGB(50, 140, 80) or Color3.fromRGB(60, 60, 75)
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.18), {
			Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		}):Play()
		callback(state)
		saveSettings()
	end)
end

local function createButton(parent, text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 13
	btn.AutoButtonColor = false
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.new(math.min(color.R + 0.08, 1), math.min(color.G + 0.08, 1), math.min(color.B + 0.08, 1))
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
	end)

	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function createSlider(parent, labelText, minV, maxV, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 54)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -65, 0, 16)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = labelText
	title.TextColor3 = Color3.fromRGB(190, 190, 220)
	title.Font = Enum.Font.Gotham
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local valueBox = Instance.new("TextBox")
	valueBox.Size = UDim2.new(0, 48, 0, 16)
	valueBox.Position = UDim2.new(1, -56, 0, 5)
	valueBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	valueBox.Text = tostring(default)
	valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueBox.Font = Enum.Font.Gotham
	valueBox.TextSize = 12
	valueBox.ClearTextOnFocus = false
	valueBox.Parent = frame

	local vbCorner = Instance.new("UICorner")
	vbCorner.CornerRadius = UDim.new(0, 5)
	vbCorner.Parent = valueBox

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 5)
	track.Position = UDim2.new(0, 10, 0, 32)
	track.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
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
	knob.Size = UDim2.new(0, 13, 0, 13)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.Parent = track

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local sliding = false

	local function set(val)
		val = math.clamp(val, minV, maxV)
		val = math.floor(val * 100 + 0.5) / 100
		local a = (val - minV) / (maxV - minV)
		fill.Size = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, -6, 0.5, -6)
		valueBox.Text = tostring(val)
		callback(val)
		saveSettings()
	end

	knob.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local rel = i.Position.X - track.AbsolutePosition.X
			set(minV + (maxV - minV) * math.clamp(rel / track.AbsoluteSize.X, 0, 1))
		end
	end)
	valueBox.FocusLost:Connect(function()
		local n = tonumber(valueBox.Text)
		if n then set(n) else valueBox.Text = tostring(default) end
	end)

	set(default)
end

-------------------------------------------------
-- Teleport
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
		local pos = start:Lerp(goal, i / Settings.MultiStepSteps)
		local ray = workspace:Raycast(pos + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), rayParams)
		if ray then pos = Vector3.new(pos.X, ray.Position.Y + 3, pos.Z) end
		hrp.CFrame = CFrame.new(pos)
		task.wait(Settings.MultiStepDelay)
	end
	notify("Multi-step finished")
end

-------------------------------------------------
-- Eggs (Multiple Rarity Support)
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

	-- Build list of allowed egg names from all enabled rarities
	local allowed = {}
	for rarity, isEnabled in pairs(enabledRarities) do
		if isEnabled and RarityEggs[rarity] then
			for _, name in ipairs(RarityEggs[rarity]) do
				allowed[name] = true
			end
		end
	end

	local count = 0

	for _, egg in ipairs(rendered:GetChildren()) do
		if allowed[egg.Name] then
			if currentSearch == "" or egg.Name:lower():find(currentSearch:lower(), 1, true) then
				count += 1
				local btn = createButton(rightContent, egg.Name, Color3.fromRGB(36, 36, 48), function()
					teleportTo(egg)
					notify("Teleported to " .. egg.Name)
				end)
				eggButtons[btn] = egg.Name
			end
		end
	end

	notify("Showing " .. count .. " eggs")
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	currentSearch = searchBox.Text
	refreshEggs()
end)

-------------------------------------------------
-- Rarity Buttons (Multi Select)
-------------------------------------------------
local function updateRarityButtons()
	for rarity, btn in pairs(rarityButtons) do
		if enabledRarities[rarity] then
			btn.BackgroundColor3 = Color3.fromRGB(45, 110, 70)
			btn.Text = "ON  " .. rarity
		else
			btn.BackgroundColor3 = Color3.fromRGB(55, 35, 40)
			btn.Text = "OFF " .. rarity
		end
	end
end

local function createRarityButton(rarity)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -12, 0, 28)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
	btn.Text = rarity
	btn.TextColor3 = Color3.fromRGB(230, 230, 255)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	btn.AutoButtonColor = false
	btn.Parent = sidebar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		enabledRarities[rarity] = not enabledRarities[rarity]
		Settings.EnabledRarities = enabledRarities
		updateRarityButtons()
		refreshEggs()
		saveSettings()
	end)

	rarityButtons[rarity] = btn
	return btn
end

-- Create rarity buttons
local rarityY = 58
for _, rarity in ipairs(Rarities) do
	local btn = createRarityButton(rarity)
	btn.Position = UDim2.new(0, 6, 0, rarityY)
	rarityY += 32
end

updateRarityButtons()

-------------------------------------------------
-- ESP
-------------------------------------------------
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "EggSizeESP"
ESPFolder.Parent = CoreGui

local function getSizeLabel(egg)
	local s = egg:GetExtentsSize()
	local v = s.X * s.Y * s.Z
	if v > 80 then return "HUGE", Color3.fromRGB(255, 70, 70)
	elseif v > 40 then return "Large", Color3.fromRGB(255, 175, 50)
	elseif v > 18 then return "Medium", Color3.fromRGB(60, 255, 130)
	else return "Small", Color3.fromRGB(170, 170, 180) end
end

local function createESP(egg)
	if not espEnabled then return end
	local id = tostring(egg:GetDebugId())
	if espObjects[id] then return end

	local part = egg:FindFirstChild("EggBase") or egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	local bb = Instance.new("BillboardGui")
	bb.Name = id
	bb.Adornee = part
	bb.Size = UDim2.new(0, 130, 0, 40)
	bb.StudsOffset = Vector3.new(0, 4, 0)
	bb.AlwaysOnTop = true
	bb.Parent = ESPFolder

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.Parent = bb

	local text, color = getSizeLabel(egg)
	label.Text = egg.Name .. "\n" .. text
	label.TextColor3 = color
	espObjects[id] = bb
end

local function clearAllESP()
	for _, gui in pairs(espObjects) do
		gui:Destroy()
	end
	espObjects = {}
end

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
createSection(leftContent, "MOVEMENT")
createSlider(leftContent, "Tween Speed (s)", 2, 12, Settings.TweenDuration, function(v)
	Settings.TweenDuration = v
end)
createSlider(leftContent, "Multi-Step Delay (s)", 0.2, 1.2, Settings.MultiStepDelay, function(v)
	Settings.MultiStepDelay = v
end)

createButton(leftContent, "Instant Return to Base", Color3.fromRGB(30, 100, 70), function()
	local base = getBase()
	if base then teleportTo(base) notify("Returned to base") else notify("Base not found") end
end)

createButton(leftContent, "Smooth Tween to Base", Color3.fromRGB(40, 85, 150), function()
	tweenToBase()
end)

createButton(leftContent, "Multi-Step (Grounded)", Color3.fromRGB(90, 55, 140), function()
	multiStepToBase()
end)

createSection(leftContent, "OPTIONS")
createToggle(leftContent, "ESP", Settings.ESPEnabled, function(state)
	espEnabled = state
	Settings.ESPEnabled = state
	if not state then clearAllESP() end
	notify(state and "ESP enabled" or "ESP disabled")
end)

createToggle(leftContent, "Auto Refresh", Settings.AutoRefreshEnabled, function(state)
	autoRefreshEnabled = state
	Settings.AutoRefreshEnabled = state
	notify(state and "Auto refresh enabled" or "Auto refresh disabled")
end)

createButton(rightContent, "Refresh Eggs", Color3.fromRGB(45, 45, 70), function()
	refreshEggs()
end)

-------------------------------------------------
-- Close
-------------------------------------------------
closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	isOpen = false
	saveSettings()
	notify("UI closed")
end)

closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 35, 45)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 30, 35)}):Play()
end)

-------------------------------------------------
-- Auto Refresh
-------------------------------------------------
task.spawn(function()
	while task.wait(Settings.AutoRefreshInterval) do
		if autoRefreshEnabled and isOpen and screenGui.Parent then
			refreshEggs()
		end
	end
end)

player.AncestryChanged:Connect(function()
	if not player.Parent then
		saveSettings()
	end
end)

refreshEggs()
notify("Divine Soul loaded")
print("Divine Soul - Ride a Pet loaded (Multi Rarity Support)")
