-- Improved Egg Teleport UI + Size ESP (Unique Eggs Only)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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
mainFrame.Size = UDim2.new(0, 260, 0, 380)
mainFrame.Position = UDim2.new(0, 25, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(90, 90, 130)
stroke.Thickness = 1.8
stroke.Parent = mainFrame

-- Title Bar (this is the drag handle)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

-- Fix bottom corners of title
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 15)
titleFix.Position = UDim2.new(0, 0, 1, -15)
titleFix.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🥚 Egg Teleport + ESP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = titleBar

-- ====================== DRAGGING (Fixed) ======================
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

titleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- ====================== SCROLL ======================
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 160)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

local function teleportTo(target)
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp and target then
		hrp.CFrame = target:GetPivot() * CFrame.new(0, 5, 0)
	end
end

local function createButton(text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 36)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 14
	btn.AutoButtonColor = false
	btn.Parent = scroll

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 9)
	c.Parent = btn

	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.new(
			math.min(color.R + 0.12, 1),
			math.min(color.G + 0.12, 1),
			math.min(color.B + 0.12, 1)
		)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = color
	end)

	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Baseplate Button
createButton("🏠  Teleport to Base", Color3.fromRGB(35, 120, 75), function()
	local base = workspace:FindFirstChild("Plots")
		and workspace.Plots:FindFirstChild("Plot")
		and workspace.Plots.Plot:FindFirstChild("Baseplate")
	if base then
		teleportTo(base)
		print("Teleported to Base")
	else
		warn("Baseplate not found")
	end
end)

-- Refresh Button
createButton("🔄  Refresh Eggs (Unique)", Color3.fromRGB(55, 55, 95), function()
	-- Clear old egg buttons
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") and child.Text:find("🥚") then
			child:Destroy()
		end
	end

	local rendered = workspace:FindFirstChild("RenderedEggs")
	if not rendered then
		warn("RenderedEggs not found")
		return
	end

	local uniqueEggs = {}
	local count = 0

	for _, egg in ipairs(rendered:GetChildren()) do
		if not uniqueEggs[egg.Name] then
			uniqueEggs[egg.Name] = egg
			count += 1

			createButton("🥚  " .. egg.Name, Color3.fromRGB(45, 45, 65), function()
				-- Teleport to the first egg with this name
				teleportTo(egg)
				print("Teleported to → " .. egg.Name)
			end)
		end
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 15)
	print("Loaded " .. count .. " unique eggs")
end)

-- ====================== ESP ======================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "EggSizeESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function getEggSize(egg)
	local size = egg:GetExtentsSize()
	local volume = size.X * size.Y * size.Z

	if volume > 80 then
		return "HUGE", Color3.fromRGB(255, 60, 60)
	elseif volume > 40 then
		return "Large", Color3.fromRGB(255, 170, 40)
	elseif volume > 18 then
		return "Medium", Color3.fromRGB(50, 255, 120)
	else
		return "Small", Color3.fromRGB(170, 170, 170)
	end
end

local function createESP(egg)
	local id = egg.Name .. "_" .. egg:GetDebugId()
	if ESPFolder:FindFirstChild(id) then return end

	local part = egg:FindFirstChild("EggBase") or egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = id
	billboard.Adornee = part
	billboard.Size = UDim2.new(0, 135, 0, 42)
	billboard.StudsOffset = Vector3.new(0, 3.8, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = ESPFolder

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextStrokeTransparency = 0.2
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.Parent = billboard

	local sizeText, color = getEggSize(egg)
	label.Text = egg.Name .. "\n" .. sizeText
	label.TextColor3 = color
end

local function updateESP()
	local renderedEggs = workspace:FindFirstChild("RenderedEggs")
	if not renderedEggs then return end

	for _, esp in ipairs(ESPFolder:GetChildren()) do
		local stillExists = false
		for _, egg in ipairs(renderedEggs:GetChildren()) do
			if esp.Name:find(egg:GetDebugId()) then
				stillExists = true
				break
			end
		end
		if not stillExists then
			esp:Destroy()
		end
	end

	for _, egg in ipairs(renderedEggs:GetChildren()) do
		createESP(egg)
	end
end

task.spawn(function()
	while task.wait(0.8) do
		updateESP()
	end
end)

print("✅ Improved UI + Unique Eggs + ESP loaded!")
print("Drag from the top bar • Click Refresh to load unique eggs")
