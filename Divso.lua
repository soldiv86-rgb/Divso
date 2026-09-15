-- Professional Egg Manager (Tabs + Adjustable Multi-Step)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TWEEN_DURATION = 2.8
local MULTISTEP_DELAY = 0.22

-- Remove old UI
if playerGui:FindFirstChild("EggTeleportUI") then
	playerGui.EggTeleportUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggTeleportUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 520)
mainFrame.Position = UDim2.new(0, 30, 0.2, 0)
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
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 16)
headerFix.Position = UDim2.new(0, 0, 1, -16)
headerFix.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

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
local dragging, dragStart, startPos
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
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Tab Buttons
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -24, 0, 34)
tabFrame.Position = UDim2.new(0, 12, 0, 56)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabTeleport = Instance.new("TextButton")
tabTeleport.Size = UDim2.new(0.5, -4, 1, 0)
tabTeleport.BackgroundColor3 = Color3.fromRGB(50, 90, 160)
tabTeleport.Text = "Teleport"
tabTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
tabTeleport.Font = Enum.Font.GothamBold
tabTeleport.TextSize = 14
tabTeleport.Parent = tabFrame

local tabEggs = Instance.new("TextButton")
tabEggs.Size = UDim2.new(0.5, -4, 1, 0)
tabEggs.Position = UDim2.new(0.5, 4, 0, 0)
tabEggs.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
tabEggs.Text = "Eggs"
tabEggs.TextColor3 = Color3.fromRGB(200, 200, 220)
tabEggs.Font = Enum.Font.GothamBold
tabEggs.TextSize = 14
tabEggs.Parent = tabFrame

local function corner(btn)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn
end
corner(tabTeleport)
corner(tabEggs)

-- Pages
local teleportPage = Instance.new("ScrollingFrame")
teleportPage.Size = UDim2.new(1, -24, 1, -108)
teleportPage.Position = UDim2.new(0, 12, 0, 98)
teleportPage.BackgroundTransparency = 1
teleportPage.BorderSizePixel = 0
teleportPage.ScrollBarThickness = 4
teleportPage.Visible = true
teleportPage.Parent = mainFrame

local eggsPage = Instance.new("ScrollingFrame")
eggsPage.Size = UDim2.new(1, -24, 1, -108)
eggsPage.Position = UDim2.new(0, 12, 0, 98)
eggsPage.BackgroundTransparency = 1
eggsPage.BorderSizePixel = 0
eggsPage.ScrollBarThickness = 4
eggsPage.Visible = false
eggsPage.Parent = mainFrame

local function addList(parent)
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 9)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = parent
	return l
end

local teleportList = addList(teleportPage)
local eggsList = addList(eggsPage)

-- Tab switching
local function switchTab(isTeleport)
	teleportPage.Visible = isTeleport
	eggsPage.Visible = not isTeleport

	tabTeleport.BackgroundColor3 = isTeleport and Color3.fromRGB(50, 90, 160) or Color3.fromRGB(40, 40, 55)
	tabEggs.BackgroundColor3 = isTeleport and Color3.fromRGB(40, 40, 55) or Color3.fromRGB(50, 90, 160)

	tabTeleport.TextColor3 = isTeleport and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
	tabEggs.TextColor3 = isTeleport and Color3.fromRGB(200, 200, 220) or Color3.fromRGB(255, 255, 255)
end

tabTeleport.MouseButton1Click:Connect(function()
	switchTab(true)
end)
tabEggs.MouseButton1Click:Connect(function()
	switchTab(false)
end)

-- ====================== SLIDERS ======================
local function createSlider(parent, titleText, minVal, maxVal, defaultVal, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 58)
	frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 20)
	title.Position = UDim2.new(0, 10, 0, 6)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = Color3.fromRGB(200, 200, 220)
	title.Font = Enum.Font.GothamMedium
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -20, 0, 8)
	bg.Position = UDim2.new(0, 10, 0, 34)
	bg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	bg.BorderSizePixel = 0
	bg.Parent = frame

	local bgC = Instance.new("UICorner")
	bgC.CornerRadius = UDim.new(1, 0)
	bgC.Parent = bg

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(90, 130, 255)
	fill.BorderSizePixel = 0
	fill.Parent = bg

	local fillC = Instance.new("UICorner")
	fillC.CornerRadius = UDim.new(1, 0)
	fillC.Parent = fill

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 18, 0, 18)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = bg

	local btnC = Instance.new("UICorner")
	btnC.CornerRadius = UDim.new(1, 0)
	btnC.Parent = btn

	local sliding = false

	local function update(value)
		value = math.clamp(value, 0, 1)
		fill.Size = UDim2.new(value, 0, 1, 0)
		btn.Position = UDim2.new(value, -9, 0.5, -9)

		local result = minVal + (maxVal - minVal) * value
		result = math.floor(result * 100) / 100
		title.Text = titleText:gsub("%d+%.?%d*", tostring(result))
		callback(result)
	end

	btn.InputBegan:Connect(function(input)
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
			local rel = input.Position.X - bg.AbsolutePosition.X
			update(rel / bg.AbsoluteSize.X)
		end
	end)

	-- Set default
	local defaultAlpha = (defaultVal - minVal) / (maxVal - minVal)
	update(defaultAlpha)

	return frame
end

createSlider(teleportPage, "Tween Speed: 2.8s", 1.0, 6.0, 2.8, function(val)
	TWEEN_DURATION = val
end)

createSlider(teleportPage, "Multi-Step Delay: 0.22s", 0.08, 0.50, 0.22, function(val)
	MULTISTEP_DELAY = val
end)

-- ====================== BUTTONS ======================
local function createButton(parent, text, bgColor, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = bgColor
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 14
	btn.AutoButtonColor = false
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = btn

	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(255, 255, 255)
	s.Thickness = 1
	s.Transparency = 0.92
	s.Parent = btn

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
	return workspace:FindFirstChild("Plots")
		and workspace.Plots:FindFirstChild("Plot")
		and workspace.Plots.Plot:FindFirstChild("Baseplate")
end

local function teleportTo(target)
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp and target then
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
	print("Tweening • " .. TWEEN_DURATION .. "s")
end

local function multiStepToBase()
	local base = getBase()
	local char = player.Character
	if not base or not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local start = hrp.Position
	local goal = (base:GetPivot() * CFrame.new(0, 5, 0)).Position
	local steps = 12

	for i = 1, steps do
		hrp.CFrame = CFrame.new(start:Lerp(goal, i / steps))
		task.wait(MULTISTEP_DELAY)
	end
	print("Multi-step done • delay " .. MULTISTEP_DELAY .. "s")
end

createButton(teleportPage, "Instant Return to Base", Color3.fromRGB(32, 95, 65), function()
	local base = getBase()
	if base then teleportTo(base) else warn("Base not found") end
end)

createButton(teleportPage, "Smooth Tween to Base", Color3.fromRGB(35, 80, 140), function()
	tweenToBase()
end)

createButton(teleportPage, "Multi-Step Return to Base", Color3.fromRGB(85, 55, 130), function()
	multiStepToBase()
end)

createButton(eggsPage, "Refresh Unique Eggs", Color3.fromRGB(45, 45, 70), function()
	for _, child in ipairs(eggsPage:GetChildren()) do
		if child:IsA("TextButton") and child.Text:find("Egg •") then
			child:Destroy()
		end
	end

	local rendered = workspace:FindFirstChild("RenderedEggs")
	if not rendered then
		warn("RenderedEggs not found")
		return
	end

	local unique = {}
	local count = 0

	for _, egg in ipairs(rendered:GetChildren()) do
		if not unique[egg.Name] then
			unique[egg.Name] = true
			count += 1

			createButton(eggsPage, "Egg • " .. egg.Name, Color3.fromRGB(38, 38, 52), function()
				teleportTo(egg)
				print("→ " .. egg.Name)
			end)
		end
	end

	eggsPage.CanvasSize = UDim2.new(0, 0, 0, eggsList.AbsoluteContentSize.Y + 12)
	print("Loaded " .. count .. " unique eggs")
end)

-- ====================== ESP ======================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "EggSizeESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function getSize(egg)
	local s = egg:GetExtentsSize()
	local vol = s.X * s.Y * s.Z
	if vol > 80 then return "HUGE", Color3.fromRGB(255, 70, 70)
	elseif vol > 40 then return "Large", Color3.fromRGB(255, 175, 50)
	elseif vol > 18 then return "Medium", Color3.fromRGB(60, 255, 130)
	else return "Small", Color3.fromRGB(170, 170, 180) end
end

local function createESP(egg)
	local id = egg.Name .. "_" .. egg:GetDebugId()
	if ESPFolder:FindFirstChild(id) then return end

	local part = egg:FindFirstChild("EggBase") or egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	local bb = Instance.new("BillboardGui")
	bb.Name = id
	bb.Adornee = part
	bb.Size = UDim2.new(0, 140, 0, 44)
	bb.StudsOffset = Vector3.new(0, 4, 0)
	bb.AlwaysOnTop = true
	bb.Parent = ESPFolder

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextStrokeTransparency = 0.25
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.Parent = bb

	local text, color = getSize(egg)
	label.Text = egg.Name .. "\n" .. text
	label.TextColor3 = color
end

task.spawn(function()
	while task.wait(0.75) do
		local folder = workspace:FindFirstChild("RenderedEggs")
		if not folder then continue end

		for _, esp in ipairs(ESPFolder:GetChildren()) do
			local exists = false
			for _, egg in ipairs(folder:GetChildren()) do
				if esp.Name:find(egg:GetDebugId()) then
					exists = true
					break
				end
			end
			if not exists then esp:Destroy() end
		end

		for _, egg in ipairs(folder:GetChildren()) do
			createESP(egg)
		end
	end
end)

print("Tabbed Egg Manager loaded • Adjustable Tween + Multi-Step")
