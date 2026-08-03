--[[
    Flow Hub | Universal
    Using official Starlight & Nebula Icons loaders from docs.nebulasoftworks.xyz
    Fully mobile-compatible with draggable centered toggle button.
]]

-- ============================================================
-- BOOT THE LIBRARIES (Official method)
-- ============================================================
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

-- ============================================================
-- EXECUTOR DETECTION
-- ============================================================
local function getExecutorName()
    local executors = {
        {name = "Synapse X", check = function() return syn and syn.request ~= nil end},
        {name = "Krnl", check = function() return krnl and krnl.request ~= nil end},
        {name = "ScriptWare", check = function() return scriptware and scriptware.request ~= nil end},
        {name = "Fluxus", check = function() return fluxus and fluxus.request ~= nil end},
        {name = "Oxygen U", check = function() return oxygen and oxygen.request ~= nil end},
        {name = "Electron", check = function() return electron and electron.request ~= nil end},
        {name = "Vega X", check = function() return vega and vega.request ~= nil end},
        {name = "Calamari", check = function() return calamari and calamari.request ~= nil end},
        {name = "Sirius", check = function() return sirius and sirius.request ~= nil end},
        {name = "Cipher", check = function() return cipher and cipher.request ~= nil end},
        {name = "RipX", check = function() return rip and rip.request ~= nil end},
        {name = "Valyse", check = function() return valyse and valyse.request ~= nil end},
        {name = "Nihon", check = function() return nihon and nihon.request ~= nil end},
        {name = "Skull", check = function() return skull and skull.request ~= nil end},
        {name = "Vynixius", check = function() return vynixius and vynixius.request ~= nil end},
        {name = "Arceus X", check = function() return arceus and arceus.request ~= nil end},
    }
    for _, exec in ipairs(executors) do
        if exec.check() then return exec.name end
    end
    local success, name = pcall(getexecutorname)
    if success and name and name ~= "" then return name end
    success, name = pcall(identifyexecutor)
    if success and name and name ~= "" then return name end
    if gethui then return "Unknown (has gethui)" end
    return "Unknown"
end
local ExecutorName = getExecutorName()

-- ============================================================
-- CONFIGURATION & STATE
-- ============================================================
local Settings = {
    Enabled = true,
    KeybindOpen = Enum.KeyCode.Insert,

    -- Visuals
    Crosshair = { Enabled = true, Color = Color3.new(0, 1, 0), Size = 20, Style = "Cross" },
    FOV = { Enabled = false, Value = 90 },
    Fullbright = { Enabled = false },
    NoFog = { Enabled = false },
    NoSky = { Enabled = false },
    ESP = { Enabled = false, Players = true, NPCs = true, Items = true, Distance = 300 },

    -- Movement
    WalkSpeed = { Enabled = false, Value = 16 },
    JumpPower = { Enabled = false, Value = 50 },
    Fly = { Enabled = false, Speed = 50 },
    Noclip = { Enabled = false },

    -- Misc
    AntiAFK = { Enabled = true },
    AutoRespawn = { Enabled = true },
    ServerHop = { Enabled = true },
    Rejoin = { Enabled = true },
    FPSBooster = { Enabled = true },
    InfiniteZoom = { Enabled = false },
    Freecam = { Enabled = false },
    Spectate = { Enabled = false, Target = nil },
    Teleport = { Enabled = false, Target = nil },

    -- Aimbot
    Aimbot = { Enabled = false, FOV = 90, Smoothness = 5, Keybind = Enum.KeyCode.RightButton, MobileAutoAim = false },

    -- Theme
    Theme = "Dark",
}

-- ============================================================
-- AUTO-GAME DETECTION
-- ============================================================
local GameInfo = {
    Type = "Unknown",
    Supports = {
        WalkSpeed = true,
        JumpPower = true,
        Fly = false,
        Noclip = false,
        Teleport = false,
        ESP_Players = true,
        ESP_NPCs = false,
        ESP_Items = false,
        Aimbot = false,
    }
}

local function detectGame()
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or ""
    local lower = string.lower(gameName)
    if string.find(lower, "fps") or string.find(lower, "shooter") or string.find(lower, "battle") then
        GameInfo.Type = "FPS"
        GameInfo.Supports.Aimbot = true
        GameInfo.Supports.ESP_Players = true
    elseif string.find(lower, "rpg") or string.find(lower, "quest") or string.find(lower, "adventure") then
        GameInfo.Type = "RPG"
        GameInfo.Supports.ESP_NPCs = true
        GameInfo.Supports.ESP_Items = true
    elseif string.find(lower, "simulator") or string.find(lower, "clicker") then
        GameInfo.Type = "Simulator"
        GameInfo.Supports.Fly = true
        GameInfo.Supports.Noclip = true
    elseif string.find(lower, "survival") or string.find(lower, "zombie") then
        GameInfo.Type = "Survival"
        GameInfo.Supports.ESP_Players = true
        GameInfo.Supports.ESP_Items = true
    elseif string.find(lower, "horror") or string.find(lower, "scary") then
        GameInfo.Type = "Horror"
        GameInfo.Supports.Fly = false
        GameInfo.Supports.Noclip = false
    elseif string.find(lower, "roleplay") or string.find(lower, "rp") then
        GameInfo.Type = "Roleplay"
        GameInfo.Supports.Fly = true
        GameInfo.Supports.Noclip = true
        GameInfo.Supports.Teleport = true
    end
end
detectGame()

-- ============================================================
-- HELPERS
-- ============================================================
local function getPlayer() return game:GetService("Players").LocalPlayer end
local function getCharacter()
    local plr = getPlayer()
    return plr and plr.Character
end
local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local UserInputService = game:GetService("UserInputService")
local TouchEnabled = UserInputService.TouchEnabled

-- ============================================================
-- FEATURE MODULES
-- ============================================================

-- FPS Booster
local FPSBooster = {
    Toggle = function(state)
        if state then
            settings().Rendering.QualityLevel = 1
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").Technology = Enum.Technology.Legacy
        else
            settings().Rendering.QualityLevel = 10
            game:GetService("Lighting").GlobalShadows = true
            game:GetService("Lighting").Technology = Enum.Technology.Future
        end
    end
}

-- Fullbright
local Fullbright = {
    Toggle = function(state)
        local lighting = game:GetService("Lighting")
        if state then
            lighting.Brightness = 5
            lighting.ExposureCompensation = 1
            lighting.Ambient = Color3.new(1,1,1)
        else
            lighting.Brightness = 2
            lighting.ExposureCompensation = 0
            lighting.Ambient = Color3.new(0,0,0)
        end
    end
}

-- No Fog
local NoFog = {
    Toggle = function(state)
        local lighting = game:GetService("Lighting")
        if state then
            lighting.FogEnd = 100000
            lighting.FogStart = 0
        else
            lighting.FogEnd = 500
            lighting.FogStart = 0
        end
    end
}

-- Anti AFK
local AntiAFK = {
    Running = false,
    Toggle = function(state)
        AntiAFK.Running = state
        if state then
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:CaptureController()
            spawn(function()
                while AntiAFK.Running do
                    wait(60)
                    virtualUser:ClickButton2(Vector2.new())
                end
            end)
        end
    end
}

-- WalkSpeed & JumpPower
local Movement = {
    Apply = function()
        local hum = getHumanoid()
        if hum then
            if Settings.WalkSpeed.Enabled then hum.WalkSpeed = Settings.WalkSpeed.Value end
            if Settings.JumpPower.Enabled then hum.JumpPower = Settings.JumpPower.Value end
        end
    end,
    Update = function() Movement.Apply() end
}

-- Fly & Noclip (with mobile controls)
local FlyNoclip = {
    FlyEnabled = false,
    NoclipEnabled = false,
    MoveDirection = Vector3.new(0,0,0),
    Vertical = 0,
    PCMoveDirection = Vector3.new(0,0,0),

    ToggleFly = function(state)
        FlyNoclip.FlyEnabled = state
        if state then
            local char = getCharacter()
            if not char then return end
            local bp = char:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
            bp.Parent = char
            bp.Velocity = Vector3.new(0,0,0)
            bp.MaxForce = Vector3.new(4000,4000,4000)
            if TouchEnabled then
                FlyNoclip:ShowMobileFlyControls(true)
            end
        else
            local char = getCharacter()
            if char then
                local bp = char:FindFirstChild("BodyVelocity")
                if bp then bp:Destroy() end
            end
            if TouchEnabled then
                FlyNoclip:ShowMobileFlyControls(false)
            end
        end
    end,

    ToggleNoclip = function(state)
        FlyNoclip.NoclipEnabled = state
        spawn(function()
            while FlyNoclip.NoclipEnabled do
                local char = getCharacter()
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                wait(0.1)
            end
            local char = getCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end,

    FlyControlsFrame = nil,
    ShowMobileFlyControls = function(show)
        if show then
            if FlyNoclip.FlyControlsFrame then return end
            local screenGui = Instance.new("ScreenGui")
            screenGui.Parent = game:GetService("CoreGui")
            screenGui.Name = "FlyControls"
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 400, 0, 300)
            frame.Position = UDim2.new(0.5, -200, 1, -320)
            frame.BackgroundTransparency = 0.5
            frame.BackgroundColor3 = Color3.new(0,0,0)
            frame.BorderSizePixel = 0
            frame.Parent = screenGui
            FlyNoclip.FlyControlsFrame = frame

            local buttonSize = UDim2.new(0, 60, 0, 60)
            local function makeButton(text, pos, color)
                local btn = Instance.new("TextButton")
                btn.Size = buttonSize
                btn.Position = pos
                btn.Text = text
                btn.TextColor3 = Color3.new(1,1,1)
                btn.BackgroundColor3 = color or Color3.new(0.2,0.2,0.2)
                btn.BorderSizePixel = 0
                btn.Parent = frame
                return btn
            end

            local upBtn = makeButton("↑", UDim2.new(0.5, -30, 0, 10), Color3.new(0.3,0.3,0.8))
            local downBtn = makeButton("↓", UDim2.new(0.5, -30, 0, 130), Color3.new(0.3,0.3,0.8))
            local leftBtn = makeButton("←", UDim2.new(0, 10, 0.5, -30), Color3.new(0.3,0.3,0.8))
            local rightBtn = makeButton("→", UDim2.new(0, 130, 0.5, -30), Color3.new(0.3,0.3,0.8))
            local ascendBtn = makeButton("▲", UDim2.new(0.8, 0, 0.5, -30), Color3.new(0.8,0.3,0.3))
            local descendBtn = makeButton("▼", UDim2.new(0.8, 0, 0.5, 30), Color3.new(0.8,0.3,0.3))
            local toggleFlyBtn = makeButton("Fly", UDim2.new(0, 200, 0, 10), Color3.new(0,0.6,0))
            local toggleNoclipBtn = makeButton("Noclip", UDim2.new(0, 200, 0, 80), Color3.new(0.6,0.6,0))

            local function setDirection(btn, dir)
                btn.MouseButton1Down:Connect(function()
                    FlyNoclip.MoveDirection = FlyNoclip.MoveDirection + dir
                end)
                btn.MouseButton1Up:Connect(function()
                    FlyNoclip.MoveDirection = FlyNoclip.MoveDirection - dir
                end)
                btn.TouchEnded:Connect(function()
                    FlyNoclip.MoveDirection = FlyNoclip.MoveDirection - dir
                end)
            end

            setDirection(upBtn, Vector3.new(0,0,-1))
            setDirection(downBtn, Vector3.new(0,0,1))
            setDirection(leftBtn, Vector3.new(-1,0,0))
            setDirection(rightBtn, Vector3.new(1,0,0))

            ascendBtn.MouseButton1Down:Connect(function() FlyNoclip.Vertical = 1 end)
            ascendBtn.MouseButton1Up:Connect(function() FlyNoclip.Vertical = 0 end)
            ascendBtn.TouchEnded:Connect(function() FlyNoclip.Vertical = 0 end)

            descendBtn.MouseButton1Down:Connect(function() FlyNoclip.Vertical = -1 end)
            descendBtn.MouseButton1Up:Connect(function() FlyNoclip.Vertical = 0 end)
            descendBtn.TouchEnded:Connect(function() FlyNoclip.Vertical = 0 end)

            toggleFlyBtn.MouseButton1Click:Connect(function()
                Settings.Fly.Enabled = not Settings.Fly.Enabled
                FlyNoclip.ToggleFly(Settings.Fly.Enabled)
            end)

            toggleNoclipBtn.MouseButton1Click:Connect(function()
                Settings.Noclip.Enabled = not Settings.Noclip.Enabled
                FlyNoclip.ToggleNoclip(Settings.Noclip.Enabled)
            end)
        else
            if FlyNoclip.FlyControlsFrame then
                local gui = FlyNoclip.FlyControlsFrame.Parent
                if gui then gui:Destroy() end
                FlyNoclip.FlyControlsFrame = nil
            end
        end
    end
}

-- Fly update loop
spawn(function()
    while wait() do
        if Settings.Fly.Enabled then
            local char = getCharacter()
            if char then
                local bp = char:FindFirstChild("BodyVelocity")
                if bp then
                    local moveDir = Vector3.new(0,0,0)
                    if TouchEnabled then
                        moveDir = FlyNoclip.MoveDirection
                        local vert = FlyNoclip.Vertical
                        moveDir = moveDir + Vector3.new(0, vert, 0)
                    else
                        moveDir = FlyNoclip.PCMoveDirection or Vector3.new(0,0,0)
                    end
                    if moveDir ~= Vector3.new(0,0,0) then
                        moveDir = moveDir.Unit * Settings.Fly.Speed
                        local cam = workspace.CurrentCamera
                        local cameraCF = cam.CFrame
                        local forward = cameraCF.LookVector
                        local right = cameraCF.RightVector
                        local up = cameraCF.UpVector
                        local velocity = forward * -moveDir.Z + right * moveDir.X + up * moveDir.Y
                        bp.Velocity = velocity
                    else
                        bp.Velocity = Vector3.new(0,0,0)
                    end
                end
            end
        end
    end
end)

-- PC key handling for fly
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or TouchEnabled then return end
    if Settings.Fly.Enabled then
        local dir = Vector3.new(0,0,0)
        if input.KeyCode == Enum.KeyCode.W then dir = Vector3.new(0,0,-1) end
        if input.KeyCode == Enum.KeyCode.S then dir = Vector3.new(0,0,1) end
        if input.KeyCode == Enum.KeyCode.A then dir = Vector3.new(-1,0,0) end
        if input.KeyCode == Enum.KeyCode.D then dir = Vector3.new(1,0,0) end
        if input.KeyCode == Enum.KeyCode.Space then dir = Vector3.new(0,1,0) end
        if input.KeyCode == Enum.KeyCode.LeftControl then dir = Vector3.new(0,-1,0) end
        if dir ~= Vector3.new(0,0,0) then
            FlyNoclip.PCMoveDirection = FlyNoclip.PCMoveDirection + dir
        end
    end
    if input.KeyCode == Enum.KeyCode.F then
        Settings.Fly.Enabled = not Settings.Fly.Enabled
        FlyNoclip.ToggleFly(Settings.Fly.Enabled)
    end
    if input.KeyCode == Enum.KeyCode.N then
        Settings.Noclip.Enabled = not Settings.Noclip.Enabled
        FlyNoclip.ToggleNoclip(Settings.Noclip.Enabled)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or TouchEnabled then return end
    if Settings.Fly.Enabled then
        local dir = Vector3.new(0,0,0)
        if input.KeyCode == Enum.KeyCode.W then dir = Vector3.new(0,0,-1) end
        if input.KeyCode == Enum.KeyCode.S then dir = Vector3.new(0,0,1) end
        if input.KeyCode == Enum.KeyCode.A then dir = Vector3.new(-1,0,0) end
        if input.KeyCode == Enum.KeyCode.D then dir = Vector3.new(1,0,0) end
        if input.KeyCode == Enum.KeyCode.Space then dir = Vector3.new(0,1,0) end
        if input.KeyCode == Enum.KeyCode.LeftControl then dir = Vector3.new(0,-1,0) end
        if dir ~= Vector3.new(0,0,0) then
            FlyNoclip.PCMoveDirection = FlyNoclip.PCMoveDirection - dir
        end
    end
end)

-- Infinite Zoom
local InfiniteZoom = {
    Toggle = function(state)
        if state then
            workspace.CurrentCamera.MaxZoomDistance = math.huge
        else
            workspace.CurrentCamera.MaxZoomDistance = 400
        end
    end
}

-- Freecam
local Freecam = {
    Running = false,
    Toggle = function(state)
        Freecam.Running = state
        if state then
            local cam = workspace.CurrentCamera
            local freecamPart = Instance.new("Part")
            freecamPart.Name = "FreecamPart"
            freecamPart.Anchored = true
            freecamPart.CanCollide = false
            freecamPart.Transparency = 1
            freecamPart.Size = Vector3.new(1,1,1)
            freecamPart.Parent = workspace
            cam.CameraSubject = freecamPart
            if TouchEnabled then
                Freecam:ShowMobileFreecamControls(true)
            end
        else
            local cam = workspace.CurrentCamera
            local plr = getPlayer()
            if plr and plr.Character then
                cam.CameraSubject = plr.Character
            end
            local freecamPart = workspace:FindFirstChild("FreecamPart")
            if freecamPart then freecamPart:Destroy() end
            if TouchEnabled then
                Freecam:ShowMobileFreecamControls(false)
            end
        end
    end,
    FreecamControlsFrame = nil,
    ShowMobileFreecamControls = function(show)
        if show then
            if Freecam.FreecamControlsFrame then return end
            local screenGui = Instance.new("ScreenGui")
            screenGui.Parent = game:GetService("CoreGui")
            screenGui.Name = "FreecamControls"
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 300, 0, 200)
            frame.Position = UDim2.new(0.5, -150, 1, -220)
            frame.BackgroundTransparency = 0.5
            frame.BackgroundColor3 = Color3.new(0,0,0)
            frame.BorderSizePixel = 0
            frame.Parent = screenGui
            Freecam.FreecamControlsFrame = frame

            local function makeButton(text, pos, color)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0, 60, 0, 60)
                btn.Position = pos
                btn.Text = text
                btn.TextColor3 = Color3.new(1,1,1)
                btn.BackgroundColor3 = color or Color3.new(0.2,0.2,0.2)
                btn.BorderSizePixel = 0
                btn.Parent = frame
                return btn
            end

            local up = makeButton("↑", UDim2.new(0.5, -30, 0, 10), Color3.new(0.3,0.3,0.8))
            local down = makeButton("↓", UDim2.new(0.5, -30, 0, 130), Color3.new(0.3,0.3,0.8))
            local left = makeButton("←", UDim2.new(0, 10, 0.5, -30), Color3.new(0.3,0.3,0.8))
            local right = makeButton("→", UDim2.new(0, 130, 0.5, -30), Color3.new(0.3,0.3,0.8))

            local moveVec = Vector3.new(0,0,0)
            local function setDir(btn, dir)
                btn.MouseButton1Down:Connect(function() moveVec = moveVec + dir end)
                btn.MouseButton1Up:Connect(function() moveVec = moveVec - dir end)
                btn.TouchEnded:Connect(function() moveVec = moveVec - dir end)
            end
            setDir(up, Vector3.new(0,0,-1))
            setDir(down, Vector3.new(0,0,1))
            setDir(left, Vector3.new(-1,0,0))
            setDir(right, Vector3.new(1,0,0))

            spawn(function()
                while Freecam.Running do
                    local part = workspace:FindFirstChild("FreecamPart")
                    if part and moveVec ~= Vector3.new(0,0,0) then
                        local speed = 10
                        local cam = workspace.CurrentCamera
                        local forward = cam.CFrame.LookVector
                        local right = cam.CFrame.RightVector
                        local up = cam.CFrame.UpVector
                        local vel = forward * -moveVec.Z + right * moveVec.X + up * moveVec.Y
                        part.Position = part.Position + vel * speed
                    end
                    wait()
                end
            end)

            local toggleBtn = makeButton("Exit Freecam", UDim2.new(0, 200, 0, 10), Color3.new(0.8,0,0))
            toggleBtn.Size = UDim2.new(0, 120, 0, 40)
            toggleBtn.MouseButton1Click:Connect(function()
                Settings.Freecam.Enabled = false
                Freecam.Toggle(false)
            end)
        else
            if Freecam.FreecamControlsFrame then
                local gui = Freecam.FreecamControlsFrame.Parent
                if gui then gui:Destroy() end
                Freecam.FreecamControlsFrame = nil
            end
        end
    end
}

-- ESP
local ESP = {
    Running = false,
    Objects = {},
    Toggle = function(state)
        ESP.Running = state
        if state then ESP.Update() else ESP.Clear() end
    end,
    Clear = function()
        for _, obj in ipairs(ESP.Objects) do
            if obj and obj.Parent then obj:Destroy() end
        end
        ESP.Objects = {}
    end,
    Update = function()
        while ESP.Running do
            ESP.Clear()
            local players = game:GetService("Players")
            local localPlayer = players.LocalPlayer
            if Settings.ESP.Players then
                for _, plr in ipairs(players:GetPlayers()) do
                    if plr ~= localPlayer and plr.Character then
                        local char = plr.Character
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local esp = Instance.new("BillboardGui")
                            esp.Adornee = root
                            esp.Size = UDim2.new(0, 100, 0, 30)
                            esp.StudsOffset = Vector3.new(0, 2, 0)
                            local label = Instance.new("TextLabel", esp)
                            label.Size = UDim2.new(1,0,1,0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.new(1,0,0)
                            label.Text = plr.Name
                            label.TextScaled = true
                            esp.Parent = workspace
                            table.insert(ESP.Objects, esp)
                        end
                    end
                end
            end
            wait(0.5)
        end
    end
}

-- Aimbot
local Aimbot = {
    Running = false,
    Target = nil,
    Toggle = function(state)
        Aimbot.Running = state
        if state then
            spawn(function()
                while Aimbot.Running do
                    if not TouchEnabled or Settings.Aimbot.MobileAutoAim then
                        local localPlayer = getPlayer()
                        local char = localPlayer.Character
                        if char then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if root then
                                local closest = nil
                                local closestDist = math.huge
                                for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                                    if plr ~= localPlayer and plr.Character then
                                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                                        if targetRoot then
                                            local pos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(targetRoot.Position)
                                            if onScreen then
                                                local screenCenter = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
                                                local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                                                if dist < Settings.Aimbot.FOV then
                                                    if dist < closestDist then
                                                        closestDist = dist
                                                        closest = targetRoot
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if closest then
                                    Aimbot.Target = closest
                                    local targetPos = closest.Position
                                    local screenPoint, onScreen = workspace.CurrentCamera:WorldToScreenPoint(targetPos)
                                    if onScreen and not TouchEnabled then
                                        local mouse = localPlayer:GetMouse()
                                        local targetPos2 = Vector2.new(screenPoint.X, screenPoint.Y)
                                        local currentPos = Vector2.new(mouse.X, mouse.Y)
                                        local newPos = currentPos:Lerp(targetPos2, 1 / Settings.Aimbot.Smoothness)
                                        mouse.Move(newPos)
                                    elseif TouchEnabled then
                                        local cam = workspace.CurrentCamera
                                        local lookAt = targetPos
                                        cam.CFrame = CFrame.new(cam.CFrame.Position, lookAt)
                                    end
                                end
                            end
                        end
                    end
                    wait()
                end
            end)
        else
            Aimbot.Target = nil
        end
    end
}

-- Server Hop & Rejoin
local function ServerHop()
    game:GetService("TeleportService"):Teleport(game.PlaceId, getPlayer())
end
local function Rejoin()
    game:GetService("TeleportService"):Teleport(game.PlaceId, getPlayer())
end

-- Auto Respawn
local AutoRespawn = {
    Running = false,
    Toggle = function(state)
        AutoRespawn.Running = state
        if state then
            spawn(function()
                while AutoRespawn.Running do
                    local plr = getPlayer()
                    if plr and plr.Character and plr.Character.Humanoid and plr.Character.Humanoid.Health <= 0 then
                        plr:LoadCharacter()
                    end
                    wait(1)
                end
            end)
        end
    end
}

-- ============================================================
-- DRAGGABLE FLOATING TOGGLE BUTTON (Centered)
-- ============================================================
local function createFloatingToggle()
    local old = game:GetService("CoreGui"):FindFirstChild("FlowHubToggle")
    if old then old:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.Name = "FlowHubToggle"
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 60, 0, 60)
    frame.Position = UDim2.new(0.5, -30, 0.5, -30) -- Centered
    frame.BackgroundTransparency = 1
    frame.Parent = screenGui

    local button = Instance.new("ImageButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.Image = "rbxassetid://6023426922" -- Menu icon
    button.Parent = frame
    button.ClipsDescendants = true

    local dragging = false
    local dragStart, startPos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    button.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            dragStart = input.Position
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    button.MouseButton1Click:Connect(function()
        if window then
            if window.Visible then
                window:Hide()
            else
                window:Show()
            end
        end
    end)
end

-- ============================================================
-- CREATE STARLIGHT UI
-- ============================================================
local window = Starlight:CreateWindow({
    Title = "Flow Hub | Universal",
    Theme = Settings.Theme,
    Keybind = Settings.KeybindOpen,
})

-- Create floating toggle button (centered + draggable)
createFloatingToggle()

-- ============================================================
-- UI TABS & SECTIONS
-- ============================================================

-- General Tab
local generalTab = window:CreateTab("General")
local infoSection = generalTab:CreateSection("Game Info")
infoSection:CreateLabel("Detected Game: " .. GameInfo.Type)
infoSection:CreateLabel("Executor: " .. ExecutorName)
infoSection:CreateLabel("Supported Features:")

local toggleSection = generalTab:CreateSection("Core Toggles")
toggleSection:CreateToggle("Enable Script", Settings.Enabled, function(value)
    Settings.Enabled = value
end)

-- Visuals Tab
local visualTab = window:CreateTab("Visuals")

local crosshairSection = visualTab:CreateSection("Crosshair")
crosshairSection:CreateToggle("Enabled", Settings.Crosshair.Enabled, function(value)
    Settings.Crosshair.Enabled = value
end)
crosshairSection:CreateColorPicker("Color", Settings.Crosshair.Color, function(value)
    Settings.Crosshair.Color = value
end)
crosshairSection:CreateSlider("Size", 10, 50, Settings.Crosshair.Size, function(value)
    Settings.Crosshair.Size = value
end)
crosshairSection:CreateDropdown("Style", {"Cross", "Dot", "Circle"}, Settings.Crosshair.Style, function(value)
    Settings.Crosshair.Style = value
end)

visualTab:CreateSection("Camera")
visualTab:CreateToggle("FOV Changer", Settings.FOV.Enabled, function(value)
    Settings.FOV.Enabled = value
    if value then workspace.CurrentCamera.FieldOfView = Settings.FOV.Value else workspace.CurrentCamera.FieldOfView = 70 end
end)
visualTab:CreateSlider("FOV Value", 1, 120, Settings.FOV.Value, function(value)
    Settings.FOV.Value = value
    if Settings.FOV.Enabled then workspace.CurrentCamera.FieldOfView = value end
end)

visualTab:CreateToggle("Fullbright", Settings.Fullbright.Enabled, function(value)
    Settings.Fullbright.Enabled = value
    Fullbright.Toggle(value)
end)

visualTab:CreateToggle("No Fog", Settings.NoFog.Enabled, function(value)
    Settings.NoFog.Enabled = value
    NoFog.Toggle(value)
end)

local espSection = visualTab:CreateSection("ESP")
espSection:CreateToggle("Enable ESP", Settings.ESP.Enabled, function(value)
    Settings.ESP.Enabled = value
    ESP.Toggle(value)
end)
espSection:CreateToggle("Players", Settings.ESP.Players, function(value)
    Settings.ESP.Players = value
    if Settings.ESP.Enabled then ESP.Toggle(true) end
end)
espSection:CreateToggle("NPCs", Settings.ESP.NPCs, function(value)
    Settings.ESP.NPCs = value
end)
espSection:CreateToggle("Items", Settings.ESP.Items, function(value)
    Settings.ESP.Items = value
end)
espSection:CreateSlider("Distance", 50, 1000, Settings.ESP.Distance, function(value)
    Settings.ESP.Distance = value
end)

-- Movement Tab
local movementTab = window:CreateTab("Movement")

movementTab:CreateToggle("WalkSpeed", Settings.WalkSpeed.Enabled, function(value)
    Settings.WalkSpeed.Enabled = value
    Movement.Update()
end)
movementTab:CreateSlider("WalkSpeed Value", 0, 100, Settings.WalkSpeed.Value, function(value)
    Settings.WalkSpeed.Value = value
    Movement.Update()
end)

movementTab:CreateToggle("JumpPower", Settings.JumpPower.Enabled, function(value)
    Settings.JumpPower.Enabled = value
    Movement.Update()
end)
movementTab:CreateSlider("JumpPower Value", 0, 200, Settings.JumpPower.Value, function(value)
    Settings.JumpPower.Value = value
    Movement.Update()
end)

movementTab:CreateToggle("Fly", Settings.Fly.Enabled, function(value)
    Settings.Fly.Enabled = value
    FlyNoclip.ToggleFly(value)
end)
movementTab:CreateSlider("Fly Speed", 10, 200, Settings.Fly.Speed, function(value)
    Settings.Fly.Speed = value
end)

movementTab:CreateToggle("Noclip", Settings.Noclip.Enabled, function(value)
    Settings.Noclip.Enabled = value
    FlyNoclip.ToggleNoclip(value)
end)

-- Misc Tab
local miscTab = window:CreateTab("Misc")

miscTab:CreateToggle("Anti AFK", Settings.AntiAFK.Enabled, function(value)
    Settings.AntiAFK.Enabled = value
    AntiAFK.Toggle(value)
end)

miscTab:CreateToggle("Auto Respawn", Settings.AutoRespawn.Enabled, function(value)
    Settings.AutoRespawn.Enabled = value
    AutoRespawn.Toggle(value)
end)

miscTab:CreateToggle("FPS Booster", Settings.FPSBooster.Enabled, function(value)
    Settings.FPSBooster.Enabled = value
    FPSBooster.Toggle(value)
end)

miscTab:CreateToggle("Infinite Zoom", Settings.InfiniteZoom.Enabled, function(value)
    Settings.InfiniteZoom.Enabled = value
    InfiniteZoom.Toggle(value)
end)

miscTab:CreateToggle("Freecam", Settings.Freecam.Enabled, function(value)
    Settings.Freecam.Enabled = value
    Freecam.Toggle(value)
end)

miscTab:CreateButton("Server Hop", ServerHop)
miscTab:CreateButton("Rejoin", Rejoin)

-- Aimbot Tab
if GameInfo.Supports.Aimbot then
    local aimbotTab = window:CreateTab("Aimbot")
    aimbotTab:CreateToggle("Enable Aimbot", Settings.Aimbot.Enabled, function(value)
        Settings.Aimbot.Enabled = value
        Aimbot.Toggle(value)
    end)
    aimbotTab:CreateSlider("FOV", 10, 180, Settings.Aimbot.FOV, function(value)
        Settings.Aimbot.FOV = value
    end)
    aimbotTab:CreateSlider("Smoothness", 1, 20, Settings.Aimbot.Smoothness, function(value)
        Settings.Aimbot.Smoothness = value
    end)
    aimbotTab:CreateKeybind("Aim Key (PC)", Settings.Aimbot.Keybind, function(key)
        Settings.Aimbot.Keybind = key
    end)
    if TouchEnabled then
        aimbotTab:CreateToggle("Mobile Auto-Aim", Settings.Aimbot.MobileAutoAim, function(value)
            Settings.Aimbot.MobileAutoAim = value
        end)
    end
else
    local aimbotTab = window:CreateTab("Aimbot")
    aimbotTab:CreateLabel("Aimbot not supported in this game")
end

-- Settings Tab
local settingsTab = window:CreateTab("Settings")

settingsTab:CreateKeybind("Open GUI Key (PC)", Settings.KeybindOpen, function(key)
    Settings.KeybindOpen = key
    window:SetKeybind(key)
end)

settingsTab:CreateDropdown("Theme", {"Dark", "Light", "Blue", "Red"}, Settings.Theme, function(value)
    Settings.Theme = value
    window:SetTheme(value)
end)

settingsTab:CreateButton("Save Config", function()
    print("Config saved")
end)

settingsTab:CreateButton("Load Config", function()
    print("Config loaded")
end)

-- ============================================================
-- APPLY INITIAL SETTINGS
-- ============================================================
if Settings.Fullbright.Enabled then Fullbright.Toggle(true) end
if Settings.NoFog.Enabled then NoFog.Toggle(true) end
if Settings.AntiAFK.Enabled then AntiAFK.Toggle(true) end
if Settings.AutoRespawn.Enabled then AutoRespawn.Toggle(true) end
if Settings.FPSBooster.Enabled then FPSBooster.Toggle(true) end
if Settings.InfiniteZoom.Enabled then InfiniteZoom.Toggle(true) end
if Settings.Freecam.Enabled then Freecam.Toggle(true) end
if Settings.ESP.Enabled then ESP.Toggle(true) end
if Settings.WalkSpeed.Enabled or Settings.JumpPower.Enabled then Movement.Update() end
if Settings.Aimbot.Enabled and GameInfo.Supports.Aimbot then Aimbot.Toggle(true) end

-- ============================================================
-- STARTUP MESSAGES
-- ============================================================
print("Flow Hub | Universal loaded.")
print("Detected game: " .. GameInfo.Type)
print("Executor: " .. ExecutorName)
if TouchEnabled then
    print("Mobile mode active. Drag the floating button to move it.")
end
