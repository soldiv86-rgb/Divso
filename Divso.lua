-- Professional Egg Manager + Adjustable Tween Slider

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Default tween duration
local TWEEN_DURATION = 1.6

-- Remove old UI
if playerGui:FindFirstChild("EggTeleportUI") then
	playerGui.EggTeleportUI:Destroy()
end

-- ====================== UI ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggTeleportUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 290, 0, 510)
mainFrame.Position = UDim2.new(0, 30, 0.22, 0)
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

-- Content
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -24, 1, -66)
content.Position = UDim2.new(0, 12, 0, 56)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = mainFrame

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 9)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = content

-- ====================== SLIDER ======================
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(1, 0, 0, 58)
sliderFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
sliderFrame.BorderSizePixel = 0
sliderFrame.Parent = content

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 10)
sliderCorner.Parent = sliderFrame

local sliderTitle = Instance.new("TextLabel")
sliderTitle.Size = UDim2.new(1, -16, 0, 20)
sliderTitle.Position = UDim2.new(0, 10, 0, 6)
sliderTitle.BackgroundTransparency = 1
sliderTitle.Text = "Tween Speed: 1.6s"
sliderTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
sliderTitle.Font = Enum.Font.GothamMedium
sliderTitle.TextSize = 13
sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
sliderTitle.Parent = sliderFrame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -20, 0, 8)
sliderBg.Position = UDim2.new(0, 10, 0, 34)
sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = sliderFrame

local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(1, 0)
sliderBgCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.32, 0, 1, 0) -- default position
sliderFill.BackgroundColor3 = Color3.fromRGB(90, 130, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(1, 0)
sliderFillCorner.Parent = sliderFill

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 18, 0, 18)
sliderButton.Position = UDim2.new(0.32, -9, 0.5, -9)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.Text = ""
sliderButton.AutoButtonColor = false
sliderButton.Parent = sliderBg

local sliderBtnCorner = Instance.new("UICorner")
sliderBtnCorner.CornerRadius = UDim.new(1, 0)
sliderBtnCorner.Parent = sliderButton

-- Slider logic (0.4s → 4.0s)
local sliding = false
local minDuration = 0.4
local maxDuration = 4.0

local function updateSlider(value)
	value = math.clamp(value, 0, 1)
	sliderFill.Size = UDim2.new(value, 0, 1, 0)
	sliderButton.Position = UDim2.new(value, -9, 0.5, -9)

	TWEEN_DURATION = minDuration + (maxDuration - minDuration) * value
	TWEEN_DURATION = math.floor(TWEEN_DURATION * 10) / 10 -- 1 decimal
	sliderTitle.Text = "Tween Speed: " .. TWEEN_DURATION .. "s"
end

sliderButton.InputBegan:Connect(function(input)
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
		local rel = input.Position.X - sliderBg.AbsolutePosition.X
		local value = rel / sliderBg.AbsoluteSize.X
		updateSlider(value)
	end
end)

-- Set default
updateSlider(0.32)

-- ====================== BUTTONS ======================
local function createButton(text, bgColor, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = bgColor
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 14
	btn.AutoButtonColor = false
	btn.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 1
	stroke.Transparency = 0.92
	stroke.Parent = btn

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

	local tween = TweenService:Create(hrp, TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = base:GetPivot() * CFrame.new(0, 5, 0)
	})
	tween:Play()
	print("Tweening to base • " .. TWEEN_DURATION .. "s")
end

local function multiStepToBase()
	local base = getBase()
	local char = player.Character
	if not base or not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local start = hrp.Position
	local goal = (base:GetPivot() * CFrame.new(0, 5, 0)).Position
	local steps = 7

	for i = 1, steps do
		hrp.CFrame = CFrame.new(start:Lerp(goal, i / steps))
		task.wait(0.11)
	end
	print("Multi-step returned to base")
end

createButton("Instant Return to Base", Color3.fromRGB(32, 95, 65), function()
	local base = getBase()
	if base then
		teleportTo(base)
	else
		warn("Baseplate not found")
	end
end)

createButton("Smooth Tween to Base", Color3.fromRGB(35, 80, 140), function()
	tweenToBase()
end)

createButton("Multi-Step Return to Base", Color3.fromRGB(85, 55, 130), function()
	multiStepToBase()
end)

createButton("Refresh Unique Eggs", Color3.fromRGB(45, 45, 70), function()
	for _, child in ipairs(content:GetChildren()) do
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

			createButton("Egg • " .. egg.Name, Color3.fromRGB(38, 38, 52), function()
				teleportTo(egg)
				print("→ " .. egg.Name)
			end)
		end
	end

	content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 12)
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

print("Professional Egg Manager + Slider loaded")
