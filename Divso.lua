-- Divine Soul - Full UI Restructure (Automation + Egg + Other + Settings)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
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
	ESPEnabled = true,
	AutoRefreshEnabled = false,
	AutoFarmEnabled = false,
	AutoFarmDelay = 1.2,
	CollectHoldTime = 0.75,
	GoMethod = "MultiTeleport",
	ReturnMethod = "Tween",

	-- Automation placeholders
	AutoPlaceBestPet = false,
	AutoBuyShop = false,
	AutoPlaceEgg = false,
	AutoHatch = false,
	AutoFeed = false,
	MinEggKG = 30000,

	-- Webhook
	WebhookEnabled = false,
	WebhookURL = "",
	WebhookInterval = 15, -- minutes

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
local RarityPriority = {
	Ethereal = 7, Divine = 6, Mythic = 5, Legendary = 4,
	Epic = 3, Rare = 2, Common = 1
}
local RarityColors = {
	Ethereal  = Color3.fromRGB(200, 90, 255),
	Divine    = Color3.fromRGB(255, 215, 60),
	Mythic    = Color3.fromRGB(190, 60, 255),
	Legendary = Color3.fromRGB(255, 155, 30),
	Epic      = Color3.fromRGB(170, 70, 255),
	Rare      = Color3.fromRGB(60, 140, 255),
	Common    = Color3.fromRGB(160, 160, 170),
}
local RarityEggs = {
	Ethereal = { "Cherub Egg" },
	Divine = {"Blackhole Egg", "Galaxy Egg", "Aurora Egg" },
	Mythic = { "Crystal Egg", "Skull Egg", "Dominus Egg", "Flaming Egg", "Sinister Egg", "Soul Egg" },
	Legendary = { "Glass Egg", "Golden Egg" },
	Epic = { "Mushroom Egg", "Flower Egg", "Slime Egg", "Ice Egg" },
	Rare = { "Cracked Egg", "Easter Egg", "Stone Egg", "Leaf Egg" },
	Common = { "Brown Egg", "White Egg" },
}

-------------------------------------------------
-- STATE
-------------------------------------------------
local isOpen = true
local currentTab = "Egg"
local currentSearch = ""
local eggButtons = {}
local espObjects = {}
local espEnabled = Settings.ESPEnabled
local autoRefreshEnabled = Settings.AutoRefreshEnabled
local autoFarmEnabled = Settings.AutoFarmEnabled
local enabledRarities = Settings.EnabledRarities
local goMethod = Settings.GoMethod
local returnMethod = Settings.ReturnMethod

local farmStartTime = 0
local eggsCollected = 0
local lastCollectedRarity = "-"
local currentAction = "Idle"
local currentTarget = "-"

-------------------------------------------------
-- CLEANUP
-------------------------------------------------
if playerGui:FindFirstChild("DivineSoulUI") then playerGui.DivineSoulUI:Destroy() end
if CoreGui:FindFirstChild("EggSizeESP") then CoreGui.EggSizeESP:Destroy() end
if playerGui:FindFirstChild("DivineSoulStatus") then playerGui.DivineSoulStatus:Destroy() end

-------------------------------------------------
-- STATUS PANEL
-------------------------------------------------
local statusGui = Instance.new("ScreenGui")
statusGui.Name = "DivineSoulStatus"
statusGui.ResetOnSpawn = false
statusGui.Parent = playerGui

local statusPanel = Instance.new("Frame")
statusPanel.Size = UDim2.new(0, 290, 0, 0)
statusPanel.AutomaticSize = Enum.AutomaticSize.Y
statusPanel.Position = UDim2.new(1, -310, 0, 20)
statusPanel.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
statusPanel.BorderSizePixel = 0
statusPanel.Visible = false
statusPanel.Parent = statusGui

Instance.new("UICorner", statusPanel).CornerRadius = UDim.new(0, 10)
local ss = Instance.new("UIStroke", statusPanel)
ss.Color = Color3.fromRGB(255, 140, 40)
ss.Thickness = 1.2

local sp = Instance.new("UIPadding", statusPanel)
sp.PaddingTop = UDim.new(0, 12)
sp.PaddingBottom = UDim.new(0, 12)
sp.PaddingLeft = UDim.new(0, 14)
sp.PaddingRight = UDim.new(0, 14)

Instance.new("UIListLayout", statusPanel).Padding = UDim.new(0, 4)

local function addStatusLabel(text, color, size)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, size or 18)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color or Color3.fromRGB(220, 180, 120)
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = statusPanel
	return l
end

local titleLabel = addStatusLabel("Divine Soul • Auto Farm", Color3.fromRGB(255, 160, 50), 20)
titleLabel.Font = Enum.Font.GothamBold
local statusLabel = addStatusLabel("Status: Idle")
local actionLabel = addStatusLabel("Action: -")
local targetLabel = addStatusLabel("Target: -")
local collectedLabel = addStatusLabel("Eggs Collected: 0")
local lastRarityLabel = addStatusLabel("Last Rarity: -")
local uptimeLabel = addStatusLabel("Uptime: 00:00")
local settingsLabel = addStatusLabel("Go: Multi | Return: Tween | Hold: 0.75s", Color3.fromRGB(160, 140, 100))

local function updateStatusPanel()
	if not autoFarmEnabled then
		statusPanel.Visible = false
		return
	end
	statusPanel.Visible = true
	statusLabel.Text = "Status: Running"
	actionLabel.Text = "Action: " .. currentAction
	targetLabel.Text = "Target: " .. currentTarget
	collectedLabel.Text = "Eggs Collected: " .. eggsCollected
	lastRarityLabel.Text = "Last Rarity: " .. lastCollectedRarity
	local elapsed = math.floor(os.clock() - farmStartTime)
	uptimeLabel.Text = string.format("Uptime: %02d:%02d", math.floor(elapsed/60), elapsed%60)
	settingsLabel.Text = string.format("Go: %s | Return: %s | Hold: %.2fs",
		goMethod == "MultiTeleport" and "Multi" or "Tween",
		returnMethod == "MultiTeleport" and "Multi" or "Tween",
		Settings.CollectHoldTime)
end

task.spawn(function()
	while task.wait(0.5) do
		if autoFarmEnabled then updateStatusPanel() else statusPanel.Visible = false end
	end
end)

-------------------------------------------------
-- MAIN UI
-------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DivineSoulUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 820, 0, 540)
main.Position = UDim2.new(0.5, -410, 0.5, -270)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local ms = Instance.new("UIStroke", main)
ms.Color = Color3.fromRGB(255, 140, 40)
ms.Thickness = 1.2

-------------------------------------------------
-- SIDEBAR
-------------------------------------------------
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 160, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

local sideCover = Instance.new("Frame")
sideCover.Size = UDim2.new(0, 20, 1, 0)
sideCover.Position = UDim2.new(1, -20, 0, 0)
sideCover.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
sideCover.BorderSizePixel = 0
sideCover.Parent = sidebar

local sideTitle = Instance.new("TextLabel")
sideTitle.Size = UDim2.new(1, -20, 0, 28)
sideTitle.Position = UDim2.new(0, 14, 0, 16)
sideTitle.BackgroundTransparency = 1
sideTitle.Text = "Divine Soul"
sideTitle.TextColor3 = Color3.fromRGB(255, 160, 50)
sideTitle.Font = Enum.Font.GothamBold
sideTitle.TextSize = 17
sideTitle.TextXAlignment = Enum.TextXAlignment.Left
sideTitle.Parent = sidebar

local sideSub = Instance.new("TextLabel")
sideSub.Size = UDim2.new(1, -20, 0, 16)
sideSub.Position = UDim2.new(0, 14, 0, 42)
sideSub.BackgroundTransparency = 1
sideSub.Text = "Ride a Pet"
sideSub.TextColor3 = Color3.fromRGB(180, 120, 60)
sideSub.Font = Enum.Font.Gotham
sideSub.TextSize = 12
sideSub.TextXAlignment = Enum.TextXAlignment.Left
sideSub.Parent = sidebar

local tabButtons = {}
local function createSideTab(name, y)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -16, 0, 36)
	btn.Position = UDim2.new(0, 8, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	btn.Text = "  " .. name
	btn.TextColor3 = Color3.fromRGB(200, 140, 70)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.AutoButtonColor = false
	btn.Parent = sidebar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	tabButtons[name] = btn
	return btn
end

local tabAutomation = createSideTab("Automation", 70)
local tabEgg        = createSideTab("Egg", 112)
local tabOther      = createSideTab("Other", 154)
local tabSettings   = createSideTab("Settings", 196)

-------------------------------------------------
-- CONTENT AREA
-------------------------------------------------
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -175, 1, -20)
content.Position = UDim2.new(0, 168, 0, 10)
content.BackgroundTransparency = 1
content.Parent = main

-- Header (now just game name)
local headerBar = Instance.new("Frame")
headerBar.Size = UDim2.new(1, 0, 0, 40)
headerBar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
headerBar.BorderSizePixel = 0
headerBar.Parent = content
Instance.new("UICorner", headerBar).CornerRadius = UDim.new(0, 9)

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -50, 1, 0)
headerTitle.Position = UDim2.new(0, 14, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "Divine Soul"
headerTitle.TextColor3 = Color3.fromRGB(255, 170, 60)
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 16
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = headerBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 26)
closeBtn.Position = UDim2.new(1, -38, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 10)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 160, 80)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 17
closeBtn.AutoButtonColor = false
closeBtn.Parent = headerBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)

-------------------------------------------------
-- TAB CONTENTS
-------------------------------------------------
local function createTabContent()
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 1, -50)
	f.Position = UDim2.new(0, 0, 0, 48)
	f.BackgroundTransparency = 1
	f.Visible = false
	f.Parent = content
	return f
end

local automationContent = createTabContent()
local eggContent = createTabContent()
local otherContent = createTabContent()
local settingsContent = createTabContent()

-------------------------------------------------
-- HELPERS
-------------------------------------------------
local function createCard(parent, titleText)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
	card.BorderSizePixel = 0
	card.Parent = parent

	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", card)
	stroke.Color = Color3.fromRGB(255, 140, 40)
	stroke.Thickness = 1
	stroke.Transparency = 0.7

	local pad = Instance.new("UIPadding", card)
	pad.PaddingTop = UDim.new(0, 12)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)

	local list = Instance.new("UIListLayout", card)
	list.Padding = UDim.new(0, 8)
	list.SortOrder = Enum.SortOrder.LayoutOrder

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 18)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = Color3.fromRGB(255, 150, 50)
	title.Font = Enum.Font.GothamMedium
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.LayoutOrder = 0
	title.Parent = card

	return card
end

local function createToggle(parent, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 34)
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -55, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(230, 180, 110)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 40, 0, 20)
	toggle.Position = UDim2.new(1, -48, 0.5, -10)
	toggle.BackgroundColor3 = default and Color3.fromRGB(255, 140, 40) or Color3.fromRGB(45, 40, 35)
	toggle.Text = ""
	toggle.AutoButtonColor = false
	toggle.Parent = frame
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 220, 160)
	knob.BorderSizePixel = 0
	knob.Parent = toggle
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(toggle, TweenInfo.new(0.18), {
			BackgroundColor3 = state and Color3.fromRGB(255, 140, 40) or Color3.fromRGB(45, 40, 35)
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.18), {
			Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		}):Play()
		callback(state)
		saveSettings()
	end)
	return frame
end

local function createSlider(parent, label, minV, maxV, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 52)
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 0, 16)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = label
	title.TextColor3 = Color3.fromRGB(220, 160, 90)
	title.Font = Enum.Font.Gotham
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, 50, 0, 16)
	box.Position = UDim2.new(1, -58, 0, 5)
	box.BackgroundColor3 = Color3.fromRGB(35, 30, 25)
	box.Text = tostring(default)
	box.TextColor3 = Color3.fromRGB(255, 200, 120)
	box.Font = Enum.Font.Gotham
	box.TextSize = 12
	box.ClearTextOnFocus = false
	box.Parent = frame
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 5)
	track.Position = UDim2.new(0, 10, 0, 32)
	track.BackgroundColor3 = Color3.fromRGB(40, 35, 30)
	track.BorderSizePixel = 0
	track.Parent = frame
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(255, 140, 40)
	fill.BorderSizePixel = 0
	fill.Parent = track
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 13, 0, 13)
	knob.BackgroundColor3 = Color3.fromRGB(255, 180, 80)
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.Parent = track
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

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
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
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
	return frame
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
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.new(math.min(color.R+0.1,1), math.min(color.G+0.08,1), math.min(color.B+0.05,1))
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
	end)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function createMethodSelector(parent, labelText, currentValue, onChange)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 34)
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.42, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(230, 180, 110)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local tweenBtn = Instance.new("TextButton")
	tweenBtn.Size = UDim2.new(0.26, -4, 0, 24)
	tweenBtn.Position = UDim2.new(0.45, 0, 0.5, -12)
	tweenBtn.BackgroundColor3 = currentValue == "Tween" and Color3.fromRGB(255, 140, 40) or Color3.fromRGB(40, 35, 30)
	tweenBtn.Text = "Tween"
	tweenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tweenBtn.Font = Enum.Font.GothamMedium
	tweenBtn.TextSize = 11
	tweenBtn.AutoButtonColor = false
	tweenBtn.Parent = frame
	Instance.new("UICorner", tweenBtn).CornerRadius = UDim.new(0, 6)

	local multiBtn = Instance.new("TextButton")
	multiBtn.Size = UDim2.new(0.26, -4, 0, 24)
	multiBtn.Position = UDim2.new(0.72, 0, 0.5, -12)
	multiBtn.BackgroundColor3 = currentValue == "MultiTeleport" and Color3.fromRGB(255, 140, 40) or Color3.fromRGB(40, 35, 30)
	multiBtn.Text = "Multi"
	multiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	multiBtn.Font = Enum.Font.GothamMedium
	multiBtn.TextSize = 11
	multiBtn.AutoButtonColor = false
	multiBtn.Parent = frame
	Instance.new("UICorner", multiBtn).CornerRadius = UDim.new(0, 6)

	local function update()
		tweenBtn.BackgroundColor3 = currentValue == "Tween" and Color3.fromRGB(255, 140, 40) or Color3.fromRGB(40, 35, 30)
		multiBtn.BackgroundColor3 = currentValue == "MultiTeleport" and Color3.fromRGB(255, 140, 40) or Color3.fromRGB(40, 35, 30)
	end

	tweenBtn.MouseButton1Click:Connect(function()
		currentValue = "Tween"
		onChange("Tween")
		update()
	end)
	multiBtn.MouseButton1Click:Connect(function()
		currentValue = "MultiTeleport"
		onChange("MultiTeleport")
		update()
	end)
	return frame
end

-------------------------------------------------
-- AUTOMATION TAB
-------------------------------------------------
local autoScroll = Instance.new("ScrollingFrame")
autoScroll.Size = UDim2.new(1, 0, 1, 0)
autoScroll.BackgroundTransparency = 1
autoScroll.BorderSizePixel = 0
autoScroll.ScrollBarThickness = 4
autoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
autoScroll.Parent = automationContent

local autoList = Instance.new("UIListLayout", autoScroll)
autoList.Padding = UDim.new(0, 12)
autoList.SortOrder = Enum.SortOrder.LayoutOrder

local autoPad = Instance.new("UIPadding", autoScroll)
autoPad.PaddingTop = UDim.new(0, 4)
autoPad.PaddingBottom = UDim.new(0, 10)
autoPad.PaddingLeft = UDim.new(0, 4)
autoPad.PaddingRight = UDim.new(0, 8)

-- Placeholder cards
local placePetCard = createCard(autoScroll, "AUTO PLACE BEST PET")
createToggle(placePetCard, "Enable Auto Place Best Pet", Settings.AutoPlaceBestPet, function(s)
	Settings.AutoPlaceBestPet = s
end)
local placePetDesc = Instance.new("TextLabel")
placePetDesc.Size = UDim2.new(1, 0, 0, 32)
placePetDesc.BackgroundTransparency = 1
placePetDesc.Text = "Places the pet with highest Money/sec from your backpack"
placePetDesc.TextColor3 = Color3.fromRGB(160, 140, 100)
placePetDesc.Font = Enum.Font.Gotham
placePetDesc.TextSize = 12
placePetDesc.TextXAlignment = Enum.TextXAlignment.Left
placePetDesc.TextWrapped = true
placePetDesc.Parent = placePetCard

local buyShopCard = createCard(autoScroll, "AUTO BUY FROM SHOP")
createToggle(buyShopCard, "Enable Auto Buy", Settings.AutoBuyShop, function(s)
	Settings.AutoBuyShop = s
end)
local buyDesc = Instance.new("TextLabel")
buyDesc.Size = UDim2.new(1, 0, 0, 32)
buyDesc.BackgroundTransparency = 1
buyDesc.Text = "Automatically buys food / track items from the shop"
buyDesc.TextColor3 = Color3.fromRGB(160, 140, 100)
buyDesc.Font = Enum.Font.Gotham
buyDesc.TextSize = 12
buyDesc.TextXAlignment = Enum.TextXAlignment.Left
buyDesc.TextWrapped = true
buyDesc.Parent = buyShopCard

local placeEggCard = createCard(autoScroll, "AUTO PLACE EGG")
createToggle(placeEggCard, "Enable Auto Place Egg", Settings.AutoPlaceEgg, function(s)
	Settings.AutoPlaceEgg = s
end)
createSlider(placeEggCard, "Minimum KG", 1000, 100000, Settings.MinEggKG, function(v)
	Settings.MinEggKG = v
end)
local placeEggDesc = Instance.new("TextLabel")
placeEggDesc.Size = UDim2.new(1, 0, 0, 32)
placeEggDesc.BackgroundTransparency = 1
placeEggDesc.Text = "Only places eggs that are ≥ the minimum KG you set"
placeEggDesc.TextColor3 = Color3.fromRGB(160, 140, 100)
placeEggDesc.Font = Enum.Font.Gotham
placeEggDesc.TextSize = 12
placeEggDesc.TextXAlignment = Enum.TextXAlignment.Left
placeEggDesc.TextWrapped = true
placeEggDesc.Parent = placeEggCard

local hatchCard = createCard(autoScroll, "AUTO HATCH")
createToggle(hatchCard, "Enable Auto Hatch", Settings.AutoHatch, function(s)
	Settings.AutoHatch = s
end)
local hatchDesc = Instance.new("TextLabel")
hatchDesc.Size = UDim2.new(1, 0, 0, 32)
hatchDesc.BackgroundTransparency = 1
hatchDesc.Text = "Automatically hatches the egg when it is ready"
hatchDesc.TextColor3 = Color3.fromRGB(160, 140, 100)
hatchDesc.Font = Enum.Font.Gotham
hatchDesc.TextSize = 12
hatchDesc.TextXAlignment = Enum.TextXAlignment.Left
hatchDesc.TextWrapped = true
hatchDesc.Parent = hatchCard

local feedCard = createCard(autoScroll, "AUTO FEED PETS")
createToggle(feedCard, "Enable Auto Feed", Settings.AutoFeed, function(s)
	Settings.AutoFeed = s
end)
local feedDesc = Instance.new("TextLabel")
feedDesc.Size = UDim2.new(1, 0, 0, 32)
feedDesc.BackgroundTransparency = 1
feedDesc.Text = "Feeds pets with food from backpack until desired age is reached"
feedDesc.TextColor3 = Color3.fromRGB(160, 140, 100)
feedDesc.Font = Enum.Font.Gotham
feedDesc.TextSize = 12
feedDesc.TextXAlignment = Enum.TextXAlignment.Left
feedDesc.TextWrapped = true
feedDesc.Parent = feedCard

-------------------------------------------------
-- EGG TAB
-------------------------------------------------
local eggLeft = Instance.new("ScrollingFrame")
eggLeft.Size = UDim2.new(0.42, 0, 1, 0)
eggLeft.BackgroundTransparency = 1
eggLeft.BorderSizePixel = 0
eggLeft.ScrollBarThickness = 3
eggLeft.AutomaticCanvasSize = Enum.AutomaticSize.Y
eggLeft.Parent = eggContent

local eggLeftList = Instance.new("UIListLayout", eggLeft)
eggLeftList.Padding = UDim.new(0, 12)
local eggLeftPad = Instance.new("UIPadding", eggLeft)
eggLeftPad.PaddingTop = UDim.new(0, 4)
eggLeftPad.PaddingBottom = UDim.new(0, 10)
eggLeftPad.PaddingLeft = UDim.new(0, 2)
eggLeftPad.PaddingRight = UDim.new(0, 6)

local eggRight = Instance.new("Frame")
eggRight.Size = UDim2.new(0.56, 0, 1, 0)
eggRight.Position = UDim2.new(0.44, 0, 0, 0)
eggRight.BackgroundTransparency = 1
eggRight.Parent = eggContent

-- Auto Farm Card
local autoFarmCard = createCard(eggLeft, "AUTO FARM")
createToggle(autoFarmCard, "Auto Farm", Settings.AutoFarmEnabled, function(state)
	autoFarmEnabled = state
	Settings.AutoFarmEnabled = state
	if state then
		-- start logic later
	end
end)
createSlider(autoFarmCard, "Farm Delay (s)", 0.4, 4.0, Settings.AutoFarmDelay, function(v) Settings.AutoFarmDelay = v end)
createSlider(autoFarmCard, "Collect Hold Time (s)", 0.3, 2.0, Settings.CollectHoldTime, function(v) Settings.CollectHoldTime = v end)
createMethodSelector(autoFarmCard, "Go to Egg", goMethod, function(val)
	goMethod = val
	Settings.GoMethod = val
end)
createMethodSelector(autoFarmCard, "Return to Base", returnMethod, function(val)
	returnMethod = val
	Settings.ReturnMethod = val
end)

-- Movement Card
local movementCard = createCard(eggLeft, "MOVEMENT")
createButton(movementCard, "Instant Return to Base", Color3.fromRGB(255, 120, 30), function() end)
createButton(movementCard, "Multi-Teleport to Base", Color3.fromRGB(200, 90, 20), function() end)
createSlider(movementCard, "Multi-Teleport Delay (s)", 0.2, 1.2, Settings.MultiStepDelay, function(v) Settings.MultiStepDelay = v end)
createButton(movementCard, "Smooth Tween to Base", Color3.fromRGB(255, 140, 40), function() end)
createSlider(movementCard, "Tween Speed (s)", 2, 12, Settings.TweenDuration, function(v) Settings.TweenDuration = v end)

-- Additionals Card
local additionalsCard = createCard(eggLeft, "ADDITIONALS")
createToggle(additionalsCard, "Auto Refresh", Settings.AutoRefreshEnabled, function(state)
	autoRefreshEnabled = state
	Settings.AutoRefreshEnabled = state
end)
createToggle(additionalsCard, "Egg ESP", Settings.ESPEnabled, function(state)
	espEnabled = state
	Settings.ESPEnabled = state
end)

-- Right side: Rarities + Eggs
local rarityCard = createCard(eggRight, "RARITIES")
rarityCard.Size = UDim2.new(1, 0, 0, 160)

local rarityScroll = Instance.new("ScrollingFrame")
rarityScroll.Size = UDim2.new(1, 0, 1, -30)
rarityScroll.Position = UDim2.new(0, 0, 0, 26)
rarityScroll.BackgroundTransparency = 1
rarityScroll.BorderSizePixel = 0
rarityScroll.ScrollBarThickness = 3
rarityScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
rarityScroll.Parent = rarityCard
Instance.new("UIListLayout", rarityScroll).Padding = UDim.new(0, 4)

-- Egg list card
local eggListCard = Instance.new("Frame")
eggListCard.Size = UDim2.new(1, 0, 1, -175)
eggListCard.Position = UDim2.new(0, 0, 0, 170)
eggListCard.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
eggListCard.BorderSizePixel = 0
eggListCard.Parent = eggRight
Instance.new("UICorner", eggListCard).CornerRadius = UDim.new(0, 10)
local elStroke = Instance.new("UIStroke", eggListCard)
elStroke.Color = Color3.fromRGB(255, 140, 40)
elStroke.Thickness = 1
elStroke.Transparency = 0.7

local eggSearch = Instance.new("TextBox")
eggSearch.Size = UDim2.new(1, -20, 0, 32)
eggSearch.Position = UDim2.new(0, 10, 0, 10)
eggSearch.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
eggSearch.PlaceholderText = "Search eggs..."
eggSearch.Text = ""
eggSearch.TextColor3 = Color3.fromRGB(255, 200, 140)
eggSearch.PlaceholderColor3 = Color3.fromRGB(140, 100, 60)
eggSearch.Font = Enum.Font.Gotham
eggSearch.TextSize = 13
eggSearch.ClearTextOnFocus = false
eggSearch.Parent = eggListCard
Instance.new("UICorner", eggSearch).CornerRadius = UDim.new(0, 8)

local eggScroll = Instance.new("ScrollingFrame")
eggScroll.Size = UDim2.new(1, -20, 1, -55)
eggScroll.Position = UDim2.new(0, 10, 0, 50)
eggScroll.BackgroundTransparency = 1
eggScroll.BorderSizePixel = 0
eggScroll.ScrollBarThickness = 3
eggScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
eggScroll.Parent = eggListCard
Instance.new("UIListLayout", eggScroll).Padding = UDim.new(0, 6)

-------------------------------------------------
-- OTHER TAB
-------------------------------------------------
local otherCard = createCard(otherContent, "SERVER")
otherCard.Size = UDim2.new(0.5, 0, 0, 0)
otherCard.Position = UDim2.new(0.25, 0, 0.2, 0)

createButton(otherCard, "Server Hop Now", Color3.fromRGB(255, 120, 30), function()
	TeleportService:Teleport(game.PlaceId, player)
end)

local otherDesc = Instance.new("TextLabel")
otherDesc.Size = UDim2.new(1, 0, 0, 40)
otherDesc.BackgroundTransparency = 1
otherDesc.Text = "Teleport to a different server of this place."
otherDesc.TextColor3 = Color3.fromRGB(160, 140, 100)
otherDesc.Font = Enum.Font.Gotham
otherDesc.TextSize = 13
otherDesc.TextXAlignment = Enum.TextXAlignment.Left
otherDesc.TextWrapped = true
otherDesc.Parent = otherCard

-------------------------------------------------
-- SETTINGS TAB
-------------------------------------------------
local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Size = UDim2.new(1, 0, 1, 0)
settingsScroll.BackgroundTransparency = 1
settingsScroll.BorderSizePixel = 0
settingsScroll.ScrollBarThickness = 4
settingsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
settingsScroll.Parent = settingsContent

local settingsList = Instance.new("UIListLayout", settingsScroll)
settingsList.Padding = UDim.new(0, 12)
local settingsPad = Instance.new("UIPadding", settingsScroll)
settingsPad.PaddingTop = UDim.new(0, 4)
settingsPad.PaddingBottom = UDim.new(0, 10)
settingsPad.PaddingLeft = UDim.new(0, 4)
settingsPad.PaddingRight = UDim.new(0, 8)

local webhookCard = createCard(settingsScroll, "DISCORD WEBHOOK")
createToggle(webhookCard, "Enable Webhook", Settings.WebhookEnabled, function(s)
	Settings.WebhookEnabled = s
end)

local urlLabel = Instance.new("TextLabel")
urlLabel.Size = UDim2.new(1, 0, 0, 18)
urlLabel.BackgroundTransparency = 1
urlLabel.Text = "Webhook URL"
urlLabel.TextColor3 = Color3.fromRGB(200, 160, 100)
urlLabel.Font = Enum.Font.Gotham
urlLabel.TextSize = 12
urlLabel.TextXAlignment = Enum.TextXAlignment.Left
urlLabel.Parent = webhookCard

local urlBox = Instance.new("TextBox")
urlBox.Size = UDim2.new(1, 0, 0, 36)
urlBox.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
urlBox.Text = Settings.WebhookURL
urlBox.PlaceholderText = "Paste your Discord webhook URL here..."
urlBox.TextColor3 = Color3.fromRGB(255, 200, 140)
urlBox.PlaceholderColor3 = Color3.fromRGB(120, 100, 70)
urlBox.Font = Enum.Font.Gotham
urlBox.TextSize = 13
urlBox.ClearTextOnFocus = false
urlBox.TextXAlignment = Enum.TextXAlignment.Left
urlBox.Parent = webhookCard
Instance.new("UICorner", urlBox).CornerRadius = UDim.new(0, 8)
local urlPad = Instance.new("UIPadding", urlBox)
urlPad.PaddingLeft = UDim.new(0, 10)

urlBox.FocusLost:Connect(function()
	Settings.WebhookURL = urlBox.Text
	saveSettings()
end)

createSlider(webhookCard, "Send Interval (minutes)", 5, 60, Settings.WebhookInterval, function(v)
	Settings.WebhookInterval = v
end)

local webhookInfo = Instance.new("TextLabel")
webhookInfo.Size = UDim2.new(1, 0, 0, 50)
webhookInfo.BackgroundTransparency = 1
webhookInfo.Text = "Sends hatch data (pet name, MPS, KG, luck) to your Discord.\nBlack & orange embed style."
webhookInfo.TextColor3 = Color3.fromRGB(160, 140, 100)
webhookInfo.Font = Enum.Font.Gotham
webhookInfo.TextSize = 12
webhookInfo.TextXAlignment = Enum.TextXAlignment.Left
webhookInfo.TextWrapped = true
webhookInfo.Parent = webhookCard

-------------------------------------------------
-- TAB SWITCHING
-------------------------------------------------
local function setTab(name)
	currentTab = name
	automationContent.Visible = name == "Automation"
	eggContent.Visible = name == "Egg"
	otherContent.Visible = name == "Other"
	settingsContent.Visible = name == "Settings"

	for tabName, btn in pairs(tabButtons) do
		if tabName == name then
			btn.BackgroundColor3 = Color3.fromRGB(30, 22, 15)
			btn.TextColor3 = Color3.fromRGB(255, 170, 60)
		else
			btn.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
			btn.TextColor3 = Color3.fromRGB(180, 120, 60)
		end
	end
end

tabAutomation.MouseButton1Click:Connect(function() setTab("Automation") end)
tabEgg.MouseButton1Click:Connect(function() setTab("Egg") end)
tabOther.MouseButton1Click:Connect(function() setTab("Other") end)
tabSettings.MouseButton1Click:Connect(function() setTab("Settings") end)
setTab("Egg")

-------------------------------------------------
-- CLOSE / OPEN + DRAG
-------------------------------------------------
closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	isOpen = false
	saveSettings()
end)

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 46, 0, 46)
openBtn.Position = UDim2.new(0, 30, 0, 100)
openBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
openBtn.Text = "DS"
openBtn.TextColor3 = Color3.fromRGB(255, 160, 50)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.Parent = screenGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 11)
local os = Instance.new("UIStroke", openBtn)
os.Color = Color3.fromRGB(255, 140, 40)
os.Thickness = 1.4

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

print("Divine Soul - New Tab Structure Loaded")
