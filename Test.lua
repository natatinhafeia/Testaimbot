local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local AimbotEnabled = true
local ESPEnabled = true
local TargetPlayer = nil
local AimbotSmoothing = 0.1  -- Controla o nível de suavização (0 = instantâneo, 1 = muito suave)

-- Função para desenhar o ESP (caixa ao redor do alvo)
local function DrawESP(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local screenPosition, onScreen = Camera:WorldToScreenPoint(rootPart.Position)
        if onScreen then
            -- Criar um quadrado para o ESP
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 50, 0, 50)
            box.Position = UDim2.new(0, screenPosition.X - 25, 0, screenPosition.Y - 25)
            box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Vermelho
            box.BackgroundTransparency = 0.7  -- Transparente
            box.BorderSizePixel = 2
            box.Parent = game.CoreGui

            -- Remover o ESP após um tempo
            game:GetService("Debris"):AddItem(box, 0.1)
        end
    end
end

-- Função para encontrar o melhor alvo (puxando a mira para a cabeça)
local function FindTarget()
    local closestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = player.Character:FindFirstChild("Head")  -- Mira para a cabeça
            if target then
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    TargetPlayer = player
                end
            end
        end
    end
end

-- Função de Aimbot para puxar a mira com suavização
local function Aimbot()
    if AimbotEnabled and TargetPlayer and TargetPlayer.Character then
        local target = TargetPlayer.Character:FindFirstChild("Head")  -- Foca na cabeça
        if target then
            local targetPosition = target.Position
            local cameraPosition = Camera.CFrame.Position
            local direction = (targetPosition - cameraPosition).unit
            local smoothedPosition = cameraPosition + direction * AimbotSmoothing  -- Suaviza o movimento

            Camera.CFrame = CFrame.new(cameraPosition, smoothedPosition)  -- Atualiza a posição da câmera
        end
    end
end

-- Função para criar a GUI do Aimbot e ESP
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainFrame.BackgroundTransparency = 0.5
    mainFrame.Parent = ScreenGui

    -- Barra superior para arrastar
    local dragBar = Instance.new("Frame")
    dragBar.Size = UDim2.new(1, 0, 0, 20)
    dragBar.Position = UDim2.new(0, 0, 0, 0)
    dragBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    dragBar.Parent = mainFrame

    -- Botão Aimbot
    local aimbotButton = Instance.new("TextButton")
    aimbotButton.Size = UDim2.new(0, 180, 0, 50)
    aimbotButton.Position = UDim2.new(0, 10, 0, 30)
    aimbotButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    aimbotButton.Text = "Toggle Aimbot"
    aimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotButton.TextSize = 18
    aimbotButton.Parent = mainFrame
    aimbotButton.MouseButton1Click:Connect(function()
        AimbotEnabled = not AimbotEnabled
        aimbotButton.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    -- Botão ESP
    local espButton = Instance.new("TextButton")
    espButton.Size = UDim2.new(0, 180, 0, 50)
    espButton.Position = UDim2.new(0, 10, 0, 90)
    espButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    espButton.Text = "Toggle ESP"
    espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    espButton.TextSize = 18
    espButton.Parent = mainFrame
    espButton.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        espButton.BackgroundColor3 = ESPEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    -- Função de mover a GUI
    local dragging = false
    local dragInput, dragStart, startPos
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    dragBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    dragBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Chama a função para criar a GUI
CreateGUI()

-- Loop para encontrar o alvo e ativar o Aimbot e ESP
while true do
    wait(0.1)
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                DrawESP(player)
            end
        end
    end
    FindTarget()
    Aimbot()
end
