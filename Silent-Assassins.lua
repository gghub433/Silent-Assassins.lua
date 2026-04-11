local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- === КОПИРОВАНИЕ ССЫЛКИ В БУФЕР ===
-- Эта функция сработает сразу при запуске скрипта
if setclipboard then
    setclipboard("https://t.me/zood3llotgk")
    -- Можно вывести уведомление в консоль (F9)
    print("Ссылка скопирована в буфер обмена!")
end

-- Чистим старое
local old = lp.PlayerGui:FindFirstChild("SilentHitboxHub")
if old then old:Destroy() end

-- === ФУНКЦИЯ ДЛЯ НИКОВ ===
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

-- === ИНТЕРФЕЙС ===
local ScreenGui = Instance.new("ScreenGui", lp.PlayerGui)
ScreenGui.Name = "SilentHitboxHub"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 360) -- Чуть увеличил высоту для ссылки
Main.Position = UDim2.new(1, -240, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Active, Main.Draggable = true, true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Silent Assassins: BY NEXUS"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

-- Состояния
local states = {esp = false, speed = false, hitbox = false}
local hitboxSize = 15 

local function makeBtn(txt, pos, key)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 45)
    b.Position = pos
    b.Text = txt..": OFF"
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        states[key] = not states[key]
        b.BackgroundColor3 = states[key] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(45, 45, 50)
        b.Text = txt..(states[key] and ": ON" or ": OFF")
    end)
end

makeBtn("ESP + NICKS", UDim2.new(0.05, 0, 0.15, 0), "esp")
makeBtn("SPEED HACK", UDim2.new(0.05, 0, 0.30, 0), "speed")
makeBtn("BIG HITBOX", UDim2.new(0.05, 0, 0.45, 0), "hitbox")

-- === РАЗДЕЛИТЕЛЬ (ПАЛКА) ===
local Separator = Instance.new("Frame", Main)
Separator.Size = UDim2.new(0.9, 0, 0, 2)
Separator.Position = UDim2.new(0.05, 0, 0.75, 0) -- Позиция под кнопками
Separator.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
Separator.BorderSizePixel = 0

-- === ССЫЛКА ВНИЗУ ===
local LinkLabel = Instance.new("TextBox", Main) -- Используем TextBox, чтобы можно было выделить текст
LinkLabel.Size = UDim2.new(1, 0, 0, 40)
LinkLabel.Position = UDim2.new(0, 0, 0.82, 0)
LinkLabel.BackgroundTransparency = 1
LinkLabel.Text = "t.me/zood3llotgk"
LinkLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
LinkLabel.Font = Enum.Font.Gotham
LinkLabel.TextSize = 14
LinkLabel.ClearTextOnFocus = false
LinkLabel.TextEditable = false

-- === ЛОГИКА ===
RunService.RenderStepped:Connect(function()
    -- Скорость
    if states.speed and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = 28
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local char = p.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            
            -- ESP + Ники
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

            -- Hitbox
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
