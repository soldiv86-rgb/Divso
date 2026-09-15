-- Divine Soul - Ride a Pet (Sidebar Layout)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-------------------------------------------------
-- SETTINGS
-------------------------------------------------
local SAVE_FILE = "DivineSoul_Settings.json"

local Settings = {
	TweenDuration = 8.0,
	MultiStepDelay = 0.8,
	MultiStepSteps = 14,
	AutoRefreshInterval = 3,
	NotificationDuration = 2.5,
	ESPEnabled = true,
	AutoRefreshEnabled = false,
	EnabledRarities = {
		Ethereal = true, Divine = true, Mythic = true, Legendary = true,
		Epic = true, Rare = true, Common = true
	}
}

local function loadSettings()
	if isfile and readfile and isfile(SAVE_FILE) then
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(SAVE_FILE))
		end)
		if ok and type(data) == "table" then
			for k, v in pairs(data) do
				if Settings[k] ~= nil then Settings[k] = v end
			end
		end
	end
end

local function saveSettings()
	if writefile then
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode(Settings)
		end)
		if ok then pcall(writefile, SAVE_FILE, encoded) end
	end
end

loadSettings()

-------------------------------------------------
-- RARITY DATA
-------------------------------------------------
local Rarities = {"Ethereal", "Divine", "Mythic", "Legendary", "Epic", "Rare", "Common"}

local RarityColors = {
	Ethereal  = Color3.fromRGB(180, 70, 255),
	Divine    = Color3.fromRGB(255, 210, 70),
	Mythic    = Color3.fromRGB(170, 50, 210),
	Legendary = Color3.fromRGB(255, 165, 30),
	Epic      = Color3.fromRGB(160, 50, 200),
	Rare      = Color3.fromRGB(50, 120, 255),
	Common    = Color3.fromRGB(150, 150, 160),
}

local RarityEggs = {
	Ethereal = { "Cherub Egg" },
	Divine = {"Blackhole Egg", "Galaxy Egg", "Aurora Egg" },
	Mythic = { "Crystal Egg", "Skull Egg", "Dominus Egg", "Flaming Egg", "Sinister egg", "Soul Egg" },
	Legendary = { "Glass Egg", "Golden Egg" },
	Epic = { "Mushroom Egg", "Flower Egg", "Slime Egg", "Ice Egg" },
	Rare = { "Cracked Egg", "Easter Egg", "Stone Egg", "Leaf Egg" },
	Common = { "Brown Egg", "White Egg" },
}

-------------------------------------------------
-- STATE
-------------------------------------------------
local isOpen = true
local currentTab = "Main"
local currentSearch = ""
local eggButtons = {}
local espObjects = {}
local espEnabled = Settings.ESPEnabled
local autoRefreshEnabled = Settings.AutoRefreshEnabled
local enabledRarities = Settings.EnabledRarities

-------------------------------------------------
-- CLEANUP
-------------------------------------------------
if playerGui:FindFirstChild("DivineSoulUI") then
	playerGui.DivineSoulUI:Destroy()
end
if CoreGui:FindFirstChild("EggSizeESP") then
	CoreGui.EggSizeESP:Destroy()
end

-------------------------------------------------
-- UI
-------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DivineSoulUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Window
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 780, 0, 500)
main.Position = UDim2.new(0.5, -390, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(45, 45, 65)
mainStroke.Thickness = 1
mainStroke.Parent = main

-------------------------------------------------
-- LEFT SIDEBAR (like BigFroot)
-------------------------------------------------
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 170, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 12)
sideCorner.Parent = sidebar

local sideCover = Instance.new("Frame")
sideCover.Size = UDim2.new(0, 20, 1, 0)
sideCover.Position = UDim2.new(1, -20, 0, 0)
sideCover.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
sideCover.BorderSizePixel = 0
sideCover.Parent = sidebar

-- Title
local sideTitle = Instance.new("TextLabel")
sideTitle.Size = UDim2.new(1, -20, 0, 28)
sideTitle.Position = UDim2.new(0, 14, 0, 14)
sideTitle.BackgroundTransparency = 1
sideTitle.Text = "Divine Soul"
sideTitle.TextColor3 = Color3.fromRGB(245, 245, 255)
sideTitle.Font = Enum.Font.GothamBold
sideTitle.TextSize = 17
sideTitle.TextXAlignment = Enum.TextXAlignment.Left
sideTitle.Parent = sidebar

local sideSub = Instance.new("TextLabel")
sideSub.Size = UDim2.new(1, -20, 0, 18)
sideSub.Position = UDim2.new(0, 14, 0, 40)
sideSub.BackgroundTransparency = 1
sideSub.Text = "Ride a Pet"
sideSub.TextColor3 = Color3.fromRGB(130, 130, 160)
sideSub.Font = Enum.Font.Gotham
sideSub.TextSize = 12
sideSub.TextXAlignment = Enum.TextXAlignment.Left
sideSub.Parent = sidebar

-- Sidebar Tabs
local tabButtons = {}

local function createSideTab(name, y)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 36)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
	btn.Text = "  " .. name
	btn.TextColor3 = Color3.fromRGB(200, 200, 220)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.AutoButtonColor = false
	btn.Parent = sidebar

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	tabButtons[name] = btn
	return btn
end

local tabMain = createSideTab("Main", 70)
local tabHop = createSideTab("Server Hop", 112)

-------------------------------------------------
-- RIGHT CONTENT AREA
-------------------------------------------------
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -190, 1, -20)
content.Position = UDim2.new(0, 180, 0, 10)
content.BackgroundTransparency = 1
content.Parent = main

-- Header bar inside content
local headerBar = Instance.new("Frame")
headerBar.Size = UDim2.new(1, 0, 0, 40)
headerBar.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
headerBar.BorderSizePixel = 0
headerBar.Parent = content

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 9)
headerCorner.Parent = headerBar

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -50, 1, 0)
headerTitle.Position = UDim2.new(0, 14, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "Controls & Eggs"
headerTitle.TextColor3 = Color3.fromRGB(230, 230, 255)
headerTitle.Font = Enum.Font.GothamMedium
headerTitle.TextSize = 15
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = headerBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 26)
closeBtn.Position = UDim2.new(1, -38, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(55, 30, 35)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 17
closeBtn.AutoButtonColor = false
closeBtn.Parent = headerBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = closeBtn

-------------------------------------------------
-- MAIN TAB CONTENT
-------------------------------------------------
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, -50)
mainContent.Position = UDim2.new(0, 0, 0, 48)
mainContent.BackgroundTransparency = 1
mainContent.Parent = content

-- Left controls
local left = Instance.new("ScrollingFrame")
left.Size = UDim2.new(0.42, 0, 1, 0)
left.BackgroundTransparency = 1
left.BorderSizePixel = 0
left.ScrollBarThickness = 3
left.AutomaticCanvasSize = Enum.AutomaticSize.Y
left.Parent = mainContent

local leftList = Instance.new("UIListLayout")
leftList.Padding = UDim.new(0, 8)
leftList.Parent = left

-- Right side (Rarity + Eggs)
local right = Instance.new("Frame")
right.Size = UDim2.new(0.56, 0, 1, 0)
right.Position = UDim2.new(0.44, 0, 0, 0)
right.BackgroundTransparency = 1
right.Parent = mainContent

-- Rarity
local rarityFrame = Instance.new("Frame")
rarityFrame.Size = UDim2.new(1, 0, 0, 155)
rarityFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
rarityFrame.BorderSizePixel = 0
rarityFrame.Parent = right

local rarityCorner = Instance.new("UICorner")
rarityCorner.CornerRadius = UDim.new(0, 10)
rarityCorner.Parent = rarityFrame

local rarityTitle = Instance.new("TextLabel")
rarityTitle.Size = UDim2.new(1, -16, 0, 24)
rarityTitle.Position = UDim2.new(0, 10, 0, 6)
rarityTitle.BackgroundTransparency = 1
rarityTitle.Text = "Rarities"
rarityTitle.TextColor3 = Color3.fromRGB(200, 200, 230)
rarityTitle.Font = Enum.Font.GothamMedium
rarityTitle.TextSize = 14
rarityTitle.TextXAlignment = Enum.TextXAlignment.Left
rarityTitle.Parent = rarityFrame

local rarityScroll = Instance.new("ScrollingFrame")
rarityScroll.Size = UDim2.new(1, -12, 1, -36)
rarityScroll.Position = UDim2.new(0, 6, 0, 32)
rarityScroll.BackgroundTransparency = 1
rarityScroll.BorderSizePixel = 0
rarityScroll.ScrollBarThickness = 3
rarityScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
rarityScroll.Parent = rarityFrame

local rarityList = Instance.new("UIListLayout")
rarityList.Padding = UDim.new(0, 4)
rarityList.Parent = rarityScroll

-- Eggs
local eggSearch = Instance.new("TextBox")
eggSearch.Size = UDim2.new(1, 0, 0, 32)
eggSearch.Position = UDim2.new(0, 0, 0, 165)
eggSearch.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
eggSearch.PlaceholderText = "Search eggs..."
eggSearch.Text = ""
eggSearch.TextColor3 = Color3.fromRGB(240, 240, 255)
eggSearch.PlaceholderColor3 = Color3.fromRGB(120, 120, 150)
eggSearch.Font = Enum.Font.Gotham
eggSearch.TextSize = 13
eggSearch.ClearTextOnFocus = false
eggSearch.Parent = right

local esCorner = Instance.new("UICorner")
esCorner.CornerRadius = UDim.new(0, 8)
esCorner.Parent = eggSearch

local eggScroll = Instance.new("ScrollingFrame")
eggScroll.Size = UDim2.new(1, 0, 1, -207)
eggScroll.Position = UDim2.new(0, 0, 0, 205)
eggScroll.BackgroundTransparency = 1
eggScroll.BorderSizePixel = 0
eggScroll.ScrollBarThickness = 3
eggScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
eggScroll.Parent = right

local eggList = Instance.new("UIListLayout")
eggList.Padding = UDim.new(0, 6)
eggList.Parent = eggScroll

-------------------------------------------------
-- HOP TAB CONTENT
-------------------------------------------------
local hopContent = Instance.new("Frame")
hopContent.Size = UDim2.new(1, 0, 1, -50)
hopContent.Position = UDim2.new(0, 0, 0, 48)
hopContent.BackgroundTransparency = 1
hopContent.Visible = false
hopContent.Parent = content

local hopTitle = Instance.new("TextLabel")
hopTitle.Size = UDim2.new(1, 0, 0, 30)
hopTitle.BackgroundTransparency = 1
hopTitle.Text = "Server Hop"
hopTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
hopTitle.Font = Enum.Font.GothamBold
hopTitle.TextSize = 18
hopTitle.Parent = hopContent

local hopDesc = Instance.new("TextLabel")
hopDesc.Size = UDim2.new(1, 0, 0, 40)
hopDesc.Position = UDim2.new(0, 0, 0, 35)
hopDesc.BackgroundTransparency = 1
hopDesc.Text = "Teleport to a different server of this place."
hopDesc.TextColor3 = Color3.fromRGB(160, 160, 180)
hopDesc.Font = Enum.Font.Gotham
hopDesc.TextSize = 14
hopDesc.Parent = hopContent

-------------------------------------------------
-- FLOATING BUTTON + NOTIFICATION
-------------------------------------------------
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 46, 0, 46)
openBtn.Position = UDim2.new(0, 30, 0, 100)
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
openCorner.CornerRadius = UDim.new(0, 11)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(70, 70, 110)
openStroke.Thickness = 1.2
openStroke.Parent = openBtn

local notif = Instance.new("Frame")
notif.Size = UDim2.new(0, 250, 0, 32)
notif.Position = UDim2.new(0.5, -125, 0, 16)
notif.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
notif.BorderSizePixel = 0
notif.Visible = false
notif.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 8)
notifCorner.Parent = notif

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, -10, 1, 0)
notifText.Position = UDim2.new(0, 5, 0, 0)
notifText.BackgroundTransparency = 1
notifText.TextColor3 = Color3.fromRGB(230, 230, 255)
notifText.Font = Enum.Font.GothamMedium
notifText.TextSize = 13
notifText.TextXAlignment = Enum.TextXAlignment.Center
notifText.Parent = notif

-------------------------------------------------
-- HELPERS
-------------------------------------------------
local function notify(msg)
	notifText.Text = msg
	notif.Visible = true
	notif.BackgroundTransparency = 0
	notifText.TextTransparency = 0
	task.delay(Settings.NotificationDuration, function()
		TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		TweenService:Create(notifText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		task.wait(0.3)
		notif.Visible = false
	end)
end

local function createSection(parent, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 18)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(140, 140, 170)
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 12
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
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

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.new(math.min(color.R+0.08,1), math.min(color.G+0.08,1), math.min(color.B+0.08,1))
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
	end)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function createSlider(parent, label, minV, maxV, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 52)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 0, 16)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = label
	title.TextColor3 = Color3.fromRGB(190, 190, 220)
	title.Font = Enum.Font.Gotham
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, 46, 0, 16)
	box.Position = UDim2.new(1, -54, 0, 5)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	box.Text = tostring(default)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Gotham
	box.TextSize = 12
	box.ClearTextOnFocus = false
	box.Parent = frame

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 5)
	bc.Parent = box

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 5)
	track.Position = UDim2.new(0, 10, 0, 32)
	track.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	track.BorderSizePixel = 0
	track.Parent = frame

	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = track

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(90, 130, 255)
	fill.BorderSizePixel = 0
	fill.Parent = track

	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = fill

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 13, 0, 13)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.Parent = track

	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

	local sliding = false
	local function set(val)
		val = math.clamp(val, minV, maxV)
		val = math.floor(val * 100 + 0.5) / 100
		local a = (val - minV) / (maxV - minV)
		fill.Size = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, -6, 0.5, -6)
		box.Text = tostring(val)
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
	box.FocusLost:Connect(function()
		local n = tonumber(box.Text)
		if n then set(n) else box.Text = tostring(default) end
	end)
	set(default)
end

local function createToggle(parent, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 34)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = frame

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

	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = toggle

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = toggle

	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

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

-------------------------------------------------
-- TELEPORT
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
-- EGGS
-------------------------------------------------
local function clearEggs()
	for btn in pairs(eggButtons) do
		btn:Destroy()
	end
	eggButtons = {}
end

local function refreshEggs()
	clearEggs()
	local rendered = workspace:FindFirstChild("RenderedEggs")
	if not rendered then
		notify("No RenderedEggs found")
		return
	end

	local allowed = {}
	for rarity, on in pairs(enabledRarities) do
		if on then
			for _, name in ipairs(RarityEggs[rarity] or {}) do
				allowed[name] = rarity
			end
		end
	end

	local count = 0
	for _, egg in ipairs(rendered:GetChildren()) do
		local rarity = allowed[egg.Name]
		if rarity then
			if currentSearch == "" or egg.Name:lower():find(currentSearch:lower(), 1, true) then
				count += 1
				local color = RarityColors[rarity] or Color3.fromRGB(40, 40, 55)
				local btn = createButton(eggScroll, egg.Name, color, function()
					teleportTo(egg)
					notify("Teleported to " .. egg.Name)
				end)
				eggButtons[btn] = true
			end
		end
	end
	notify("Showing " .. count .. " eggs")
end

eggSearch:GetPropertyChangedSignal("Text"):Connect(function()
	currentSearch = eggSearch.Text
	refreshEggs()
end)

-------------------------------------------------
-- RARITY BUTTONS
-------------------------------------------------
local function updateRarityButtons()
	for _, child in ipairs(rarityScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, rarity in ipairs(Rarities) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 28)
		btn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.Parent = rarityScroll

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = btn

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(0, 4, 1, -8)
		bar.Position = UDim2.new(0, 4, 0, 4)
		bar.BackgroundColor3 = Color3.fromRGB(255, 140, 40)
		bar.BorderSizePixel = 0
		bar.Visible = enabledRarities[rarity] == true
		bar.Parent = btn

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 2)
		bc.Parent = bar

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -20, 1, 0)
		label.Position = UDim2.new(0, 16, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = rarity
		label.TextColor3 = Color3.fromRGB(230, 230, 255)
		label.Font = Enum.Font.Gotham
		label.TextSize = 13
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = btn

		btn.MouseButton1Click:Connect(function()
			enabledRarities[rarity] = not enabledRarities[rarity]
			Settings.EnabledRarities = enabledRarities
			bar.Visible = enabledRarities[rarity]
			refreshEggs()
			saveSettings()
		end)
	end
end

updateRarityButtons()

-------------------------------------------------
-- CONTROLS
-------------------------------------------------
createSection(left, "MOVEMENT")
createSlider(left, "Tween Speed (s)", 2, 12, Settings.TweenDuration, function(v) Settings.TweenDuration = v end)
createSlider(left, "Multi-Step Delay (s)", 0.2, 1.2, Settings.MultiStepDelay, function(v) Settings.MultiStepDelay = v end)

createButton(left, "Instant Return to Base", Color3.fromRGB(30, 100, 70), function()
	local base = getBase()
	if base then teleportTo(base) notify("Returned to base") else notify("Base not found") end
end)
createButton(left, "Smooth Tween to Base", Color3.fromRGB(40, 85, 150), function() tweenToBase() end)
createButton(left, "Multi-Step (Grounded)", Color3.fromRGB(90, 55, 140), function() multiStepToBase() end)

createSection(left, "OPTIONS")
createToggle(left, "ESP", Settings.ESPEnabled, function(state)
	espEnabled = state
	Settings.ESPEnabled = state
	notify(state and "ESP enabled" or "ESP disabled")
end)
createToggle(left, "Auto Refresh", Settings.AutoRefreshEnabled, function(state)
	autoRefreshEnabled = state
	Settings.AutoRefreshEnabled = state
	notify(state and "Auto refresh enabled" or "Auto refresh disabled")
end)

createButton(eggScroll, "Refresh Eggs", Color3.fromRGB(45, 45, 70), function()
	refreshEggs()
end)

createButton(hopContent, "Server Hop Now", Color3.fromRGB(90, 50, 160), function()
	notify("Server hopping...")
	TeleportService:Teleport(game.PlaceId, player)
end).Position = UDim2.new(0, 0, 0, 90)

-------------------------------------------------
-- TAB SWITCHING
-------------------------------------------------
local function setTab(name)
	currentTab = name
	mainContent.Visible = name == "Main"
	hopContent.Visible = name == "Hop"

	for tabName, btn in pairs(tabButtons) do
		if tabName == name then
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			btn.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
			btn.TextColor3 = Color3.fromRGB(180, 180, 200)
		end
	end
end

tabMain.MouseButton1Click:Connect(function() setTab("Main") end)
tabHop.MouseButton1Click:Connect(function() setTab("Server Hop") end)

setTab("Main")

-------------------------------------------------
-- CLOSE / OPEN + DRAG
-------------------------------------------------
closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	isOpen = false
	saveSettings()
	notify("UI closed")
end)

local openDragging, openDragStart, openStartPos, openMoved = false, nil, nil, false

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
		if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then openMoved = true end
		openBtn.Position = UDim2.new(openStartPos.X.Scale, openStartPos.X.Offset + delta.X, openStartPos.Y.Scale, openStartPos.Y.Offset + delta.Y)
	end
end)

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

task.spawn(function()
	while task.wait(0.7) do
		if not espEnabled then
			for _, g in pairs(espObjects) do g:Destroy() end
			espObjects = {}
			continue
		end
		local folder = workspace:FindFirstChild("RenderedEggs")
		if not folder then continue end
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
-- AUTO REFRESH
-------------------------------------------------
task.spawn(function()
	while task.wait(Settings.AutoRefreshInterval) do
		if autoRefreshEnabled and isOpen and screenGui.Parent then
			refreshEggs()
		end
	end
end)

refreshEggs()
notify("Divine Soul loaded")
print("Divine Soul - Sidebar UI loaded")
