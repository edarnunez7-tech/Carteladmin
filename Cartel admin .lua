
-- CARTEL ADMIN | MENU DE PRUEBAS
-- Para tu propio juego en Roblox Studio

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local gui = Instance.new("ScreenGui")
gui.Name = "CartelAdmin"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280, 245)
frame.Position = UDim2.new(0.5, -140, 0.5, -120)
frame.BackgroundColor3 = Color3.fromRGB(25,25,32)
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -85, 0, 40)
title.BackgroundTransparency = 1
title.Text = "CARTEL ADMIN"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local function makeButton(text, color, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(35, 30)
    b.Position = UDim2.new(1, x, 0, 5)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 18
    b.Parent = frame
    Instance.new("UICorner", b)
    return b
end

local close = makeButton("X",
    Color3.fromRGB(220,45,45), -42)

local minimize = makeButton("-",
    Color3.fromRGB(35,115,220), -82)

local minimized = false

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, obj in ipairs(frame:GetChildren()) do
        if obj ~= title and obj ~= close
            and obj ~= minimize then
            obj.Visible = not minimized
        end
    end
    frame.Size = minimized
        and UDim2.fromOffset(280,40)
        or UDim2.fromOffset(280,245)
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Ventana movible
local dragging = false
local dragStart, startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local function addToggle(name, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,-24,0,42)
    button.Position = UDim2.fromOffset(12,y)
    button.BackgroundColor3 = Color3.fromRGB(55,55,68)
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = frame
    Instance.new("UICorner",button)

    local enabled = false

    local function update()
        button.Text = name .. " : " ..
            (enabled and "ON" or "OFF")
        button.BackgroundColor3 = enabled
            and Color3.fromRGB(35,145,85)
            or Color3.fromRGB(55,55,68)
        callback(enabled)
    end

    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        update()
    end)

    update()
end

local godMode = false
local aimbot = false
local esp = false

addToggle("GOD MODE",50,function(v)
    godMode = v
end)

addToggle("AIMBOT PRACTICA",100,function(v)
    aimbot = v
end)

addToggle("ESP JUGADORES",150,function(v)
    esp = v
end)

-- God Mode de entrenamiento:
-- Solo desactiva el daño de un sistema de prueba
-- que respete este atributo.
player:SetAttribute("TrainingGodMode", false)

local function updateGod()
    player:SetAttribute("TrainingGodMode", godMode)
end

-- ESP visual para jugadores
local highlights = {}

local function clearESP()
    for _, h in pairs(highlights) do
        h:Destroy()
    end
    table.clear(highlights)
end

RunService.RenderStepped:Connect(function()
    updateGod()

    if not esp then
        clearESP()
        return
    end

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player and target.Character
            and not highlights[target] then

            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(255,60,60)
            h.OutlineColor = Color3.new(1,1,1)
            h.Adornee = target.Character
            h.Parent = gui
            highlights[target] = h
        end
    end

    for target, h in pairs(highlights) do
        if not target.Parent or not target.Character
            or h.Adornee ~= target.Character then
            h:Destroy()
            highlights[target] = nil
        end
    end
end)

-- Aimbot: modo de práctica no automático.
-- Activa una indicación visual al apuntar.
local practiceLabel = Instance.new("TextLabel")
practiceLabel.Size = UDim2.fromOffset(210,30)
practiceLabel.Position = UDim2.new(0.5,-105,0.8,0)
practiceLabel.BackgroundTransparency = 1
practiceLabel.TextColor3 = Color3.new(1,1,0)
practiceLabel.Text = "MODO DE PRACTICA"
practiceLabel.Visible = false
practiceLabel.Parent = gui

RunService.RenderStepped:Connect(function()
    practiceLabel.Visible = aimbot
end)
