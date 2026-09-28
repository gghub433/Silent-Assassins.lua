local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- Clipboard
if setclipboard then
    setclipboard("https://t.me/zood3llotgk")
    print("Ссылка скопирована в буфер обмена!")
end

-- Cleanup
local old = lp.PlayerGui:FindFirstChild("SilentHitboxHub")
if old then old:Destroy() end

-- === NAME TAG ===
local function createNameTag(char, name)
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    local bgui = Instance.new("BillboardGui", head)
    bgui.Name = "NexusTag"
    bgui.Adornee = head
    bgui.Size = UDim2.new(0, 100, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 3, 0)
    bgui.AlwaysOnTop = true
    local label = Instance.new("TextLabel", bgui)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.5
    return bgui
end

-- === UI ===
local ScreenGui = Instance.new("ScreenGui", lp.PlayerGui)
ScreenGui.Name = "SilentHitboxHub"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 520)
Main.Position = UDim2.new(1, -240, 0.05, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "Silent Assassins: BY NEXUS"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1

-- === STATES ===
local states = {esp=false, speed=false, hitbox=false, killAura=false, autoFarm=false, godMode=false}
local hitboxSize = 15
local killAuraRadius = 20
local autoFarmRadius = 30

-- Button refs for radius label updates
local killAuraBtn, autoFarmBtn

-- Button factory
local function makeBtn(txt, yPos, key, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 196, 0, 36)
    b.Position = UDim2.new(0, 12, 0, yPos)
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        states[key] = not states[key]
        b.BackgroundColor3 = states[key] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(45, 45, 50)
        b.Text = txt .. (states[key] and ": ON" or ": OFF")
        if callback then callback(states[key]) end
    end)
    return b
end

makeBtn("ESP + NICKS", 45, "esp")
makeBtn("SPEED HACK",  86, "speed")
makeBtn("BIG HITBOX", 127, "hitbox")

-- === KILL AURA ===
killAuraBtn = makeBtn("KILL AURA [20m]", 168, "killAura", function(on)
    if on then
        task.spawn(function()
            while states.killAura do
                local myChar = lp.Character
                if myChar then
                    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                    local myHum = myChar:FindFirstChild("Humanoid")
                    if myHrp and myHum and myHum.Health > 0 then
                        local tool = myChar:FindFirstChildOfClass("Tool")
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= lp and p.Character then
                                local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
                                local tHum = p.Character:FindFirstChild("Humanoid")
                                if tHrp and tHum and tHum.Health > 0 then
                                    if (myHrp.Position - tHrp.Position).Magnitude <= killAuraRadius then
                                        local origCF = myHrp.CFrame
                                        myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, -2)
                                        if tool then pcall(function() tool:Activate() end) end
                                        task.wait(0.1)
                                        myHrp.CFrame = origCF
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.15)
            end
        end)
    end
end)

-- === AUTO FARM ===
autoFarmBtn = makeBtn("AUTO FARM [30m]", 209, "autoFarm", function(on)
    if on then
        task.spawn(function()
            while states.autoFarm do
                local myChar = lp.Character
                if myChar then
                    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        local tool = myChar:FindFirstChildOfClass("Tool")
                        local playerChars = {}
                        for _, p in pairs(Players:GetPlayers()) do
                            if p.Character then playerChars[p.Character] = true end
                        end
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("Humanoid") and obj.Health > 0 and not playerChars[obj.Parent] then
                                local npcHrp = obj.Parent:FindFirstChild("HumanoidRootPart")
                                if npcHrp then
                                    if (myHrp.Position - npcHrp.Position).Magnitude <= autoFarmRadius then
                                        local origCF = myHrp.CFrame
                                        myHrp.CFrame = npcHrp.CFrame * CFrame.new(0, 0, -2)
                                        if tool then pcall(function() tool:Activate() end) end
                                        task.wait(0.1)
                                        myHrp.CFrame = origCF
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    end
end)

-- === GOD MODE ===
makeBtn("GOD MODE", 250, "godMode", function(on)
    if on then
        task.spawn(function()
            while states.godMode do
                local myChar = lp.Character
                if myChar then
                    local hum = myChar:FindFirstChild("Humanoid")
                    if hum then
                        hum.MaxHealth = math.huge
                        hum.Health = math.huge
                    end
                end
                task.wait(0.05)
            end
        end)
    end
end)

-- === GET SWORDS (one-shot) ===
local getSwordsBtn = Instance.new("TextButton", Main)
getSwordsBtn.Size = UDim2.new(0, 196, 0, 36)
getSwordsBtn.Position = UDim2.new(0, 12, 0, 291)
getSwordsBtn.Text = "GET SWORDS"
getSwordsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
getSwordsBtn.TextColor3 = Color3.new(1, 1, 1)
getSwordsBtn.Font = Enum.Font.GothamBold
getSwordsBtn.TextSize = 13
Instance.new("UICorner", getSwordsBtn)
getSwordsBtn.MouseButton1Click:Connect(function()
    getSwordsBtn.Text = "GETTING..."
    getSwordsBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 0)
    -- Tools lying in workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Tool") then
                obj.Parent = lp.Backpack
            end
        end)
    end
    -- StarterPack clones
    pcall(function()
        for _, obj in pairs(game:GetService("StarterPack"):GetChildren()) do
            if obj:IsA("Tool") then
                local clone = obj:Clone()
                clone.Parent = lp.Backpack
            end
        end
    end)
    -- ReplicatedStorage clones
    pcall(function()
        for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if obj:IsA("Tool") then
                local clone = obj:Clone()
                clone.Parent = lp.Backpack
            end
        end
    end)
    task.wait(0.4)
    getSwordsBtn.Text = "GET SWORDS ✓"
    getSwordsBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
    task.wait(2)
    getSwordsBtn.Text = "GET SWORDS"
    getSwordsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
end)

-- === RADIUS CONTROLS ===
local function makeRadiusRow(labelText, yLabel, yBtns, getVal, setVal, updateBtnFn)
    local lbl = Instance.new("TextLabel", Main)
    lbl.Size = UDim2.new(0, 196, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, yLabel)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. getVal() .. "m"
    lbl.TextColor3 = Color3.fromRGB(170, 170, 175)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local decBtn = Instance.new("TextButton", Main)
    decBtn.Size = UDim2.new(0, 38, 0, 24)
    decBtn.Position = UDim2.new(0, 12, 0, yBtns)
    decBtn.Text = "−"
    decBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 68)
    decBtn.TextColor3 = Color3.new(1, 1, 1)
    decBtn.Font = Enum.Font.GothamBold
    decBtn.TextSize = 16
    Instance.new("UICorner", decBtn)

    local incBtn = Instance.new("TextButton", Main)
    incBtn.Size = UDim2.new(0, 38, 0, 24)
    incBtn.Position = UDim2.new(0, 54, 0, yBtns)
    incBtn.Text = "+"
    incBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 68)
    incBtn.TextColor3 = Color3.new(1, 1, 1)
    incBtn.Font = Enum.Font.GothamBold
    incBtn.TextSize = 16
    Instance.new("UICorner", incBtn)

    decBtn.MouseButton1Click:Connect(function()
        setVal(math.max(5, getVal() - 5))
        lbl.Text = labelText .. getVal() .. "m"
        updateBtnFn(getVal())
    end)
    incBtn.MouseButton1Click:Connect(function()
        setVal(math.min(200, getVal() + 5))
        lbl.Text = labelText .. getVal() .. "m"
        updateBtnFn(getVal())
    end)
end

makeRadiusRow(
    "Kill Aura Radius: ", 336, 358,
    function() return killAuraRadius end,
    function(v) killAuraRadius = v end,
    function(v)
        killAuraBtn.Text = "KILL AURA [" .. v .. "m]" .. (states.killAura and ": ON" or ": OFF")
    end
)

makeRadiusRow(
    "Auto Farm Radius: ", 390, 412,
    function() return autoFarmRadius end,
    function(v) autoFarmRadius = v end,
    function(v)
        autoFarmBtn.Text = "AUTO FARM [" .. v .. "m]" .. (states.autoFarm and ": ON" or ": OFF")
    end
)

-- === SEPARATOR + LINK ===
local Sep = Instance.new("Frame", Main)
Sep.Size = UDim2.new(0.9, 0, 0, 2)
Sep.Position = UDim2.new(0.05, 0, 0, 448)
Sep.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
Sep.BorderSizePixel = 0

local LinkLabel = Instance.new("TextBox", Main)
LinkLabel.Size = UDim2.new(1, 0, 0, 40)
LinkLabel.Position = UDim2.new(0, 0, 0, 458)
LinkLabel.BackgroundTransparency = 1
LinkLabel.Text = "t.me/zood3llotgk"
LinkLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
LinkLabel.Font = Enum.Font.Gotham
LinkLabel.TextSize = 14
LinkLabel.ClearTextOnFocus = false
LinkLabel.TextEditable = false

-- === RENDER LOOP (ESP / Hitbox / Speed) ===
RunService.RenderStepped:Connect(function()
    if states.speed and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = 28
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local char = p.Character
            local hrp  = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")

            local hl = char:FindFirstChild("Highlight")
            if states.esp then
                if not hl then
                    hl = Instance.new("Highlight", char)
                    hl.FillTransparency = 0.5
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                if head then
                    local tag = head:FindFirstChild("NexusTag")
                    if not tag then
                        createNameTag(char, p.DisplayName or p.Name)
                    else
                        tag.Enabled = true
                    end
                end
            else
                if hl then hl:Destroy() end
                if head and head:FindFirstChild("NexusTag") then
                    head.NexusTag.Enabled = false
                end
            end

            if hrp then
                if states.hitbox then
                    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
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
end)

-- Anti-AFK
lp.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
