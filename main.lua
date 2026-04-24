-- ============================================
--       DOORS SCRIPT v2.0
--       Clean UI | Monster Alert | ESP | Auto Collect
-- ============================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Lighting       = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local Character   = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid    = Character:WaitForChild("Humanoid")
local HRP         = Character:WaitForChild("HumanoidRootPart")

-- ============================================
-- SETTINGS
-- ============================================
local Settings = {
    FullBright        = true,
    AntiAFK           = true,
    -- THÊM VÀO ĐÂY
    BookESP      = true,
    AntiGloombat = true,
    AntiTimothy  = true,
    AntiDupe     = true,c
    InfiniteJump      = true,
    InfiniteStamina   = true,

    -- ESP
    EntityESP         = true,
    ItemESP           = true,
    GoldESP           = true,
    KeyESP            = true,
    BatteryESP        = true,
    CrucifixESP       = true,
    VitaminESP        = true,
    BandageESP        = true,
    ClosetHighlight   = true,
    PlayerESP         = true,

    -- Auto
    AutoCollectGold   = true,
    AutoCollectItems  = true,
    AutoHide          = true,
    AutoUseCrucifix   = false,

    -- Alert
    EntityAlert       = true,
    EntityAlertDist   = 40,
    NotifySystem      = true,

    -- Sound
    SoundEnabled      = true,
}

-- ============================================
-- SOUND (beep)
-- ============================================
local function Beep(pitch)
    if not Settings.SoundEnabled then return end
    local s = Instance.new("Sound", workspace)
    s.SoundId = "rbxassetid://4612803745"
    s.Volume  = 0.4
    s.Pitch   = pitch or 1
    s:Play()
    game:GetService("Debris"):AddItem(s, 1)
end

-- ============================================
-- NOTIFY
-- ============================================
local notifyQueue = {}
local notifyActive = false

local function ShowNextNotify()
    if #notifyQueue == 0 then notifyActive = false return end
    notifyActive = true
    local data = table.remove(notifyQueue, 1)
    
    local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    sg.Name = "DNotify"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 300, 0, 64)
    frame.Position = UDim2.new(1, 10, 1, -80)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    -- Accent bar kiri
    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = data.color or Color3.fromRGB(140, 80, 255)
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 4)

    local icon = Instance.new("TextLabel", frame)
    icon.Size = UDim2.new(0, 32, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = data.icon or "🔔"
    icon.TextSize = 22
    icon.Font = Enum.Font.Gotham

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -55, 0, 26)
    title.Position = UDim2.new(0, 46, 0, 8)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = data.title

    local msg = Instance.new("TextLabel", frame)
    msg.Size = UDim2.new(1, -55, 0, 20)
    msg.Position = UDim2.new(0, 46, 0, 34)
    msg.BackgroundTransparency = 1
    msg.TextColor3 = Color3.fromRGB(180, 180, 200)
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 11
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Text = data.msg

    -- Slide in
    TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -314, 1, -80)
    }):Play()

    task.delay(data.dur or 3, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 10, 1, -80)
        }):Play()
        task.delay(0.4, function()
            sg:Destroy()
            ShowNextNotify()
        end)
    end)
end

local function Notify(title, msg, icon, color, dur)
    if not Settings.NotifySystem then return end
    table.insert(notifyQueue, {
        title = title, msg = msg,
        icon = icon or "🔔",
        color = color or Color3.fromRGB(140, 80, 255),
        dur = dur or 3
    })
    if not notifyActive then ShowNextNotify() end
end

-- ============================================
-- UTILITY
-- ============================================
local function DistanceTo(obj)
    local ok, pos = pcall(function()
        return obj:IsA("Model") and obj:GetPivot().Position
            or obj.Position
    end)
    if not ok or not pos then return math.huge end
    return (HRP.Position - pos).Magnitude
end

local espObjects = {}

local function ClearESP(obj)
    for _, v in ipairs(obj:GetChildren()) do
        if v:IsA("SelectionBox") or v:IsA("BillboardGui") then
            v:Destroy()
        end
    end
end

local function CreateESP(obj, color, label)
    if not obj or not obj.Parent then return end
    ClearESP(obj)

    local sel = Instance.new("SelectionBox")
    sel.Adornee = obj
    sel.Color3 = color
    sel.LineThickness = 0.04
    sel.SurfaceTransparency = 0.75
    sel.SurfaceColor3 = color
    sel.Parent = obj

    if label then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 120, 0, 28)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.Adornee = obj
        bb.Parent = obj

        local bg = Instance.new("Frame", bb)
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
        bg.BackgroundTransparency = 0.3
        bg.BorderSizePixel = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

        local lbl = Instance.new("TextLabel", bg)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = color
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.Text = label
    end
end

-- ============================================
-- FULL BRIGHT
-- ============================================
local function ApplyFullBright(state)
    if state then
        Lighting.Ambient       = Color3.fromRGB(180, 180, 180)
        Lighting.Brightness    = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 9e9
        for _, e in ipairs(Lighting:GetDescendants()) do
            if e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect") then
                e.Enabled = false
            end
        end
    else
        Lighting.Ambient       = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness    = 1
        Lighting.GlobalShadows = true
    end
end
ApplyFullBright(Settings.FullBright)

-- ============================================
-- ANTI-AFK
-- ============================================
if Settings.AntiAFK then
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.5)
        vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end

-- ============================================
-- INFINITE JUMP
-- ============================================
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ============================================
-- INFINITE STAMINA
-- ============================================
RunService.Heartbeat:Connect(function()
    if Settings.InfiniteStamina then
        local stamina = LocalPlayer:FindFirstChild("Stamina", true)
        if stamina and stamina:IsA("NumberValue") then
            stamina.Value = stamina.MaxValue or 100
        end
    end
end)

-- ============================================
-- ENTITIES
-- ============================================
local ENTITIES = {
    { name = "Rush",    icon = "💨", color = Color3.fromRGB(255,60,60)   },
    { name = "Ambush",  icon = "🌀", color = Color3.fromRGB(255,150,30)  },
    { name = "Screech", icon = "👁️", color = Color3.fromRGB(180,50,255)  },
    { name = "Eyes",    icon = "👀", color = Color3.fromRGB(255,255,50)  },
    { name = "Halt",    icon = "✋", color = Color3.fromRGB(50,200,255)  },
    { name = "Seek",    icon = "🩸", color = Color3.fromRGB(220,30,180)  },
    { name = "Figure",  icon = "👹", color = Color3.fromRGB(255,120,60)  },
    { name = "Shadow",  icon = "🌑", color = Color3.fromRGB(120,120,255) },
    { name = "Hide",    icon = "🫥", color = Color3.fromRGB(100,230,150) },
}

local entityAlerted = {}

-- Monster scan + ESP + Alert
RunService.Heartbeat:Connect(function()
    for _, eData in ipairs(ENTITIES) do
        local entity = workspace:FindFirstChild(eData.name, true)
        if entity then
            local dist = DistanceTo(entity)
            local target = entity:IsA("Model")
                and (entity.PrimaryPart or entity:FindFirstChildOfClass("BasePart"))
                or entity

            -- ESP
            if Settings.EntityESP and target then
                local distLabel = eData.name .. " [" .. math.floor(dist) .. "m]"
                if not target:FindFirstChildOfClass("SelectionBox") then
                    CreateESP(target, eData.color, distLabel)
                else
                    -- Update label
                    local bb = target:FindFirstChildOfClass("BillboardGui")
                    if bb then
                        local lbl = bb:FindFirstChildOfClass("Frame")
                            and bb:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("TextLabel")
                        if lbl then lbl.Text = distLabel end
                    end
                end
            end

            -- Alert (1 lần mỗi khi entity xuất hiện)
            if Settings.EntityAlert and not entityAlerted[eData.name] then
                if dist < Settings.EntityAlertDist then
                    entityAlerted[eData.name] = true
                    Beep(1.5)
                    Notify(
                        eData.icon .. " " .. eData.name .. " xuất hiện!",
                        "Khoảng cách: " .. math.floor(dist) .. "m — Hãy cẩn thận!",
                        eData.icon,
                        eData.color,
                        4
                    )
                end
            end

            -- Screech: cần nhìn vào mắt
            if eData.name == "Screech" and dist < 12 and Settings.EntityAlert then
                if target then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                end
            end
        else
            -- Reset alert khi entity biến mất
            entityAlerted[eData.name] = nil
        end
    end
end)

-- ============================================
-- ITEM ESP SCAN
-- ============================================
local ITEM_TAGS = {
    { keywords={"gold","coin"},         color=Color3.fromRGB(255,215,0),   label="💰 Gold",     key="GoldESP"      },
    { keywords={"key"},                 color=Color3.fromRGB(80,255,130),  label="🔑 Key",      key="KeyESP"       },
    { keywords={"battery"},             color=Color3.fromRGB(50,200,255),  label="🔋 Battery",  key="BatteryESP"   },
    { keywords={"crucifix"},            color=Color3.fromRGB(255,255,255), label="✝️ Crucifix", key="CrucifixESP"  },
    { keywords={"vitamin"},             color=Color3.fromRGB(180,255,80),  label="💊 Vitamin",  key="VitaminESP"   },
    { keywords={"bandage"},             color=Color3.fromRGB(255,140,140), label="🩹 Bandage",  key="BandageESP"   },
    { keywords={"wardrobe","closet"},   color=Color3.fromRGB(160,110,60),  label="🚪 Closet",   key="ClosetHighlight"},
}

task.spawn(function()
    while task.wait(4) do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local name = obj.Name:lower()
                -- Item ESP
                if Settings.ItemESP then
                    for _, tag in ipairs(ITEM_TAGS) do
                        if Settings[tag.key] then
                            for _, kw in ipairs(tag.keywords) do
                                if name:find(kw) then
                                    local target = obj:IsA("Model")
                                        and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart"))
                                        or obj
                                    if target and not target:FindFirstChildOfClass("SelectionBox") then
                                        CreateESP(target, tag.color, tag.label)
                                    end
                                end
                            end
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
                        CreateESP(root, Color3.fromRGB(50, 200, 255), "👤 " .. plr.Name)
                    end
                end
            end
        end
    end
end)

-- ============================================
-- AUTO COLLECT GOLD / ITEMS
-- ============================================
task.spawn(function()
    while task.wait(0.8) do
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            local dist = DistanceTo(obj)

            if Settings.AutoCollectGold and (name:find("gold") or name:find("coin")) then
                if dist < 12 then
                    local touch = obj:FindFirstChild("Collect")
                        or obj:FindFirstChild("ItemPickUp")
                    if touch and touch:IsA("RemoteEvent") then
                        touch:FireServer()
                    end
                    -- Simulate proximity
                    local part = Instance.new("Part")
                    part.CFrame = HRP.CFrame
                    part.Size = Vector3.new(1,1,1)
                    part.Anchored = true
                    part.CanCollide = false
                    part.Transparency = 1
                    part.Parent = workspace
                    task.delay(0.15, function() part:Destroy() end)
                end
            end

            if Settings.AutoCollectItems then
                local itemKW = {"battery","crucifix","vitamin","bandage","lighter","key"}
                for _, kw in ipairs(itemKW) do
                    if name:find(kw) and dist < 10 then
                        local remote = obj:FindFirstChild("Collect")
                            or obj:FindFirstChild("PickUp")
                        if remote and remote:IsA("RemoteEvent") then
                            remote:FireServer()
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- AUTO HIDE
-- ============================================
local function FindNearestCloset()
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("wardrobe") or name:find("closet") then
            local d = DistanceTo(obj)
            if d < bestDist then bestDist = d best = obj end
        end
    end
    return best, bestDist
end

task.spawn(function()
    while task.wait(0.3) do
        if Settings.AutoHide then
            for _, eData in ipairs(ENTITIES) do
                if eData.name == "Rush" or eData.name == "Ambush" then
                    local entity = workspace:FindFirstChild(eData.name, true)
                    if entity and DistanceTo(entity) < 30 then
                        local closet, dist = FindNearestCloset()
                        if closet and dist < 18 then
                            local pos = closet:IsA("Model")
                                and closet:GetPivot().Position
                                or closet.Position
                            HRP.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                            Notify("🚪 Auto Hide", eData.name .. " đang đến! Đã trốn vào tủ.", "🚪", Color3.fromRGB(100,200,255), 3)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- GUI
-- ============================================
local guiVisible = false

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "DoorsScriptGui"
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.DisplayOrder = 100
mainGui.IgnoreGuiInset = true
mainGui.Parent = LocalPlayer.PlayerGui

-- Overlay backdrop (blur feel)
local overlay = Instance.new("Frame", mainGui)
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
overlay.ZIndex = 1
overlay.Visible = false

-- Main panel
local panel = Instance.new("Frame", mainGui)
panel.Size = UDim2.new(0, 380, 0, 520)
panel.Position = UDim2.new(0.5, -190, 0.5, -260)
panel.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
panel.BorderSizePixel = 0
panel.ZIndex = 2
panel.Visible = false
panel.ClipsDescendants = true

local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0, 14)

-- Stroke
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(100, 60, 200)
stroke.Thickness = 1.5
stroke.Transparency = 0.3

-- Header
local header = Instance.new("Frame", panel)
header.Size = UDim2.new(1, 0, 0, 54)
header.BackgroundColor3 = Color3.fromRGB(18, 10, 40)
header.BorderSizePixel = 0
header.ZIndex = 3

local headerGrad = Instance.new("UIGradient", header)
headerGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 40, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 10, 100)),
}
headerGrad.Rotation = 90

local headerTitle = Instance.new("TextLabel", header)
headerTitle.Size = UDim2.new(1, -60, 1, 0)
headerTitle.Position = UDim2.new(0, 16, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "🚪  DOORS SCRIPT"
headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 16
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.ZIndex = 4

local subTitle = Instance.new("TextLabel", header)
subTitle.Size = UDim2.new(1, -60, 0, 16)
subTitle.Position = UDim2.new(0, 16, 1, -16)
subTitle.BackgroundTransparency = 1
subTitle.Text = "INSERT để mở/đóng"
subTitle.TextColor3 = Color3.fromRGB(160, 120, 255)
subTitle.Font = Enum.Font.Gotham
subTitle.TextSize = 10
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.ZIndex = 4

-- Close button
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -44, 0.5, -17)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 80)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.ZIndex = 5
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Tab bar
local tabBar = Instance.new("Frame", panel)
tabBar.Size = UDim2.new(1, -20, 0, 36)
tabBar.Position = UDim2.new(0, 10, 0, 60)
tabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 3
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
local tabPad = Instance.new("UIPadding", tabBar)
tabPad.PaddingLeft = UDim.new(0, 4)
tabPad.PaddingRight = UDim.new(0, 4)
tabPad.PaddingTop = UDim.new(0, 4)
tabPad.PaddingBottom = UDim.new(0, 4)

-- Scroll frame
local scroll = Instance.new("ScrollingFrame", panel)
scroll.Size = UDim2.new(1, -16, 1, -108)
scroll.Position = UDim2.new(0, 8, 0, 104)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 60, 220)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 3
scroll.BorderSizePixel = 0
local scrollLayout = Instance.new("UIListLayout", scroll)
scrollLayout.Padding = UDim.new(0, 6)
local scrollPad = Instance.new("UIPadding", scroll)
scrollPad.PaddingTop = UDim.new(0, 4)
scrollPad.PaddingBottom = UDim.new(0, 8)
scrollPad.PaddingLeft = UDim.new(0, 4)
scrollPad.PaddingRight = UDim.new(0, 4)

-- ============================================
-- TAB SYSTEM
-- ============================================
local tabs = {}
local tabContents = {}
local currentTab = nil

local function SelectTab(name)
    currentTab = name
    for tName, tBtn in pairs(tabs) do
        local active = tName == name
        TweenService:Create(tBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = active
                and Color3.fromRGB(100, 50, 220)
                or  Color3.fromRGB(28, 28, 44)
        }):Play()
        tBtn.TextColor3 = active
            and Color3.fromRGB(255,255,255)
            or  Color3.fromRGB(160,160,200)
    end
    -- Show/hide content
    for cName, items in pairs(tabContents) do
        for _, item in ipairs(items) do
            item.Visible = cName == name
        end
    end
end

local function CreateTab(name)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.25, -4, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 44)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(160, 160, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.ZIndex = 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    tabs[name] = btn
    tabContents[name] = {}
    btn.MouseButton1Click:Connect(function()
        Beep(1.2)
        SelectTab(name)
    end)
    return btn
end

CreateTab("Visual")
CreateTab("Entity")
CreateTab("Auto")
CreateTab("Misc")
CreateTab("Floor2")

-- ============================================
-- TOGGLE COMPONENT
-- ============================================
local function CreateToggle(tabName, label, icon, settingKey, onChange)
    local state = Settings[settingKey]

    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    frame.BorderSizePixel = 0
    frame.ZIndex = 4
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    -- Left accent
    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0, 3, 0.6, 0)
    accent.Position = UDim2.new(0, 0, 0.2, 0)
    accent.BackgroundColor3 = state
        and Color3.fromRGB(120, 60, 255)
        or  Color3.fromRGB(80, 80, 80)
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local iconLabel = Instance.new("TextLabel", frame)
    iconLabel.Size = UDim2.new(0, 30, 1, 0)
    iconLabel.Position = UDim2.new(0, 10, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 18
    iconLabel.Font = Enum.Font.Gotham
    iconLabel.ZIndex = 5

    local textLabel = Instance.new("TextLabel", frame)
    textLabel.Size = UDim2.new(1, -100, 1, 0)
    textLabel.Position = UDim2.new(0, 44, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 13
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.ZIndex = 5

    -- Toggle pill
    local pillBg = Instance.new("Frame", frame)
    pillBg.Size = UDim2.new(0, 44, 0, 24)
    pillBg.Position = UDim2.new(1, -54, 0.5, -12)
    pillBg.BackgroundColor3 = state
        and Color3.fromRGB(100, 50, 220)
        or  Color3.fromRGB(50, 50, 70)
    pillBg.BorderSizePixel = 0
    pillBg.ZIndex = 5
    Instance.new("UICorner", pillBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pillBg)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = state
        and UDim2.new(1, -21, 0.5, -9)
        or  UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    -- Click area
    local clickBtn = Instance.new("TextButton", frame)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 7
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        Settings[settingKey] = state
        Beep(state and 1.4 or 0.8)

        TweenService:Create(pillBg, TweenInfo.new(0.2), {
            BackgroundColor3 = state
                and Color3.fromRGB(100, 50, 220)
                or  Color3.fromRGB(50, 50, 70)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state
                and UDim2.new(1, -21, 0.5, -9)
                or  UDim2.new(0, 3, 0.5, -9)
        }):Play()
        TweenService:Create(accent, TweenInfo.new(0.2), {
            BackgroundColor3 = state
                and Color3.fromRGB(120, 60, 255)
                or  Color3.fromRGB(80, 80, 80)
        }):Play()

        if onChange then onChange(state) end
        Notify(
            label,
            state and "Đã bật" or "Đã tắt",
            state and "✅" or "❌",
            state and Color3.fromRGB(80,220,120) or Color3.fromRGB(220,80,80),
            1.8
        )
    end)

    -- Hover
    frame.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(28, 28, 44)
        }):Play()
    end)
    frame.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(20, 20, 32)
        }):Play()
    end)

    table.insert(tabContents[tabName], frame)
    frame.Visible = false
    return frame
end

-- Section label
local function CreateSection(tabName, text)
    local lbl = Instance.new("TextLabel", scroll)
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = Color3.fromRGB(130, 90, 220)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 4
    table.insert(tabContents[tabName], lbl)
    lbl.Visible = false
end

-- ============================================
-- POPULATE TABS
-- ============================================

-- VISUAL
CreateSection("Visual", "── VISUAL ──────────────────")
CreateToggle("Visual", "Full Bright", "☀️", "FullBright", function(v)
    ApplyFullBright(v)
end)
CreateToggle("Visual", "Item ESP", "📦", "ItemESP", nil)
CreateToggle("Visual", "Gold ESP", "💰", "GoldESP", nil)
CreateToggle("Visual", "Key ESP", "🔑", "KeyESP", nil)
CreateToggle("Visual", "Battery ESP", "🔋", "BatteryESP", nil)
CreateToggle("Visual", "Crucifix ESP", "✝️", "CrucifixESP", nil)
CreateToggle("Visual", "Vitamin ESP", "💊", "VitaminESP", nil)
CreateToggle("Visual", "Bandage ESP", "🩹", "BandageESP", nil)
CreateToggle("Visual", "Closet ESP", "🚪", "ClosetHighlight", nil)
CreateToggle("Visual", "Player ESP", "👤", "PlayerESP", nil)

-- ENTITY
CreateSection("Entity", "── ENTITY ──────────────────")
CreateToggle("Entity", "Entity ESP", "👻", "EntityESP", nil)
CreateToggle("Entity", "Entity Alert", "⚠️", "EntityAlert", nil)
CreateToggle("Entity", "Auto Hide (Rush/Ambush)", "🏃", "AutoHide", nil)
CreateToggle("Entity", "Auto Use Crucifix", "✝️", "AutoUseCrucifix", nil)

-- AUTO
CreateSection("Auto", "── AUTO ────────────────────")
CreateToggle("Auto", "Auto Collect Gold", "💰", "AutoCollectGold", nil)
CreateToggle("Auto", "Auto Collect Items", "📦", "AutoCollectItems", nil)

-- MISC
CreateSection("Misc", "── MISC ────────────────────")
CreateToggle("Misc", "Infinite Jump", "🦘", "InfiniteJump", nil)
CreateToggle("Misc", "Infinite Stamina", "⚡", "InfiniteStamina", nil)
CreateToggle("Misc", "Anti-AFK", "🟢", "AntiAFK", nil)
CreateToggle("Misc", "Thông báo hệ thống", "🔔", "NotifySystem", nil)
CreateToggle("Misc", "Âm thanh bíp bíp", "🔊", "SoundEnabled", nil)

-- THÊM VÀO ĐÂY
CreateSection("Floor2", "── ESP ─────────────────────")
CreateToggle("Floor2", "Book ESP (Library)",      "📖", "BookESP",      nil)
CreateToggle("Floor2", "Item ESP Tầng 2",          "⛏️", "ItemESP",      nil)
CreateToggle("Floor2", "Entity ESP Tầng 2",        "👻", "EntityESP",    nil)
CreateSection("Floor2", "── ANTI-ENTITY ─────────────")
CreateToggle("Floor2", "Anti-Gloombat (tắt đèn)", "🦇", "AntiGloombat", nil)
CreateToggle("Floor2", "Anti-Timothy (nhện)",      "🕷️", "AntiTimothy",  nil)
CreateToggle("Floor2", "Anti-Dupe (cửa giả)",      "🚪", "AntiDupe",     nil)

-- ============================================
-- OPEN / CLOSE GUI
-- ============================================
local function SetGuiVisible(state)
    guiVisible = state
    panel.Visible = state
    overlay.Visible = state

    -- Hiện/ẩn chuột
    UserInputService.MouseIconEnabled = true
    if state then
        -- Unlock chuột khi mở GUI
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    else
        -- Trả về lock bình thường khi đóng
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end

    if state then
        panel.Size = UDim2.new(0, 360, 0, 500)
        TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 380, 0, 520)
        }):Play()
        TweenService:Create(overlay, TweenInfo.new(0.25), {
            BackgroundTransparency = 0.6
        }):Play()
        SelectTab("Visual")
        Beep(1.3)
    else
        TweenService:Create(panel, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 360, 0, 500)
        }):Play()
        TweenService:Create(overlay, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
        Beep(0.8)
    end
end

closeBtn.MouseButton1Click:Connect(function() SetGuiVisible(false) end)
overlay.MouseButton1Click:Connect(function() SetGuiVisible(false) end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        SetGuiVisible(not guiVisible)
    end
end)

-- ============================================
-- KHỞI ĐỘNG
-- ============================================
task.wait(1)
Notify("✅ DOORS SCRIPT", "Load xong! Nhấn INSERT để mở menu.", "🚪", Color3.fromRGB(120,60,255), 5)
Beep(1)
task.wait(0.15)
Beep(1.3)
task.wait(0.15)
Beep(1.6)

print("[DOORS] Script loaded. Press INSERT to open menu.")

-- ============================================
--   THÊM VÀO SCRIPT CŨ - TẦNG 2 + LIBRARY
-- ============================================

-- ============================================
-- 1. ESP BOOK CHO LIBRARY (tầng 1 & tầng 2)
-- ============================================
local BOOK_KEYWORDS = {
    "book", "notebook", "journal",
    "librarybook", "library_book",
    "codex", "tome", "manuscript",
    "BookItem", "BookPickup",
}

task.spawn(function()
    while task.wait(3) do
        if not Settings.BookESP then continue end
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            for _, kw in ipairs(BOOK_KEYWORDS) do
                if name:find(kw:lower()) then
                    local target = obj:IsA("Model")
                        and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart"))
                        or (obj:IsA("BasePart") and obj or nil)
                    if target and not target:FindFirstChildOfClass("SelectionBox") then
                        -- Highlight cam đặc trưng
                        local sel = Instance.new("SelectionBox")
                        sel.Adornee            = target
                        sel.Color3             = Color3.fromRGB(255, 140, 50)
                        sel.LineThickness      = 0.05
                        sel.SurfaceTransparency= 0.65
                        sel.SurfaceColor3      = Color3.fromRGB(255, 140, 50)
                        sel.Parent             = target

                        local bb = Instance.new("BillboardGui")
                        bb.Size         = UDim2.new(0, 110, 0, 28)
                        bb.AlwaysOnTop  = true
                        bb.StudsOffset  = Vector3.new(0, 3.5, 0)
                        bb.Adornee      = target
                        bb.Parent       = target

                        local bg = Instance.new("Frame", bb)
                        bg.Size = UDim2.new(1,0,1,0)
                        bg.BackgroundColor3   = Color3.fromRGB(10,10,18)
                        bg.BackgroundTransparency = 0.25
                        bg.BorderSizePixel    = 0
                        Instance.new("UICorner", bg).CornerRadius = UDim.new(0,5)

                        local lbl = Instance.new("TextLabel", bg)
                        lbl.Size = UDim2.new(1,0,1,0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(255,160,60)
                        lbl.Font       = Enum.Font.GothamBold
                        lbl.TextSize   = 11
                        lbl.Text       = "📖 Book  [" .. math.floor(DistanceTo(target)) .. "m]"

                        -- Update khoảng cách liên tục
                        RunService.Heartbeat:Connect(function()
                            if target and target.Parent then
                                lbl.Text = "📖 Book  [" .. math.floor(DistanceTo(target)) .. "m]"
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- ============================================
-- 2. ENTITY TẦNG 2 (The Mines)
-- ============================================
local FLOOR2_ENTITIES = {
    -- Entity mới tầng 2
    { name = "Gloombat",   icon = "🦇", color = Color3.fromRGB(100,  50, 200) },
    { name = "Timothy",    icon = "🕷️", color = Color3.fromRGB(180, 100,  30) },
    { name = "Blitz",      icon = "⚡", color = Color3.fromRGB(255, 240,  50) },
    { name = "Dupe",       icon = "🚪", color = Color3.fromRGB(255,  80,  80) },
    { name = "Void",       icon = "🌀", color = Color3.fromRGB( 60,  60, 255) },
    { name = "Snare",      icon = "🪤", color = Color3.fromRGB(200, 140,  40) },
    { name = "Grumble",    icon = "🪨", color = Color3.fromRGB(150, 120,  90) },
}

-- Gộp vào hệ thống alert chung
local function ScanFloor2Entities()
    for _, eData in ipairs(FLOOR2_ENTITIES) do
        local entity = workspace:FindFirstChild(eData.name, true)
        if entity then
            local dist = DistanceTo(entity)
            local target = entity:IsA("Model")
                and (entity.PrimaryPart or entity:FindFirstChildOfClass("BasePart"))
                or entity

            -- ESP
            if Settings.EntityESP and target then
                if not target:FindFirstChildOfClass("SelectionBox") then
                    local sel = Instance.new("SelectionBox")
                    sel.Adornee             = target
                    sel.Color3              = eData.color
                    sel.LineThickness       = 0.04
                    sel.SurfaceTransparency = 0.72
                    sel.SurfaceColor3       = eData.color
                    sel.Parent              = target

                    local bb = Instance.new("BillboardGui")
                    bb.Size        = UDim2.new(0,130,0,28)
                    bb.AlwaysOnTop = true
                    bb.StudsOffset = Vector3.new(0,3.5,0)
                    bb.Adornee     = target
                    bb.Parent      = target

                    local bg = Instance.new("Frame", bb)
                    bg.Size = UDim2.new(1,0,1,0)
                    bg.BackgroundColor3       = Color3.fromRGB(10,10,18)
                    bg.BackgroundTransparency = 0.25
                    bg.BorderSizePixel        = 0
                    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,5)

                    local lbl = Instance.new("TextLabel", bg)
                    lbl.Size               = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3         = eData.color
                    lbl.Font               = Enum.Font.GothamBold
                    lbl.TextSize           = 11
                    lbl.Text               = eData.icon .. " " .. eData.name .. " [" .. math.floor(dist) .. "m]"

                    RunService.Heartbeat:Connect(function()
                        if target and target.Parent then
                            lbl.Text = eData.icon .. " " .. eData.name .. " [" .. math.floor(DistanceTo(target)) .. "m]"
                        end
                    end)
                end
            end

            -- Alert
            if Settings.EntityAlert and not entityAlerted[eData.name] then
                if dist < Settings.EntityAlertDist then
                    entityAlerted[eData.name] = true
                    Beep(1.6)
                    task.delay(0.12, function() Beep(1.9) end)
                    Notify(
                        eData.icon .. " " .. eData.name .. "!",
                        "Khoảng cách: " .. math.floor(dist) .. "m",
                        eData.icon,
                        eData.color,
                        4
                    )
                end
            end
        else
            entityAlerted[eData.name] = nil
        end
    end
end

RunService.Heartbeat:Connect(ScanFloor2Entities)

-- ============================================
-- 3. ITEM ESP TẦNG 2
-- ============================================
local FLOOR2_ITEMS = {
    { keywords = {"crucifix","cross"},          color = Color3.fromRGB(255,255,255), label = "✝️ Crucifix"  },
    { keywords = {"candle"},                    color = Color3.fromRGB(255,200,80),  label = "🕯️ Candle"   },
    { keywords = {"lockpick","lock_pick"},       color = Color3.fromRGB(180,180,180), label = "🔓 Lockpick"  },
    { keywords = {"flashlight","flash_light"},   color = Color3.fromRGB(220,220,100), label = "🔦 Flashlight"},
    { keywords = {"fuse","fusebox"},             color = Color3.fromRGB(255,100,50),  label = "⚡ Fuse"      },
    { keywords = {"knob","doorknob"},            color = Color3.fromRGB(200,160,50),  label = "🔩 Knob"      },
    { keywords = {"mining","pickaxe"},           color = Color3.fromRGB(160,140,120), label = "⛏️ Pickaxe"  },
    { keywords = {"lantern"},                    color = Color3.fromRGB(255,180,50),  label = "🪔 Lantern"   },
    { keywords = {"book","notebook","journal"},  color = Color3.fromRGB(255,140,50),  label = "📖 Book"      },
}

task.spawn(function()
    while task.wait(3) do
        if not Settings.ItemESP then continue end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not (obj:IsA("BasePart") or obj:IsA("Model")) then continue end
            local name = obj.Name:lower()
            for _, tag in ipairs(FLOOR2_ITEMS) do
                for _, kw in ipairs(tag.keywords) do
                    if name:find(kw) then
                        local target = obj:IsA("Model")
                            and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart"))
                            or obj
                        if target and target:IsA("BasePart")
                           and not target:FindFirstChildOfClass("SelectionBox") then
                            local sel = Instance.new("SelectionBox")
                            sel.Adornee             = target
                            sel.Color3              = tag.color
                            sel.LineThickness       = 0.04
                            sel.SurfaceTransparency = 0.7
                            sel.SurfaceColor3       = tag.color
                            sel.Parent              = target

                            local bb = Instance.new("BillboardGui")
                            bb.Size        = UDim2.new(0,120,0,26)
                            bb.AlwaysOnTop = true
                            bb.StudsOffset = Vector3.new(0,3,0)
                            bb.Adornee     = target
                            bb.Parent      = target

                            local bg = Instance.new("Frame", bb)
                            bg.Size = UDim2.new(1,0,1,0)
                            bg.BackgroundColor3       = Color3.fromRGB(10,10,18)
                            bg.BackgroundTransparency = 0.25
                            bg.BorderSizePixel        = 0
                            Instance.new("UICorner", bg).CornerRadius = UDim.new(0,5)

                            local lbl = Instance.new("TextLabel", bg)
                            lbl.Size = UDim2.new(1,0,1,0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextColor3 = tag.color
                            lbl.Font       = Enum.Font.GothamBold
                            lbl.TextSize   = 11
                            lbl.Text       = tag.label
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- 4. ANTI-GLOOMBAT (né dơi)
-- ============================================
Settings.AntiGloombat = true

task.spawn(function()
    while task.wait(0.2) do
        if not Settings.AntiGloombat then continue end
        local gloombat = workspace:FindFirstChild("Gloombat", true)
        if gloombat then
            local dist = DistanceTo(gloombat)
            if dist < 20 then
                -- Tắt đèn/lighter để né Gloombat
                local lighter = Character:FindFirstChild("Lighter")
                    or LocalPlayer.Backpack:FindFirstChild("Lighter")
                if lighter then
                    local toggle = lighter:FindFirstChild("Toggle")
                    if toggle and toggle:IsA("RemoteEvent") then
                        toggle:FireServer(false)
                    end
                end
                Notify("🦇 Gloombat!", "TẮT ĐÈN! Gloombat cách " .. math.floor(dist) .. "m", "🦇", Color3.fromRGB(100,50,200), 3)
            end
        end
    end
end)

-- ============================================
-- 5. ANTI-TIMOTHY (né nhện)
-- ============================================
Settings.AntiTimothy = true

task.spawn(function()
    while task.wait(0.3) do
        if not Settings.AntiTimothy then continue end
        local timothy = workspace:FindFirstChild("Timothy", true)
        if timothy and DistanceTo(timothy) < 8 then
            Notify("🕷️ Timothy!", "CÓ NHỆN! Đừng mở tủ đó!", "🕷️", Color3.fromRGB(180,100,30), 3)
            Beep(0.7)
            task.delay(0.1, function() Beep(0.9) end)
        end
    end
end)

-- ============================================
-- 6. ANTI-DUPE (phát hiện cửa giả)
-- ============================================
Settings.AntiDupe = true

task.spawn(function()
    while task.wait(0.5) do
        if not Settings.AntiDupe then continue end
        local dupe = workspace:FindFirstChild("Dupe", true)
        if dupe and DistanceTo(dupe) < 15 then
            Notify("🚪 Dupe!", "CỬA GIẢ gần đây! Hãy cẩn thận!", "🚪", Color3.fromRGB(255,80,80), 3)
            Beep(1.8)
        end
    end
end)
