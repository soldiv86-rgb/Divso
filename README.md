-- Fully Automatic Egg Teleport UI
-- Detects rarities from workspace.EggSpawns + eggs from RenderedEggs

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoEggTeleportUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 420)
mainFrame.Position = UDim2.new(0, 20, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 110)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "🥚 Auto Egg Teleport"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = mainFrame

-- Scrolling Frame
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -50)
scroll.Position = UDim2.new(0, 8, 0, 42)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scroll

-- ====================== DRAGGABLE ======================
local dragging, dragStart, startPos = false, nil, nil

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

title.InputEnded:Connect(function(input)
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
-- =======================================================

local function teleportTo(target)
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = target:GetPivot() * CFrame.new(0, 5, 0)
end

-- Rarity colors
local RarityColors = {
    Common = Color3.fromRGB(180, 180, 180),
    Rare = Color3.fromRGB(70, 140, 255),
    Epic = Color3.fromRGB(180, 70, 255),
    Legendary = Color3.fromRGB(255, 170, 0),
    Mythic = Color3.fromRGB(255, 50, 50),
    Secret = Color3.fromRGB(255, 0, 100),
    Exclusive = Color3.fromRGB(0, 255, 200)
}

-- Create Baseplate button
local function createBaseButton()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(35, 95, 55)
    btn.Text = "🏠 Teleport to Base"
    btn.TextColor3 = Color3.fromRGB(220, 255, 220)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.LayoutOrder = 0
    btn.Parent = scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local base = workspace:FindFirstChild("Plots") 
            and workspace.Plots:FindFirstChild("Plot") 
            and workspace.Plots.Plot:FindFirstChild("Baseplate")
        if base then
            teleportTo(base)
        else
            warn("Baseplate not found")
        end
    end)
end

-- Refresh everything
local function refresh()
    -- Clear old buttons
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") and child.Text ~= "🏠 Teleport to Base" then
            child:Destroy()
        end
    end

    local eggSpawns = workspace:FindFirstChild("EggSpawns")
    local renderedEggs = workspace:FindFirstChild("RenderedEggs")

    if not eggSpawns then 
        warn("EggSpawns not found")
        return 
    end

    local order = 1

    -- Loop through every rarity folder (Common, Rare, Epic, etc.)
    for _, rarityFolder in ipairs(eggSpawns:GetChildren()) do
        if rarityFolder:IsA("Folder") or rarityFolder:IsA("Model") then
            local rarityName = rarityFolder.Name
            local color = RarityColors[rarityName] or Color3.fromRGB(200, 200, 200)

            -- Rarity Header
            local header = Instance.new("TextLabel")
            header.Size = UDim2.new(1, 0, 0, 26)
            header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            header.Text = "★ " .. rarityName
            header.TextColor3 = color
            header.Font = Enum.Font.GothamBold
            header.TextSize = 14
            header.LayoutOrder = order
            header.Parent = scroll
            order += 1

            local hCorner = Instance.new("UICorner")
            hCorner.CornerRadius = UDim.new(0, 6)
            hCorner.Parent = header

            -- Now find eggs of this rarity that are currently rendered
            if renderedEggs then
                for _, egg in ipairs(renderedEggs:GetChildren()) do
                    -- Simple check: if the egg name exists inside this rarity folder
                    if rarityFolder:FindFirstChild(egg.Name) then
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, 0, 0, 32)
                        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                        btn.Text = "  " .. egg.Name
                        btn.TextColor3 = color
                        btn.Font = Enum.Font.Gotham
                        btn.TextSize = 13
                        btn.TextXAlignment = Enum.TextXAlignment.Left
                        btn.LayoutOrder = order
                        btn.Parent = scroll
                        order += 1

                        local bCorner = Instance.new("UICorner")
                        bCorner.CornerRadius = UDim.new(0, 6)
                        bCorner.Parent = btn

                        btn.MouseButton1Click:Connect(function()
                            teleportTo(egg)
                            print("Teleported to", egg.Name, "(" .. rarityName .. ")")
                        end)
                    end
                end
            end
        end
    end

    -- Update scroll size
    task.wait()
    scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
end

-- Create base button
createBaseButton()

-- Auto refresh
task.spawn(function()
    while true do
        refresh()
        task.wait(1.8)
    end
end)

print("✅ Fully Automatic Egg UI loaded (using EggSpawns rarities)")
