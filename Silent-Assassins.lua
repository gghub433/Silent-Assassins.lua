--[[
    Silent Assassins / Silent Assassin: NEXUS HUB v3.0
    Supports: Creed Creations (Yen/slash) + TypicalType (cloak/sprint/escape)
    t.me/zood3llotgk
--]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp                = Players.LocalPlayer
local cam               = workspace.CurrentCamera

if setclipboard then
    setclipboard("https://t.me/zood3llotgk")
    print("[NEXUS] Ссылка скопирована!")
end

pcall(function()
    if lp.PlayerGui:FindFirstChild("SilentHitboxHub") then
        lp.PlayerGui.SilentHitboxHub:Destroy()
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  STATES
-- ─────────────────────────────────────────────────────────────────────────────
local states = {
    -- Visual
    esp          = false,
    distEsp      = false,
    healthEsp    = false,
    chams        = false,
    tracers      = false,
    boxEsp       = false,
    crosshair    = false,
    minimap      = false,
    hitbox       = false,
    killFeed     = false,
    -- Combat
    killAura     = false,
    autoFarm     = false,
    aimlock      = false,
    antiRagdoll  = false,
    -- Movement
    speed        = false,
    fly          = false,
    noclip       = false,
    jumpBoost    = false,
    infJump      = false,
    bunnyhop     = false,
    infStamina   = false,
    -- Misc
    godMode      = false,
    autoCollect  = false,
    chatSpam     = false,
    autoRespawn  = false,
    fakeLag      = false,
    -- Game-specific
    fastSlash    = false,
    bypassDetect = false,
    infCloak     = false,
    infSprint    = false,
    autoEscape   = false,
    remoteSpy    = false,
    dupeYen      = false,
}

-- ─────────────────────────────────────────────────────────────────────────────
--  CONFIG
-- ─────────────────────────────────────────────────────────────────────────────
local cfg = {
    speedValue      = 28,
    jumpValue       = 80,
    hitboxSize      = 15,
    killAuraRadius  = 20,
    autoFarmRadius  = 30,
    aimlockRange    = 80,
    collectRadius   = 25,
    flySpeed        = 40,
    chatMsg         = "NEXUS HUB | t.me/zood3llotgk",
    chatDelay       = 3,
    dupeCount       = 5,
    fakeLagDelay    = 0.3,
    slashSpeed      = 2,
    minimapSize     = 160,
}

local conns  = {}
local flyBV, flyBG

-- remote spy log
local remoteLog = {}

-- kill feed log
local killFeedEntries = {}

-- ─────────────────────────────────────────────────────────────────────────────
--  HELPERS
-- ─────────────────────────────────────────────────────────────────────────────
local function getNearestPlayer(maxDist)
    local mc = lp.Character
    if not mc then return nil, 9999 end
    local mrp = mc:FindFirstChild("HumanoidRootPart")
    if not mrp then return nil, 9999 end
    local best, bestDist = nil, maxDist or 9999
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local th = p.Character:FindFirstChild("HumanoidRootPart")
            local hm = p.Character:FindFirstChild("Humanoid")
            if th and hm and hm.Health > 0 then
                local d = (mrp.Position - th.Position).Magnitude
                if d < bestDist then bestDist = d; best = p end
            end
        end
    end
    return best, bestDist
end

local function getPlayerIndex(target)
    for i, p in ipairs(Players:GetPlayers()) do
        if p == target then return i end
    end
    return 1
end

-- search for a value by name patterns inside a model
local function findValueByNames(parent, names)
    for _, n in pairs(names) do
        local v = parent:FindFirstChild(n, true)
        if v then return v end
    end
    return nil
end

-- fire a RemoteEvent if it exists anywhere in ReplicatedStorage
local function tryFireRemote(names, ...)
    for _, n in pairs(names) do
        local re = ReplicatedStorage:FindFirstChild(n, true)
        if re and re:IsA("RemoteEvent") then
            pcall(function() re:FireServer(...) end)
            return re
        end
    end
    return nil
end

local function createESPTag(char, player)
    local head = char:WaitForChild("Head", 5)
    if not head or head:FindFirstChild("NexusTag") then return end
    local bgui = Instance.new("BillboardGui", head)
    bgui.Name = "NexusTag"
    bgui.Adornee = head
    bgui.Size = UDim2.new(0, 180, 0, 90)
    bgui.StudsOffset = Vector3.new(0, 2.8, 0)
    bgui.AlwaysOnTop = true

    local nameL = Instance.new("TextLabel", bgui)
    nameL.Name = "NameLabel"
    nameL.BackgroundTransparency = 1
    nameL.Size = UDim2.new(1, 0, 0, 22)
    nameL.Text = player.DisplayName or player.Name
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 14
    nameL.TextColor3 = Color3.new(1, 1, 1)
    nameL.TextStrokeTransparency = 0.35

    local distL = Instance.new("TextLabel", bgui)
    distL.Name = "DistLabel"
    distL.BackgroundTransparency = 1
    distL.Size = UDim2.new(1, 0, 0, 16)
    distL.Position = UDim2.new(0, 0, 0, 24)
    distL.Font = Enum.Font.Gotham
    distL.TextSize = 11
    distL.TextColor3 = Color3.fromRGB(190, 190, 200)
    distL.TextStrokeTransparency = 0.5
    distL.Visible = false

    local hpBg = Instance.new("Frame", bgui)
    hpBg.Name = "HpBg"
    hpBg.Size = UDim2.new(0.82, 0, 0, 6)
    hpBg.Position = UDim2.new(0.09, 0, 0, 44)
    hpBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    hpBg.BorderSizePixel = 0
    hpBg.Visible = false
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)

    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Name = "HpFill"
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
    hpFill.BorderSizePixel = 0
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)
end

local function refreshESPTag(char, player)
    local head = char:FindFirstChild("Head")
    if not head then return end
    local tag = head:FindFirstChild("NexusTag")
    if not tag then return end

    local distL = tag:FindFirstChild("DistLabel")
    local mc = lp.Character
    if mc and mc:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
        local d = math.floor((mc.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
        if distL then
            distL.Text = d .. " studs"
            distL.Visible = states.distEsp
        end
    end

    local hpBg = tag:FindFirstChild("HpBg")
    if hpBg then
        hpBg.Visible = states.healthEsp
        if states.healthEsp then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                local hpFill = hpBg:FindFirstChild("HpFill")
                if hpFill then
                    hpFill.Size = UDim2.new(ratio, 0, 1, 0)
                    hpFill.BackgroundColor3 = Color3.fromRGB(
                        math.floor((1 - ratio) * 255),
                        math.floor(ratio * 200), 50)
                end
            end
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
--  MAIN FRAME
-- ─────────────────────────────────────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui", lp.PlayerGui)
ScreenGui.Name = "SilentHitboxHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

local Main = Instance.new("Frame", ScreenGui)
Main.Name = "Main"
Main.Size = UDim2.new(0, 420, 0, 500)
Main.Position = UDim2.new(0.5, -210, 0.06, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- ── Header ────────────────────────────────────────────────────────────────────
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local hFix = Instance.new("Frame", Header)
hFix.Size = UDim2.new(1, 0, 0.5, 0)
hFix.Position = UDim2.new(0, 0, 0.5, 0)
hFix.BackgroundColor3 = Header.BackgroundColor3
hFix.BorderSizePixel = 0

local TitleL = Instance.new("TextLabel", Header)
TitleL.Size = UDim2.new(1, -80, 1, 0)
TitleL.Position = UDim2.new(0, 12, 0, 0)
TitleL.BackgroundTransparency = 1
TitleL.Text = "⚡ SILENT ASSASSINS — NEXUS HUB v3"
TitleL.TextColor3 = Color3.fromRGB(0, 180, 255)
TitleL.Font = Enum.Font.GothamBold
TitleL.TextSize = 12
TitleL.TextXAlignment = Enum.TextXAlignment.Left

local minimized = false
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 27, 0, 22)
MinBtn.Position = UDim2.new(1, -60, 0.5, -11)
MinBtn.Text = "—"
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 68)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Main.Size = minimized and UDim2.new(0, 420, 0, 40) or UDim2.new(0, 420, 0, 500)
    MinBtn.Text = minimized and "□" or "—"
end)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 27, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -11)
CloseBtn.Text = "✕"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
CloseBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
    if flyBV then pcall(function() flyBV:Destroy() end) end
    if flyBG then pcall(function() flyBG:Destroy() end) end
    ScreenGui:Destroy()
end)

-- ── Tab bar (5 tabs) ─────────────────────────────────────────────────────────
local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, 0, 0, 32)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
TabBar.BorderSizePixel = 0

local tabNames  = {"COMBAT", "MOVE", "VISUAL", "MISC", "GAME"}
local tabFrames = {}
local tabBtns   = {}

local function switchTab(name)
    for _, n in pairs(tabNames) do
        if tabBtns[n] then
            tabBtns[n].BackgroundColor3 = (n == name)
                and Color3.fromRGB(0, 100, 220)
                or  Color3.fromRGB(25, 25, 32)
        end
        if tabFrames[n] then tabFrames[n].Visible = (n == name) end
    end
end

for i, name in ipairs(tabNames) do
    local b = Instance.new("TextButton", TabBar)
    b.Size = UDim2.new(0.2, 0, 1, 0)
    b.Position = UDim2.new(0.2 * (i - 1), 0, 0, 0)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.BorderSizePixel = 0
    tabBtns[name] = b
    b.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- ── Scrollable content per tab ───────────────────────────────────────────────
local function makeTabFrame(name)
    local sf = Instance.new("ScrollingFrame", Main)
    sf.Name = name .. "Tab"
    sf.Size = UDim2.new(1, 0, 0, 400)
    sf.Position = UDim2.new(0, 0, 0, 72)
    sf.BackgroundTransparency = 1
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.Visible = false
    local layout = Instance.new("UIListLayout", sf)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    local pad = Instance.new("UIPadding", sf)
    pad.PaddingLeft  = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingTop   = UDim.new(0, 8)
    tabFrames[name] = sf
    return sf
end

local combatTab = makeTabFrame("COMBAT")
local moveTab   = makeTabFrame("MOVE")
local visualTab = makeTabFrame("VISUAL")
local miscTab   = makeTabFrame("MISC")
local gameTab   = makeTabFrame("GAME")

-- ── Link bar ──────────────────────────────────────────────────────────────────
local LinkBar = Instance.new("Frame", Main)
LinkBar.Size = UDim2.new(1, 0, 0, 28)
LinkBar.Position = UDim2.new(0, 0, 1, -28)
LinkBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
LinkBar.BorderSizePixel = 0
local LinkBox = Instance.new("TextBox", LinkBar)
LinkBox.Size = UDim2.new(1, -20, 1, 0)
LinkBox.Position = UDim2.new(0, 10, 0, 0)
LinkBox.BackgroundTransparency = 1
LinkBox.Text = "t.me/zood3llotgk"
LinkBox.TextColor3 = Color3.fromRGB(0, 180, 255)
LinkBox.Font = Enum.Font.Gotham
LinkBox.TextSize = 12
LinkBox.ClearTextOnFocus = false
LinkBox.TextEditable = false

-- ─────────────────────────────────────────────────────────────────────────────
--  UI BUILDERS
-- ─────────────────────────────────────────────────────────────────────────────
local _order = 1
local function nextOrder() _order = _order + 1; return _order end

local function makeSection(parent, label)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.LayoutOrder = nextOrder()
    local line = Instance.new("Frame", f)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
    line.BorderSizePixel = 0
    local lbl = Instance.new("TextLabel", f)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    lbl.Text = "  " .. label .. "  "
    lbl.TextColor3 = Color3.fromRGB(0, 170, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    return f
end

local function makeToggle(parent, label, key, onToggle)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Text = "  " .. label .. ":  OFF"
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.LayoutOrder = nextOrder()
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local dot = Instance.new("Frame", b)
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(1, -18, 0.5, -4)
    dot.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    b.MouseButton1Click:Connect(function()
        states[key] = not states[key]
        if states[key] then
            b.BackgroundColor3 = Color3.fromRGB(0, 88, 185)
            b.Text = "  " .. label .. ":  ON"
            dot.BackgroundColor3 = Color3.fromRGB(50, 220, 100)
        else
            b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            b.Text = "  " .. label .. ":  OFF"
            dot.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
        if onToggle then onToggle(states[key], b) end
    end)
    return b
end

local function makeAction(parent, label, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(0, 78, 155)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Text = label
    b.LayoutOrder = nextOrder()
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        if callback then callback(b) end
    end)
    return b
end

local function makeSlider(parent, label, minV, maxV, defVal, onChange)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, 0, 0, 54)
    c.BackgroundColor3 = Color3.fromRGB(26, 26, 33)
    c.LayoutOrder = nextOrder()
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel", c)
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. defVal
    lbl.TextColor3 = Color3.fromRGB(190, 190, 200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local track = Instance.new("Frame", c)
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 36)
    track.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local r0 = math.clamp((defVal - minV) / (maxV - minV), 0, 1)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(r0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 13, 0, 13)
    knob.Position = UDim2.new(r0, -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function applyR(r)
        r = math.clamp(r, 0, 1)
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, -6, 0.5, -6)
        local v = math.floor(minV + r * (maxV - minV))
        lbl.Text = label .. ": " .. v
        if onChange then onChange(v) end
    end
    knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            applyR((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            applyR((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
        end
    end)
    return c
end

local function makeRadiusRow(parent, label, cfgKey, minV, maxV)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, 0, 0, 36)
    c.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    c.LayoutOrder = nextOrder()
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel", c)
    lbl.Size = UDim2.new(1, -90, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. cfg[cfgKey] .. "m"
    lbl.TextColor3 = Color3.fromRGB(160, 160, 170)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local dec = Instance.new("TextButton", c)
    dec.Size = UDim2.new(0, 32, 0, 24)
    dec.Position = UDim2.new(1, -74, 0.5, -12)
    dec.Text = "−"; dec.BackgroundColor3 = Color3.fromRGB(48, 48, 58)
    dec.TextColor3 = Color3.new(1,1,1); dec.Font = Enum.Font.GothamBold; dec.TextSize = 16
    Instance.new("UICorner", dec).CornerRadius = UDim.new(0, 5)
    local inc = Instance.new("TextButton", c)
    inc.Size = UDim2.new(0, 32, 0, 24)
    inc.Position = UDim2.new(1, -38, 0.5, -12)
    inc.Text = "+"; inc.BackgroundColor3 = Color3.fromRGB(48, 48, 58)
    inc.TextColor3 = Color3.new(1,1,1); inc.Font = Enum.Font.GothamBold; inc.TextSize = 16
    Instance.new("UICorner", inc).CornerRadius = UDim.new(0, 5)
    dec.MouseButton1Click:Connect(function()
        cfg[cfgKey] = math.max(minV, cfg[cfgKey] - 5)
        lbl.Text = label .. ": " .. cfg[cfgKey] .. "m"
    end)
    inc.MouseButton1Click:Connect(function()
        cfg[cfgKey] = math.min(maxV, cfg[cfgKey] + 5)
        lbl.Text = label .. ": " .. cfg[cfgKey] .. "m"
    end)
    return c
end

local function makeTextInput(parent, placeholder, default)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, 0, 0, 38)
    c.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    c.LayoutOrder = nextOrder()
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 6)
    local box = Instance.new("TextBox", c)
    box.Size = UDim2.new(1, -20, 0, 26)
    box.Position = UDim2.new(0, 10, 0.5, -13)
    box.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = Color3.fromRGB(90, 90, 100)
    box.Font = Enum.Font.Gotham; box.TextSize = 12
    box.Text = default or ""; box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    return c, box
end

local function makeInfoLabel(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 28)
    lbl.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    lbl.TextColor3 = Color3.fromRGB(130, 130, 145)
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11
    lbl.TextWrapped = true; lbl.Text = text
    lbl.LayoutOrder = nextOrder()
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)
    return lbl
end

local function makeSpacer(parent)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 4)
    f.BackgroundTransparency = 1
    f.LayoutOrder = nextOrder()
end

-- ─────────────────────────────────────────────────────────────────────────────
--  COMBAT TAB
-- ─────────────────────────────────────────────────────────────────────────────
makeSection(combatTab, "KILL AURA")

makeToggle(combatTab, "KILL AURA", "killAura", function(on)
    if not on then return end
    task.spawn(function()
        while states.killAura do
            local mc = lp.Character
            if mc then
                local mrp = mc:FindFirstChild("HumanoidRootPart")
                local mhm = mc:FindFirstChild("Humanoid")
                if mrp and mhm and mhm.Health > 0 then
                    local tool = mc:FindFirstChildOfClass("Tool")
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= lp and p.Character then
                            local trp = p.Character:FindFirstChild("HumanoidRootPart")
                            local thm = p.Character:FindFirstChild("Humanoid")
                            if trp and thm and thm.Health > 0 then
                                if (mrp.Position - trp.Position).Magnitude <= cfg.killAuraRadius then
                                    local orig = mrp.CFrame
                                    mrp.CFrame = trp.CFrame * CFrame.new(0, 0, -1.8)
                                    if tool then pcall(function() tool:Activate() end) end
                                    task.wait(0.08)
                                    mrp.CFrame = orig
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.12)
        end
    end)
end)

makeRadiusRow(combatTab, "Kill Aura Radius", "killAuraRadius", 5, 150)

makeSection(combatTab, "AUTO FARM")

makeToggle(combatTab, "AUTO FARM (NPCs)", "autoFarm", function(on)
    if not on then return end
    task.spawn(function()
        while states.autoFarm do
            local mc = lp.Character
            if mc then
                local mrp = mc:FindFirstChild("HumanoidRootPart")
                if mrp then
                    local tool = mc:FindFirstChildOfClass("Tool")
                    local pcs = {}
                    for _, p in pairs(Players:GetPlayers()) do
                        if p.Character then pcs[p.Character] = true end
                    end
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Humanoid") and obj.Health > 0 and not pcs[obj.Parent] then
                            local nrp = obj.Parent:FindFirstChild("HumanoidRootPart")
                            if nrp and (mrp.Position - nrp.Position).Magnitude <= cfg.autoFarmRadius then
                                local orig = mrp.CFrame
                                mrp.CFrame = nrp.CFrame * CFrame.new(0, 0, -1.8)
                                if tool then pcall(function() tool:Activate() end) end
                                task.wait(0.08)
                                mrp.CFrame = orig
                            end
                        end
                    end
                end
            end
            task.wait(0.18)
        end
    end)
end)

makeRadiusRow(combatTab, "Farm Radius", "autoFarmRadius", 5, 200)

makeSection(combatTab, "TARGETING")

makeToggle(combatTab, "AIMLOCK (nearest head)", "aimlock", function(on)
    if not on then return end
    task.spawn(function()
        while states.aimlock do
            local nearest = getNearestPlayer(cfg.aimlockRange)
            if nearest and nearest.Character then
                local head = nearest.Character:FindFirstChild("Head")
                if head then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, head.Position) end
            end
            task.wait(0.03)
        end
    end)
end)

makeRadiusRow(combatTab, "Aimlock Range", "aimlockRange", 10, 300)

makeToggle(combatTab, "ANTI-RAGDOLL", "antiRagdoll")

makeSection(combatTab, "ACTIONS")

makeAction(combatTab, "▶  INSTANT KILL — Nearest", function()
    task.spawn(function()
        local mc = lp.Character
        if not mc then return end
        local mrp = mc:FindFirstChild("HumanoidRootPart")
        if not mrp then return end
        local tool = mc:FindFirstChildOfClass("Tool")
        local nearest = getNearestPlayer(9999)
        if not nearest or not nearest.Character then return end
        local trp = nearest.Character:FindFirstChild("HumanoidRootPart")
        if not trp then return end
        local orig = mrp.CFrame
        mrp.CFrame = trp.CFrame * CFrame.new(0, 0, -1.5)
        for _ = 1, 12 do
            if tool then pcall(function() tool:Activate() end) end
            task.wait(0.03)
        end
        mrp.CFrame = orig
    end)
end)

makeAction(combatTab, "💀  MURDER ALL — Server", function(btn)
    btn.Text = "💀  Executing..."
    btn.BackgroundColor3 = Color3.fromRGB(160, 25, 25)
    task.spawn(function()
        local mc = lp.Character
        if mc then
            local mrp = mc:FindFirstChild("HumanoidRootPart")
            local tool = mrp and mc:FindFirstChildOfClass("Tool")
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local trp = p.Character:FindFirstChild("HumanoidRootPart")
                    local thm = p.Character:FindFirstChild("Humanoid")
                    if trp and thm and thm.Health > 0 and mrp then
                        local orig = mrp.CFrame
                        mrp.CFrame = trp.CFrame * CFrame.new(0, 0, -1.5)
                        for _ = 1, 7 do
                            if tool then pcall(function() tool:Activate() end) end
                            task.wait(0.04)
                        end
                        mrp.CFrame = orig; task.wait(0.06)
                    end
                end
            end
        end
        btn.Text = "💀  MURDER ALL — Server"
        btn.BackgroundColor3 = Color3.fromRGB(0, 78, 155)
    end)
end)

makeAction(combatTab, "⚡  KILL ALL NPCs — Workspace", function(btn)
    btn.BackgroundColor3 = Color3.fromRGB(120, 80, 0)
    task.spawn(function()
        local mc = lp.Character
        if not mc then return end
        local mrp = mc:FindFirstChild("HumanoidRootPart")
        if not mrp then return end
        local tool = mc:FindFirstChildOfClass("Tool")
        local pcs = {}
        for _, p in pairs(Players:GetPlayers()) do if p.Character then pcs[p.Character] = true end end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Health > 0 and not pcs[obj.Parent] then
                local nrp = obj.Parent:FindFirstChild("HumanoidRootPart")
                if nrp then
                    local orig = mrp.CFrame
                    mrp.CFrame = nrp.CFrame * CFrame.new(0, 0, -1.5)
                    for _ = 1, 5 do if tool then pcall(function() tool:Activate() end) end; task.wait(0.04) end
                    mrp.CFrame = orig; task.wait(0.05)
                end
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 78, 155)
    end)
end)

makeSpacer(combatTab)

-- ─────────────────────────────────────────────────────────────────────────────
--  MOVE TAB
-- ─────────────────────────────────────────────────────────────────────────────
makeSection(moveTab, "SPEED")
makeToggle(moveTab, "SPEED HACK", "speed")
makeSlider(moveTab, "Walk Speed", 16, 150, cfg.speedValue, function(v) cfg.speedValue = v end)

makeSection(moveTab, "FLY  [WASD + Space/Shift]")
makeToggle(moveTab, "FLY HACK", "fly", function(on)
    if on then
        local mc = lp.Character
        if not mc then return end
        local hrp = mc:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = mc:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
        pcall(function()
            if hrp:FindFirstChild("NexusFlyBV") then hrp.NexusFlyBV:Destroy() end
            if hrp:FindFirstChild("NexusFlyBG") then hrp.NexusFlyBG:Destroy() end
        end)
        flyBV = Instance.new("BodyVelocity", hrp)
        flyBV.Name = "NexusFlyBV"; flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5); flyBV.Velocity = Vector3.zero
        flyBG = Instance.new("BodyGyro", hrp)
        flyBG.Name = "NexusFlyBG"; flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5); flyBG.D = 100; flyBG.P = 10000
        local flyConn
        flyConn = RunService.RenderStepped:Connect(function()
            if not states.fly then
                flyConn:Disconnect()
                pcall(function() flyBV:Destroy() end); pcall(function() flyBG:Destroy() end)
                flyBV = nil; flyBG = nil
                local c2 = lp.Character
                if c2 and c2:FindFirstChild("Humanoid") then c2.Humanoid.PlatformStand = false end
                return
            end
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * cfg.flySpeed or Vector3.zero
            flyBG.CFrame = cam.CFrame
        end)
    end
end)
makeSlider(moveTab, "Fly Speed", 10, 200, cfg.flySpeed, function(v) cfg.flySpeed = v end)

makeSection(moveTab, "MISC MOVEMENT")

makeToggle(moveTab, "NOCLIP  (walk through walls)", "noclip", function(on)
    if not on then return end
    task.spawn(function()
        while states.noclip do
            local mc = lp.Character
            if mc then
                for _, v in pairs(mc:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
            task.wait(0)
        end
    end)
end)

makeToggle(moveTab, "JUMP BOOST", "jumpBoost")
makeSlider(moveTab, "Jump Power", 50, 500, cfg.jumpValue, function(v) cfg.jumpValue = v end)

makeToggle(moveTab, "INFINITE JUMP  (air jump)", "infJump")
makeInfoLabel(moveTab, "  Infinite Jump: press Space mid-air to keep jumping")

makeToggle(moveTab, "BUNNYHOP  (auto jump on land)", "bunnyhop")

makeToggle(moveTab, "INFINITE STAMINA / ENERGY", "infStamina")

makeSection(moveTab, "TELEPORT")

local tpListFrame = Instance.new("Frame", moveTab)
tpListFrame.Size = UDim2.new(1, 0, 0, 10)
tpListFrame.BackgroundTransparency = 1
tpListFrame.AutomaticSize = Enum.AutomaticSize.Y
tpListFrame.LayoutOrder = nextOrder()
Instance.new("UIListLayout", tpListFrame).Padding = UDim.new(0, 4)

local function rebuildTPList()
    for _, c in pairs(tpListFrame:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp then
            local btn = Instance.new("TextButton", tpListFrame)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(28, 48, 28)
            btn.TextColor3 = Color3.fromRGB(80, 230, 100)
            btn.Font = Enum.Font.Gotham; btn.TextSize = 12
            btn.Text = "  TP → " .. (p.DisplayName or p.Name)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.LayoutOrder = 1
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                local mc = lp.Character; local tc = p.Character
                if mc and tc then
                    local mrp = mc:FindFirstChild("HumanoidRootPart")
                    local trp = tc:FindFirstChild("HumanoidRootPart")
                    if mrp and trp then mrp.CFrame = trp.CFrame * CFrame.new(0, 0, 2.5) end
                end
            end)
        end
    end
end

makeAction(moveTab, "↺  Refresh Player List", function() rebuildTPList() end)
rebuildTPList()
Players.PlayerAdded:Connect(rebuildTPList)
Players.PlayerRemoving:Connect(rebuildTPList)
makeSpacer(moveTab)

-- ─────────────────────────────────────────────────────────────────────────────
--  VISUAL TAB
-- ─────────────────────────────────────────────────────────────────────────────
makeSection(visualTab, "ESP")
makeToggle(visualTab, "ESP + NAME TAGS", "esp")
makeToggle(visualTab, "DISTANCE ESP  (stud count)", "distEsp")
makeToggle(visualTab, "HEALTH ESP  (HP bars)", "healthEsp")
makeToggle(visualTab, "CHAMS  (rainbow highlights)", "chams", function(on)
    if not on then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChild("NexusHL")
                if hl then hl:Destroy() end
            end
        end
    end
end)

local hasDrawing = false
pcall(function() local t = Drawing.new("Line"); t:Destroy(); hasDrawing = true end)

local boxObjs = {}
makeToggle(visualTab, "BOX ESP" .. (hasDrawing and "" or "  [needs Drawing]"), "boxEsp", function(on)
    if not on then
        for _, d in pairs(boxObjs) do pcall(function() d:Destroy() end) end; boxObjs = {}
    end
end)

makeSection(visualTab, "OVERLAY")

local crosshairObj
makeToggle(visualTab, "CUSTOM CROSSHAIR", "crosshair", function(on)
    if crosshairObj then crosshairObj:Destroy(); crosshairObj = nil end
    if not on then return end
    crosshairObj = Instance.new("Frame", ScreenGui)
    crosshairObj.Size = UDim2.new(0, 26, 0, 26)
    crosshairObj.Position = UDim2.new(0.5, -13, 0.5, -13)
    crosshairObj.BackgroundTransparency = 1; crosshairObj.ZIndex = 20
    local function mkLine(sz, pos)
        local f = Instance.new("Frame", crosshairObj)
        f.Size = sz; f.Position = pos
        f.BackgroundColor3 = Color3.new(1, 1, 1)
        f.BorderSizePixel = 0; f.ZIndex = 20
    end
    mkLine(UDim2.new(0, 26, 0, 2), UDim2.new(0, 0, 0.5, -1))
    mkLine(UDim2.new(0, 2, 0, 26), UDim2.new(0.5, -1, 0, 0))
    local dot = Instance.new("Frame", crosshairObj)
    dot.Size = UDim2.new(0, 4, 0, 4); dot.Position = UDim2.new(0.5, -2, 0.5, -2)
    dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50); dot.BorderSizePixel = 0; dot.ZIndex = 21
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
end)

local tracerObjs = {}
makeToggle(visualTab, "TRACERS" .. (hasDrawing and "" or "  [needs Drawing]"), "tracers", function(on)
    if not on then
        for _, d in pairs(tracerObjs) do pcall(function() d:Destroy() end) end; tracerObjs = {}
    end
end)

-- Minimap
local minimapFrame
makeToggle(visualTab, "MINIMAP  (radar)", "minimap", function(on)
    if minimapFrame then minimapFrame:Destroy(); minimapFrame = nil end
    if not on then return end
    minimapFrame = Instance.new("Frame", ScreenGui)
    minimapFrame.Name = "NexusMinimap"
    minimapFrame.Size = UDim2.new(0, cfg.minimapSize, 0, cfg.minimapSize)
    minimapFrame.Position = UDim2.new(0, 10, 1, -cfg.minimapSize - 38)
    minimapFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    minimapFrame.BorderSizePixel = 0; minimapFrame.ZIndex = 50
    Instance.new("UICorner", minimapFrame).CornerRadius = UDim.new(0, 8)
    -- border
    local border = Instance.new("UIStroke", minimapFrame)
    border.Color = Color3.fromRGB(0, 120, 255); border.Thickness = 1.5
    -- center dot (self)
    local selfDot = Instance.new("Frame", minimapFrame)
    selfDot.Name = "SelfDot"
    selfDot.Size = UDim2.new(0, 8, 0, 8)
    selfDot.Position = UDim2.new(0.5, -4, 0.5, -4)
    selfDot.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    selfDot.BorderSizePixel = 0; selfDot.ZIndex = 52
    Instance.new("UICorner", selfDot).CornerRadius = UDim.new(1, 0)
    -- label
    local mapLbl = Instance.new("TextLabel", minimapFrame)
    mapLbl.Size = UDim2.new(1, 0, 0, 16)
    mapLbl.BackgroundTransparency = 1
    mapLbl.Text = "RADAR"
    mapLbl.TextColor3 = Color3.fromRGB(0, 180, 255)
    mapLbl.Font = Enum.Font.GothamBold; mapLbl.TextSize = 10
    mapLbl.ZIndex = 52
end)

makeSection(visualTab, "KILL FEED")

local killFeedFrame
makeToggle(visualTab, "KILL FEED  (who killed who)", "killFeed", function(on)
    if killFeedFrame then killFeedFrame:Destroy(); killFeedFrame = nil end
    if not on then return end
    killFeedFrame = Instance.new("Frame", ScreenGui)
    killFeedFrame.Name = "KillFeed"
    killFeedFrame.Size = UDim2.new(0, 240, 0, 200)
    killFeedFrame.Position = UDim2.new(1, -250, 0, 50)
    killFeedFrame.BackgroundTransparency = 1; killFeedFrame.ZIndex = 40
    local kfLayout = Instance.new("UIListLayout", killFeedFrame)
    kfLayout.SortOrder = Enum.SortOrder.LayoutOrder
    kfLayout.Padding = UDim.new(0, 2)
    kfLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

    -- Hook all player deaths
    local function hookPlayer(p)
        local function hookChar(char)
            local hum = char:WaitForChild("Humanoid", 10)
            if not hum then return end
            hum.Died:Connect(function()
                if not states.killFeed or not killFeedFrame then return end
                local entry = Instance.new("TextLabel", killFeedFrame)
                entry.Size = UDim2.new(1, 0, 0, 22)
                entry.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                entry.BackgroundTransparency = 0.3
                entry.TextColor3 = p == lp
                    and Color3.fromRGB(255, 100, 100)
                    or  Color3.fromRGB(200, 200, 200)
                entry.Font = Enum.Font.Gotham; entry.TextSize = 11
                entry.Text = "💀 " .. (p.DisplayName or p.Name) .. " died"
                entry.LayoutOrder = tick()
                Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 4)
                task.delay(5, function() if entry and entry.Parent then entry:Destroy() end end)
            end)
        end
        if p.Character then hookChar(p.Character) end
        p.CharacterAdded:Connect(hookChar)
    end

    for _, p in pairs(Players:GetPlayers()) do hookPlayer(p) end
    Players.PlayerAdded:Connect(hookPlayer)
end)

makeSection(visualTab, "HITBOX / CAMERA")
makeToggle(visualTab, "BIG HITBOX", "hitbox")
makeSlider(visualTab, "Hitbox Size", 5, 60, cfg.hitboxSize, function(v) cfg.hitboxSize = v end)
makeSlider(visualTab, "FOV", 50, 120, 70, function(v) workspace.CurrentCamera.FieldOfView = v end)
makeSpacer(visualTab)

-- ─────────────────────────────────────────────────────────────────────────────
--  MISC TAB
-- ─────────────────────────────────────────────────────────────────────────────
makeSection(miscTab, "SURVIVAL")

makeToggle(miscTab, "GOD MODE", "godMode", function(on)
    if not on then return end
    task.spawn(function()
        while states.godMode do
            local mc = lp.Character
            if mc then
                local hm = mc:FindFirstChild("Humanoid")
                if hm then hm.MaxHealth = math.huge; hm.Health = math.huge end
            end
            task.wait(0.05)
        end
    end)
end)

makeToggle(miscTab, "AUTO RESPAWN  (instant respawn)", "autoRespawn")

makeSection(miscTab, "WEAPONS")

makeAction(miscTab, "⚔  GET ALL SWORDS / TOOLS", function(btn)
    btn.Text = "⏳  Searching..."
    btn.BackgroundColor3 = Color3.fromRGB(130, 90, 0)
    task.spawn(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            pcall(function() if obj:IsA("Tool") then obj.Parent = lp.Backpack end end)
        end
        pcall(function()
            for _, obj in pairs(game:GetService("StarterPack"):GetChildren()) do
                if obj:IsA("Tool") then obj:Clone().Parent = lp.Backpack end
            end
        end)
        pcall(function()
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("Tool") then
                    pcall(function() obj:Clone().Parent = lp.Backpack end)
                end
            end
        end)
        task.wait(0.4)
        btn.Text = "✓  SWORDS ACQUIRED"
        btn.BackgroundColor3 = Color3.fromRGB(0, 125, 55)
        task.wait(2.5)
        btn.Text = "⚔  GET ALL SWORDS / TOOLS"
        btn.BackgroundColor3 = Color3.fromRGB(0, 78, 155)
    end)
end)

makeAction(miscTab, "🗡  EQUIP BEST TOOL", function()
    local mc = lp.Character
    if not mc then return end
    local hum = mc:FindFirstChild("Humanoid")
    if not hum then return end
    for _, tool in pairs(lp.Backpack:GetChildren()) do
        if tool:IsA("Tool") then hum:EquipTool(tool); return end
    end
end)

makeAction(miscTab, "🔄  UNEQUIP ALL TOOLS", function()
    local mc = lp.Character
    if not mc then return end
    local hum = mc:FindFirstChild("Humanoid")
    if hum then hum:UnequipTools() end
end)

makeSection(miscTab, "AUTO ACTIONS")

makeToggle(miscTab, "AUTO COLLECT (coins/drops)", "autoCollect", function(on)
    if not on then return end
    task.spawn(function()
        while states.autoCollect do
            local mc = lp.Character
            if mc then
                local mrp = mc:FindFirstChild("HumanoidRootPart")
                if mrp then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local n = obj.Name:lower()
                            if n:find("coin") or n:find("cash") or n:find("reward")
                               or n:find("drop") or n:find("collect") or n:find("pickup")
                               or n:find("money") or n:find("gem") or n:find("credit")
                               or n:find("yen") or n:find("loot") then
                                if (mrp.Position - obj.Position).Magnitude <= cfg.collectRadius then
                                    mrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end)

makeRadiusRow(miscTab, "Collect Radius", "collectRadius", 5, 120)

makeToggle(miscTab, "FAKE LAG  (packet delay)", "fakeLag", function(on)
    if not on then return end
    task.spawn(function()
        while states.fakeLag do
            task.wait(cfg.fakeLagDelay)
        end
    end)
end)
makeSlider(miscTab, "Lag Delay (sec)", 1, 10, 3, function(v) cfg.fakeLagDelay = v * 0.1 end)

makeSection(miscTab, "CHAT / SERVER")

local _, chatBox = makeTextInput(miscTab, "Spam message...", cfg.chatMsg)

makeToggle(miscTab, "CHAT SPAM", "chatSpam", function(on)
    if not on then return end
    local msg = chatBox.Text ~= "" and chatBox.Text or cfg.chatMsg
    task.spawn(function()
        while states.chatSpam do
            pcall(function()
                local cse = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if cse then
                    local ev = cse:FindFirstChild("SayMessageRequest")
                    if ev then ev:FireServer(msg, "All") end
                end
            end)
            task.wait(cfg.chatDelay)
        end
    end)
end)

makeSlider(miscTab, "Spam Delay (sec)", 1, 30, cfg.chatDelay, function(v) cfg.chatDelay = v end)

makeAction(miscTab, "↺  REJOIN SERVER", function()
    pcall(function() TeleportService:Teleport(game.PlaceId, lp) end)
end)

makeAction(miscTab, "🌐  SERVER HOP  (find new server)", function(btn)
    btn.Text = "🌐  Hopping..."
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 80)
    task.spawn(function()
        pcall(function()
            -- Teleport to same place — lands in random server
            TeleportService:Teleport(game.PlaceId)
        end)
        task.wait(3)
        btn.Text = "🌐  SERVER HOP  (find new server)"
        btn.BackgroundColor3 = Color3.fromRGB(0, 78, 155)
    end)
end)

makeAction(miscTab, "✖  KICK SELF", function()
    pcall(function() lp:Kick("[NEXUS] Kicked by user.") end)
end)

makeSection(miscTab, "INFO")

local infoLabel = Instance.new("TextLabel", miscTab)
infoLabel.Size = UDim2.new(1, 0, 0, 68)
infoLabel.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
infoLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
infoLabel.Font = Enum.Font.Gotham; infoLabel.TextSize = 11
infoLabel.TextWrapped = true
infoLabel.LayoutOrder = nextOrder()
infoLabel.Text = string.format(
    "Player:  %s\nUser ID: %d\nJob ID:  %s...\nPlayers: %d / %d",
    lp.Name, lp.UserId, tostring(game.JobId):sub(1, 16),
    #Players:GetPlayers(), Players.MaxPlayers
)
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 6)

task.spawn(function()
    while task.wait(3) do
        if infoLabel and infoLabel.Parent then
            infoLabel.Text = string.format(
                "Player:  %s\nUser ID: %d\nJob ID:  %s...\nPlayers: %d / %d",
                lp.Name, lp.UserId, tostring(game.JobId):sub(1, 16),
                #Players:GetPlayers(), Players.MaxPlayers
            )
        end
    end
end)

makeSpacer(miscTab)

-- ─────────────────────────────────────────────────────────────────────────────
--  GAME TAB  — Silent Assassins / Silent Assassin specific
-- ─────────────────────────────────────────────────────────────────────────────
makeSection(gameTab, "CREED — Yen / Slash")

makeInfoLabel(gameTab, "  Game: Silent Assassins by Creed Creations (103854444055060)")

-- Dupe Yen: fire kill/hit RemoteEvent multiple times
makeAction(gameTab, "💰  DUPE YEN  (repeat kill RE)", function(btn)
    btn.Text = "💰  Firing..."
    btn.BackgroundColor3 = Color3.fromRGB(140, 100, 0)
    task.spawn(function()
        local knownKillREs = {
            "Kill", "KillPlayer", "Killed", "PlayerKilled",
            "HitEvent", "OnHit", "DamagePlayer", "Attack",
            "Slash", "KnifeHit", "SlashHit", "DealDamage",
            "RemoteKill", "PlayerDied", "GiveYen", "AddYen",
        }
        local nearest = getNearestPlayer(9999)
        local target = nearest and nearest.Character
        for _ = 1, cfg.dupeCount do
            tryFireRemote(knownKillREs, target)
            -- Also try firing all REs in ReplicatedStorage with kill/hit pattern
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    local n = obj.Name:lower()
                    if n:find("kill") or n:find("hit") or n:find("yen") or n:find("slash") then
                        pcall(function() obj:FireServer(target) end)
                    end
                end
            end
            task.wait(0.05)
        end
        btn.Text = "💰  DUPE YEN  (repeat kill RE)"
        btn.BackgroundColor3 = Color3.fromRGB(0, 78, 155)
    end)
end)

makeSlider(gameTab, "Dupe Count", 1, 50, cfg.dupeCount, function(v) cfg.dupeCount = v end)

-- Fast Slash: speed up tool animation + rapid activate loop
makeToggle(gameTab, "FAST SLASH  (rapid knife)", "fastSlash", function(on)
    if not on then return end
    task.spawn(function()
        while states.fastSlash do
            local mc = lp.Character
            if mc then
                local tool = mc:FindFirstChildOfClass("Tool")
                if tool then
                    -- Speed up any animations playing on the tool
                    for _, obj in pairs(mc:GetDescendants()) do
                        if obj:IsA("AnimationTrack") and obj.IsPlaying then
                            pcall(function() obj:AdjustSpeed(cfg.slashSpeed) end)
                        end
                    end
                    pcall(function() tool:Activate() end)
                end
            end
            task.wait(0.06)
        end
    end)
end)

makeSlider(gameTab, "Slash Speed Mult", 1, 10, cfg.slashSpeed, function(v) cfg.slashSpeed = v end)

-- Bypass Detection: zero out any detection/awareness values
makeToggle(gameTab, "BYPASS DETECT  (hide from AI)", "bypassDetect", function(on)
    if not on then return end
    task.spawn(function()
        local detectionNames = {
            "Detection", "Awareness", "Alert", "Suspicion",
            "SuspicionLevel", "DetectionLevel", "NoiseLevel",
            "Detected", "AlertLevel", "Stealth",
        }
        while states.bypassDetect do
            local mc = lp.Character
            if mc then
                -- Check character values
                for _, n in pairs(detectionNames) do
                    local v = mc:FindFirstChild(n, true)
                    if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                        v.Value = 0
                    end
                end
                -- Check player values
                for _, n in pairs(detectionNames) do
                    local v = lp:FindFirstChild(n, true)
                    if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                        v.Value = 0
                    end
                end
            end
            -- Also fire stealth REs
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    local n = obj.Name:lower()
                    if n:find("detect") or n:find("aware") or n:find("stealth") then
                        pcall(function() obj:FireServer(0) end)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

makeSection(gameTab, "TYPICALTYPE — Cloak / Sprint")

makeInfoLabel(gameTab, "  Game: Silent Assassin by TypicalType (1382113806)")

-- Infinite Cloak
makeToggle(gameTab, "INFINITE CLOAK  (never runs out)", "infCloak", function(on)
    if not on then return end
    task.spawn(function()
        local cloakNames = {
            "Cloak", "CloakEnergy", "CloakMeter", "CloakTime",
            "InvisEnergy", "StealthEnergy", "CloakValue",
            "AbilityEnergy", "Ability1Energy",
        }
        while states.infCloak do
            local mc = lp.Character
            if mc then
                for _, n in pairs(cloakNames) do
                    local v = mc:FindFirstChild(n, true) or lp:FindFirstChild(n, true)
                    if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                        v.Value = v.Value < 90 and 100 or v.Value
                    end
                end
            end
            -- Try firing cloak recharge RE
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    local n = obj.Name:lower()
                    if n:find("cloak") or n:find("invis") or n:find("recharge") then
                        pcall(function() obj:FireServer(100) end)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- Infinite Sprint
makeToggle(gameTab, "INFINITE SPRINT  (never runs out)", "infSprint", function(on)
    if not on then return end
    task.spawn(function()
        local sprintNames = {
            "Sprint", "SprintEnergy", "SprintMeter", "SprintTime",
            "RunEnergy", "Stamina", "StaminaValue", "Ability2Energy",
        }
        while states.infSprint do
            local mc = lp.Character
            if mc then
                for _, n in pairs(sprintNames) do
                    local v = mc:FindFirstChild(n, true) or lp:FindFirstChild(n, true)
                    if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                        v.Value = v.Value < 90 and 100 or v.Value
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- Auto Escape: TP to escape zone
makeAction(gameTab, "🚪  AUTO ESCAPE  (TP to exit)", function(btn)
    btn.Text = "🚪  Searching escape..."
    task.spawn(function()
        local escapeNames = {
            "Escape", "EscapePoint", "Exit", "ExitPoint",
            "EscapeZone", "SafeZone", "Goal", "EndPoint", "EscapePad",
        }
        local mc = lp.Character
        local mrp = mc and mc:FindFirstChild("HumanoidRootPart")
        if not mrp then
            btn.Text = "🚪  AUTO ESCAPE  (TP to exit)"; return
        end
        for _, n in pairs(escapeNames) do
            local obj = workspace:FindFirstChild(n, true)
            if obj and obj:IsA("BasePart") then
                mrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                btn.Text = "🚪  Escaped to: " .. n
                task.wait(2)
                btn.Text = "🚪  AUTO ESCAPE  (TP to exit)"
                btn.BackgroundColor3 = Color3.fromRGB(0, 78, 155)
                return
            end
        end
        btn.Text = "🚪  No escape point found"
        task.wait(2)
        btn.Text = "🚪  AUTO ESCAPE  (TP to exit)"
        btn.BackgroundColor3 = Color3.fromRGB(0, 78, 155)
    end)
end)

makeSection(gameTab, "REMOTE SPY")

makeInfoLabel(gameTab, "  Remote Spy logs all FireServer calls to console (F9)")

-- Remote Spy via hookmetamethod (executor-dependent)
makeToggle(gameTab, "REMOTE SPY  (log to console)", "remoteSpy", function(on)
    if on then
        pcall(function()
            if not hookmetamethod then return end
            local oldNC
            oldNC = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if states.remoteSpy and (method == "FireServer" or method == "InvokeServer") then
                    local args = {...}
                    local line = "[RemoteSpy] " .. method .. " → " .. self:GetFullName()
                    print(line)
                    table.insert(remoteLog, {
                        time   = os.clock(),
                        name   = self:GetFullName(),
                        method = method,
                        args   = args,
                    })
                    if #remoteLog > 200 then table.remove(remoteLog, 1) end
                end
                return oldNC(self, ...)
            end)
        end)
        if not pcall(function() return hookmetamethod ~= nil end) then
            print("[NEXUS] hookmetamethod not available — Remote Spy needs a full executor (Synapse/KRNL/Fluxus)")
        end
    end
end)

makeAction(gameTab, "📋  PRINT REMOTE LOG (console)", function()
    print("[NEXUS] === REMOTE LOG (" .. #remoteLog .. " entries) ===")
    for i, entry in ipairs(remoteLog) do
        print(string.format("[%d] %.2fs | %s | %s",
            i, entry.time, entry.method, entry.name))
    end
    print("[NEXUS] === END LOG ===")
end)

makeAction(gameTab, "🗑  CLEAR REMOTE LOG", function()
    remoteLog = {}
    print("[NEXUS] Remote log cleared.")
end)

makeSection(gameTab, "FIRE CUSTOM REMOTE")

makeInfoLabel(gameTab, "  Use Remote Spy to find RE names, then fire manually")

local _, reNameBox = makeTextInput(gameTab, "RemoteEvent name (e.g. Kill)...", "")
local _, reArgBox  = makeTextInput(gameTab, "Arg (optional, e.g. player name)...", "")

makeAction(gameTab, "⚡  FIRE REMOTE  (FireServer)", function()
    local reName = reNameBox.Text
    if reName == "" then return end
    local argStr = reArgBox.Text
    local arg = nil
    if argStr ~= "" then
        -- Try to resolve to player
        local targetP = Players:FindFirstChild(argStr)
        arg = targetP or argStr
    end
    pcall(function()
        local re = ReplicatedStorage:FindFirstChild(reName, true)
        if re and re:IsA("RemoteEvent") then
            if arg then re:FireServer(arg) else re:FireServer() end
            print("[NEXUS] Fired: " .. re:GetFullName())
        else
            print("[NEXUS] RemoteEvent not found: " .. reName)
        end
    end)
end)

makeAction(gameTab, "🔍  SCAN ALL REMOTES", function()
    print("[NEXUS] === ALL REMOTES IN ReplicatedStorage ===")
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            print("  " .. obj.ClassName .. ": " .. obj:GetFullName())
        end
    end
    print("[NEXUS] === END SCAN ===")
end)

makeSpacer(gameTab)

-- ─────────────────────────────────────────────────────────────────────────────
--  INFINITE JUMP — UserInputService hook
-- ─────────────────────────────────────────────────────────────────────────────
UserInputService.JumpRequest:Connect(function()
    if states.infJump then
        local mc = lp.Character
        if mc then
            local hm = mc:FindFirstChild("Humanoid")
            if hm then hm:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  RENDER LOOP
-- ─────────────────────────────────────────────────────────────────────────────
local renderConn = RunService.RenderStepped:Connect(function()

    -- Speed
    if states.speed then
        local mc = lp.Character
        if mc and mc:FindFirstChild("Humanoid") then
            mc.Humanoid.WalkSpeed = cfg.speedValue
        end
    end

    -- Jump / Stamina / Bunnyhop / Anti-ragdoll
    local mc = lp.Character
    if mc then
        local hm = mc:FindFirstChild("Humanoid")
        if hm then
            if states.jumpBoost then hm.JumpPower = cfg.jumpValue end
            if states.infStamina then
                for _, v in pairs(hm:GetChildren()) do
                    if v:IsA("NumberValue") then
                        local n = v.Name:lower()
                        if n:find("stam") or n:find("energy") or n:find("mana") then
                            v.Value = 100
                        end
                    end
                end
            end
            if states.bunnyhop and hm:GetState() == Enum.HumanoidStateType.Landed then
                hm:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        if states.antiRagdoll then
            for _, v in pairs(mc:GetDescendants()) do
                if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
                    v.Enabled = false
                end
            end
        end
    end

    -- Per-player: ESP / Chams / Hitbox
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local char = p.Character
            local hrp  = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")

            -- Chams / highlight
            local hl = char:FindFirstChild("NexusHL")
            if states.esp or states.chams then
                if not hl then
                    hl = Instance.new("Highlight", char)
                    hl.Name = "NexusHL"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                if states.chams then
                    local idx = getPlayerIndex(p)
                    hl.FillColor = Color3.fromHSV((tick() * 0.08 + idx * 0.18) % 1, 0.75, 1)
                    hl.FillTransparency = 0.22
                    hl.OutlineColor = Color3.new(1, 1, 1)
                else
                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            else
                if hl then hl:Destroy() end
            end

            -- Name / dist / health tags
            if head then
                if states.esp or states.distEsp or states.healthEsp then
                    if not head:FindFirstChild("NexusTag") then createESPTag(char, p) end
                    local tag = head:FindFirstChild("NexusTag")
                    if tag then tag.Enabled = true; refreshESPTag(char, p) end
                else
                    local tag = head:FindFirstChild("NexusTag")
                    if tag then tag.Enabled = false end
                end
            end

            -- Big Hitbox
            if hrp then
                if states.hitbox then
                    hrp.Size = Vector3.new(cfg.hitboxSize, cfg.hitboxSize, cfg.hitboxSize)
                    hrp.Transparency = 0.7
                    hrp.Color = Color3.new(0, 0.5, 1)
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end
            end
        end
    end

    -- Tracers
    if states.tracers and hasDrawing then
        for _, d in pairs(tracerObjs) do pcall(function() d:Destroy() end) end
        tracerObjs = {}
        local origin = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local sp, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local line = Drawing.new("Line")
                        line.Visible = true; line.From = origin
                        line.To = Vector2.new(sp.X, sp.Y)
                        line.Color = Color3.fromRGB(255, 55, 55)
                        line.Thickness = 1.2; line.Transparency = 0.2
                        table.insert(tracerObjs, line)
                    end
                end
            end
        end
    elseif not states.tracers and #tracerObjs > 0 then
        for _, d in pairs(tracerObjs) do pcall(function() d:Destroy() end) end
        tracerObjs = {}
    end

    -- Box ESP
    if states.boxEsp and hasDrawing then
        for _, d in pairs(boxObjs) do pcall(function() d:Destroy() end) end
        boxObjs = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local top    = hrp.Position + Vector3.new(0, 2.5, 0)
                    local bottom = hrp.Position - Vector3.new(0, 2.5, 0)
                    local sp1, os1 = cam:WorldToViewportPoint(top)
                    local sp2, os2 = cam:WorldToViewportPoint(bottom)
                    if os1 and os2 then
                        local h = math.abs(sp1.Y - sp2.Y)
                        local w = h * 0.5
                        local cx = sp1.X
                        local ty = math.min(sp1.Y, sp2.Y)
                        local idx = getPlayerIndex(p)
                        local col = Color3.fromHSV((idx * 0.2) % 1, 0.9, 1)
                        -- Draw 4 lines: top, bottom, left, right
                        local function mkBoxLine(from, to)
                            local ln = Drawing.new("Line")
                            ln.Visible = true; ln.From = from; ln.To = to
                            ln.Color = col; ln.Thickness = 1.5; ln.Transparency = 0.1
                            table.insert(boxObjs, ln)
                        end
                        local x1, y1 = cx - w/2, ty
                        local x2, y2 = cx + w/2, ty + h
                        mkBoxLine(Vector2.new(x1, y1), Vector2.new(x2, y1))
                        mkBoxLine(Vector2.new(x2, y1), Vector2.new(x2, y2))
                        mkBoxLine(Vector2.new(x2, y2), Vector2.new(x1, y2))
                        mkBoxLine(Vector2.new(x1, y2), Vector2.new(x1, y1))
                    end
                end
            end
        end
    elseif not states.boxEsp and #boxObjs > 0 then
        for _, d in pairs(boxObjs) do pcall(function() d:Destroy() end) end
        boxObjs = {}
    end

    -- Minimap update
    if states.minimap and minimapFrame then
        -- Remove old player dots
        for _, c in pairs(minimapFrame:GetChildren()) do
            if c.Name:sub(1, 7) == "PDot_" then c:Destroy() end
        end
        local mc2 = lp.Character
        if mc2 and mc2:FindFirstChild("HumanoidRootPart") then
            local myPos = mc2.HumanoidRootPart.Position
            local scale = cfg.minimapSize / 200  -- 200 studs = full map
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local tPos = p.Character.HumanoidRootPart.Position
                    local rel = tPos - myPos
                    local nx = math.clamp(0.5 + rel.X * scale / cfg.minimapSize, 0.05, 0.95)
                    local ny = math.clamp(0.5 - rel.Z * scale / cfg.minimapSize, 0.05, 0.95)
                    local dot = Instance.new("Frame", minimapFrame)
                    dot.Name = "PDot_" .. p.Name
                    dot.Size = UDim2.new(0, 7, 0, 7)
                    dot.Position = UDim2.new(nx, -3, ny, -3)
                    local idx = getPlayerIndex(p)
                    dot.BackgroundColor3 = Color3.fromHSV((idx * 0.2) % 1, 0.9, 1)
                    dot.BorderSizePixel = 0; dot.ZIndex = 51
                    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                end
            end
        end
    end
end)

table.insert(conns, renderConn)

-- ─────────────────────────────────────────────────────────────────────────────
--  ANTI-AFK
-- ─────────────────────────────────────────────────────────────────────────────
lp.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  CHARACTER RESPAWN
-- ─────────────────────────────────────────────────────────────────────────────
lp.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 10)
    if states.autoRespawn then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.Died:Connect(function()
                task.wait(0.1)
                if states.autoRespawn then
                    lp:LoadCharacter()
                end
            end)
        end
    end
    if states.godMode then
        task.spawn(function()
            while states.godMode do
                local hm = char:FindFirstChild("Humanoid")
                if hm then hm.MaxHealth = math.huge; hm.Health = math.huge end
                task.wait(0.05)
            end
        end)
    end
    if states.fly then states.fly = false end
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  INIT
-- ─────────────────────────────────────────────────────────────────────────────
switchTab("COMBAT")
print("[NEXUS HUB v3.0] Loaded — t.me/zood3llotgk")
print("[NEXUS] PlaceId: " .. game.PlaceId)
