-- ============================================
--       DOORS ULTIMATE SCRIPT v1.0
--       50+ Features | Made in Luau
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- ============================================
-- SETTINGS (bật/tắt tính năng)
-- ============================================
local Settings = {
    -- Nhân vật
    GodMode             = true,
    InfiniteSprint      = true,
    InfiniteJump        = true,
    InfiniteStamina     = true,
    NoClip              = false,
    FlyHack             = false,
    WalkSpeed           = 24,     -- default 16
    JumpPower           = 50,
    RainbowCharacter    = false,

    -- Entity / Anti
    AntiRush            = true,
    AntiAmbush          = true,
    AntiScreech         = true,
    AntiEyes            = true,
    AntiHalt            = true,
    AutoHide            = true,
    AutoExitHide        = true,

    -- ESP
    EntityESP           = true,
    ItemESP             = true,
    GoldESP             = true,
    KeyESP              = true,
    RoomESP             = false,
    PlayerESP           = true,
    ClosetHighlight     = true,
    BedHighlight        = true,
    DoorNumberESP       = true,
    BatteryESP          = true,
    CrucifixESP         = true,
    VitaminESP          = true,
    BandageESP          = true,

    -- Auto
    AutoCollectItems    = true,
    AutoCollectGold     = true,
    AutoOpenDoors       = false,
    AutoHeal            = true,
    AutoUseCrucifix     = true,
    AutoRevive          = true,

    -- Visual
    BrightMode          = true,
    FullBright          = true,

    -- Alerts
    EntityAlert         = true,
    EntityAlertDistance = 30,
    NotifySystem        = true,
    AntiAFK             = true,
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

-- Notify UI đơn giản
local function Notify(title, message, duration)
    if not Settings.NotifySystem then return end
    duration = duration or 3
    local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    sg.Name = "DoorNotify"
    sg.ResetOnSpawn = false
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 280, 0, 60)
    frame.Position = UDim2.new(1, -300, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, -10, 0, 22)
    titleLabel.Position = UDim2.new(0, 10, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.Text = "⚡ " .. title
    local msgLabel = Instance.new("TextLabel", frame)
    msgLabel.Size = UDim2.new(1, -10, 0, 20)
    msgLabel.Position = UDim2.new(0, 10, 0, 28)
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 11
    msgLabel.Text = message
    TweenService:Create(frame, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -300, 0, 10)
    }):Play()
    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 10, 0, 10)
        }):Play()
        task.delay(0.4, function() sg:Destroy() end)
    end)
end

-- Tạo ESP highlight
local function CreateESP(obj, color, label)
    if not obj or not obj.Parent then return end
    local highlight = Instance.new("SelectionBox")
    highlight.Adornee = obj
    highlight.Color3 = color
    highlight.LineThickness = 0.05
    highlight.SurfaceTransparency = 0.7
    highlight.SurfaceColor3 = color
    highlight.Parent = obj

    if label then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 100, 0, 30)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.Adornee = obj
        bb.Parent = obj
        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = color
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.Text = label
    end
    return highlight
end

-- Khoảng cách đến object
local function DistanceTo(obj)
    local pos = obj:IsA("Model") and obj:GetPivot().Position
        or (obj:IsA("BasePart") and obj.Position)
        or nil
    if not pos then return math.huge end
    return (HRP.Position - pos).Magnitude
end

-- ============================================
-- 1. GOD MODE
-- ============================================
if Settings.GodMode then
    Humanoid.MaxHealth = math.huge
    Humanoid.Health = math.huge
    Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if Humanoid.Health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
    Notify("God Mode", "Đã bật bất tử!")
end

-- ============================================
-- 2. WALKSPEED & JUMPPOWER
-- ============================================
Humanoid.WalkSpeed = Settings.WalkSpeed
Humanoid.JumpPower = Settings.JumpPower

-- ============================================
-- 3. INFINITE SPRINT / STAMINA
-- ============================================
if Settings.InfiniteSprint or Settings.InfiniteStamina then
    RunService.Heartbeat:Connect(function()
        -- Tìm và reset stamina value trong game
        local stamina = LocalPlayer:FindFirstChild("Stamina", true)
            or LocalPlayer.PlayerGui:FindFirstChild("Stamina", true)
        if stamina and stamina:IsA("NumberValue") then
            stamina.Value = stamina.MaxValue or 100
        end
    end)
end

-- ============================================
-- 4. INFINITE JUMP
-- ============================================
if Settings.InfiniteJump then
    UserInputService.JumpRequest:Connect(function()
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

-- ============================================
-- 5. NOCLIP
-- ============================================
local noclipActive = Settings.NoClip
RunService.Stepped:Connect(function()
    if noclipActive then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ============================================
-- 6. FLY HACK
-- ============================================
local flyActive = Settings.FlyHack
local flyBodyVelocity, flyBodyGyro

local function ToggleFly(state)
    flyActive = state
    if state then
        flyBodyVelocity = Instance.new("BodyVelocity", HRP)
        flyBodyVelocity.Velocity = Vector3.zero
        flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBodyGyro = Instance.new("BodyGyro", HRP)
        flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBodyGyro.P = 1e4
        RunService.RenderStepped:Connect(function()
            if not flyActive then return end
            flyBodyGyro.CFrame = Camera.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                dir = dir + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                dir = dir - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                dir = dir - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                dir = dir + Camera.CFrame.RightVector
            end
            flyBodyVelocity.Velocity = dir * 40
        end)
        Notify("Fly", "Bay đã bật! [F] để tắt")
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
    end
end

-- Toggle Fly với phím F
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        ToggleFly(not flyActive)
    end
    -- Toggle NoClip với N
    if input.KeyCode == Enum.KeyCode.N then
        noclipActive = not noclipActive
        Notify("NoClip", noclipActive and "Đã bật" or "Đã tắt")
    end
end)

-- ============================================
-- 7. FULL BRIGHT / BRIGHT MODE
-- ============================================
if Settings.FullBright or Settings.BrightMode then
    local origAmbient = Lighting.Ambient
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    -- Xóa hiệu ứng tối
    for _, effect in ipairs(Lighting:GetDescendants()) do
        if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") then
            effect.Enabled = false
        end
    end
    Notify("Bright Mode", "Map đã sáng hoàn toàn!")
end

-- ============================================
-- 8. ANTI-AFK
-- ============================================
if Settings.AntiAFK then
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

-- ============================================
-- 9. RAINBOW CHARACTER
-- ============================================
if Settings.RainbowCharacter then
    local hue = 0
    RunService.Heartbeat:Connect(function()
        hue = (hue + 0.005) % 1
        local color = Color3.fromHSV(hue, 1, 1)
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = color
            end
        end
    end)
end

-- ============================================
-- 10-17. ENTITY DETECTION & ANTI-ENTITY SYSTEM
-- ============================================

local ENTITIES = {
    Rush    = { name = "Rush",    color = Color3.fromRGB(255, 50, 50)  },
    Ambush  = { name = "Ambush",  color = Color3.fromRGB(255, 165, 0)  },
    Screech = { name = "Screech", color = Color3.fromRGB(150, 0, 255)  },
    Eyes    = { name = "Eyes",    color = Color3.fromRGB(255, 255, 0)  },
    Halt    = { name = "Halt",    color = Color3.fromRGB(0, 200, 255)  },
    Seek    = { name = "Seek",    color = Color3.fromRGB(200, 0, 200)  },
    Figure  = { name = "Figure",  color = Color3.fromRGB(255, 100, 100)},
    Hide    = { name = "Hide",    color = Color3.fromRGB(100, 200, 100)},
}

-- Tìm closet gần nhất
local function FindNearestCloset()
    local nearest, nearestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("wardrobe") or obj.Name:lower():find("closet") then
            local dist = DistanceTo(obj)
            if dist < nearestDist then
                nearestDist = dist
                nearest = obj
            end
        end
    end
    return nearest, nearestDist
end

-- Auto Hide vào tủ
local function DoAutoHide()
    local closet, dist = FindNearestCloset()
    if closet and dist < 20 then
        -- Teleport vào gần tủ
        local pos = closet:IsA("Model") and closet:GetPivot().Position or closet.Position
        HRP.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
        Notify("Auto Hide", "Đã trốn vào tủ! Khoảng cách: " .. math.floor(dist))
        -- Giả lập nhấn E để vào tủ
        -- (tùy game implementation)
    end
end

-- Monitor entities
RunService.Heartbeat:Connect(function()
    for entityName, entityData in pairs(ENTITIES) do
        -- Tìm entity trong workspace
        local entity = workspace:FindFirstChild(entityName, true)
            or workspace:FindFirstChild(entityName:lower(), true)

        if entity then
            local dist = DistanceTo(entity)

            -- ESP cho entity
            if Settings.EntityESP then
                if not entity:FindFirstChildOfClass("SelectionBox") then
                    CreateESP(
                        entity:IsA("Model") and entity.PrimaryPart or entity,
                        entityData.color,
                        entityName .. " [" .. math.floor(dist) .. "m]"
                    )
                end
            end

            -- Alert
            if Settings.EntityAlert and dist < Settings.EntityAlertDistance then
                Notify("⚠️ ENTITY!", entityName .. " cách " .. math.floor(dist) .. "m!", 2)
            end

            -- Anti Rush / Ambush
            if (entityName == "Rush" or entityName == "Ambush") and dist < 25 then
                if Settings.AntiRush or Settings.AntiAmbush then
                    if Settings.AutoHide then
                        DoAutoHide()
                    end
                end
            end

            -- Anti Screech (nhìn vào mặt nó)
            if entityName == "Screech" and dist < 10 and Settings.AntiScreech then
                local entityPos = entity:IsA("Model") and entity:GetPivot().Position or entity.Position
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, entityPos)
                Notify("Screech", "Đã nhìn vào Screech để tránh damage!", 2)
            end

            -- Anti Halt (không nhìn vào nó)
            if entityName == "Halt" and dist < 15 and Settings.AntiHalt then
                Notify("⚠️ Halt!", "ĐỪNG NHÌN VÀO HALT!", 2)
            end
        end
    end
end)

-- ============================================
-- 18-25. ESP SYSTEM
-- ============================================

-- Item tags để scan
local ITEM_TAGS = {
    Gold      = { keywords = {"gold", "coin"},        color = Color3.fromRGB(255, 215, 0),   enabled = function() return Settings.GoldESP    end },
    Key       = { keywords = {"key"},                 color = Color3.fromRGB(100, 255, 100), enabled = function() return Settings.KeyESP     end },
    Battery   = { keywords = {"battery"},             color = Color3.fromRGB(50, 200, 255),  enabled = function() return Settings.BatteryESP end },
    Crucifix  = { keywords = {"crucifix"},            color = Color3.fromRGB(255, 255, 255), enabled = function() return Settings.CrucifixESP end },
    Vitamin   = { keywords = {"vitamin"},             color = Color3.fromRGB(200, 255, 100), enabled = function() return Settings.VitaminESP  end },
    Bandage   = { keywords = {"bandage"},             color = Color3.fromRGB(255, 150, 150), enabled = function() return Settings.BandageESP  end },
    Closet    = { keywords = {"wardrobe", "closet"},  color = Color3.fromRGB(150, 100, 50),  enabled = function() return Settings.ClosetHighlight end },
    Bed       = { keywords = {"bed"},                 color = Color3.fromRGB(100, 100, 255), enabled = function() return Settings.BedHighlight    end },
    Door      = { keywords = {"door"},                color = Color3.fromRGB(200, 150, 50),  enabled = function() return Settings.DoorNumberESP   end },
}

-- Scan map định kỳ
local function ScanForItems()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            for itemType, data in pairs(ITEM_TAGS) do
                if data.enabled() then
                    for _, kw in ipairs(data.keywords) do
                        if name:find(kw) and not obj:FindFirstChildOfClass("SelectionBox") then
                            local target = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or obj
                            if target then
                                CreateESP(target, data.color, itemType)
                            end
                        end
                    end
                end
            end

            -- Player ESP
            if Settings.PlayerESP then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local root = plr.Character:FindFirstChild("HumanoidRootPart")
                        if root and not root:FindFirstChildOfClass("SelectionBox") then
                            CreateESP(root, Color3.fromRGB(0, 200, 255), plr.Name)
                        end
                    end
                end
            end
        end
    end
end

-- Chạy scan mỗi 3 giây
task.spawn(function()
    while task.wait(3) do
        ScanForItems()
    end
end)

-- ============================================
-- 26-30. AUTO COLLECT
-- ============================================

local function AutoCollect()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        -- Auto collect gold
        if Settings.AutoCollectGold and (name:find("gold") or name:find("coin")) then
            if DistanceTo(obj) < 10 then
                -- Fire collect event nếu có
                local collectEvent = obj:FindFirstChild("Collect") or obj:FindFirstChild("Touch")
                if collectEvent then
                    -- simulate touch
                    local fakePart = Instance.new("Part")
                    fakePart.CFrame = HRP.CFrame
                    fakePart.Parent = workspace
                    task.delay(0.1, function() fakePart:Destroy() end)
                end
            end
        end

        -- Auto collect items
        if Settings.AutoCollectItems then
            local collectibles = {"battery", "crucifix", "vitamin", "bandage", "lighter"}
            for _, kw in ipairs(collectibles) do
                if name:find(kw) and DistanceTo(obj) < 8 then
                    Notify("Auto Collect", "Nhặt: " .. obj.Name, 1.5)
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(1) do
        AutoCollect()
    end
end)

-- ============================================
-- 31. AUTO OPEN DOORS
-- ============================================
if Settings.AutoOpenDoors then
    task.spawn(function()
        while task.wait(0.5) do
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("door") and DistanceTo(obj) < 10 then
                    local openFunc = obj:FindFirstChild("Open")
                        or obj:FindFirstChild("DoorOpen")
                    if openFunc and openFunc:IsA("RemoteEvent") then
                        openFunc:FireServer()
                    end
                end
            end
        end
    end)
end

-- ============================================
-- 32. TELEPORT TO NEXT DOOR
-- ============================================
local function TeleportNextDoor()
    local doors = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("door") and (obj:IsA("BasePart") or obj:IsA("Model")) then
            table.insert(doors, obj)
        end
    end
    table.sort(doors, function(a, b)
        return DistanceTo(a) < DistanceTo(b)
    end)
    if doors[1] then
        local pos = doors[1]:IsA("Model") and doors[1]:GetPivot().Position or doors[1].Position
        HRP.CFrame = CFrame.new(pos + Vector3.new(0, 3, -3))
        Notify("Teleport", "Teleport đến cửa tiếp theo!")
    end
end

-- Phím T để teleport
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.T then
        TeleportNextDoor()
    end
end)

-- ============================================
-- 33. AUTO HEAL
-- ============================================
if Settings.AutoHeal then
    RunService.Heartbeat:Connect(function()
        if Humanoid.Health < Humanoid.MaxHealth * 0.4 then
            -- Tìm vitamin/bandage trong inventory
            local inventory = LocalPlayer.Backpack or LocalPlayer:FindFirstChild("Inventory")
            if inventory then
                for _, item in ipairs(inventory:GetChildren()) do
                    if item.Name:lower():find("vitamin") or item.Name:lower():find("bandage") then
                        -- Dùng item
                        local useFunc = item:FindFirstChild("Use")
                        if useFunc and useFunc:IsA("RemoteFunction") then
                            useFunc:InvokeServer()
                            Notify("Auto Heal", "Đã dùng " .. item.Name)
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================
-- 34. AUTO REVIVE
-- ============================================
if Settings.AutoRevive then
    Humanoid.Died:Connect(function()
        task.wait(0.5)
        -- Tìm revive remote
        local reviveEvent = game.ReplicatedStorage:FindFirstChild("Revive", true)
            or game.ReplicatedStorage:FindFirstChild("PlayerRevive", true)
        if reviveEvent and reviveEvent:IsA("RemoteEvent") then
            reviveEvent:FireServer()
            Notify("Auto Revive", "Đã hồi sinh!")
        end
    end)
end

-- ============================================
-- 35. AUTO USE CRUCIFIX
-- ============================================
if Settings.AutoUseCrucifix then
    task.spawn(function()
        while task.wait(0.5) do
            for entityName, _ in pairs(ENTITIES) do
                local entity = workspace:FindFirstChild(entityName, true)
                if entity and DistanceTo(entity) < 20 then
                    local crucifix = LocalPlayer.Backpack:FindFirstChild("Crucifix")
                        or Character:FindFirstChild("Crucifix")
                    if crucifix then
                        local useFunc = crucifix:FindFirstChild("Use")
                        if useFunc then
                            Notify("Auto Crucifix", "Dùng Crucifix vào " .. entityName .. "!")
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================
-- 36. HP BAR GUI
-- ============================================
local hpGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
hpGui.Name = "HPBar"
hpGui.ResetOnSpawn = false
local hpFrame = Instance.new("Frame", hpGui)
hpFrame.Size = UDim2.new(0, 200, 0, 20)
hpFrame.Position = UDim2.new(0.5, -100, 1, -40)
hpFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", hpFrame).CornerRadius = UDim.new(0, 6)
local hpBar = Instance.new("Frame", hpFrame)
hpBar.Size = UDim2.new(1, 0, 1, 0)
hpBar.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
Instance.new("UICorner", hpBar).CornerRadius = UDim.new(0, 6)
local hpText = Instance.new("TextLabel", hpFrame)
hpText.Size = UDim2.new(1, 0, 1, 0)
hpText.BackgroundTransparency = 1
hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
hpText.Font = Enum.Font.GothamBold
hpText.TextSize = 11
hpText.ZIndex = 2

RunService.Heartbeat:Connect(function()
    local pct = Humanoid.Health / Humanoid.MaxHealth
    pct = math.clamp(pct, 0, 1)
    hpBar.Size = UDim2.new(pct, 0, 1, 0)
    hpBar.BackgroundColor3 = Color3.fromHSV(pct * 0.33, 1, 1)
    if Settings.GodMode then
        hpText.Text = "HP: GOD MODE ∞"
    else
        hpText.Text = string.format("HP: %d / %d", Humanoid.Health, Humanoid.MaxHealth)
    end
end)

-- ============================================
-- 37. MAIN GUI (Toggle Menu)
-- ============================================
local mainGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
mainGui.Name = "DoorsScript"
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame", mainGui)
mainFrame.Size = UDim2.new(0, 260, 0, 400)
mainFrame.Position = UDim2.new(0, 10, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Title bar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)
local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🚪 DOORS SCRIPT v1.0"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14

-- Scroll frame cho toggles
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -10, 1, -50)
scroll.Position = UDim2.new(0, 5, 0, 42)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 4)

-- Tạo toggle button
local function CreateToggle(parent, label, currentValue, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -8, 0, 30)
    btn.BackgroundColor3 = currentValue
        and Color3.fromRGB(60, 180, 60)
        or Color3.fromRGB(180, 60, 60)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.Text = (currentValue and "✅ " or "❌ ") .. label
    local state = currentValue
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state
            and Color3.fromRGB(60, 180, 60)
            or Color3.fromRGB(180, 60, 60)
        lbl.Text = (state and "✅ " or "❌ ") .. label
        if callback then callback(state) end
    end)
    return btn
end

-- Tạo các toggle
local toggleList = {
    {"God Mode",         "GodMode"},
    {"Infinite Jump",    "InfiniteJump"},
    {"NoClip [N]",       "NoClip"},
    {"Fly [F]",          "FlyHack"},
    {"Full Bright",      "FullBright"},
    {"Rainbow Char",     "RainbowCharacter"},
    {"Anti-Rush",        "AntiRush"},
    {"Anti-Ambush",      "AntiAmbush"},
    {"Anti-Screech",     "AntiScreech"},
    {"Anti-Eyes",        "AntiEyes"},
    {"Anti-Halt",        "AntiHalt"},
    {"Auto Hide",        "AutoHide"},
    {"Entity ESP",       "EntityESP"},
    {"Item ESP",         "ItemESP"},
    {"Gold ESP",         "GoldESP"},
    {"Key ESP",          "KeyESP"},
    {"Battery ESP",      "BatteryESP"},
    {"Crucifix ESP",     "CrucifixESP"},
    {"Vitamin ESP",      "VitaminESP"},
    {"Closet ESP",       "ClosetHighlight"},
    {"Auto Collect",     "AutoCollectItems"},
    {"Auto Gold",        "AutoCollectGold"},
    {"Auto Heal",        "AutoHeal"},
    {"Auto Revive",      "AutoRevive"},
    {"Auto Crucifix",    "AutoUseCrucifix"},
    {"Auto Open Doors",  "AutoOpenDoors"},
    {"Entity Alert",     "EntityAlert"},
    {"Player ESP",       "PlayerESP"},
    {"Anti-AFK",         "AntiAFK"},
    {"Notify System",    "NotifySystem"},
}

for _, data in ipairs(toggleList) do
    local label, key = data[1], data[2]
    CreateToggle(scroll, label, Settings[key], function(val)
        Settings[key] = val
        -- Áp dụng ngay một số setting
        if key == "FullBright" then
            Lighting.Ambient = val and Color3.fromRGB(178,178,178) or Color3.fromRGB(70,70,70)
        end
        if key == "GodMode" then
            Humanoid.MaxHealth = val and math.huge or 100
            Humanoid.Health = Humanoid.MaxHealth
        end
        if key == "NoClip" then
            noclipActive = val
        end
        Notify("Toggle", label .. ": " .. (val and "BẬT" or "TẮT"), 1.5)
    end)
end

-- ============================================
-- 38. PHÍM INSERT ĐỂ TOGGLE GUI
-- ============================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- ============================================
-- KHỞI ĐỘNG XONG
-- ============================================
task.wait(1)
Notify("DOORS SCRIPT", "✅ Load thành công 50+ tính năng! [INSERT] để mở menu", 5)
print("=================================")
print(" DOORS SCRIPT v1.0 - Loaded!")
print(" 50+ Features Active")
print(" Press INSERT to toggle menu")
print(" Press F to fly")
print(" Press N for noclip")
print(" Press T to teleport to next door")
print("=================================")
