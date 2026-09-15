-- Divine Soul - Ride a Pet (Black & Orange + Auto Farm + Status Panel)
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
	GoMethod = "MultiTeleport",     -- "Tween" or "MultiTeleport"
	ReturnMethod = "Tween",         -- "Tween" or "MultiTeleport"
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
local currentTab = "Main"
local currentSearch = ""
local eggButtons = {}
local espObjects = {}
local espEnabled = Settings.ESPEnabled
local autoRefreshEnabled = Settings.AutoRefreshEnabled
local autoFarmEnabled = Settings.AutoFarmEnabled
local enabledRarities = Settings.EnabledRarities
local goMethod = Settings.GoMethod
local returnMethod = Settings.ReturnMethod

-- Auto Farm Stats
local farmStartTime = 0
local eggsCollected = 0
local lastCollectedRarity = "-"
local currentAction = "Idle"
local currentTarget = "-"
-------------------------------------------------
-- CLEANUP
-------------------------------------------------
if playerGui:FindFirstChild("DivineSoulUI") then
	playerGui.DivineSoulUI:Destroy()
end
if CoreGui:FindFirstChild("EggSizeESP") then
	CoreGui.EggSizeESP:Destroy()
end
if playerGui:FindFirstChild("DivineSoulStatus") then
	playerGui.DivineSoulStatus:Destroy()
end
-------------------------------------------------
-- STATUS PANEL (Top Right)
-------------------------------------------------
local statusGui = Instance.new("ScreenGui")
statusGui.Name = "DivineSoulStatus"
statusGui.ResetOnSpawn = false
statusGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
statusGui.Parent = playerGui

local statusPanel = Instance.new("Frame")
statusPanel.Size = UDim2.new(0, 290, 0, 0)
statusPanel.AutomaticSize = Enum.AutomaticSize.Y
statusPanel.Position = UDim2.new(1, -310, 0, 20)
statusPanel.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
statusPanel.BorderSizePixel = 0
statusPanel.Visible = false
statusPanel.Parent = statusGui

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 10)
statusCorner.Parent = statusPanel

local statusStroke = Instance.new("UIStroke")
statusStroke.Color = Color3.fromRGB(255, 140, 40)
statusStroke.Thickness = 1.2
statusStroke.Parent = statusPanel

local statusPadding = Instance.new("UIPadding")
statusPadding.PaddingTop = UDim.new(0, 12)
statusPadding.PaddingBottom = UDim.new(0, 12)
statusPadding.PaddingLeft = UDim.new(0, 14)
statusPadding.PaddingRight = UDim.new(0, 14)
statusPadding.Parent = statusPanel

local statusList = Instance.new("UIListLayout")
statusList.Padding = UDim.new(0, 4)
statusList.Parent = statusPanel

local function addStatusLabel(text, color, size)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, size or 18)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(220, 180, 120)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Parent = statusPanel
	return label
end

local titleLabel = addStatusLabel("Divine Soul • Auto Farm", Color3.fromRGB(255, 160, 50), 20)
titleLabel.Font = Enum.Font.GothamBold

local statusLabel = addStatusLabel("Status: Idle", Color3.fromRGB(180, 180, 180))
local actionLabel = addStatusLabel("Action: -", Color3.fromRGB(220, 180, 120))
local targetLabel = addStatusLabel("Target: -", Color3.fromRGB(220, 180, 120))
local collectedLabel = addStatusLabel("Eggs Collected: 0", Color3.fromRGB(220, 180, 120))
local lastRarityLabel = addStatusLabel("Last Rarity: -", Color3.fromRGB(220, 180, 120))
local uptimeLabel = addStatusLabel("Uptime: 00:00", Color3.fromRGB(180, 180, 180))
local settingsLabel = addStatusLabel("Go: Multi  |  Return: Tween  |  Hold: 0.75s", Color3.fromRGB(160, 140, 100))

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
	local mins = math.floor(elapsed / 60)
	local secs = elapsed % 60
	uptimeLabel.Text = string.format("Uptime: %02d:%02d", mins, secs)

	settingsLabel.Text = string.format("Go: %s  |  Return: %s  |  Hold: %.2fs",
		goMethod == "MultiTeleport" and "Multi" or "Tween",
		returnMethod == "MultiTeleport" and "Multi" or "Tween",
		Settings.CollectHoldTime)
end

task.spawn(function()
	while task.wait(0.5) do
		if autoFarmEnabled then
			updateStatusPanel()
		else
			statusPanel.Visible = false
		end
	end
end)
-------------------------------------------------
-- UI
-------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DivineSoulUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 780, 0, 520)
main.Position = UDim2.new(0.5, -390, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 140, 40)
mainStroke.Thickness = 1.2
mainStroke.Parent = main
-------------------------------------------------
-- LEFT SIDEBAR
-------------------------------------------------
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 170, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 12)
sideCorner.Parent = sidebar
local sideCover = Instance.new("Frame")
sideCover.Size = UDim2.new(0, 20, 1, 0)
sideCover.Position = UDim2.new(1, -20, 0, 0)
sideCover.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
sideCover.BorderSizePixel = 0
sideCover.Parent = sidebar

local sideTitle = Instance.new("TextLabel")
sideTitle.Size = UDim2.new(1, -20, 0, 28)
sideTitle.Position = UDim2.new(0, 14, 0, 14)
sideTitle.BackgroundTransparency = 1
sideTitle.Text = "Divine Soul"
sideTitle.TextColor3 = Color3.fromRGB(255, 160, 50)
sideTitle.Font = Enum.Font.GothamBold
sideTitle.TextSize = 17
sideTitle.TextXAlignment = Enum.TextXAlignment.Left
sideTitle.Parent = sidebar

local sideSub = Instance.new("TextLabel")
sideSub.Size = UDim2.new(1, -20, 0, 18)
sideSub.Position = UDim2.new(0, 14, 0, 40)
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
	btn.Size = UDim2.new(1, -20, 0, 36)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	btn.Text = "  " .. name
	btn.TextColor3 = Color3.fromRGB(200, 140, 70)
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
local tabHop  = createSideTab("Server Hop", 112)
-------------------------------------------------
-- CONTENT
-------------------------------------------------
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -190, 1, -20)
content.Position = UDim2.new(0, 180, 0, 10)
content.BackgroundTransparency = 1
content.Parent = main

local headerBar = Instance.new("Frame")
headerBar.Size = UDim2.new(1, 0, 0, 40)
headerBar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
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
headerTitle.TextColor3 = Color3.fromRGB(255, 170, 60)
headerTitle.Font = Enum.Font.GothamMedium
headerTitle.TextSize = 15
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
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = closeBtn
-------------------------------------------------
-- MAIN TAB
-------------------------------------------------
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, -50)
mainContent.Position = UDim2.new(0, 0, 0, 48)
mainContent.BackgroundTransparency = 1
mainContent.Parent = content

local left = Instance.new("ScrollingFrame")
left.Size = UDim2.new(0.42, 0, 1, 0)
left.BackgroundTransparency = 1
left.BorderSizePixel = 0
left.ScrollBarThickness = 3
left.AutomaticCanvasSize = Enum.AutomaticSize.Y
left.CanvasSize = UDim2.new(0, 0, 0, 0)
left.Parent = mainContent

local leftList = Instance.new("UIListLayout")
leftList.Padding = UDim.new(0, 12)
leftList.SortOrder = Enum.SortOrder.LayoutOrder
leftList.Parent = left

local leftPadding = Instance.new("UIPadding")
leftPadding.PaddingTop = UDim.new(0, 4)
leftPadding.PaddingBottom = UDim.new(0, 10)
leftPadding.PaddingLeft = UDim.new(0, 2)
leftPadding.PaddingRight = UDim.new(0, 6)
leftPadding.Parent = left

local right = Instance.new("Frame")
right.Size = UDim2.new(0.56, 0, 1, 0)
right.Position = UDim2.new(0.44, 0, 0, 0)
right.BackgroundTransparency = 1
right.Parent = mainContent

-- Rarity
local rarityFrame = Instance.new("Frame")
rarityFrame.Size = UDim2.new(1, 0, 0, 155)
rarityFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
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
rarityTitle.TextColor3 = Color3.fromRGB(255, 160, 50)
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
eggSearch.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
eggSearch.PlaceholderText = "Search eggs..."
eggSearch.Text = ""
eggSearch.TextColor3 = Color3.fromRGB(255, 200, 140)
eggSearch.PlaceholderColor3 = Color3.fromRGB(140, 100, 60)
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
-- HOP TAB
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
hopTitle.TextColor3 = Color3.fromRGB(255, 170, 60)
hopTitle.Font = Enum.Font.GothamBold
hopTitle.TextSize = 18
hopTitle.Parent = hopContent

local hopDesc = Instance.new("TextLabel")
hopDesc.Size = UDim2.new(1, 0, 0, 40)
hopDesc.Position = UDim2.new(0, 0, 0, 35)
hopDesc.BackgroundTransparency = 1
hopDesc.Text = "Teleport to a different server of this place."
hopDesc.TextColor3 = Color3.fromRGB(180, 130, 80)
hopDesc.Font = Enum.Font.Gotham
hopDesc.TextSize = 14
hopDesc.Parent = hopContent
-------------------------------------------------
-- FLOATING BUTTON
-------------------------------------------------
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 46, 0, 46)
openBtn.Position = UDim2.new(0, 30, 0, 100)
openBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
openBtn.Text = "DS"
openBtn.TextColor3 = Color3.fromRGB(255, 160, 50)
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
openStroke.Color = Color3.fromRGB(255, 140, 40)
openStroke.Thickness = 1.4
openStroke.Parent = openBtn
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

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 140, 40)
	stroke.Thickness = 1
	stroke.Transparency = 0.7
	stroke.Parent = card

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = card

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = card

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 18)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = Color3.fromRGB(255, 150, 50)
	title.Font = Enum.Font.GothamMedium
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.LayoutOrder = 0
	title.Parent = card

	return card
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
			BackgroundColor3 = Color3.new(math.min(color.R+0.1,1), math.min(color.G+0.08,1), math.min(color.B+0.05,1))
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
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
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
	title.TextColor3 = Color3.fromRGB(220, 160, 90)
	title.Font = Enum.Font.Gotham
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, 46, 0, 16)
	box.Position = UDim2.new(1, -54, 0, 5)
	box.BackgroundColor3 = Color3.fromRGB(35, 30, 25)
	box.Text = tostring(default)
	box.TextColor3 = Color3.fromRGB(255, 200, 120)
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
	track.BackgroundColor3 = Color3.fromRGB(40, 35, 30)
	track.BorderSizePixel = 0
	track.Parent = frame
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = track

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(255, 140, 40)
	fill.BorderSizePixel = 0
	fill.Parent = track
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = fill

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 13, 0, 13)
	knob.BackgroundColor3 = Color3.fromRGB(255, 180, 80)
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
	return frame
end

local function createToggle(parent, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 34)
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
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
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = toggle

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 220, 160)
	knob.BorderSizePixel = 0
	knob.Parent = toggle
	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

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

local function createMethodSelector(parent, labelText, currentValue, onChange)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 34)
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = frame

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
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0, 6)
	tc.Parent = tweenBtn

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
	local mc = Instance.new("UICorner")
	mc.CornerRadius = UDim.new(0, 6)
	mc.Parent = multiBtn

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
-- TELEPORT HELPERS
-------------------------------------------------
local function getBase()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	for _, plot in ipairs(plots:GetChildren()) do
		if plot.Name == "Plot" or plot:IsA("Model") or plot:IsA("Folder") then
			local data = plot:FindFirstChild("Data")
			if data then
				local ownerValue = data:FindFirstChild("Owner")
				if ownerValue and ownerValue:IsA("ObjectValue") then
					local owner = ownerValue.Value
					if typeof(owner) == "string" and owner == player.Name then
						return plot:FindFirstChild("Baseplate")
							or plot:FindFirstChild("Base")
							or plot:FindFirstChildWhichIsA("BasePart")
							or plot:FindFirstChild("Spawn")
							or plot.PrimaryPart
					end
					if typeof(owner) == "Instance" and owner:IsA("Player") and owner == player then
						return plot:FindFirstChild("Baseplate")
							or plot:FindFirstChild("Base")
							or plot:FindFirstChildWhichIsA("BasePart")
							or plot:FindFirstChild("Spawn")
							or plot.PrimaryPart
					end
				end
			end
		end
	end
	return nil
end

local function teleportTo(target)
	local char = player.Character
	if not char or not target then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = target:GetPivot() * CFrame.new(0, 5, 0)
	end
end

local function tweenTo(target)
	local char = player.Character
	if not char or not target then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	TweenService:Create(hrp, TweenInfo.new(Settings.TweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = target:GetPivot() * CFrame.new(0, 5, 0)
	}):Play()
	task.wait(Settings.TweenDuration)
end

local function multiTeleportTo(target)
	local char = player.Character
	if not char or not target then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local start = hrp.Position
	local goal = (target:GetPivot() * CFrame.new(0, 3, 0)).Position
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {char}

	for i = 1, Settings.MultiStepSteps do
		local pos = start:Lerp(goal, i / Settings.MultiStepSteps)
		local ray = workspace:Raycast(pos + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), rayParams)
		if ray then
			pos = Vector3.new(pos.X, ray.Position.Y + 3, pos.Z)
		end
		hrp.CFrame = CFrame.new(pos)
		task.wait(Settings.MultiStepDelay)
	end
end

local function goToTarget(target)
	if goMethod == "MultiTeleport" then
		multiTeleportTo(target)
	else
		tweenTo(target)
	end
end

local function returnToBase()
	local base = getBase()
	if not base then return end
	if returnMethod == "MultiTeleport" then
		multiTeleportTo(base)
	else
		tweenTo(base)
	end
end

-- Collect with adjustable hold time
local function collectEgg(egg)
	currentAction = "Collecting..."
	updateStatusPanel()

	local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then
		pcall(function()
			prompt:InputHoldBegin()
			task.wait(Settings.CollectHoldTime)
			prompt:InputHoldEnd()
		end)
		return
	end

	-- Fallback
	pcall(function()
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		task.wait(Settings.CollectHoldTime)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
	end)
end
-------------------------------------------------
-- AUTO FARM LOGIC
-------------------------------------------------
local function getEggRarity(eggName)
	for rarity, names in pairs(RarityEggs) do
		for _, name in ipairs(names) do
			if name == eggName then return rarity end
		end
	end
	return "Unknown"
end

local function getBestEgg()
	local rendered = workspace:FindFirstChild("RenderedEggs")
	if not rendered then return nil end

	local bestEgg, bestPriority = nil, -1
	for _, egg in ipairs(rendered:GetChildren()) do
		local rarity = getEggRarity(egg.Name)
		if enabledRarities[rarity] then
			local prio = RarityPriority[rarity] or 0
			if prio > bestPriority then
				bestPriority = prio
				bestEgg = egg
			end
		end
	end
	return bestEgg
end

local autoFarmRunning = false
local function startAutoFarm()
	if autoFarmRunning then return end
	autoFarmRunning = true
	farmStartTime = os.clock()
	eggsCollected = 0
	lastCollectedRarity = "-"
	currentAction = "Starting..."
	currentTarget = "-"

	task.spawn(function()
		while autoFarmEnabled and screenGui.Parent do
			local egg = getBestEgg()
			if egg and egg.Parent then
				local rarity = getEggRarity(egg.Name)
				currentTarget = egg.Name .. " (" .. rarity .. ")"
				currentAction = "Going to egg"
				updateStatusPanel()

				goToTarget(egg)
				task.wait(0.25)

				currentAction = "Holding to collect"
				updateStatusPanel()
				collectEgg(egg)
				task.wait(0.2)

				eggsCollected += 1
				lastCollectedRarity = rarity

				currentAction = "Returning to base"
				updateStatusPanel()
				returnToBase()

				task.wait(Settings.AutoFarmDelay)
			else
				currentAction = "Waiting for eggs..."
				currentTarget = "-"
				updateStatusPanel()
				task.wait(1.5)
			end
		end
		autoFarmRunning = false
		currentAction = "Stopped"
		updateStatusPanel()
	end)
end
-------------------------------------------------
-- EGGS + RARITY (same as before)
-------------------------------------------------
local function clearEggs()
	for btn in pairs(eggButtons) do btn:Destroy() end
	eggButtons = {}
end

local function refreshEggs()
	clearEggs()
	local rendered = workspace:FindFirstChild("RenderedEggs")
	if not rendered then return end

	local allowed = {}
	for rarity, on in pairs(enabledRarities) do
		if on then
			for _, name in ipairs(RarityEggs[rarity] or {}) do
				allowed[name] = rarity
			end
		end
	end

	for _, egg in ipairs(rendered:GetChildren()) do
		local rarity = allowed[egg.Name]
		if rarity and (currentSearch == "" or egg.Name:lower():find(currentSearch:lower(), 1, true)) then
			local color = RarityColors[rarity] or Color3.fromRGB(60, 50, 40)
			local btn = createButton(eggScroll, egg.Name, color, function()
				teleportTo(egg)
			end)
			eggButtons[btn] = true
		end
	end
end

eggSearch:GetPropertyChangedSignal("Text"):Connect(function()
	currentSearch = eggSearch.Text
	refreshEggs()
end)

local function updateRarityButtons()
	for _, child in ipairs(rarityScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for _, rarity in ipairs(Rarities) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 28)
		btn.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
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
		label.TextColor3 = Color3.fromRGB(230, 180, 110)
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
local autoFarmCard = createCard(left, "AUTO FARM")

createToggle(autoFarmCard, "Auto Farm", Settings.AutoFarmEnabled, function(state)
	autoFarmEnabled = state
	Settings.AutoFarmEnabled = state
	if state then startAutoFarm() end
	saveSettings()
end)

createSlider(autoFarmCard, "Farm Delay (s)", 0.4, 4.0, Settings.AutoFarmDelay, function(v)
	Settings.AutoFarmDelay = v
end)

createSlider(autoFarmCard, "Collect Hold Time (s)", 0.3, 2.0, Settings.CollectHoldTime, function(v)
	Settings.CollectHoldTime = v
end)

createMethodSelector(autoFarmCard, "Go to Egg", goMethod, function(val)
	goMethod = val
	Settings.GoMethod = val
	saveSettings()
end)

createMethodSelector(autoFarmCard, "Return to Base", returnMethod, function(val)
	returnMethod = val
	Settings.ReturnMethod = val
	saveSettings()
end)

-- MOVEMENT CARD
local movementCard = createCard(left, "MOVEMENT")

createButton(movementCard, "Instant Return to Base", Color3.fromRGB(255, 120, 30), function()
	local base = getBase()
	if base then teleportTo(base) end
end)

createButton(movementCard, "Multi-Teleport to Base", Color3.fromRGB(200, 90, 20), function()
	local base = getBase()
	if base then multiTeleportTo(base) end
end)
createSlider(movementCard, "Multi-Teleport Delay (s)", 0.2, 1.2, Settings.MultiStepDelay, function(v)
	Settings.MultiStepDelay = v
end)

createButton(movementCard, "Smooth Tween to Base", Color3.fromRGB(255, 140, 40), function()
	local base = getBase()
	if base then tweenTo(base) end
end)
createSlider(movementCard, "Tween Speed (s)", 2, 12, Settings.TweenDuration, function(v)
	Settings.TweenDuration = v
end)

-- OPTIONS CARD
local optionsCard = createCard(left, "OPTIONS")

createToggle(optionsCard, "Auto Refresh", Settings.AutoRefreshEnabled, function(state)
	autoRefreshEnabled = state
	Settings.AutoRefreshEnabled = state
end)

createToggle(optionsCard, "Egg ESP", Settings.ESPEnabled, function(state)
	espEnabled = state
	Settings.ESPEnabled = state
end)

createButton(eggScroll, "Refresh Eggs", Color3.fromRGB(50, 40, 30), function()
	refreshEggs()
end)

createButton(hopContent, "Server Hop Now", Color3.fromRGB(255, 120, 30), function()
	TeleportService:Teleport(game.PlaceId, player)
end).Position = UDim2.new(0, 0, 0, 90)
-------------------------------------------------
-- TABS + CLOSE/OPEN + DRAG (same as before)
-------------------------------------------------
local function setTab(name)
	currentTab = name
	mainContent.Visible = name == "Main"
	hopContent.Visible = name == "Server Hop"
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
tabMain.MouseButton1Click:Connect(function() setTab("Main") end)
tabHop.MouseButton1Click:Connect(function() setTab("Server Hop") end)
setTab("Main")

closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	isOpen = false
	saveSettings()
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

local function isEggAllowed(egg)
	return enabledRarities[getEggRarity(egg.Name)] == true
end

local function createESP(egg)
	if not espEnabled or not isEggAllowed(egg) then return end
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
			if isEggAllowed(egg) then
				local id = tostring(egg:GetDebugId())
				alive[id] = true
				createESP(egg)
			end
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

if autoFarmEnabled then startAutoFarm() end
refreshEggs()
print("Divine Soul loaded - Go/Return Method + Collect Hold Slider")
