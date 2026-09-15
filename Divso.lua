-- Combined: Egg Teleport UI + Egg Size ESP

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old UI if exists
if playerGui:FindFirstChild("EggTeleportUI") then
    playerGui.EggTeleportUI:Destroy()
end

-- ====================== UI ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggTeleportUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 320)
mainFrame.Position = UDim2.new(0, 20, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 110)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "🥚 Egg Teleport + ESP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = mainFrame

-- Dragging
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
title.InputEnded:Connect(function()
    dragging = false
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Scrolling frame
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -50)
scroll.Position = UDim2.new(0, 8, 0, 42)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
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
    btn.Size = UDim2.new(1, -4, 0, 34)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Baseplate Button
createButton("🏠 Teleport to Base", Color3.fromRGB(40, 110, 70), function()
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

-- Refresh Eggs Button
createButton("🔄 Refresh Eggs", Color3.fromRGB(60, 60, 90), function()
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

    local count = 0
    for _, egg in ipairs(rendered:GetChildren()) do
        count += 1
        createButton("🥚 " .. egg.Name, Color3.fromRGB(50, 50, 70), function()
            teleportTo(egg)
            print("Teleported to → " .. egg.Name)
        end)
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    print("Found " .. count .. " eggs")
end)

-- ====================== ESP ======================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "EggSizeESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function getEggSize(egg)
    local size = egg:GetExtentsSize()
    local volume = size.X * size.Y * size.Z

    if volume > 80 then
        return "HUGE", Color3.fromRGB(255, 50, 50)
    elseif volume > 40 then
        return "Large", Color3.fromRGB(255, 170, 0)
    elseif volume > 18 then
        return "Medium", Color3.fromRGB(0, 255, 100)
    else
        return "Small", Color3.fromRGB(180, 180, 180)
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
    billboard.Size = UDim2.new(0, 130, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.25
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

    -- Remove old ESPs
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

    -- Create new ESPs
    for _, egg in ipairs(renderedEggs:GetChildren()) do
        createESP(egg)
    end
end

-- Update ESP every 0.7 seconds
task.spawn(function()
    while task.wait(0.7) do
        updateESP()
    end
end)

print("✅ Combined Egg Teleport UI + Size ESP loaded!")
print("Click 'Refresh Eggs' to load current eggs into the UI")
