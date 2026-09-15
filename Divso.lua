-- Egg Manager (Split View + Grounded Multi-Step)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TWEEN_DURATION = 5.0
local MULTISTEP_DELAY = 0.45

if playerGui:FindFirstChild("EggTeleportUI") then
	playerGui.EggTeleportUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggTeleportUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 480)
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
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 14)
headerFix.Position = UDim2.new(0, 0, 1, -14)
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

-- Left Panel (Teleport)
local leftPanel = Instance.new("ScrollingFrame")
leftPanel.Size = UDim2.new(0.5, -18, 1, -62)
leftPanel.Position = UDim2.new(0, 12, 0, 54)
leftPanel.BackgroundTransparency = 1
leftPanel.BorderSizePixel = 0
leftPanel.ScrollBarThickness = 4
leftPanel.Parent = mainFrame

local leftList = Instance.new("UIListLayout")
leftList.Padding = UDim.new(0, 8)
leftList.SortOrder = Enum.SortOrder.LayoutOrder
leftList.Parent = leftPanel

-- Right Panel (Eggs)
local rightPanel = Instance.new("ScrollingFrame")
rightPanel.Size = UDim2.new(0.5, -18, 1, -62)
rightPanel.Position = UDim2.new(0.5, 6, 0, 54)
rightPanel.BackgroundTransparency = 1
rightPanel.BorderSizePixel = 0
rightPanel.ScrollBarThickness = 4
rightPanel.Parent = mainFrame

local rightList = Instance.new("UIListLayout")
rightList.Padding = UDim.new(0, 8)
rightList.SortOrder = Enum.SortOrder.LayoutOrder
rightList.Parent = rightPanel

-- Divider line
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 1, -70)
divider.Position = UDim2.new(0.5, -0.5, 0, 54)
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-- ====================== CONTROLS ======================
local function createAdvancedControl(parent, labelText, minVal, maxVal, defaultVal, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 72)
	frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -80, 0, 18)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = labelText
	title.TextColor3 = Color3.fromRGB(200, 200, 220)
	title.Font = Enum.Font.GothamMedium
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

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

	local tbC = Instance.new("UICorner")
	tbC.CornerRadius = UDim.new(0, 6)
	tbC.Parent = textBox

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -20, 0, 7)
	bg.Position = UDim2.new(0, 10, 0, 40)
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
	btn.Size = UDim2.new(0, 16, 0, 16)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = bg

	local btnC = Instance.new("UICorner")
	btnC.CornerRadius = UDim.new(1, 0)
	btnC.Parent = btn

	local sliding = false

	local function setValue(val)
		val = math.clamp(val, minVal, maxVal)
		val = math.floor(val * 100) / 100
		local alpha = (val - minVal) / (maxVal - minVal)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		btn.Position = UDim2.new(alpha, -8, 0.5, -8)
		textBox.Text = tostring(val)
		callback(val)
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
			local alpha = math.clamp(rel / bg.AbsoluteSize.X, 0, 1)
			setValue(minVal + (maxVal - minVal) * alpha)
		end
	end)

	textBox.FocusLost:Connect(function()
		local num = tonumber(textBox.Text)
		if num then setValue(num) else textBox.Text = tostring(defaultVal) end
	end)

	setValue(defaultVal)
end

createAdvancedControl(leftPanel, "Tween Speed (s)", 2.0, 12.0, 5.0, function(v) TWEEN_DURATION = v end)
createAdvancedControl(leftPanel, "Multi-Step Delay (s)", 0.20, 1.20, 0.45, function(v) MULTISTEP_DELAY = v end)

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

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 9)
	c.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.new(math.min(bgColor.R+0.08,1), math.min(bgColor.G+0.08,1), math.min(bgColor.B+0.08,1))
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = bgColor}):Play()
	end)

	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function getBase()
	return workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild("Plot") and workspace.Plots.Plot:FindFirstChild("Baseplate")
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
end

-- Grounded Multi-Step
local function multiStepToBase()
	local base = getBase()
	local char = player.Character
	if not base or not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local start = hrp.Position
	local goal = (base:GetPivot() * CFrame.new(0, 3, 0)).Position
	local steps = 14

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {char}

	for i = 1, steps do
		local targetPos = start:Lerp(goal, i / steps)

		-- Raycast down to stay on ground
		local ray = workspace:Raycast(targetPos + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), rayParams)
		if ray then
			targetPos = Vector3.new(targetPos.X, ray.Position.Y + 3, targetPos.Z)
		end

		hrp.CFrame = CFrame.new(targetPos)
		task.wait(MULTISTEP_DELAY)
	end
	print("Grounded multi-step finished")
end

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

createButton(rightPanel, "Refresh Unique Eggs", Color3.fromRGB(45, 45, 70), function()
	for _, child in ipairs(rightPanel:GetChildren()) do
		if child:IsA("TextButton") and child.Text:find("Egg •") then
			child:Destroy()
		end
	end

	local rendered = workspace:FindFirstChild("RenderedEggs")
	if not rendered then return end

	local unique = {}
	local count = 0

	for _, egg in ipairs(rendered:GetChildren()) do
		if not unique[egg.Name] then
			unique[egg.Name] = true
			count += 1
			createButton(rightPanel, "Egg • " .. egg.Name, Color3.fromRGB(38, 38, 52), function()
				teleportTo(egg)
			end)
		end
	end

	rightPanel.CanvasSize = UDim2.new(0, 0, 0, rightList.AbsoluteContentSize.Y + 10)
	print("Loaded " .. count .. " unique eggs")
end)

-- ESP
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
				if esp.Name:find(egg:GetDebugId()) then exists = true break end
			end
			if not exists then esp:Destroy() end
		end
		for _, egg in ipairs(folder:GetChildren()) do createESP(egg) end
	end
end)

print("Split UI + Grounded Multi-Step loaded")
