-- LOAD SAFE
if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local virtualInput = game:GetService("VirtualInputManager")

-- ESTADOS
local autoEatEnabled = false
local safeModeEnabled = false
local autoCollectEnabled = false
local xrayEnabled = false

-- CACHE
local cachedFossils = {}
local lastScan = 0

-- FUNÇÕES
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHum()
    return getChar():FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    return getChar():FindFirstChild("HumanoidRootPart")
end

local function notify(t)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Zandinho",
            Text = t,
            Duration = 3
        })
    end)
end

-- SCAN OTIMIZADO
local function scanFossils()
    if tick() - lastScan < 5 then return cachedFossils end
    lastScan = tick()

    cachedFossils = {}
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and string.find(string.lower(v.Name),"fossil") then
            table.insert(cachedFossils,v)
        end
    end
    return cachedFossils
end

-- AUTO FARM
task.spawn(function()
    while true do
        task.wait(3)
        if autoCollectEnabled then
            for _,f in pairs(scanFossils()) do
                if f and f.Parent then
                    f:Destroy()
                end
            end
        end
    end
end)

-- AUTO EAT
task.spawn(function()
    while true do
        task.wait(5)
        if autoEatEnabled then
            local h = getHum()
            if h then
                h.Health = h.MaxHealth
                h:SetAttribute("Hunger",100)
                h:SetAttribute("Thirst",100)
            end
        end
    end
end)

-- SAFE MODE
task.spawn(function()
    while true do
        task.wait(1)
        if safeModeEnabled then
            local h = getHum()
            if h and h.Health < h.MaxHealth then
                h.Health = h.MaxHealth
            end
        end
    end
end)

-- X-RAY SIMPLES
local highlights = {}

local function clearXray()
    for _,h in pairs(highlights) do
        if h then h:Destroy() end
    end
    highlights = {}
end

task.spawn(function()
    while true do
        task.wait(2)
        if xrayEnabled then
            clearXray()
            for _,f in pairs(scanFossils()) do
                if f then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(255,140,0)
                    h.Parent = f
                    table.insert(highlights,h)
                end
            end
        else
            clearXray()
        end
    end
end)

-- TELEPORT
local function tpFossil()
    local root = getRoot()
    if not root then return end

    local nearest,dist = nil,math.huge
    for _,f in pairs(scanFossils()) do
        local d = (root.Position - f.Position).Magnitude
        if d < dist then
            dist = d
            nearest = f
        end
    end

    if nearest then
        root.CFrame = nearest.CFrame + Vector3.new(0,3,0)
    else
        notify("Nenhum fóssil")
    end
end

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,220,0,250)
frame.Position = UDim2.new(0.5,-110,0.5,-125)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local function makeBtn(txt,y,func)
    local b = Instance.new("TextButton",frame)
    b.Size = UDim2.new(1,0,0,40)
    b.Position = UDim2.new(0,0,0,y)
    b.Text = txt
    b.MouseButton1Click:Connect(func)
    return b
end

makeBtn("AUTO FARM ❌",0,function(btn)
    autoCollectEnabled = not autoCollectEnabled
    btn.Text = "AUTO FARM "..(autoCollectEnabled and "✅" or "❌")
end)

makeBtn("AUTO EAT ❌",45,function(btn)
    autoEatEnabled = not autoEatEnabled
    btn.Text = "AUTO EAT "..(autoEatEnabled and "✅" or "❌")
end)

makeBtn("SAFE MODE ❌",90,function(btn)
    safeModeEnabled = not safeModeEnabled
    btn.Text = "SAFE MODE "..(safeModeEnabled and "✅" or "❌")
end)

makeBtn("X-RAY ❌",135,function(btn)
    xrayEnabled = not xrayEnabled
    btn.Text = "X-RAY "..(xrayEnabled and "✅" or "❌")
end)

makeBtn("TP FÓSSIL",180,function()
    tpFossil()
end)

notify("Zandinho FULL carregado")
